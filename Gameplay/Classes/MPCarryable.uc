class MPCarryable extends MPActor
	native
	dependsOn(ObjectiveInfo)
	dependsOn(Vehicle);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

const MPC_LINEAR_VELOCITY_ACCURACY_FACTOR = 100;
const MPC_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.01;

const MPC_ANGULAR_VELOCITY_ACCURACY_FACTOR = 1000;
const MPC_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.001;

// Notes
// Characters can only carry MPCarryables of a particular class (and its subclasses).
// Characters can pickup individual MPCarryables but they cannot drop individual MPCarryables.
// In other words, characters always drop or throw all MPCarryables that are being carried.
// When multiple carryables are carried, only a single instance is stored and the rest get deleted.
// Carryables get dropped at their largest possible denominations.
// For example, if dropping 16 carryables with 1, 5, 10 denominations, one of each denomination is spawned and dropped.

// Denominations
var(MPCarryable) int			maxCarried					"The maximum number of carryables of this type that you can carry at a time";
var(MPCarryable) array< class<MPMetaCarryable> > denominations	"If maxCarried > 0, you can add denominations in order to group numerous carryables together.  A denomination is an MPMetaCarryable class.";
var(MPCarryable) float			returnTime					"How long this carryable takes to return when it is dropped.  -1 to disable.";
var(MPCarryable) float			minRespawnTime				"The minimum time it takes for the carryable to respawn after it has been returned.";
var(MPCarryable) float			maxRespawnTime				"The maximum time it takes for the carryable to respawn after it has been returned.";
var(MPCarryable) float			existenceTime				"How long this carryable will remain in existence after being picked up from its home location.  0 or less to disable.";
var(MPCarryable) config Material		hudIcon						"The icon displayed in the player's hud while this object is held";
var(MPCarryable) config MatCoords		hudIconCoords				"UV coordinates of the hud icon space in the hudIcon material";
var(MPCarryable) float			selfPickupTimeout			"Number of seconds before you can pickup this object after dropping it";
var(MPCarryable) int			stopSpeed					"Speed at which this object will stop moving";
var(MPCarryable) float			elasticity					"How much the object bounces";
var(MPCarryable) float			spread						"The degree to which multiple carryables will randomly spread";
var(MPCarryable) EPhysics		droppedPhysics				"The physics state when dropped";
var(MPCarryable) bool			bRandomizeStartingRotation	"Should the yaw of this object be randomized?";
var(MPCarryable) float			maxTimeCarried				"The maximum number of seconds this carryable can be held.  0 or less disables the limit.";
var(MPCarryable) float			damagePerSecondAfterMaxTimeCarried		"After maxTimeCarried expires, this amount of damage is applied to the carrier per second.  If 0, it's disabled and the player will simply drop the carryable instead.";
var(MPCarryable) array<Vector> randomStartingLocations		"Put extra locations in this array if you want the carryable to respawn at them randomly. (NOT FULLY IMPLEMENTED)";
var(MPCarryable) Name			attachmentSocket			"The name of the socket where this carryable should be attached when carried.";
var(MPCarryable) Vector			offsetCOM					"Offset the center of mass when using Havok";
var(MPCarryable) bool			bIsWeaponType				"If true, the carryable is carried and selected like a weapon and thrown when the weapon is fired as normal. If false, the carryable is not part of the player's inventory and is thrown with the alt-fire key.";
var(MPCarryable) bool			bAllowThroughEnergyBarriers	"If true, you can carry or throw this carryable through friendly energy barriers.";
var(MPCarryable) StaticMesh		staticMeshWhileCarried		"If set, use this static mesh when carried.";
var(MPCarryable) Mesh			meshWhileCarried			"If set, use this mesh when carried.";
var(MPCarryable) name			carriedAnimation			"Anim to play while carried. Not applicable for static meshes.";
var(MPCarryable) bool			bCanBeGrappledInField		"If true, you can pickup this carryable in the field by grappling it.";
var(MPCarryable) bool			bCanBeGrappledAtHome		"If true, you can pickup this carryable at its home by grappling it.";
var(MPCarryable) bool			bDontReplicateEffects		"If true, no effects will be replicated to clients.  Useful if there are many instances";
var(MPCarryable) bool			bCanBringIntoVehicle		"If true, players carrying this carryable can enter vehicles.";
var(MPCarryable) float			extraMass					"If used, adds this many kilograms to the player when picked up.";
var(MPCarryable) bool			bBlockActorsWhenDropped		"If true will be set bBlockActors to true when dropped.";
var(MPCarryable) float			inheritedVelocityFactor		"Percentage of velocity the carryable will inherit when dropped after carrier death.";
var(LocalMessage) class<Engine.LocalMessage>	CarryableMessageClass "The class used for displaying messages and playing effects related to carryables.";

// Stats
var(Stats) class<Stat>	pickupStat					"The stat awarded for picking up this carryable";
var(Stats) class<Stat>	carrierKillStat				"The stat awarded for killing the carrier of this carryable";

var (EffectEvents)	Name	pickupEffectEvent		"The name of an effect event that plays once on the carryable when picked up";
var (EffectEvents)	Name	dropEffectEvent			"The name of an effect event that plays once on the carryable when dropped";
var (EffectEvents)	Name	thrownEffectEvent		"The name of an effect event that plays once on the carryable when thrown";
var (EffectEvents)	Name	returnedHomeEffectEvent	"The name of an effect event that plays once on the carryable after it returns home";
var (EffectEvents)	Name	preReturnEffectEvent	"The name of an effect event that plays once on the carryable just before it returns home";
var (EffectEvents)	Name	carryingEffectEvent		"The name of an effect event that loops on the carryable while carried";
var (EffectEvents)	Name	idlingEffectEvent		"The name of an effect event that loops on the carryable when it is in the world";
var (EffectEvents)	Name	throwingEffectEvent		"The name of an effect event that loops on the carryable when the throw button is held";
var (EffectEvents)	Name	idlingHomeEffectEvent	"The name of an effect event that loops on the carryable when it is idling at its home location";

var int				numCarried;
var Vector			homeLocation;
var Rotator			homeRotation;
var Character		carrier;
var Character		lastCarrier;
var Controller		carrierController;
var float			timeDropped;
var float			timePickedUp;
var bool			bHome;
var Timer			existenceTimer;
var bool			bHotPotato;
var MPCarryableContainer homeContainer;
var float			lastEnergyBarrierCollisionTime;
var float			timeBetweenEnergyBarrierCollisions;
var Rotator			pickupRotation;

// Effect bools
var bool			bInitialization;
var bool			bCarriedEffect;
var bool			bLocalCarriedEffect;
var bool			bHomeEffect;
var bool			bPreReturnEffect;
var bool			bLocalPreReturnEffect;
var bool			bLocalHomeEffect;
var bool			bThrowingEffect;
var bool			bLocalThrowingEffect;
var bool			bWasDropped; // for client physics
var bool			bOldWasDropped;

var() class<MPCarryableThrower>	carriedObjectClass			"This class gets carried while the player is holding the object";

// Havok
struct native HavokCarryableReplicationState
{
	var vector  Position;
	var quat	Rotation;
	var vector	LinVel;
	var vector	AngVel;
	var bool bNewState;
};

var (Havok)	float maximumNetUpdateInterval;
var (Havok) float minimumNetUpdateInterval;
// latest time we should force an update of vehicles state
var float maximumNextNetUpdateTime;
// earliest time we shoudl force an update of vehicles state
var float minimumNextNetUpdateTime;
var	HavokCarryableReplicationState ReplicationState;
var float lastStateReceiveTime;
var bool bInitialized;

var Vehicle.DesiredHavokState currentDesiredHavokState;

// controls how quickly the client side object interpolates to the server side state
var (Havok)	float clientInterpolationPeriod;

// when the client side object deviates this distance from the server it shall be snapped
var (Havok)	float clientInterpolationSnapDistance;

var transient noexport private const int padding[1];

replication
{
	reliable if (!bDontReplicateEffects && Role == ROLE_Authority)
		bCarriedEffect, bHomeEffect, bThrowingEffect;
	reliable if (Role == ROLE_Authority)
		ReplicationState, bWasDropped, timeDropped;
}

native function forceNetDirty();

// PostBeginPlay
simulated function PostBeginPlay()
{
	local Rotator newRotation;

	Super.PostBeginPlay();
	
	if (Level.NetMode != NM_Client)
	{
		// Add the starting location to the list of possible random locations and choose a random starting location
		randomStartingLocations[randomStartingLocations.Length] = Location;
		homeLocation = chooseHomeLocation();

		homeRotation = Rotation;
		SetOwner(None);

		if (bRandomizeStartingRotation)
		{
			newRotation = Rotation;
			newRotation.Yaw = Rand(65535);
			homeRotation = newRotation;
		}
		bHome = true;

		if (existenceTime > 0)
		{
			existenceTimer = Spawn(class'Timer');
			existenceTimer.TimerDelegate = existenceTimerExpired;
		}
	}

	if (Physics == PHYS_Havok || droppedPhysics == PHYS_Havok)
	{
		bUpdateSimulatedPosition = false;
		bUseCompressedPosition=false;
		HavokSetCOM(offsetCOM);
	}
}

simulated function PostNetReceive()
{
	local Name oldAttachmentBone;
	local Actor oldBase;

	super.PostNetReceive();
	updateCarryableEffects();

	if (bWasDropped != bOldWasDropped)
	{
		oldAttachmentBone = AttachmentBone;
		oldBase = Base;

		if (bWasDropped)
			SetPhysics(droppedPhysics);
		else
			SetPhysics(default.Physics);

		oldBase.AttachToBone(self, oldAttachmentBone);

		bOldWasDropped = bWasDropped;
	}

	if (Physics == PHYS_Havok)
	{
		updateHavok();
	}
}

// Re-trigger necessary effects on coming into relevancy
simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if (Level.NetMode == NM_Client && !bInitialization)
	{
		if (bHomeEffect)
		{
			TriggerEffectEvent(idlingHomeEffectEvent);
		}
		else if (bCarriedEffect)
		{
			TriggerEffectEvent(carryingEffectEvent);
		}
		else
		{
			TriggerEffectEvent(idlingEffectEvent);
		}
	}
}

simulated function Destroyed()
{
	if (Level.NetMode == NM_Client)
	{
		if (bCarriedEffect)
		{
			UnTriggerEffectEvent(carryingEffectEvent);
		}
		else
		{
			UnTriggerEffectEvent(idlingEffectEvent);
			UnTriggerEffectEvent(idlingHomeEffectEvent);
		}
	}

	super.Destroyed();
}

simulated function updateCarryableEffects()
{
	if (bCarriedEffect != bLocalCarriedEffect)
	{
		bLocalCarriedEffect = bCarriedEffect;
		if (bCarriedEffect)
		{
			// The Carryable has started to be carried
			UnTriggerEffectEvent(idlingEffectEvent);
			UnTriggerEffectEvent(idlingHomeEffectEvent);
			if (!bInitialization)
				TriggerEffectEvent(pickupEffectEvent);
			TriggerEffectEvent(carryingEffectEvent);
		}
		else
		{
			// The Carryable has been dropped
			UnTriggerEffectEvent(carryingEffectEvent);
			if (!bInitialization)
				TriggerEffectEvent(dropEffectEvent);
			TriggerEffectEvent(idlingEffectEvent);
		}

	}

	if (bHomeEffect != bLocalHomeEffect)
	{
		bLocalHomeEffect = bHomeEffect;

		if (bHomeEffect)
		{
			// The Carryable has been returned home
			UnTriggerEffectEvent(idlingEffectEvent);
			if (!bInitialization)
				TriggerEffectEvent(returnedHomeEffectEvent);
			TriggerEffectEvent(idlingHomeEffectEvent);
		}
	}

	if (bThrowingEffect != bLocalThrowingEffect)
	{
		bLocalThrowingEffect = bThrowingEffect;

		if (bThrowingEffect)
		{
			// The carryable has started to be thrown
			if (!bInitialization)
				TriggerEffectEvent(throwingEffectEvent);
		}
		else
		{
			// The carryable has stopped being thrown
			UnTriggerEffectEvent(throwingEffectEvent);
			if (!bInitialization)
				TriggerEffectEvent(thrownEffectEvent);
		}
	}

	if (bPreReturnEffect != bLocalPreReturnEffect)
	{
		bLocalPreReturnEffect = bPreReturnEffect;

		if (!bInitialization)
			TriggerEffectEvent(preReturnEffectEvent);
	}
	
	bInitialization = false;
}

function cleanup()
{
	Super.cleanup();

	if (existenceTimer != None)
		existenceTimer.destroy();
}

function setMovementReplication(bool replicate)
{
	// MJ TEMP:  Disable this to see if it fixes the phantom fuel bug
	return;

	bUpdateSimulatedPosition = replicate;
}

function registerStats(StatTracker tracker)
{
	Super.registerStats(tracker);

	tracker.registerStat(pickupStat);
	tracker.registerStat(carrierKillStat);
}

function Vector chooseHomeLocation()
{
	local int i;

	if (randomStartingLocations.Length == 0)
		return homeLocation;

	i = Rand(randomStartingLocations.Length-1);

	return randomStartingLocations[i];
}

function onPickedUp(Character c)
{
}

function onDropped(Controller c)
{
}

function onCharacterPassedThrough(Character c)
{
}

function onCarrierDeath(Controller Killer)
{
	if (PlayerController(carrierController) == None || PlayerController(Killer) == None)
		return;

	if (carrierKillStat != None && ModeInfo(Level.Game) != None && carrierController != Killer
		&& Killer != None && !PlayerController(carrierController).isFriendly(Killer))
	{
		ModeInfo(Level.Game).Tracker.awardStat(Killer, carrierKillStat, carrierController);
	}
}

function onDropTimerExpired()
{
}

function onExistenceTimerExpired()
{
}

// return
function returnToHome(optional bool bSignificant)
{
	if (carrier != None)
		carrier.clearCarryables();

	clearCarrier();

	if (minRespawnTime > 0)
		GotoState('Respawning');
	else if (bSignificant)
		GotoState('Home', 'SignificantReturn');
	else
		GotoState('Home');
}

// This is called when the carrier dies
function drop(optional bool bSpread)
{
	local vector newLocation, newVelocity;

	if (carrier != None)
		newLocation = carrier.Location;
	else
		newLocation = Location;

	newLocation.z += CollisionHeight;

	if (bSpread)
	{
		newVelocity.X = 500*Frand() - 250;
		newVelocity.Y = 500*Frand() - 250;
		newVelocity.Z = 200;
	}

	if (carrier != None)
		newVelocity += inheritedVelocityFactor * carrier.ragdollInheritedVelocity;

	SetPhysics(droppedPhysics);
	bWasDropped = true;

	unifiedSetPosition(newLocation);
	unifiedSetVelocity(newVelocity);

	//Log(self$" dropped at "$newLocation);
	GotoState('Dropped');
}

simulated event toss()
{
	carrier.pseudoWeapon.Fire();
}

function existenceTimerExpired()
{
	onExistenceTimerExpired();
	returnToHome();
}

// MJ:  No longer use this
//function Landed( vector HitNormal )
//{
//	if (Physics == PHYS_Havok)
//		return;
//
//	Velocity = vect(0, 0, 0);
//	SetPhysics(default.Physics);
//}

simulated function HitWall (vector HitNormal, actor Wall)
{
	if (Physics == PHYS_Havok)
		return;

	if (Level.TimeSeconds - timeDropped < default.selfPickupTimeout)
		return;

	Velocity = elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);	
	
	TriggerEffectEvent('Bounced');	
	
	//if (VSize(Velocity) < stopSpeed) 
    //    Landed(HitNormal);		
}

function bool isReplicatedInstance()
{
	// Returns true if this carryable is the carrier's replicated instance
	return carrier != None && carrier.carryableReference == self;
}

function bool validCarrier(Character c, optional bool ignoreLastCarrierCheck)
{
	if (c == None || !c.isAlive() || c.team() == None || c.Controller.IsInState('PlayerTeleport'))
	{
		//Log(c$" wasn't a valid carrier for "$self$" due to level 1 check");
		return false;
	}
	
	if (c.isTouchingEnergyBarrier())
		return false;

	// Check for self collision (quickly drop and touch it again)
	if (!ignoreLastCarrierCheck && c == lastCarrier && Level.TimeSeconds - timeDropped < selfPickupTimeout)
	{
		//Log(c$" wasn't a valid carrier for "$self$" due to level 2 check");
		return false;
	}
	// If not carrying any, then allow the pickup
	if (c.carryableReference == None)
	{
		return true;
	}
	// Otherwise, enforce carryable exclusivity (can only carry carryables of a single type)
	else if (!canCombineWith(c.carryableReference.Class))
	{
		//Log(c$" wasn't a valid carrier for "$self$" due to level 3 check, ref = "$c.carryableReference);
		return false;
	}
	// Check to see how many of this carryable you're allowed to pickup
	else if (c.numCarryables - c.numPermanentCarryables >= getMaxCarried())
	{
		//Log(c$" wasn't a valid carrier for "$self$" due to level 4 check");
		return false;
	}

	return true;
}

function bool canCombineWith(class<MPCarryable> targetClass)
{
	return Class == targetClass || ClassIsChildOf(targetClass, class'MPMetaCarryable');
}

function clearCarrier()
{
	SetOwner(None);

	if (carrier == None)
		return;

	lastCarrier = carrier;

	dispatchMessage(new class'MessageDroppedGameObject'(label, carrier.label));
	carrier = None;
	carrierController = None;
}

function pickup(Character c)
{
	c.pickupCarryable(self);

	if (pickupStat != None)
		awardStat(pickupStat, c);
	GotoState('Held');
}

function setCarrier(Character c)
{
	carrier = c;
	carrierController = c.Controller;
	setOwner(carrier);

	dispatchMessage(new class'MessagePickedUpGameObject'(label, carrier.label));
}

function onGrappled(Character c)
{
	if (bHome)
	{
		if (!bCanBeGrappledAtHome)
		{
			c.receiveLocalizedMessage( CarryableMessageClass, 11 );
			return;
		}
	}
	else
	{
		if (!bCanBeGrappledInField)
		{
			c.receiveLocalizedMessage( CarryableMessageClass, 12 );
			return;
		}
	}

	if (c == None || c.controller == None || bHidden || !c.controller.IsInState('CharacterMovement') || carrier != None)
		return;

	attemptPickup(c, true);
}

singular function Touch(Actor Other)
{
	local Character c;
	local GrapplerProjectile p;
	local vector hitLoc, hitNormal, startLoc, testLoc;

	p = GrapplerProjectile(Other);
	if (p != None)
	{
		Character(p.Instigator).detachGrapple();
		onGrappled(Character(p.instigator));
		return;
	}

	c = Character(Other);

	if (c == None || c.controller == None || bHidden || !c.isAlive() || carrier != None 
		|| c.bDontAllowCarryablePickups || c.Physics == PHYS_None || !bInitialized)
	{
		//Log("Unable to pickup "$self$" probably due to "$bInitialized);
		return;
	}

	// Don't allow picking up through geometry
	// TODO:  Unfortunately this doesn't fully solve the case of energy barriers where
	// the player can be standing inside one
	startLoc = c.Location - Normal(c.Location - Location) * 10;
	testLoc = Location;
	testLoc.z += CollisionHeight;
	if (Trace(hitLoc, hitNormal, startLoc, testLoc, false) != None)
	{
		//Log("Not allowing pickup of "$self$" due to Trace");
		return;
	}

	//Log(self$" attempting pickup by "$c);
	attemptPickup(c);
}

function bool attemptPickup(Character c, optional bool ignoreLastCarrierCheck)
{
	if (ValidCarrier(c, ignoreLastCarrierCheck))
	{
		setCarrier(c);
		pickup(c);
		return true;
	}

	onCharacterPassedThrough(c);
	return false;
}

// Initialization state
auto simulated state Initialization
{
	simulated function BeginState()
	{
		bInitialization = true;
	}

Begin:
	if (Level.NetMode == NM_Client)
		GotoState('');
	else
		GotoState('Home');
}

// Home state
state Home
{
	function returnToHome(optional bool bSignificant)
	{
		// Already home
	}

	function CheckTouching()
	{
		local Character c;

		ForEach TouchingActors(class'Character',c)
		{
			if ( ValidCarrier(c) )
			{
				setCarrier(c);
				pickup(c);
				return;
			}
		}
	}

	function BeginState()
	{
		bWasDropped = false;

		SetRelativeLocation(Vect(0,0,0));
	    SetRelativeRotation(Rot(0,0,0));
		unifiedSetVelocity(Vect(0,0,0));
		unifiedSetAngularVelocity(Rot(0,0,0));

		SetBase(None);

		SetPhysics(default.Physics);
		bHome = true;

		// If a homeContainer is specified, use its location instead and send to Locked
		if (homeContainer != None)
		{
			//Log("homeContainer for "$self$" detected as "$homeContainer$"; adding and sending to Locked");
			homeContainer.addCarryable(self);
			unifiedSetPosition(homeContainer.Location);
			GotoState('Locked');
			return;
		}

		unifiedSetPosition(homeLocation);
		unifiedSetRotation(homeRotation);
		//Enable('Touch');

		bHomeEffect = true;
		updateCarryableEffects();
		bInitialized = true;
	}

	function EndState()
	{
		bHome = false;
		bHomeEffect = false;
		updateCarryableEffects();

		if (existenceTimer != None)
			existenceTimer.StartTimer(existenceTime);
	}

SignificantReturn:
	if (CarryableMessageClass != None)
		Level.Game.BroadcastLocalized(self, CarryableMessageClass, 2, team());

Begin:
	// After setting to its home location, see if anyone is touching it
	CheckTouching();
}

// Pawn version of this will set PHY_Falling if Physics is None and Base is None.
singular event BaseChange();

// Locked state
// When a carryable is locked, it is hidden and can't be picked up.
// Needed, for example, when it is stored in a container or metacarryable.
state Locked
{
	function BeginState()
	{
		bHidden = true;
		bInitialized = true;
		setMovementReplication(false);
	}

	function EndState()
	{
		bHidden = false;
	}

Begin:
	clearCarrier();
}

// Dropped state
state Dropped
{
	// return timer
	function Timer()
	{
		dispatchMessage(new class'MessageCarryableReturned'(label));

		onDropTimerExpired();
		returnToHome(true);
	}
	
	function BeginState()
	{
		// set collision consistent with a physical object in the world
		SetCollision(true, bBlockActorsWhenDropped, false);
		bCollideWorld = true;

		onDropped(carrierController);
		bWasDropped = true;
		//Log(self$" entered Dropped state");

       // SetRelativeLocation(Vect(0,0,0));
        //SetRelativeRotation(Rot(0,0,0));
		timeDropped = Level.TimeSeconds;

		bHidden = false;
		setMovementReplication(true);

		// Set the carryable to return based on the returnTime, if applicable
		if (returnTime >= 0)
			SetTimer(returnTime, false);

		//carrier.ReceiveLocalizedMessage(CarryableMessageClass, 1);
		if (CarryableMessageClass != None)
			Level.Game.BroadcastLocalized(self, CarryableMessageClass, 1, team());

		if (SecondaryMessageClass != None)
		{
			//Log("Sending dropped message with carrier = "$carrier$" and lastCarrier = "$lastCarrier$" and PRI = "$carrier.playerReplicationInfo);
			Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 1, carrierController.playerReplicationInfo);
		}

		clearCarrier();
	}
	
	function EndState()
	{
		bWasDropped = false;

		SetTimer(0, false);

		// turn off block actors
		SetCollision(true, false, false);
	}
}

function unsetup()
{
	if (isReplicatedInstance())
	{
		// Detach it
		carrier.DetachFromBone(self);
	}
	else
	{
		bHidden = false;
	}

	// Reset StaticMesh if applicable
	if (default.staticMeshWhileCarried != None || default.meshWhileCarried != None)
	{
		if (default.StaticMesh != None)
		{
			SetStaticMesh(default.StaticMesh);
			SetDrawType(DT_StaticMesh);
		}
		else
		{
			LinkMesh(default.Mesh);
			SetDrawType(DT_Mesh);
		}
	}
}

// moved this out of 'Held' state code due to 
// states not being replicated
simulated function Vector GetObjectiveLocation()
{
	if(bCarriedEffect)
	{
		if(carrier != None)
			return carrier.Location;
		else if(base != None)
			return base.Location;
	}
	else
		return Super.GetObjectiveLocation();
}

// Held state
state Held
{
	function BeginState()
	{
		bCarriedEffect = true;
		updateCarryableEffects();
		timePickedUp = Level.TimeSeconds;
		//bOnlyDrawIfAttached = true;
        SetCollision(false, false, false);
        bCollideWorld = false;
//		bBlockPlayers = false;
		SetPhysics(default.Physics);
		bHome = false;
		unifiedSetVelocity(Vect(0, 0, 0));
        SetRelativeLocation(Vect(0,0,0));
		pickupRotation = Rotation;
        //SetRelativeRotation(Rot(0,0,0));

		// Set all spectators to view the carrier instead
		setSpectatorViewTarget(carrier);

		setup();

		onPickedUp(carrier);
		//carrier.ReceiveLocalizedMessage(CarryableMessageClass, 0);
		if (CarryableMessageClass != None)
			Level.Game.BroadcastLocalized(self, CarryableMessageClass, 0, team());

		if (SecondaryMessageClass != None)
			Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 0, carrier.playerReplicationInfo);

		// Set maxTimeCarried timer if applicable
		if (maxTimeCarried > 0)
			SetTimer(maxTimeCarried, false);
	}

	event Tick(float Delta)
	{
		Global.Tick(Delta);

		// MJ TODO:  Carrier shouldn't be None here...need to look into this
		if (carrier != None)
			Move(carrier.Location - Location);
	}

	function setup()
	{
		SetLocation(carrier.Location);

		if (denominations.Length > 0 && !isReplicatedInstance())
			attachDenomination();
		else
		{
			if (isReplicatedInstance())
				attachToCarrier();
			else
			{
				bHidden = true;
			}
		}
	}

	function Timer()
	{
		// Timer called due to hotPotato.  A second has passed...inflict damage
		if (bHotPotato)
		{
			carrier.TakeDamage(damagePerSecondAfterMaxTimeCarried, self, vect(0, 0, 0), vect(0, 0, 0), class'DamageType');
		}
		// Timer called due to maxTimeCarried.
		// If damage is to be applied, start hotPotato
		else if (damagePerSecondAfterMaxTimeCarried != 0)
		{
			bHotPotato = true;
			SetTimer(1, true);
		}
		// Otherwise, just force it to drop
		else
			drop();
	}

	function Pawn getViewTarget()
	{
		if (carrier != None)
			return carrier;
		
		return self;
	}
	
	function EndState()
	{
		bCarriedEffect = false;
		updateCarryableEffects();
        SetCollision(true, false, false);	
        bCollideWorld = true;
		bHidden = false;
	
		resetSpectatorViewTarget();

		unsetup();

	    SetRelativeLocation(vect(0,0,0));
        //SetRelativeRotation(rot(0,0,0));
		unifiedSetRotation(pickupRotation);

		SetTimer(0, false);
		bHotPotato = false;
	}
}

// In the Respawning state, the carryable is in a state of limbo waiting to spawn
// at its home location
state Respawning
{
	function BeginState()
	{
		local int respawnTime;

		bHidden = true;
		respawnTime = Rand(maxRespawnTime - minRespawnTime);
		SetTimer(respawnTime + minRespawnTime, false);
	}

	function Timer()
	{
		SetTimer(0, false);
		GotoState('Home', 'SignificantReturn');
	}

	function EndState()
	{
		bHidden = false;
	}
}

// attachToCarrier
function attachToCarrier()
{
	if (getCarriedMesh() != None)
	{
		//Log(self$" attaching "$default.staticMeshWhileCarried$" to socket "$attachmentSocket);
		unifiedSetMesh(getCarriedMesh());
	}

	if (!carrier.AttachToBone(self, attachmentSocket))
		carrier.AttachToBone(self, 'Bip01 Spine');
}

function attachDenomination()
{
	local int i;

	i = 0;

	// Find the denomination to use, if any;  search backwards
	for (i=denominations.Length - 1; i>=0; i--)
	{
		if (carrier.numDroppableCarryables() >= denominations[i].default.maxCarryables)
		{
			// Found it
			break;
		}
	}

	// Found a denomination if i is valid
	if (i >= 0)
	{
		if (denominations[i].static.getCarriedMesh() != None)
			carrier.carryableReference.unifiedSetMesh(denominations[i].static.getCarriedMesh());
		else
			carrier.carryableReference.unifiedSetMesh(denominations[i].default.StaticMesh);

		//Log("AttachDenomination() called, set "$carrier.carryableReference$" static mesh to "$carrier.carryableReference.StaticMesh);
	}
	else
	{
		if (getCarriedMesh() != None)
			unifiedSetMesh(getCarriedMesh());
		else
			unifiedSetMesh(default.StaticMesh);
	}

	if (self != carrier.carryableReference)
	{
		bHidden = true;
		setMovementReplication(false);
	}
}

// Havok
simulated event Tick(float Delta)
{
	super.tick(Delta);

	// return if outside boundary volume
	if (Role == ROLE_Authority 
		&& !IsInState('Held') 
		&& !IsInState('Locked')
		&& (Level.Game.BoundaryVolume != None && !Level.Game.BoundaryVolume.encompasses(self)))
	{
		dispatchMessage(new class'MessageCarryableReturned'(label));
		returnToHome(true);
	}
	
	if (Physics != PHYS_Havok)
		return;

	// if server process input and pack output for replication
	if (Role == ROLE_Authority)
	{
		//processInput();
		if ( (Level.TimeSeconds > minimumNetUpdateInterval) && 
				((Level.TimeSeconds > maximumNextNetUpdateTime) || needToPushStateToClient()))
		{
			minimumNextNetUpdateTime = Level.TimeSeconds + minimumNetUpdateInterval;
			maximumNextNetUpdateTime = Level.TimeSeconds + maximumNetUpdateInterval;
			pushStateToClient();
		}
	}
}

function bool needToPushStateToClient()
{
	local vector oldPos;
	local vector oldLinVel;
	local vector chassisPos, chassisLinVel, chassisAngVel;
	local HavokRigidBodyState chassisState;

	// see if state has changed enough, or enough time has passed, that we 
	// should send out another update by updating the state struct

	// never send updates if physics is at rest
	if (!HavokIsActive())
		return false;

	// get chassis state
	HavokGetState(ChassisState);

	chassisPos = ChassisState.Position;
	chassisLinVel = ChassisState.LinVel;
	chassisAngVel = ChassisState.AngVel;

	// last position we sent
	oldPos = ReplicationState.Position;
	oldLinVel = ReplicationState.LinVel;

	if(VSize(oldPos - chassisPos) > 2 || VSize(oldLinVel - chassisLinVel) > 0.5)
	{
		return true;
	}

	return false;
}

function pushStateToClient()
{
	local HavokRigidBodyState ChassisState;

	HavokGetState(ChassisState);
	//Log("Pushing state to client with position "$ChassisState.position);

	ReplicationState.position = ChassisState.position;
	ReplicationState.linVel = ChassisState.linVel * MPC_LINEAR_VELOCITY_ACCURACY_FACTOR;
	ReplicationState.rotation = ChassisState.quaternion;
	ReplicationState.angVel = ChassisState.angVel * MPC_ANGULAR_VELOCITY_ACCURACY_FACTOR;

	// this flag lets the client know this data is new
	ReplicationState.bNewState = true;

	forceNetDirty();
}

simulated function updateHavok()
{
	if (!ReplicationState.bNewState)
	{
		Log("updateHavok() called without newState");
		return;
	}
	lastStateReceiveTime = level.timeSeconds;

	// update desired state
	currentDesiredHavokState.position = ReplicationState.position;
	currentDesiredHavokState.velocity = ReplicationState.linVel * MPC_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.angularVelocity = ReplicationState.angVel * MPC_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.rotation = ReplicationState.rotation;
	currentDesiredHavokState.newState = true;

	// update flags
	ReplicationState.bNewState = false;

	//Log("Client called updateHavok()");
}

function int getNumCarryables()
{
	// This instance is 1 carryable.  MetaCarryables override this function and use it recursively.
	return 1;
}

function int getMaxCarried()
{
	// Overriden by MetaCarryables
	return maxCarried;
}

event EnergyBarrierCollision()
{
	if (Level.TimeSeconds - lastEnergyBarrierCollisionTime < timeBetweenEnergyBarrierCollisions)
		return;

	lastEnergyBarrierCollisionTime = Level.TimeSeconds;
	if (carrier != None)
	{
		if (CarryableMessageClass != None)
			carrier.receiveLocalizedMessage( CarryableMessageClass, 10 );
	}
	else if (lastCarrier != None)
	{
		if (CarryableMessageClass != None)
			lastCarrier.receiveLocalizedMessage( CarryableMessageClass, 10 );
	}
}

simulated static function Object getCarriedMesh()
{
	if (default.meshWhileCarried != None)
		return default.meshWhileCarried;
	else
		return default.staticMeshWhileCarried;
}

simulated function unifiedSetMesh(Object m)
{
	if (StaticMesh(m) != None)
	{
		SetStaticMesh(StaticMesh(m));
		SetDrawType(DT_StaticMesh);
	}
	else
	{
		LinkMesh(Mesh(m));
		SetDrawType(DT_Mesh);
		if (carriedAnimation != '' && HasAnim(carriedAnimation))
			LoopAnim(carriedAnimation);
	}
}

cpptext
{
	virtual void TickSimulated( FLOAT DeltaSeconds );
	virtual void TickAuthoritative( FLOAT DeltaSeconds );

	virtual bool HavokInitActor();
	virtual void HavokQuitActor();

	class HkClientInterpolationControl* clientInterpolationControl;

}


defaultproperties
{
     maxCarried=1
     returnTime=20.000000
     hudIcon=Texture'HUD.Helptab'
     hudIconCoords=(V=14.000000,UL=80.000000,VL=40.000000)
     selfPickupTimeout=0.400000
     stopSpeed=40
     Elasticity=0.200000
     Spread=500.000000
     droppedPhysics=PHYS_Falling
     maxTimeCarried=-1.000000
     attachmentSocket="Flag"
     bCanBeGrappledInField=True
     bBlockActorsWhenDropped=True
     inheritedVelocityFactor=0.850000
     CarryableMessageClass=Class'MPCarryableMessages'
     pickupEffectEvent="PickedUp"
     dropEffectEvent="Dropped"
     thrownEffectEvent="Thrown"
     returnedHomeEffectEvent="returned"
     preReturnEffectEvent="PreReturned"
     carryingEffectEvent="Carrying"
     idlingEffectEvent="Idling"
     throwingEffectEvent="Throwing"
     idlingHomeEffectEvent="IdlingHome"
     timeBetweenEnergyBarrierCollisions=3.000000
     carriedObjectClass=Class'MPCarryableThrower'
     maximumNetUpdateInterval=0.500000
     minimumNetUpdateInterval=0.200000
     clientInterpolationPeriod=0.100000
     clientInterpolationSnapDistance=50.000000
     primaryFriendlyObjectiveDesc="Defend your team's carryable"
     primaryEnemyObjectiveDesc="Get the enemy carryable"
     primaryNeutralObjectiveDesc="Get the carryable"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'MPGameObjects.MPFlag'
     bStasis=False
     NetPriority=3.000000
     bHardAttach=True
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bUseCylinderCollision=True
     bBlockKarma=False
     bBlockHavok=False
     bNetNotify=True
     bBounce=True
     bRotateToDesired=False
     bNeedLifetimeEffectEvents=True
}
