class Grappler extends Weapon;

var() class<GrapplerRope>	ropeClass;
var() float					ropeNonCollisionLength		"The amount of rope at the end which won't collide, allowing you to swing around things";
var() float					maxRopeLength				"The maximum length of the rope";

var() float					reelinLengthRate			"The rate at which the rope will reel in when the trigger is held";
var() float					reelInDelay					"A delay before reeling in will occur";

var bool					bDisallowFire;

var Shader cableShader;
var ControllableTexturePanner cableTexPanner;
var ControllableTexturePanner cableNormTexPanner;
var() int cableMaterialIndex;

var bool bControllableSkinSet;

replication
{
	reliable if (Role < ROLE_Authority)
		sendServerRequestDetachGrapple;
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	registerClientMessage(class'MessagePreRender', Level.label);
}

simulated function buildControllableSkins()
{
	// Build a controllable texture panner for the cable shader
	cableShader = Shader(ShallowCopyMaterial(GetMaterial(cableMaterialIndex), self));

	if (cableShader != None)
	{
		cableTexPanner = new class'ControllableTexturePanner';
		cableTexPanner.PanDirection = Vector(TexPanner(cableShader.Diffuse).PanDirection);
		cableTexPanner.Material = TexPanner(cableShader.Diffuse).Material;

		cableNormTexPanner = new class'ControllableTexturePanner';
		cableNormTexPanner.PanDirection = Vector(TexPanner(cableShader.NormalMap).PanDirection);
		cableNormTexPanner.Material = TexPanner(cableShader.NormalMap).Material;

		cableShader.Diffuse = cableTexPanner;
		cableShader.NormalMap = cableNormTexPanner;
	}

	// If succeeded set the shader as the skin for the weapon
	if (cableTexPanner != None && cableNormTexPanner != None)
		setControllableSkins();
}

simulated function Tick(float DeltaTime)
{
	local Character c;
	local float newScale;

	Super.Tick(DeltaTime);

	if (bIsFirstPerson && equipped)
	{
		if (bControllableSkinSet)
		{
			c = Character(Owner);

			if (c != None && c.proj != None)
			{
				if (!c.bAttached)
				{
					newScale = cableTexPanner.Scale + DeltaTime * 3;

					if (newScale > 1.0)
						newScale = newScale - 1.0;

					cableTexPanner.Scale = newScale;
					cableNormTexPanner.Scale = newScale;
				}
				else if (c.bReelIn)
				{
					newScale = cableTexPanner.Scale - DeltaTime;

					if (newScale < 0.0)
						newScale = newScale + 1.0;

					cableTexPanner.Scale = newScale;
					cableNormTexPanner.Scale = newScale;
				}
			}
		}
		else
			buildControllableSkins();
	}
}

simulated function setControllableSkins()
{
	local int i;

	if (Skins.Length <= cableMaterialIndex)
		Skins.Length = cableMaterialIndex + 1;

	for (i = 0; i < cableMaterialIndex; ++i)
	{
		Skins[i] = None;
	}

	Skins[cableMaterialIndex] = cableShader;

	bControllableSkinSet = true;
}

simulated function setHasAmmoSkins()
{
	Super.setHasAmmoSkins();
	ammoSkinChange();
}

simulated function setOutOfAmmo()
{
	// Currently doesn't have empty skin
}

simulated function ammoSkinChange()
{
	if (bControllableSkinSet)
		setControllableSkins();
	else
		buildControllableSkins();
}

simulated function drop()
{
	if (Level.NetMode == NM_Client && Character(Owner) != None)
		Character(Owner).detachGrapple();

	super.drop();
}

protected function requestEquipmentDrop()
{
	if (Character(Owner) != None)
		Character(Owner).detachGrapple();

	super.requestEquipmentDrop();
}

function bool canUnequip()
{
	local Character c;

	c = Character(rookOwner);

	return c.proj == None || c.bAttached;
}

simulated function onMessage(Message m)
{
	local Character c;

	super.onMessage(m);
	
	if (equipped && bIsFirstPerson)
	{
		c = Character(Owner);

		if (c != None)
			c.updateGrapplerRopeEquippedFirstPerson();
	}
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	Character(rookOwner).proj = GrapplerProjectile(super.makeProjectile(fireRot, fireLoc));

	return Character(rookOwner).proj;
}

simulated function playIdleAnim()
{
	local Character c;

	c = Character(rookOwner);

	if (c.proj != None)
	{
		if (c.bAttached)
			animClass.static.playEquippableAnim(self, 'IdleAttach');
		else
			animClass.static.playEquippableAnim(self, 'CableIdle');
	}
	else
		super.playIdleAnim();
}

simulated function playEquipAnim()
{
	local Character c;

	c = Character(owner);

	if (c != None && c.proj != None && c.bAttached)
		animClass.static.playEquippableAnim(self, 'SelectAttach');
	else
		Super.playEquipAnim();
}

simulated function playUnequipAnim()
{
	local Character c;

	c = Character(owner);

	if (c != None && c.proj != None && c.bAttached)
		animClass.static.playEquippableAnim(self, 'DeselectAttach');
	else
		Super.playEquipAnim();
}

simulated function Timer()
{
	Character(rookOwner).bReelIn = true;
}

simulated state Held
{
	simulated function BeginState()
	{
		local Character c;

		c = Character(rookOwner);

		if (c != None)
			c.bReelIn = false;

		super.BeginState();
	}
}

simulated state FirePressed
{
	simulated function BeginState()
	{
		local Character c;

		c = Character(rookOwner);

		if (c.proj == None)
			bDisallowFire = false;

		if (c.bAttached && !c.bReelIn)
			SetTimer(reelInDelay, false);

		super.BeginState();
	}

	simulated function TickFirePressed()
	{
		local Character c;

		if (bDisallowFire)
			return;

		c = Character(rookOwner);

		if (c.proj == None && canFire() && fireRatePassed())
		{
			bDisallowFire = true;
			FireWeapon();
			c.bReelIn = true;
		}

		if (fireOnce)
			GotoState('Idle');
	}
}

// Function for AIs to use to begin reeling in
function beginReelIn()
{
	local Character c;

	c = Character(rookOwner);

	if (c.bAttached)
		c.bReelIn = true;
}

// Function for AIs to use to end reeling in
function endReelIn()
{
	Character(rookOwner).bReelIn = false;
}

event simulated bool releaseFire(optional bool bClientOnly)
{
	local Character c;

	c = Character(rookOwner);

	if (Role != ROLE_Authority && !bClientOnly)
	{
		if (!c.bReelIn)
			sendServerRequestDetachGrapple();
		else
			sendServerRequestReleaseFire();
	}

	return handleReleaseFire();
}

private function bool sendServerRequestDetachGrapple()
{
	local Character c;

	c = Character(rookOwner);

	c.bReelIn = false;

	return sendServerRequestReleaseFire();
}

simulated state FireReleased
{
	simulated function BeginState()
	{
		local Character c;

		SetTimer(0.0, false);

		c = Character(rookOwner);

		if (c.bReelIn)
			c.bReelIn = false;
		else
			c.detachGrapple();

		super.BeginState();
	}
}

defaultproperties
{
	cableMaterialIndex = 1

    firstPersonMesh = SkeletalMesh'Weapons.Grappler'
	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 1.0
	ammoCount = 10
	ammoUsage = 1

	projectileClass = class'GrapplerProjectile'
	projectileVelocity = 2500

	ropeClass = class'GrapplerRope'
	ropeNonCollisionLength = 300
	maxRopeLength = 3000

	reelinLengthRate = 500
	reelInDelay = 0.5

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Grappler"
}