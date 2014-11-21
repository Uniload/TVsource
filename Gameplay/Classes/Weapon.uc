class Weapon extends Equippable
	config(Weapons)
	native;
// TBD: Disable Z-Testing for weapon

// Ammo
var() travel int		ammoCount				"Weapon's remaining ammo";
var() int				ammoUsage				"Amount of ammo used per shot";
var() float				roundsPerSecond			"Fire rate in rounds per second";

var() bool				bNeedIdleFX;

// Projectile
var() class<Projectile>	projectileClass					"Type of projectile fired by the weapon";
var() name				projectileSpawnBone				"The bone that the projectile will be spawned at";
var	Vector				projectileSpawnOffset;			//The offset from the weapon position to spawn the projectile at
var() float				projectileVelocity				"Speed of the projectile when it is fired";
var() float				projectileInheritedVelFactor	"Proportion of velocity inherited from player when projectile is fired";

var() editinlineuse Array<Material> emptyMaterials;

// AI interfaces
var class<AimFunctions> aimClass;
var Rotator AIspread;					// added to fire direction (for inaccurate AI shots)
var float AIAccelerationModifier;
var bool bGenerateMissSpeechEvents;

// UI
var() config Material		hudReticule			"Targetting reticule for this weapon";
var() config float			hudReticuleWidth	"Width of the HUD texture";
var() config float			hudReticuleHeight	"Height of the HUD Reticule";
var() config float			hudReticuleCenterX	"X co-ord on the texture of the hud center";
var() config float			hudReticuleCenterY	"Y co-ord on the texture of the hud center";

// Internals
var float lastFireTime;
var float startEquippingTime;
var bool fireOnce;						// if true the weapon will return to the idle state after firing once

var bool bFiredWeapon;
var bool noAmmo;

var name fireAnimation;

var() bool bMelee;
var() string fireAnimSubString;

var int localAmmoCount;

var float speedPackScale;

var private bool pickupDelay;
var private bool localPickupDelay;

var private bool bBeingSwitched;

// Replication
replication
{
	// server to client variables
	unreliable if (Role == ROLE_Authority && bNetOwner)
		ammoCount, pickupDelay;
}

// Special trigger effect event, plays effect on owner if mesh is none
simulated function bool TriggerWeaponEffect(name EffectEvent)
{
	if (Mesh == None && StaticMesh == None)
	{
		if (Owner != None)
			return Owner.TriggerEffectEvent(EffectEvent);
		else
			return false;
	}
	else
		return TriggerEffectEvent(EffectEvent);
}

simulated function Destroyed()
{
	if (Character(Owner) != None)
		Character(Owner).removeFromWeaponSlot(self);

	super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	local Mesh currMesh;
	local Rotator currRotation;

	Super.PostNetBeginPlay();

	currMesh = Mesh;

	currRotation = Rotation;
	if (useAlternateMesh())
		LinkMesh(firstPersonAltMesh);
	else	
		LinkMesh(firstPersonMesh);

	SetRotation(Rot(0.0, 0.0, 0.0));

	extractFirstPersonMeshData();

	LinkMesh(currMesh);
	SetRotation(currRotation);
}

simulated function extractFirstPersonMeshData()
{
	projectileSpawnOffset = GetBoneCoords(projectileSpawnBone).origin - Location;

	if ( projectileSpawnOffset == -Location && rookOwner != None)
	{
		projectileSpawnOffset = rookOwner.GetBoneCoords(projectileSpawnBone).origin - rookOwner.Location;
	}
}

simulated function setupFirstPerson()
{
	bFiredWeapon = false;
	super.setupFirstPerson();
	playIdleAnim();
}

function applyPickupDelay()
{
	pickupDelay = true;
	lastFireTime = Level.TimeSeconds;
}

simulated function PostNetReceive()
{
	local Character characterOwner;

	Super.PostNetReceive();

	// apply client side pickup delay if necessary
	if (localPickupDelay != pickupDelay && Level.NetMode == NM_Client)
	{
		if (pickupDelay)
		{
			lastFireTime = Level.TimeSeconds;
		}
		localPickupDelay = pickupDelay;
	}

	if (bNetOwner && ammoCount > localAmmoCount)
	{
		characterOwner = Character(Owner);

		if (characterOwner != None)
			characterOwner.TriggerEffectEvent('AmmoPickup');
	}

	localAmmoCount = ammoCount;

	if (ammoCount <= 0 && !noAmmo)
	{
		setOutOfAmmo();
		noAmmo = true;
	}

	if (ammoCount > 0 && noAmmo)
	{
		setHasAmmoSkins();
		noAmmo = false;
	}
}

protected function requestEquipmentDrop()
{
	local Character characterOwner;
	local Weapon w;

	if (isInNoDropRangeOfInventoryStation())
		return;

	characterOwner = Character(Owner);

	if (characterOwner.weapon == self)
	{
		w = Weapon(characterOwner.nextEquipment(characterOwner.weapon, class'Weapon'));

		if (w == None)
			w = Weapon(characterOwner.nextEquipment(None, class'Weapon'));

		characterOwner.weapon = None;

		if (w != None && w != self)
			characterOwner.motor.setWeapon(w);
	}

	Super.requestEquipmentDrop();
}

simulated function bool canExpire()
{
	return !bBeingSwitched;
}

function doSwitch(Character newOwner)
{
	local Weapon w;

	// if there's nothing to drop then problems will occur
	if (newOwner.weapon == None)
		return;

	w = newOwner.weapon;
	newOwner.weapon = None;

	bBeingSwitched = true;

	w.requestEquipmentDrop();

	Super.doSwitch(newOwner);

	newOwner.motor.setWeapon(self);

	bBeingSwitched = false;
}

final function int increaseAmmo(int quantity)
{
	local Character characterOwner;
	local int maxAmmoCount;
	local int unused;

	if (ammoCount <= 0 && quantity > 0)
		animClass.static.playEquippableAnim(self, 'Reload');

	characterOwner = Character(rookOwner);

	if (characterOwner != None)
		maxAmmoCount = getMaxAmmo();
	else
		maxAmmoCount = default.ammoCount;

	if (characterOwner != None && ammoCount < maxAmmoCount)
		characterOwner.TriggerEffectEvent('AmmoPickup');

	ammoCount += quantity;

	unused = ammoCount - maxAmmoCount;

	if (unused > 0)
		ammoCount = maxAmmoCount;
	else
		unused = 0;

	setHasAmmoSkins();

	return unused;
}

function int getMaxAmmo()
{
	return Character(rookOwner).getMaxAmmo(class);
}

// useAmmo
function useAmmo()
{
	if (ammoCount <= 0)
		return;

	ammoCount -= ammoUsage;

	if (ammoCount <= 0)
		setOutOfAmmo();
}

simulated function setHasAmmoSkins()
{
	Skins.Length = 0;
}

simulated function setOutOfAmmo()
{
	if (!useAlternateMesh())
		Skins = emptyMaterials;
}

// hasAmmo
simulated function bool hasAmmo()
{
	return ammoCount >= ammoUsage;
}

// canFire
simulated function bool canFire()
{
	return hasAmmo();
}

function bool canPickup(Character potentialOwner)
{
	local int maxAmmo;
	local Weapon w;

	if (potentialOwner.armorClass == None)
		return false;

	maxAmmo = potentialOwner.GetMaxAmmo(class);

	if (maxAmmo >= 0)
	{
		w = Weapon(potentialOwner.nextEquipment(None, class));

		// Allowed to pickup if the weapon isn't already carried (w == None) or
		// if the weapon is already carried and doesn't have max ammo
		return w == None || w.ammoCount < maxAmmo;
	}
	else // maxAmmo less than 0 means the armor class does not allow this type of weapon
		return false;
}

function bool needPrompt(Character potentialOwner)
{
	return potentialOwner.numWeaponsCarried() >= potentialOwner.armorClass.default.maxCarriedWeapons &&
		   potentialOwner.nextEquipment(None, class) == None;
}

function bool allowPrompt(Character potentialOwner)
{
	return potentialOwner.weapon != potentialOwner.fallbackWeapon;
}

function pickup(Character newOwner)
{
	local Weapon w;
	local int maxAmmo;

	w = Weapon(newOwner.nextEquipment(None, class));

	if (w != None)
	{
		ammoCount = w.increaseAmmo(ammoCount);

		if (ammoCount <= 0)
		{
			equipmentGone();
			Destroy();
		}
	}
	else
	{
		maxAmmo = newOwner.getMaxAmmo(class);

		if (ammoCount > maxAmmo)
			ammoCount = maxAmmo;

		Super.pickup(newOwner);
	}
}

simulated function bool fireRatePassed()
{
	return (Level.TimeSeconds - lastFireTime) >= (1 / roundsPerSecond);
}

simulated function addSpeedPackScale(float scale)
{
	roundsPerSecond *= scale;
	speedPackScale = scale;
}

simulated function removeSpeedPackScale()
{
	roundsPerSecond = default.roundsPerSecond;
	speedPackScale = default.speedPackScale;
}

// onThirdPersonFireCount
simulated function onThirdPersonFireCount()
{
	if (rookMotor == None)
		initialiseRookMotor();

	firedEffectProcessing();

    playCharacterFireAnim();
}

// fire
event simulated bool fire(optional bool _fireOnce)
{
	fireOnce = _fireOnce;

	return Super.fire(_fireOnce);
}

event simulated bool altFire(optional bool _fireOnce)
{
	return fire(_fireOnce);
}

event simulated bool releaseAltFire()
{
	return releaseFire();
}

simulated function Vector calcProjectileSpawnLocation(Rotator fireRot)
{
	return equippablePos + (projectileSpawnOffset >> fireRot);
}

function initialiseVelocity(Projectile p, Vector InitialVelocity)
{
	p.InitialVelocity = InitialVelocity;
	p.Velocity = InitialVelocity;
}

// makeProjectile
// not simulated, server only
protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Projectile p;

	p = new projectileClass(rookOwner, , , fireLoc);
	if (p == None)
	{
		LOG("Warning: Weapon "$Name$" spawn projectile "$projectileClass$" failed.");
		return None;
	}

	p.SpawnTick = LastTick;

	// add inaccuracy for AI's
	if ( AIspread.Yaw != 0 || AIspread.Pitch != 0 )
	{
		fireRot += AIspread;
	}

	p.SetRotation(fireRot);
																	// inherit velocity from pawn
	initialiseVelocity(p, (Vector(fireRot) * projectileVelocity) + (Instigator.Velocity * projectileInheritedVelFactor));

	p.Acceleration = Normal(p.Velocity) * (p.AccelerationMagtitude * AIAccelerationModifier);

	useAmmo();

	++fireCount;
	
	if (fireCount==0)
	    fireCount = 1;	

	rookOwner.onShotFired( p );

	rookMotor.onShotFiredNotification();

	return p;
}

// Idle state
simulated state Idle
{
	simulated function BeginState()
	{
		fireOnce = false;

		if (bNeedIdleFX)
			TriggerEffectEvent('Idle');
	}

	simulated function EndState()
	{
		if (bNeedIdleFX)
			UnTriggerEffectEvent('Idle');
	}
}

simulated function playIdleAnim()
{
	if (bFiredWeapon)
	{
		playPostFireAnim();
	}
	else if (!hasAmmo())
	{
		animClass.static.playEquippableAnim(self, 'Idle_Empty');
	}
	else
	{
		super.playIdleAnim();
	}
}

final native final function aimTrace(out Vector hitLocation, Vector traceStart, Vector traceDirection);
final native final function Actor AIAimTrace(out Vector hitLocation, out Vector hitNormal, Vector traceStart, Vector traceEnd);

function Rotator getAimRotation(Vector fireLoc)
{
	local PlayerController pc;

	pc = PlayerController(rookOwner.Controller);	

	if (pc != None && rookMotor.aimAdjustViewRotation())
	{
		return getAimAdjustedViewRotation(pc, fireLoc);
	}

	return rookMotor.getViewRotation();
}

simulated function rotator getAimAdjustedViewRotation(PlayerController pc, Vector fireLoc)
{
	local Actor viewActor;
	local Vector startLoc;
	local Rotator viewRot;

	local Vector hitLocation;

	startLoc = pc.location;
	viewRot = pc.rotation;
	viewActor = Owner;
	pc.PlayerCalcView(viewActor, startLoc, viewRot);

	rookMotor.getAlternateAimAdjustStart(viewRot, startLoc);

	aimTrace(hitLocation, startLoc, Vector(viewRot));

	return Rotator(hitLocation - fireLoc);
}

simulated function playCharacterFireAnim()
{
	local Character c;

	c = Character(Owner);

	if (c != None)
	{
		if (bMelee)
			c.playUpperBodyAnimation(fireAnimSubString);
		else
			c.playFireAnimation(fireAnimSubString);
	}
}

simulated protected function FireWeapon()
{
	local Vector fireLoc;

	fireLoc = rookMotor.getProjectileSpawnLocation();
	makeProjectile(getAimRotation(fireLoc), fireLoc);

	lastFireTime = Level.TimeSeconds;

	if (rookMotor == None)
		initialiseRookMotor();

	firedEffectProcessing();

	bFiredWeapon = true;

	playCharacterFireAnim();
	animClass.static.playEquippableAnim(self, fireAnimation, speedPackScale);

	demoFireCount++;
	
	if (demoFireCount==0)
	    demoFireCount = 1;
}

simulated function firedEffectProcessing()
{
	local bool zoomed;
	local PlayerCharacterController playerCharacterController;

	// determine if zoomed
	if (rookOwner != None)
	{
		playerCharacterController = PlayerCharacterController(rookOwner.Controller);
		zoomed = (playerCharacterController != None) && (Level.GetLocalPlayerController() == playerCharacterController) &&
				(playerCharacterController.bZoom != 0);
	}

	if (rookMotor != None && rookMotor.customFiredEffectProcessing())
	{
		rookMotor.doCustomFiredEffectProcessing();
	}
	else if (rookMotor != None && rookMotor.getEffectsBaseActor() != None)
	{
		rookMotor.getEffectsBaseActor().TriggerEffectEvent('Fired');
		if (zoomed)
			rookMotor.getEffectsBaseActor().TriggerEffectEvent('ZoomedFired');
		else
			rookMotor.getEffectsBaseActor().TriggerEffectEvent('NotZoomedFired');
	}
	else
	{
		TriggerWeaponEffect('Fired');
		if (zoomed)
			TriggerEffectEvent('ZoomedFired');
		else
			TriggerEffectEvent('NotZoomedFired');

		// tbd: add 'reloaded' event
	}
}

simulated protected function playPostFireAnim()
{
	local Name anim;

	if (hasAmmo())
		anim = 'Refire';
	else
		anim = 'Empty';

	if (animClass.static.hasEquippableAnim(self, anim))
		animClass.static.playEquippableAnim(self, anim, speedPackScale);

	bFiredWeapon = false;
}

simulated state FirePressed
{
	simulated function BeginState()
	{
		TickFirePressed();
	}

	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (!IsInState('FirePressed')) // State change is possible in Global.Tick
			return;

		TickFirePressed();
	}

	simulated function TickFirePressed()
	{
		if (canFire())
		{
			attemptFire();
		}
		else
		{
			GotoState('Empty');
		}

		if (fireOnce)
			GotoState('FireReleased');
	}

	simulated function attemptFire()
	{
		if (fireRatePassed())
			FireWeapon();
		else if (bIsFirstPerson && bFiredWeapon && !IsAnimating())
			playPostFireAnim();
	}
}

// Empty 'clicking' state
simulated state Empty
{
	simulated protected function bool handleReleaseFire()
	{
		GotoState('Idle');
		return true;
	}

	simulated function FireEmpty()
	{
		lastFireTime = Level.TimeSeconds;

		if (rookMotor == None)
			initialiseRookMotor();

		if (rookMotor != None && rookMotor.getEffectsBaseActor() != None)
			rookMotor.getEffectsBaseActor().TriggerEffectEvent('FiredEmpty');
		else
			TriggerWeaponEffect('FiredEmpty');
	}

	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (!IsInState('Empty')) // State change is possible in Global.Tick
			return;

		if (bIsFirstPerson && bFiredWeapon && !IsAnimating())
			playPostFireAnim();

		if (canFire())
		{
			GotoState(fireState);
		}
		else if (fireRatePassed())
		{
			FireEmpty();
		}

		if (fireOnce)
			GotoState('FireReleased');
	}
}

// FireReleased state
// This state is entered when firing stops. Charge up weapons will override this to implement attacking after charging
simulated state FireReleased
{
	simulated function BeginState()
	{
		GotoState('Idle');
	}
}

simulated function heldByCharacter(Character c)
{
	if (c != None)
		c.putInWeaponSlot(self);
}

simulated state Held
{
	simulated function BeginState()
	{
		super.BeginState();

		heldByCharacter(Character(Owner));
	}
}

simulated function droppedByCharacter(Character c)
{
	if (c != None)
		c.removeFromWeaponSlot(self);
}

simulated state Dropped
{
	simulated function BeginState()
	{
		// Reset roundsPerSecond and ammoUsage to default in case either was modified
		removeSpeedPackScale();
		ammoUsage = default.ammoUsage;
		AISpread = Rot(0.0, 0.0, 0.0);
		AIAccelerationModifier = default.AIAccelerationModifier;

		droppedByCharacter(Character(Owner));

		super.BeginState();
	}
}

simulated function playEquipAnim()
{
	if (!shouldPlayEquipAnim())
		return;

	if (!hasAmmo())
	{
		animClass.static.playEquippableAnim(self, 'Select_Empty');
	}
	else
	{
		Super.playEquipAnim();
	}
}

simulated function playUnequipAnim()
{
	if (!shouldPlayEquipAnim())
		return;

	if (!hasAmmo())
	{
		animClass.static.playEquippableAnim(self, 'Deselect_Empty');
	}
	else
	{
		Super.playUnequipAnim();
	}
}

simulated function float GetProjectileSpreadScale()
{
	return 0;
}

function drawDebug(HUD debugHUD);

function float getPredictedProjectileGravity()
{
    // note: this gravity only applies to arc projectiles of course!

    if (PhysicsVolume!=None)
        return projectileClass.default.GravityScale * -PhysicsVolume.Gravity.Z;
    else       
        return projectileClass.default.GravityScale * -class'PhysicsVolume'.default.Gravity.Z;
}

// will a friendly be hurt by splash damage around 'hitLocation'?
// has to be in weapon and not in AimFunctions so the iterator can be used
// bDoObstacleCheck: checks if there is an obstacle between hitLocation and potential splash damage victim
function bool willHurtFriendly( Vector hitLocation, float timeToHit, bool bDoObstacleCheck )
{
	local Pawn p;
	local Rook rook;
	local Rook shooter;
	local Vector hitLocation2;
	local Vector hitNormal;
	local Actor thingHit;
	local float damageRadius;

	damageRadius = aimClass.static.getProjectileDamageRadius( projectileClass );

	if ( damageRadius > 0 )
	{
		shooter = Rook(Owner);

		foreach nearbyControlledPawns( hitLocation, damageRadius + class'AimFunctions'.const.DAMAGECHECK_RADIUS_BUFFER, p )
		{
			rook = Rook(p);
			if ( rook.isFriendly( shooter ) )
			{
				// check if splash damage would be done to this rook
				if ( bDoObstacleCheck )
					thingHit = Trace( hitLocation2, hitNormal, rook.Location, hitLocation, true, vect(0,0,0) );
				if ( !bDoObstacleCheck || thingHit == None || thingHit == rook )
				{
					//log( rook.name @ "DID NOT pass splash damage test from" @ shooter.name @ VSize(rook.Location - hitLocation) $ "/" $ damageRadius + class'AimFunctions'.const.DAMAGECHECK_RADIUS_BUFFER );
					return true;
				}
				//log( rook.name @ "passed splash damage test from" @ shooter.name @ thingHit.name @ VSize(rook.Location - hitLocation) $ "/" $ damageRadius + class'AimFunctions'.const.DAMAGECHECK_RADIUS_BUFFER );
			}
		}
	}

	return false;
}

// PRECACHING
static simulated function PrecacheWeaponRenderData(LevelInfo Level, class<Weapon> WeaponClass)
{
	// projectile
	if (WeaponClass.default.projectileClass != None)
		class'Projectile'.static.PrecacheProjectileRenderData(Level, WeaponClass.default.projectileClass);

	// reticle
	if (WeaponClass.default.hudReticule != None)
		Level.AddPrecacheMaterial(WeaponClass.default.hudReticule);

	// force precache of equippable base data
	PrecacheEquippableRenderData(Level, WeaponClass);
}


simulated function UpdatePrecacheRenderData()
{
	Super.UpdatePrecacheRenderData();
	PrecacheWeaponRenderData(Level, Class);
}

defaultproperties
{
     ammoCount=20
     ammoUsage=1
     roundsPerSecond=0.500000
     projectileClass=Class'Projectile'
     projectileSpawnBone="muzzle"
     projectileVelocity=2500.000000
     AIAccelerationModifier=1.000000
     bGenerateMissSpeechEvents=True
     hudReticule=Texture'HUD.reticuleDirect'
     hudReticuleWidth=128.000000
     hudReticuleHeight=128.000000
     hudReticuleCenterX=64.000000
     hudReticuleCenterY=64.000000
     fireAnimation="Fire"
     localAmmoCount=99999999
     speedPackScale=1.000000
     Prompt="Press '%1' to swap your %2 for a %3."
}
