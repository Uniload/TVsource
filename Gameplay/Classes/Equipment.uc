class Equipment extends Engine.Actor
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() bool bCanDrop;
var() float droppedElasticity			"How much the equipment will bounce when dropped";

var() int dropVelocity;

// localized switch equipment prompt
var() localized String	prompt			"String shown in the prompt screen when the user may switch";

// UI
var() localized String	localizedName		"The localized name of this item";
var() localized String	infoString			"String shown in the inventory screen describing the item";
var() Material			inventoryIcon		"Icon used in the inventory station to represent this equippable";
var() Material			hudIcon				"The icon that is used on the hud to indicate that the equippable is carried";
var() MatCoords			hudIconCoords		"UV coords for the hudIcon";
var() Material			hudRefireIcon		"The icon that is used on the hud to indicate that the equippable is recharging";
var() MatCoords			hudRefireIconCoords	"UV coords for the hudRefireIcon";
var() Material			attentionFXMaterial "Material used for the 'attention' fx";
var() float				attentionFXSpacing	"Amount of time in seconds between displays of the FX";
var() float				attentionFXDuration "The duration of FX once it has been triggered";

var bool bCanPickup;
var bool bDropped;

var bool bHeld;

var Equipment next;
var Equipment prev;

var name heldStartState;

var bool bPlayPickupSound;

var bool sensorUpdateFlag;

var float nextAttentionTime;
var float attentionLeft;

var EquipmentSpawnPoint spawnPoint;

var EPhysics awaitingPickupPhysics;

var EquipmentPickupProxy pickupProxy;
var() float pickupRadius;

replication
{
	reliable if (Role == ROLE_Authority)
		bDropped, bHeld, awaitingPickupPhysics;

	reliable if (Role == ROLE_Authority && bNetOwner)
		next, prev;

	reliable if (Role < ROLE_Authority)
		requestEquipmentDrop;
}

simulated function Destroyed()
{
	if (pickupProxy != None)
		pickupProxy.Destroy();

	removeDroppedEquipment();
	super.Destroyed();
}

function removeDroppedEquipment()
{
	GameInfo(Level.Game).removeDroppedEquipment(self);
}

function TravelPreAccept()
{
	Character(Owner).addEquipment(self);
}

simulated function PostNetReceive()
{
	if (bDropped)
		GotoState('Dropped');
}

// Called when this Equipment starts to be held by a character. Occurs
// before entering Held state.
function startHeldByCharacter(Character holder);

// Called when this Equipment is no longer held by a character.
function endHeldByCharacter(Character holder);

simulated function drop()
{
	if (Character(Owner) == None)
		return;

	requestEquipmentDrop();
}

function doSwitch(Character newOwner)
{
	pickup(newOwner);
	newOwner.potentialEquipment = None;
}

protected function setMovementReplication(bool replicate)
{
	bUpdateSimulatedPosition = replicate;
}

// Returns true if weapon cannot be dropped due to proximity to inventory station.
function bool isInNoDropRangeOfInventoryStation()
{
	local UseableObject testObject;
	local Character characterOwner;

	characterOwner = Character(Owner);

	if (characterOwner == None)
		return false;

	foreach characterOwner.touchingActors(class'UseableObject', testObject)
	{
		if (testObject == None)
			continue;
		if (testObject.getCorrespondingInventoryStation() != None)
			return true;
	}

	return false;
}

protected function requestEquipmentDrop()
{
	local Character characterOwner;
	local Rotator viewRotation;

	if (isInNoDropRangeOfInventoryStation())
		return;

	characterOwner = Character(Owner);

	setMovementReplication(true);

	viewRotation = characterOwner.motor.getViewRotation();
	Velocity = Vector(viewRotation) * dropVelocity;

	characterOwner.removeEquipment(self);

	GotoState('Dropped');
}

function bool canPickup(Character potentialOwner)
{
	return true;
}

function bool needPrompt(Character potentialOwner)
{
	return false;
}

function bool allowPrompt(Character potentialOwner)
{
	return true;
}

function onPickup()
{
}

function pickup(Character newOwner)
{
	SetTimer(0.0, false);
	setMovementReplication(false);
	newOwner.addEquipment(self);
	onPickup();
	equipmentGone();
}

function equipmentGone()
{
	if (spawnPoint != None)
	{
		spawnPoint.equipmentTaken();
		spawnPoint = None;
	}
}

function PickupProxyTouch(Actor other);
function PickupProxyUntouch(Actor other);

auto simulated state AwaitingPickup
{
	function Timer()
	{
		if (!bCanPickup) // Pickup delay passed
		{
			bCanPickup = true;
			if (Level.Game != None)
				SetTimer(GameInfo(Level.Game).equipmentLifeTime, false);
		}
		else if (bDropped) // drop lifetime expired
			Destroy();
	}

	function Attach(Actor other)
	{
		local Character grapplingCharacter;
		local GrapplerProjectile attachedGrapplerProjectile;

		attachedGrapplerProjectile = GrapplerProjectile(other);

		if (attachedGrapplerProjectile != None)
		{
			grapplingCharacter = Character(attachedGrapplerProjectile.instigator);

			if (grapplingCharacter != None && grapplingCharacter.Health > 0)
			{
				if (canPickup(grapplingCharacter) && !needPrompt(grapplingCharacter))
					pickup(grapplingCharacter);

				grapplingCharacter.detachGrapple();
			}
		}
	}

	function PickupProxyTouch(Actor other)
	{
		local Character touchedCharacter;

		if (!bCanPickup)
			return;

		touchedCharacter = Character(other);

		if (touchedCharacter != None && touchedCharacter.Controller != None && touchedCharacter.controller.bIsPlayer &&
			touchedCharacter.Health > 0 && canPickup(touchedCharacter))
		{
			if (needPrompt(touchedCharacter))
			{
				if (allowPrompt(touchedCharacter) && touchedCharacter.potentialEquipment == None)
					touchedCharacter.potentialEquipment = Self;
			}
			else
				pickup(touchedCharacter);
		}
	}

	function PickupProxyUntouch(Actor other)
	{
		local Character unTouchedCharacter;

		unTouchedCharacter = Character(other);

		if (unTouchedCharacter != None && unTouchedCharacter.potentialEquipment == Self)
		{
			unTouchedCharacter.potentialEquipment = None;
		}
	}

	simulated function Tick(float Delta)
	{
		local int i;
		local Character c;

		for (i = 0; i < Touching.Length; i++)
		{
			c = Character(Touching[i]);
			
			// fixes standing on weapon then swapping
			if (c != None)
			{
				if (c.potentialEquipment == self && !allowPrompt(c))
				{
					PickupProxyUntouch(c);
				}
				else if (c.potentialEquipment == None && allowPrompt(c))
				{
					PickupProxyTouch(c);
				}
			}
		}

		if (Level.TimeSeconds > nextAttentionTime)
		{
			nextAttentionTime = Level.TimeSeconds + attentionFXSpacing;
			attentionLeft = attentionFXDuration;
		}

		if (attentionLeft > 0)
		{
			attentionLeft -= Delta;
		}

		if (bHeld)
			gotoHeldState();

		if (pickupProxy != None)
			pickupProxy.Move(Location - pickupProxy.Location);
	}

	simulated function onMessage(Message m) {}

	simulated function setup()
	{
		SetCollision(true, false, false);
		bCollideWorld = true;
		bHidden = false;
		SetPhysics(awaitingPickupPhysics);

		if (Level.NetMode != NM_Client)
		{
			SetTimer(0.5, false);
			pickupProxy = Spawn(class'EquipmentPickupProxy', self,, Location);
			pickupProxy.SetCollisionSize(pickupRadius, pickupRadius);
			pickupProxy.SetCollision(true, false, false);
		}
	}

	simulated function BeginState()
	{
		nextAttentionTime = Level.TimeSeconds + attentionFXSpacing + FRand() * attentionFXSpacing;
		attentionLeft = 0;
	}

	simulated function EndState()
	{
		attentionLeft = 0;

		if (pickupProxy != None)
			pickupProxy.Destroy();
	}

Begin:
	bPlayPickupSound = true;
	setup();
}

simulated function gotoHeldState()
{
	if (bPlayPickupSound)
	{
		bPlayPickupSound = false;
		TriggerEffectEvent('Pickup');
	}

	removeDroppedEquipment();
	GotoState(heldStartState);
}

simulated state Held
{
	simulated function BeginState()
	{
		bHeld = true;
		bDropped = false;

		SetPhysics(PHYS_None);
		bHidden = true;
		bCollideWorld = false;
		SetCollision(false, false, false);
	}

	simulated function Tick(float Delta) {}
	simulated function onMessage(Message m) {}
}

simulated state Dropped
{
	function setupDropped()
	{
		if (Level.Game != None)
			GameInfo(Level.Game).addDroppedEquipment(self);

		setMovementReplication(true);
		bCanPickup = false;
		bDropped = true;
		bHeld = false;

		setDropLocation();
		setDropVelocity();

		SetOwner(None);
	}

	simulated function BeginState()
	{
		setupDropped();
		GotoState('AwaitingPickup');
	}

	simulated function onMessage(Message m) {}
}

function setDropLocation()
{
	SetLocation(Owner.Location);
}

function setDropVelocity()
{
	Velocity += Owner.Velocity;
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	//local float velocitySize;

	//velocitySize = VSize(Velocity);

	//if (velocitySize <= 0.001)
	//{
	//	SetPhysics(PHYS_None);
	//	return;
	//}

	//Velocity = velocitySize * droppedElasticity * MirrorVectorByNormal(Normal(Velocity), HitNormal);

	//TriggerEffectEvent('Bounce');
}

simulated event Material GetOverlayMaterial(int Index)
{
	if (attentionLeft > 0)
	{
		return attentionFXMaterial;
	}
	else
		return None;
}

// called to see if the object can expire due to timeout, max dropped equipment etc.
simulated function bool canExpire()
{
	return true;
}

// called when taken from an equipment spawn point
function onTakenFromSpawnPoint()
{
}

cpptext
{
	virtual UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);

}


defaultproperties
{
     droppedElasticity=0.200000
     dropVelocity=1500
     infoString="[Info not available]"
     inventoryIcon=Texture'Engine_res.DefaultTexture'
     hudIcon=Texture'HUD.Helptab'
     hudIconCoords=(V=14.000000,UL=80.000000,VL=40.000000)
     hudRefireIcon=Texture'HUD.Helptab'
     hudRefireIconCoords=(V=14.000000,UL=80.000000,VL=40.000000)
     attentionFXMaterial=Texture'BaseObjects.ResupplyStationLum'
     attentionFXSpacing=3.000000
     attentionFXDuration=0.500000
     heldStartState="Held"
     awaitingPickupPhysics=PHYS_Falling
     pickupRadius=50.000000
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=10.000000
     NetPriority=1.400000
     CullDistance=7500.000000
     bTravel=True
     bCollideActors=True
     bProjTarget=True
     bNetNotify=True
}
