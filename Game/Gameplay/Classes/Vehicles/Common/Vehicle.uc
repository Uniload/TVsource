// Vehicle

// Base Tribes vehicle class. Effectively a copy past of KVehicle. This was done due
// to the fact that KVehicle derives from Pawn and is located in Engine.
class Vehicle extends Rook implements IFiringMotor
	native
	abstract
	notplaceable;

const MAXIMUM_NUMBER_POSITIONS = 10;

const NUMBER_MINOR_ENTRY_SIGNALS = 4;

cpptext
{
	virtual void PostNetReceive();
	virtual void PostEditChange();
	virtual void setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV);
	virtual void CleanupDestroyed();
	virtual void tickAI( FLOAT DeltaSeconds );
	virtual UBOOL shouldLookForPawns();
	virtual void TickSimulated( FLOAT DeltaSeconds );
	virtual void TickAuthoritative( FLOAT DeltaSeconds );
	virtual FVector predictedLocation( float t );

	virtual void HavokPreStepCallback(FLOAT deltaTime);
	virtual void RemakeRigidBodyVehicle();
	virtual void initialiseHavokDataObject();
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();

	virtual void PostNetReceiveLocation();

	virtual void physicsRotation(FLOAT deltaTime, FVector OldVelocity);

	virtual UBOOL IsNetRelevantFor(APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation);

	bool isOccupant(ACharacter* character);

	virtual UBOOL Tick(float deltaSeconds, ELevelTick tickType);

	void updateInertiaTensor();

	virtual bool groundContact();

	virtual void updateHavokCollisionFilter();

	virtual bool isHavokInitialised();

	UBOOL CheckOwnerUpdated();

	void clearVehicleAnimation(USkeletalMeshInstance *mesh, int index);
	void loopVehicleAnimation(AVehicle* vehicle, USkeletalMeshInstance *mesh, int index, const FName& sequence);

	class HkSoftCeiling* softCeiling;
	class HkCollisionDamageSignaller* collisionDamageSignaller;
	class HkStayUprightAction* xStayUpright;
	class HkStayUprightAction* yStayUpright;
	class HkDampingAction* dampingAction;
	class HkStayUprightAction* flipAction;
	class HkInfiniteMassCollisionController* infiniteMassCollisionController;
	class HkClientInterpolationControl* clientInterpolationControl;
}

// not all vehicle positions are valid for each vehicle
enum VehiclePositionType
{
	VP_DRIVER,
	VP_GUNNER,
	VP_LEFT_GUNNER,
	VP_RIGHT_GUNNER,
	VP_INVENTORY_STATION_ONE,
	VP_INVENTORY_STATION_TWO,
	VP_INVENTORY_STATION_THREE,
	VP_INVENTORY_STATION_FOUR,
	VP_NULL
};

// Each vehicle position is represented by the following struct. The set of positions are stored in the 'positions' array. The
// 'toBePossessed' member specifies what is to be possessed when the position is occupied. This member is initialised by the vehicle in the
// begin play functions. If this member is None on the server it implies that the position is a Minor position rather than a Major
// position. Clients can use the isMajorPositon function. A Major
// position is one that actually involves control of the vehicle, a Minor one simply involves placement in a vehicle. Sub classes would
// be expected to provide extra fuctionality for Minor positions.
struct native VehiclePosition
{
	var VehiclePositionType type;
	var Character occupant;
	var bool wantsToGetOut;
	var bool hideOccupant;
	var bool thirdPersonCamera;
	var bool lookAtInheritPitch;
	var Rook toBePossessed;
	var name occupantControllerState;

	// only valid for turret positions
	var vector firstPersonCameraLocation;
	var vector firstPersonWeaponLocation;

	var name enterAnimation;
	var name exitAnimation;
	var name occupiedAnimation;
	var name unoccupiedAnimation;
	var weapon oldOccupantWeapon;
	var vector occupantRelativeLocation;
	var rotator occupantRelativeRotation;

	// designer editable position coords for manifest
	var() int ManifestXPosition			"X location of position on manifest diagram";
	var() int ManifestYPosition			"Y location of position on manifest diagram";
	var() bool bNotLabelledInManifest	"Whether this position should be labelled in the manifest";

	// only valid if not hideOccupant
	var name occupantConnection;
	var() name occupantAnimation;
};

var float lastStateReceiveTime;

// occupant is replicated using the clientDriverEnter function
var() array<VehiclePosition> positions;

var int driverIndex;

var (Vehicle) float inverseCosUprightAngle;

struct native VehicleEntryData
{
	var () float radius;
	var () float height;
	var () vector offset;
	var () VehiclePositionType primaryPosition;
	var () array<VehiclePositionType> secondaryPositions;
	var () class<VehicleEntry> entryClass;
};

var (Vehicle) array<VehicleEntryData> entries;
var array<VehicleEntry> vehicleEntries;

struct native VehicleFlipTriggerData
{
	var () float radius;
	var () float height;
	var () vector offset;
};
var (Vehicle) array<VehicleFlipTriggerData> flipTriggers;
var array<VehicleFlipTrigger> vehicleFlipTriggers;

var class<VehicleMotor> motorClass;

var (Vehicle) class<Explosion> destroyedExplosionClass;

// generic controls (set by controller, used by concrete derived classes)
var float StrafeInput; // between -1 and 1
var float ThrottleInput; // between -1 and 1
var rotator RotationInput;
var float ThrustInput; // between 0 and 1
var bool DiveInput;

var (Vehicle) bool customInertiaTensor;
var (Vehicle) vector customInertiaTensorDiagonal;

var (Vehicle) float minimumCollisionDamageMagnitude;
var (Vehicle) float collisionDamageMagnitudeScale;

var (Vehicle) bool bCollisionDamageEnabled;

var (Vehicle) float settledUpsideDownCosAngle;
var (Vehicle) float settledUpsideDownSpeed;

var (Vehicle) bool bVehicleCameraTrace;
var (Vehicle) vector vehicleCameraTraceExtents;

var bool bSettledUpsideDown;

var (Vehicle) float healthModifier;

var (Vehicle) array<VehiclePositionType> doNotEjectOnFlip;

var (Vehicle) bool clientInterpolationHard;

// indicates if vehicle is in the process of being spawned from a spawn point
var bool spawning;

// 'true' if vehicle is in the process of flipping
var bool bFlipping;

// current class that has been switched in, will be None if no switch has taken place
var class<Vehicle> currentSwitchClass;

// exits
struct native ExitData
{
	var () vector offset;
	var () VehiclePositionType position;
};
var (Vehicle) array<ExitData> exits;

var (ClientSidePhysics) float clientInterpolationSnapDistance;
var (ClientSidePhysics) float clientInterpolationPeriod;

// The following is used to manage animations. The indices into animationFinishThenLoop correspond to animation channels. If a value is set
// for a particular channel then that animation should loop after the one that is currently playing on the channel finishes.
var array<Name> animationFinishThenLoop;

var (Vehicle) float	maximumNetUpdateInterval;

// latest time we should force an update of vehicles state
var float maximumNextNetUpdateTime;

var (Vehicle) float flipRotationStrength;
var (Vehicle) float flipRotationDamping;
var (Vehicle) float flipPushUpImpulse;
var (Vehicle) float flipPushUpDuration;
var (Vehicle) float flipMaximumRotationDuration;
var float flipRotateTime;
var float flipRotationTimeOut;

var bool bShowPhysicsDebug;

var bool bGodMode;

var (Vehicle) bool bDisablePositionSwitching;

var bool abandonmentDestruction;
var private float abandonmentDestructionPeriod;
var private float currentAbandonmentDuration;

var TeamInfo lastOccupantTeam;

// speed at which engine shall cease to apply force to vehicle
var (Vehicle) float	TopSpeed;

var (Vehicle) bool stayUprightEnabled;
var (Vehicle) float stayUprightDamping;
var (Vehicle) float stayUprightStrength;

var (Vehicle) int driverMinimumPitch;
var (Vehicle) int driverMaximumPitch;

////////// NAVIGATION //////////

var float minimumObstacleLookAhead;
var float obstacleLookAheadVeloocityScale;
var float distanceToMaximumDurationScale;

var float driveYawCoefficient;
var float drivePitchCoefficient;

// only relevant to vehicles that slow down at corners
var float cornerSlowDownDistance;
var float cornerSlowDownMinimumCosAngle;
var float cornerSlowDownSpeedCoefficient;

var bool stopForEnemies;

////////// CAMERA //////////

var (Vehicle) float cameraDistance;

var (Vehicle) vector TPCameraLookAt;
var (Vehicle) float TPCameraDistance;

var	(Vehicle) bool bDrawDriverInTP; // whether to draw the driver when in 3rd person mode

var Vector cachedCameraLocation;

// corresponds to vehicle centre
var (Vehicle) name rootBone;

// driver weapon
var (Vehicle) class<Weapon> driverWeaponClass;
var Weapon driverWeapon;

var (Vehicle) float waterDamagePerSecond;

var vector localMoveDestination;

// enahanced damping
var bool dampingPlusEnabled;
var float dampingPlusXY;
var float dampingPlusPositiveZ;
var float dampingPlusNegativeZ;

var bool retriggerEffectEvents;

struct native VehicleEffect
{
	var name effectName;
	var bool flag;
	var VehicleEffectObserver observer;
};

struct native ClientOccupantEnterData
{
	var Controller controller;
	var Character occupant;
	var byte positionIndex;
	var bool newData;
	var bool flipFlop;
};

var ClientOccupantEnterData minorPositionEntrySignals[NUMBER_MINOR_ENTRY_SIGNALS];

struct native ClientPositionData
{
	var Character occupant;
};

var ClientPositionData clientPositions[MAXIMUM_NUMBER_POSITIONS];
var ClientPositionData localClientPositions[MAXIMUM_NUMBER_POSITIONS];

var int throttleForwardEffectIndex;
var int throttleBackEffectIndex;
var int strafeLeftEffectIndex;
var int strafeRightEffectIndex;
var int engineIdlingEffectIndex;
var int thrustingEffectIndex;
var int throttleForwardOrThrustEffectIndex;
var int strafeLeftOrThrustEffectIndex;
var int strafeRightOrThrustEffectIndex;

var array<VehicleEffect> effects;

var VehicleMotor motor;

var TeamInfo localTeam;

var() class<DynamicObject>	destructionObjectClass;

// indicates whether or not a vehicle has been occupied at all
var bool bHasBeenOccupied;

// indicates whether or not this vehicle can be driven by an enemy before being driven by an ally
var bool bCanBeStolen;

// background material for hud data
var() Material		ManifestLayoutMaterial;

// prompts
const DRIVER_PROMPT_INDEX = 0;
var (VehiclePrompts) localized string driverPrompt;
const GUNNER_PROMPT_INDEX = 1;
var (VehiclePrompts) localized string gunnerPrompt;
const LEFT_GUNNER_PROMPT_INDEX = 2;
var (VehiclePrompts) localized string leftGunnerPrompt;
const RIGHT_GUNNER_PROMPT_INDEX = 3;
var (VehiclePrompts) localized string rightGunnerPrompt;
const INVENTORY_STATION_PROMPT_INDEX = 4;
var (VehiclePrompts) localized string inventoryStationPrompt;
const FULL_VEHICLE_PROMPT_INDEX = 5;
var (VehiclePrompts) localized string fullVehiclePrompt;
const VEHICLE_PROHIBITED_OBJECT_PROMPT_INDEX = 6;
var (VehiclePrompts) localized string vehicleProhibitedObjectPrompt;
const FLIP_PROMPT_INDEX = 7;
var (VehiclePrompts) localized string flipPrompt;
const CANNOT_STEAL_VEHICLE_PROMPT_INDEX = 8;
var (VehiclePrompts) localized string cannotStealPrompt;
const ENEMY_OCCUPIED_VEHICLE_PROMPT_INDEX = 9;
var (VehiclePrompts) localized string enemyOccupiedPrompt;
const ENEMY_INVENTORY_STATION_PROMPT_INDEX = 10;
var (VehiclePrompts) localized string enemyInventoryStationPrompt;
const HEAVY_ATTEMPT_TO_PILOT = 11;
var (VehiclePrompts) localized string heavyAttemptedToPilot;
var (VehiclePrompts) float heavyAttemptedToPilotSwitchPromptDuration;

var (Vehicle) localized string localizedName;

var bool bInvincible;
var float loseInitialInvincibilityTime;
var (Vehicle) float initialInvincibilityDuration;
var (Vehicle) Material invicibilityMaterial;

var (Vehicle) float velocityInheritOnExitScale "scales how much of the vehicle's velocity the player inherits when exiting";

var (Vehicle) class<MovementCrushingDamageType>	CrushingDamageTypeClass;

// used by clients to snap to server position
struct native DesiredHavokState
{
	var vector velocity;
	var vector angularVelocity;
	var vector position;
	var quat rotation;

	var bool ignoreRotation;

	var bool newState;
};
var DesiredHavokState currentDesiredHavokState;

// padding
var transient noexport private const int padding[8];

// useful function for plotting data to real-time graph on screen
native final function GraphData(string DataName, float DataValue);

native function forceNetDirty();

native function performFlip();

native function Actor cameraTrace(out vector HitLocation, out vector HitNormal, vector TraceEnd, optional vector TraceStart,
		optional bool bTraceActors, optional vector Extent);

native function bool vehicleTrace(out vector HitLocation, out vector HitNormal, vector TraceEnd, optional vector TraceStart,
		optional vector Extent);

native function Actor vehicleTransitionTrace(out vector HitLocation, out vector HitNormal, vector TraceEnd, optional vector TraceStart);

native function bool isHavokCompletelyInitialised();

replication
{
	reliable if (Role == ROLE_Authority)
		clientOccupantEnter, clientDriverLeave, minorPositionEntrySignals, driverWeapon, clientPositions, bInvincible, bHasBeenOccupied;

	reliable if (Role == ROLE_Authority && bNetInitial)
		spawning;
}

static simulated function PrecacheVehicleMeshes(LevelInfo Level, class<Vehicle> VehicleClass)
{
	// precache damage components
	PrecacheDamageComponents(Level, VehicleClass);

	// precache destruciton mesh
	class'DynamicObject'.Static.PrecacheDynamicObjectRenderData(Level, VehicleClass.default.destructionObjectClass);

	// precache main mesh
	Level.AddPrecacheMesh(VehicleClass.default.Mesh);
}

simulated function UpdatePrecacheRenderData()
{
	Super.UpdatePrecacheRenderData();
	PrecacheVehicleMeshes(Level, Class);
}

simulated native function byte getLowByte(int angle);

simulated native function byte getHighByte(int angle);

simulated native function int getAngle(byte lowByte, byte highByte);

// Spawns a character within this vehicle. Should be called immediately after usual respawn processing.
function spawnCharacter(Character character)
{
	character.bSpawningAtVehicle = true;
}

simulated function IFiringMotor firingMotor()
{
	return self;
}

// a way to access getViewRotation from native code (it would be quite tricky to do this through the firingMotor)
simulated event Rotator getViewRotationFromMotor()
{
	return getViewRotation();
}

// Returns the character (if it exists) that is controlling this rook (i.e. turret or vehicle)
simulated function Character getControllingCharacter()
{
	if ( positions.length > 0 )
		return positions[driverIndex].occupant;
	else
		return None;
}

function processInput();

function float getTeamDamagePercentage()
{
	// vehicles ignore the team damage concept
	return 0;
}

function enableAbandonmentDestruction(float periodSeconds)
{
	abandonmentDestruction = true;
	abandonmentDestructionPeriod = periodSeconds;
}

simulated function setSkin(Material skin)
{
	skins[0] = skin;
}

function bool needToPushStateToClient()
{
	return true;
}

function pushStateToClient();

simulated function applyOutput();

function getOut(VehiclePositionType type)
{
	local int index;

	// indicate in positions array that occupant wants to get out
	index = getPositionIndex(type);
	positions[index].wantsToGetOut = true;
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	// vehicles ignore 'face rotation'
}

function initVehicleAI()
{
	local Tyrion_ResourceBase r;
	local int i;

	r = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_VehicleResource", class'Class'));
	vehicleAI = r; 
	r.setResourceOwner( self );

	for ( i = 0; i < goals.length; i++ )
	{
		r.assignGoal( goals[i] );
	}

	for ( i = 0; i < abilities.length; i++ )
	{
		r.assignAbility( abilities[i] );
	}
}

function initDriverAI( int index )
{
	local Tyrion_ResourceBase r;
	local int i;

	r = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_DriverResource", class'Class'));
	positions[index].toBePossessed.mountAI = r; 
	r.setResourceOwner( self );
	r.setIndex( index );

	for ( i = 0; i < goals.length; i++ )
	{
		r.assignGoal( goals[i] );
	}

	for ( i = 0; i < abilities.length; i++ )
	{
		r.assignAbility( abilities[i] );
	}
}

function initGunnerAI( int index )
{
	local Tyrion_ResourceBase r;
	local int i;

	// vision systems for the gunner
	positions[index].toBePossessed.CreateVisionNotifier();

	r = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_GunnerResource", class'Class'));
	positions[index].toBePossessed.mountAI = r; 
	r.setResourceOwner( self );
	r.setIndex( index );

	for ( i = 0; i < goals.length; i++ )
	{
		r.assignGoal( goals[i] );
	}

	for ( i = 0; i < abilities.length; i++ )
	{
		r.assignAbility( abilities[i] );
	}

	copyVehicleAIValuesToTurret( positions[index].toBePossessed );
}

// cleanup AI when vehicle dead
event bool cleanupAI()
{
	local int i;

	if ( super.cleanupAI() )
		return true;

	if ( vehicleAI != None )	// (can be None if vehicle is deleted before PostNetBeginPlay is called)
		vehicleAI.cleanup();
	for ( i = 0; i < positions.length; ++i )
		if ( positions[i].toBePossessed != None && positions[i].toBePossessed.mountAI != None )
			positions[i].toBePossessed.mountAI.cleanup();

	if ( vehicleAI != None )
		vehicleAI.deleteSensors();
	for ( i = 0; i < positions.length; ++i )
		if ( positions[i].toBePossessed != None && positions[i].toBePossessed.mountAI != None )
			positions[i].toBePossessed.mountAI.deleteSensors();
 
	if ( vehicleAI != None )
		vehicleAI.deleteRemovedActions();
	for ( i = 0; i < positions.length; ++i )
		if ( positions[i].toBePossessed != None && positions[i].toBePossessed.mountAI != None )
			positions[i].toBePossessed.mountAI.deleteRemovedActions();

	return false;
}

// Cause all resources attached to this pawn to re-check their goals
function rematchGoals()
{
	local int i;

	if ( vehicleAI != None )	// (can be None if vehicle is deleted before PostNetBeginPlay is called)
		vehicleAI.bMatchGoals = true;
	for ( i = 0; i < positions.length; ++i )
		if ( positions[i].toBePossessed != None )
			positions[i].toBePossessed.mountAI.bMatchGoals = true;
}

// set pertinent AI values on the vehicleMountedTurret
function copyVehicleAIValuesToTurret( Rook turret )
{
	turret.AI_LOD_ActivationDistance = AI_LOD_ActivationDistance;
	turret.AI_LOD_DeactivationDistance = AI_LOD_DeactivationDistance;
	turret.SightRadius = SightRadius;
	turret.shotAngularDeviation = shotAngularDeviation;
	turret.shotLeadAbility = shotLeadAbility;
	turret.reactionDelay = reactionDelay;
}

// generate "AllyKilled" speech events for vehicle occupants
function generateAIDeathSpeechEvents( int deadIndex )
{
	local int index;
	local String extraTag;
	local BaseAICharacter ai;

	if ( deadIndex == driverIndex )
		extraTag = "Pilot";
	else
		extraTag = "Gunner";

	for (index = 0; index < positions.length; ++index)
	{
		ai = BaseAICharacter( positions[index].occupant );
		if ( class'Pawn'.static.checkAlive( ai ) )	// (also checks for non-None)
		{
			level.speechmanager.PlayDynamicSpeech( ai, 'AllyKilled', None, self, extraTag );
			break;
		}
	}
}

simulated function updateTeamSkin()
{
	local Material teamSkin;

	// only change skin if we have none set... is this correct logic?
	if (skins.Length == 0 || skins[0] == None)
	{
		teamSkin = getTeamSkin(); // getTeamSkin overriden by derived classes
		if (teamSkin != None)
			setSkin(teamSkin);
	}	
}

// vehicles ovveride this to return their particular team skin
simulated function Material getTeamSkin()
{
	return None;
}

simulated function setTeam(TeamInfo newTeam)
{
	local int i;

	super.setTeam(newTeam);

	for ( i = 0; i < positions.length; ++i )
		if ( positions[i].toBePossessed != None && positions[i].toBePossessed != self )
			positions[i].toBePossessed.setTeam(newTeam);

	updateTeamSkin();
}

event bool EncroachingOn(Actor other)
{
	// do not encroach vehicle spawn points
	if (VehicleSpawnPoint(other) != None)
		return false;

	return Super.EncroachingOn(other);
}

simulated function PostBeginPlay()
{
	local int index;
	local coords connection;

	super.PostBeginPlay();

	assert(positions.length <= MAXIMUM_NUMBER_POSITIONS);

	// steering is straight ahead initially
	RotationInput = Rotation;

	// apply initial invincibility
	if (Role == ROLE_Authority)
	{
		bInvincible = true;
		loseInitialInvincibilityTime = Level.TimeSeconds + initialInvincibilityDuration;
	}

	// Update occupant relative location and position (perhaps would be more robust to do in native as it is easier to get relative
	// location and relative rotation of socket.
	for (index = 0; index < positions.length; ++index)
	{
		connection = GetBoneCoords(positions[index].occupantConnection, true);
		positions[index].occupantRelativeLocation = connection.origin - Location;
		positions[index].occupantRelativeLocation = positions[index].occupantRelativeLocation << Rotation;
		positions[index].occupantRelativeRotation = OrthoRotation(connection.xAxis, connection.yAxis, connection.zAxis) - Rotation;
	}
}

function PostLoadGame()
{
	local int i;

	super.PostLoadGame();

	for (i = 0; i < positions.Length; ++i)
	{
		if (positions[i].occupant != None)
			occupantEnterAnimationProcessing(i);
	}
}

simulated function initialiseEffects()
{
	addEffect('throttleForward', false, throttleForwardEffectIndex);
	addEffect('throttleBack', false, throttleBackEffectIndex);
	addEffect('strafeLeft', false, strafeLeftEffectIndex);
	addEffect('strafeRight', false, strafeRightEffectIndex);
	addEffect('EngineIdling', false, engineIdlingEffectIndex);
	addEffect('Thrusting', false, thrustingEffectIndex);
	addEffect('ThrottleForwardOrThrust', false, throttleForwardOrThrustEffectIndex);
	addEffect('StrafeLeftOrThrust', false, strafeLeftOrThrustEffectIndex);
	addEffect('StrafeRightOrThrust', false, strafeRightOrThrustEffectIndex);
}

simulated function addEffect(name effectName, bool dynamicUpdate, out int effectIndex)
{
	effectIndex = effects.length;
	effects.length = effects.length + 1;
	effects[effectIndex].effectName = effectName;
	effects[effectIndex].flag = false;
	if (dynamicUpdate)
		effects[effectIndex].observer = new class'VehicleEffectObserver'();
}

simulated function vector getVehicleUseablePoint(int pointI)
{
	return vehicleEntries[pointI].GetUseablePoint();
}

simulated event PostNetBeginPlay()
{
	local int entryI;
	local int flipTriggerI;
	local vector xAxis;
	local vector yAxis;
	local vector zAxis;
	local int index;

	if (spawning)
	{
		assert(physics == PHYS_None);
		SetPhysics(PHYS_Havok);
		SetPhysics(PHYS_None);
	}

	// vision for the driver
	CreateVisionNotifier();

	// initialise driver position index
	driverIndex = getPositionIndex(VP_DRIVER);

	// initialise driver position
	positions[driverIndex].toBePossessed = self;

	Super.PostNetBeginPlay();

	// apply health modifier
	healthMaximum *= healthModifier;
	health = healthMaximum;

	// initialise vehicle effects
	effects.length = 0;
	if (Level.NetMode != NM_DedicatedServer)
		initialiseEffects();

	motor = new motorClass(self);

	GetAxes(rotation, xAxis, yAxis, zAxis);

	// spawn driver weapon
	if (Level.NetMode != NM_Client)
	{
		if (driverWeaponClass != None)
		{
			driverWeapon = Spawn(driverWeaponClass, self, , location);
			driverWeapon.setOwner(self);

			// initialise weapon
			driverWeapon.equip();
			driverWeapon.gotostate('Idle');
		}
	}

	// spawn vehicle entries client and server side, only reason they are on the client is for HUD prompts
	vehicleEntries.length = entries.length;
	for (entryI = 0; entryI < entries.length; ++entryI)
	{
		if(entries[entryI].entryClass == None)
			entries[entryI].entryClass = class'VehicleEntry';
		vehicleEntries[entryI] = spawn(entries[entryI].entryClass, self, , location +
				entries[entryI].offset.X * xAxis + entries[entryI].offset.Y * yAxis + entries[entryI].offset.Z * zAxis);
		vehicleEntries[entryI].setBase(self);
		vehicleEntries[entryI].setCollision(true, false, false);
		vehicleEntries[entryI].setCollisionSize(entries[entryI].radius, entries[entryI].height);
		vehicleEntries[entryI].secondaryPositions = entries[entryI].secondaryPositions;
		vehicleEntries[entryI].initialiseVehicleEntry(entries[entryI].primaryPosition, self);

		// Update useable points array
		UseablePoints[entryI] = vehicleEntries[entryI].GetUseablePoint();
		UseablePointsValid[entryI] = UP_Valid;
	}
	
	// create flip triggers
	if (Level.NetMode != NM_Client)
	{
		vehicleFlipTriggers.length = flipTriggers.length;
		for (flipTriggerI = 0; flipTriggerI < flipTriggers.length; ++flipTriggerI)
		{
			vehicleFlipTriggers[flipTriggerI] = spawn(class'VehicleFlipTrigger', self, , location + flipTriggers[flipTriggerI].offset.X *
					xAxis + flipTriggers[flipTriggerI].offset.Y * yAxis + flipTriggers[flipTriggerI].offset.Z * zAxis);
			vehicleFlipTriggers[flipTriggerI].promptIndex = FLIP_PROMPT_INDEX;
			vehicleFlipTriggers[flipTriggerI].ownerVehicle = self;
			vehicleFlipTriggers[flipTriggerI].setBase(self);
			vehicleFlipTriggers[flipTriggerI].setCollision(true, false, false);
			vehicleFlipTriggers[flipTriggerI].setCollisionSize(flipTriggers[flipTriggerI].radius, flipTriggers[flipTriggerI].height);

			// Update useable points array
			UseablePoints[entries.Length + flipTriggerI] = vehicleFlipTriggers[flipTriggerI].GetUseablePoint();
			UseablePointsValid[entries.Length + flipTriggerI] = UP_Unused;
		}
	}

	// do other client processing for unoccupied positions
	for (index = 0; index < positions.length; ++index)
	{
		if (clientPositions[index].occupant == None)
		{
			// play unoccupied animation
			if (positions[index].exitAnimation != 'None')
			{
				PlayAnim(positions[index].exitAnimation);
				animationFinishThenLoop[index] = positions[index].unoccupiedAnimation;
			}
		}
		else
		{
			// play occupied animation
			if (positions[index].enterAnimation != 'None')
			{
				PlayAnim(positions[index].enterAnimation);
				animationFinishThenLoop[index] = positions[index].occupiedAnimation;
			}
		}
	}

	// init AI
	initVehicleAI();
	initDriverAI( driverIndex );

	// make sure client skin is updated
	updateTeamSkin();
}

simulated function postNetReceive()
{
	local int index;
	local Character oldOccupant;

	super.postNetReceive();

	// check for minor position entry
	for (index = 0; index < NUMBER_MINOR_ENTRY_SIGNALS; ++index)
	{
		if (minorPositionEntrySignals[index].newData)
		{
			// ideally should not be recieved at all if not character net owner
			if (minorPositionEntrySignals[index].occupant.bNetOwner)
				clientOccupantEnter(minorPositionEntrySignals[index]);
			minorPositionEntrySignals[index].newData = false;
		}
	}

	// check for team change
	if (localTeam != m_team)
	{
		localTeam = m_team;
		updateTeamSkin();
	}

	// check for occupant changes

	// ... leaving
	for (index = 0; index < positions.length; ++index)
	{
		if (clientPositions[index] != localClientPositions[index] && clientPositions[index].occupant == None)
		{
			oldOccupant = localClientPositions[index].occupant;
			localClientPositions[index] = clientPositions[index];
			otherClientOccupantLeave(index, oldOccupant);
		}
	}

	// ... entering
	for (index = 0; index < positions.length; ++index)
	{
		if (clientPositions[index] != localClientPositions[index] && clientPositions[index].occupant != None)
		{
			localClientPositions[index] = clientPositions[index];
			otherClientOccupantEnter(index);
		}
	}
}

function bool InGodMode()
{
	return bGodMode || Super.InGodMode();
}

function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation,  Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	local class<ProjectileDamageType> pdt;
	local int positionI;
	local Controller killer;
	local Rook killerRook;
	local ModeInfo mode;
	local Rook instigatedRook;

	instigatedRook = Rook(instigatedBy);

	// catch case we have been torn off and this is called
	if (Level.NetMode == NM_Client)
		return;

	// disable invincibility if attacked by our own team
	if (instigatedRook != None && instigatedRook.team() == team())
		bInvincible = false;

	// do nothing if in god mode or invincible
	if (InGodMode() || bInvincible)
		return;

	pdt = class<ProjectileDamageType>(damageType);

	if (pdt != None)
		Damage *= pdt.default.vehicleDamageModifier;

	// avoid damage healing the car
	if (Damage < 0)
		return;

	// vehicle is dead
	if ((Health - Damage) <= 0)
	{
		aboutToDie();

		// have all occupants leave
		for (positionI = 0; positionI < positions.length; ++positionI)
		{
			if (positions[positionI].occupant != None)
				driverLeave(true, positionI);
		}

		// Notify mode for stat-tracking purposes
		mode = ModeInfo(Level.Game);
		if (mode != None)
		{
			mode.OnVehicleDestroyed(instigatedBy, self, damageType);
		}

		// Remove dead vehicle's from other AI's VisionNotifier's
		// (maybe to be consistent with Pawn's postTakeDamage function we should call Died() here)
		Level.Game.NotifyKilled(instigatedBy.Controller, Controller, self);

		// emit death message
		if (instigatedBy != None)
			killer = instigatedBy.GetKillerController();
		if (killer!= None && Killer.Pawn != None)
		{
			killerRook = Rook(Killer.Pawn);
			if (killerRook != None)
				dispatchMessage(new class'MessageDeath'(killerRook.getKillerLabel(), label, killer.Pawn.PlayerReplicationInfo, None));
			else
				dispatchMessage(new class'MessageDeath'(killer.Pawn.label, label, killer.Pawn.PlayerReplicationInfo, None));
		}
		else
			dispatchMessage(new class'MessageDeath'(self.label, label, None, None));

		TriggerEffectEvent('VehicleDestroyed');
	}

	Super.PostTakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType, projectileFactor);
}

function aboutToDie()
{

}

// Vehicles do not get telefragged.
event EncroachedBy( actor Other )
{
	Log("Vehicle("$self$") Encroached By: "$Other$".");
}

// You got some new info from the server (VehicleState has some new info).
simulated event VehicleStateReceived()
{
	// make sure we are in PHYS_Havok
	if (physics != PHYS_Havok)
		setPhysics(PHYS_Havok);

	HavokActivate();

	lastStateReceiveTime = Level.TimeSeconds;
}

// Called when a parameter of the overall articulated actor has changed (like PostEditChange).
simulated event VehicleUpdateParams()
{

}

simulated function vehicleFire()
{
	if (driverWeapon == None)
		return;

	fire(false);
}

simulated function fire(optional bool fireOnce)
{
	driverWeapon.fire(fireOnce);
}

function altFire(optional bool fireOnce)
{

}

function releaseFire()
{

}

function releaseAltFire()
{

}

function bool shouldFire(Equippable e)
{
	return false;
}

function setFirePressed(Equippable e, bool pressed)
{
}

simulated function vehicleCeaseFire()
{
	if (driverWeapon == None)
		return;

	driverWeapon.releaseFire();
}

function int getOccupantPositionIndex(Character occupant)
{
	local int positionI;
	for (positionI = 0; positionI < positions.length; ++positionI)
		if (positions[positionI].occupant == occupant)
			return positionI;
	return -1;
}

// Convenience function that simply forwards an attempt to occupy the driver position.
function bool tryToDrive(Character character)
{
	local array<VehiclePositionType> secondaryPositions;
	return tryToOccupy(character, VP_DRIVER, secondaryPositions) >= 0;
}

simulated function bool canArmourBeDriver(class<Armor> armour)
{
	local int index;
	if (armour == None)
		return false;
	for (index = 0; index < armour.default.allowedDriver.length; ++index)
		if (armour.default.allowedDriver[index] == class)
			return true;
	return false;
}

simulated function bool canArmourBePassenger(class<Armor> armour)
{
	local int index;
	for (index = 0; index < armour.default.allowedPassenger.length; ++index)
		if (armour.default.allowedPassenger[index] == class)
			return true;
	return false;
}

// If this function cannot find an available position it shall simply return -1.
simulated function int getAvailablePositionIndex(int positionIndex, array<VehiclePositionType> secondaryPositions, Character character)
{
	local int index;
	local int temporary;
	if (clientPositions[positionIndex].occupant != None || !canArmorOccupy(positions[positionIndex].type, character))
	{
		for (index = 0; index < secondaryPositions.length; ++index)
		{
			temporary = getPositionIndex(secondaryPositions[index]);
			if (clientPositions[temporary].occupant == None && (character == None || canArmorOccupy(secondaryPositions[index], character)))
			{
				return temporary;
			}
		}
		return -1;
	}
	return positionIndex;
}

simulated function bool isOccupant(Character character)
{
	local int index;
	for (index = 0; index < positions.length; ++index)
	{
		if (clientPositions[index].occupant == character)
			return true;
	}
	return false;
}

// Returns true if the armour of the specified character can occupy the specified position. 
simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}
	else if (position == VP_DRIVER)
		return canArmourBeDriver(character.armorClass);
	else
		return canArmourBePassenger(character.armorClass);
}

function int canOccupy(Character character, VehiclePositionType position, array<VehiclePositionType> secondaryPositions,
		out byte promptIndex)
{
	local int positionIndex;
	local TeamInfo workTeam;
	local int targetPositionIndex;

	promptIndex = 255;

	if (spawning)
		return -1;

	if (character.Controller == None)
		return -1;

	// cannot enter flipped vehicle
	if (bSettledUpsideDown)
		return -1;

	positionIndex = getPositionIndex(position);

	// ignore if the occupant team of this vehicle is not the same as the character
	workTeam = getOccupantTeam();
	if (workTeam != None && workTeam != character.team())
	{
		promptIndex = ENEMY_OCCUPIED_VEHICLE_PROMPT_INDEX;
		return -1;
	}

	// handle case vehicle is attempted to be stolen
	if (!bCanBeStolen && !bHasBeenOccupied && character.team() != team())
	{
		promptIndex = CANNOT_STEAL_VEHICLE_PROMPT_INDEX;
		return -1;
	}

	if (isOccupant(character))
		return -1;

	// handle case character is carrying an object that prevents vehicle entry
	if (character.numDroppableCarryables() > 0 && !character.carryableReference.bCanBringIntoVehicle)
	{
		promptIndex = VEHICLE_PROHIBITED_OBJECT_PROMPT_INDEX;
		return -1;
	}

	// attempt to access a secondary position if primary is occupied
	targetPositionIndex = getAvailablePositionIndex(positionIndex, secondaryPositions, character);

	if (targetPositionIndex == -1)
	{
		promptIndex = FULL_VEHICLE_PROMPT_INDEX;

		// assume if attempting to access pilot position and armour cannot occupy we are a heavy
		if (positionIndex == driverIndex && positions[positionIndex].occupant == None &&
				!canArmorOccupy(positions[positionIndex].type, character))
			promptIndex = HEAVY_ATTEMPT_TO_PILOT;

		return -1;
	}

	// ignore if attempting to enter an inventory station position and not on vehicles team
	if (isInventoryPosition(positions[targetPositionIndex].type) && (character.team() != team()))
	{
		promptIndex = ENEMY_INVENTORY_STATION_PROMPT_INDEX;
		return -1;
	}

	// confirm possession target is initialised
	if (isMajorPosition(positions[targetPositionIndex].type) && (positions[targetPositionIndex].toBePossessed == None))
	{
		warn("possession target is none");
		return -1;
	}

	promptIndex = getPositionPromptIndex(positions[targetPositionIndex].type);

	// assume if attempting to access pilot position and armour cannot occupy we are a heavy
	if (positionIndex == driverIndex && !canArmorOccupy(positions[positionIndex].type, character))
		promptIndex = HEAVY_ATTEMPT_TO_PILOT;

	return targetPositionIndex;
}

simulated function bool isInventoryPosition(VehiclePositionType positionType)
{
	return positionType == VP_INVENTORY_STATION_ONE || positionType == VP_INVENTORY_STATION_TWO ||
			positionType == VP_INVENTORY_STATION_THREE || positionType == VP_INVENTORY_STATION_FOUR;
}

// A Character has tried to occupy this vehicle.
// Returns the positionIndex if the character successfully occupied this vehicle or -1 if not.
function int tryToOccupy(Character character, VehiclePositionType position, array<VehiclePositionType> secondaryPositions)
{
	local int targetPositionIndex;
	local byte dummy;

	targetPositionIndex = canOccupy(character, position, secondaryPositions, dummy);

	if (targetPositionIndex == -1)
		return -1;

    if (
			// player case
			(character.Controller.bIsPlayer && !character.Controller.IsInState('PlayerDriving') && character.IsHumanControlled())
			||
			// ai case
			(!character.IsHumanControlled())
			)
	{        
		occupantEnter(character, targetPositionIndex);
		return targetPositionIndex;
	}
	else
	{
		return -1;
	}
}

// returns true if the vehicle can target the location given its view constraints;
// this function should return true if it's possible to target this point, not if it can currently be targetted
// (individual vehicles should override this function based on their weapon)
function bool canTargetPoint(Vector targetLoc)
{
	return true;
}

// wrapper funtion to call aimClass.static.aimlocation from native code
event Vector getAimLocation( Pawn target )
{
	return driverWeapon.aimClass.static.getAimLocation( driverWeapon, target );
}

// Returns the team of this vehicle's occupant(s). If there are no occupants it returns None.
simulated function TeamInfo getOccupantTeam()
{
	local int positionI;
	for (positionI = 0; positionI < positions.length; ++positionI)
	{
		if (clientPositions[positionI].occupant != None)
			return clientPositions[positionI].occupant.team();
	}
	return None;
}

simulated function Character getDriver()
{
	return positions[driverIndex].occupant;
}

// Returns index into positions array corresponding to a particular position type.
simulated function int getPositionIndex(VehiclePositionType position)
{
	local int index;

	for (index = 0; index < positions.length; ++index)
	{
		if (positions[index].type == position)
			return index;
	}

	log("WARNING: vehicle position not found");

	return 0;
}

// Events called on driver entering/leaving vehicle.

// Places an occupant within this vehicle.
simulated function clientOccupantEnter(ClientOccupantEnterData data)
{
	local PlayerController pc;

	// store the driver
	positions[data.positionIndex].occupant = data.occupant;

	// ... update client position data immediately
	clientPositions[data.positionIndex].occupant = data.occupant;
	if (localClientPositions[data.positionIndex].occupant != data.occupant)
	{
		localClientPositions[data.positionIndex].occupant = data.occupant;
		otherClientOccupantEnter(data.positionIndex);
	}

	if (Role < ROLE_Authority)
		attachToVehicle(data.positionIndex);

	// prevent weapons from firing after we leave
	if (clientPositions[data.positionIndex].occupant.motor != None)
		clientPositions[data.positionIndex].occupant.motor.bFirePressed = false;

	// do player major position specific processing
	pc = PlayerController(data.controller);
	if (pc != None && isMajorPosition(positions[data.positionIndex].type))
	{
		pc.GotoState(positions[data.positionIndex].occupantControllerState);

		if (positions[data.positionIndex].thirdPersonCamera)
			pc.bBehindView = true;
		else
			pc.bBehindView = false;

		pc.bFixedCamera = false;
		pc.bFreeCamera = true;

		pc.SetRotation(Rotation);
	}
}

simulated function bool isMajorPosition(VehiclePositionType type)
{
	return (type == VP_DRIVER) || (type == VP_GUNNER) || (type == VP_LEFT_GUNNER) || (type == VP_RIGHT_GUNNER);
}

simulated function bool canBeRepairedBy(Rook otherGuy)
{
	local TeamInfo tiThisGuy;
	local TeamInfo tiOtherGuy;

	if (otherGuy == None)
		return true;

	// use last occupant team if available
	if (lastOccupantTeam != None)
		tiThisGuy = lastOccupantTeam;
	else
		tiThisGuy = team();

	tiOtherGuy = otherGuy.getControllingCharacterTeam();

	if (tiThisGuy == None || tiOtherGuy == None)
		return true;

	return tiThisGuy.isFriendly( tiOtherGuy );
}

function occupantEnter(Character p, int positionIndex)
{
	local PlayerController pc;
	local Controller c;
	local ClientOccupantEnterData data;
	local int minorPositionEntryIndex;

	if (isOccupant(p))
	{
		warn(p @ "cannot enter" @ self @ "because they are already an occupant");
		return;
	}

	bHasBeenOccupied = true;

	// store occupant
	positions[positionIndex].occupant = p;
	clientPositions[positionIndex].occupant = p;

	if (positions[positionIndex].hideOccupant)
		positions[positionIndex].occupant.setDrawType(DT_None);

	attachToVehicle(positionIndex);

	c = p.Controller;

	pc = PlayerController(c);

	// do major position specific processing
	if (positions[positionIndex].toBePossessed != None)
	{
		// disconnect PlayerController from occupant and connect to
		c.Unpossess();
		positions[positionIndex].occupant.SetOwner(c); // keeps the driver relevant
		c.Possess(positions[positionIndex].toBePossessed);

		// save the occupant's current weapon, and holster it
		if (positions[positionIndex].occupant.weapon != None)
		{
			positions[positionIndex].oldOccupantWeapon = positions[positionIndex].occupant.weapon;
			positions[positionIndex].oldOccupantWeapon.bHidden = true;
		}
		positions[positionIndex].occupant.motor.setWeapon(None);

		// player specific processing
		if (pc != None)
		{
			// set playercontroller to view the vehicle
			pc.ClientSetViewTarget(positions[positionIndex].toBePossessed);

			// change controller state to driver
			pc.GotoState(positions[positionIndex].occupantControllerState);

			// get rid of AI inaccuracy
			if ( positions[positionIndex].toBePossessed.firingMotor() != None )
				positions[positionIndex].toBePossessed.firingMotor().getWeapon().AISpread = Rot(0.0, 0.0, 0.0);
		}
	}

	// update character flag
	if (positions[positionIndex].hideOccupant)
		positions[positionIndex].occupant.bHiddenVehicleOccupant = true;

	// scripting message
	if (positionIndex == driverIndex)
		dispatchMessage(new class'MessageDriverEnter'(label, p.label));
	else
		dispatchMessage(new class'MessageGunnerEnter'(label, p.label));

	// signal to client that driver has entered
	data.controller = c;
	data.occupant = positions[positionIndex].occupant;
	data.positionIndex = positionIndex;
	if (positions[positionIndex].toBePossessed == self)
	{
		clientOccupantEnter(data);
	}
	else if (VehicleMountedTurret(positions[positionIndex].toBePossessed) != None)
	{
		// go through VehicleMountedTurret because otherwise the function is not replicated, call will
		// simply be forwarded to the vehicle on the client side
		VehicleMountedTurret(positions[positionIndex].toBePossessed).clientOccupantEnter(pc,
				positions[positionIndex].occupant, positionIndex);
	}
	else
	{
		// use variable replication to signal a client has entered a minor position
		minorPositionEntryIndex = getMinorPositionEntryIndex(data.positionIndex);
		if (minorPositionEntryIndex != -1)
		{
			minorPositionEntrySignals[minorPositionEntryIndex].controller = data.controller;
			minorPositionEntrySignals[minorPositionEntryIndex].occupant = data.occupant;
			minorPositionEntrySignals[minorPositionEntryIndex].positionIndex = data.positionIndex;
			minorPositionEntrySignals[minorPositionEntryIndex].newData = true;
			minorPositionEntrySignals[minorPositionEntryIndex].flipFlop = !minorPositionEntrySignals[minorPositionEntryIndex].flipFlop;
		}
	}

	occupantEnterAnimationProcessing(positionIndex);

	otherClientOccupantEnter(positionIndex);
}

// Does any necessary animation processing for a client in a particular position.
function occupantEnterAnimationProcessing(int positionIndex)
{
	if (!positions[positionIndex].hideOccupant)
	{
		positions[positionIndex].occupant.enterManualAnimationState();
		positions[positionIndex].occupant.LoopAnim(positions[positionIndex].occupantAnimation);
	}
}

// Called on all machines when an occupant enters this vehicle.
simulated function otherClientOccupantEnter(int positionI)
{
	bHasBeenOccupied = true;

	// kill all movement effects
	clientPositions[positionI].occupant.stopMovementEffects();

	// update last occupant team
	lastOccupantTeam = clientPositions[positionI].occupant.team();

	// animation
	if (positions[positionI].enterAnimation != 'None')
	{
		PlayAnim(positions[positionI].enterAnimation);
		animationFinishThenLoop[positionI] = positions[positionI].occupiedAnimation;
	}

	// driver enter effect
	if (positionI == driverIndex)
		TriggerEffectEvent('DriverEntered');

	clientPositions[positionI].occupant.hideJetpack();

	// turn off shadow
	if (clientPositions[positionI].occupant.Shadow != None)
		clientPositions[positionI].occupant.Shadow.bShadowActive = false;
}

function occupantLeaveAnimationProcessing(int positionIndex)
{
	positions[positionIndex].occupant.exitManualAnimationState();
}

// Move the occupant into position, and attach to car. Occurs client and server side.
simulated function attachToVehicle(int positionIndex)
{
	// when moving out of fusion collision state is set back to what it was so must set physics to PHYS_None before updating collision
	positions[positionIndex].occupant.SetPhysics(PHYS_None);

	// collide actors needs to be so as the player will set off triggers and can be shot at
	positions[positionIndex].occupant.SetCollision(true, false, false);

	positions[positionIndex].occupant.bCollideWorld = false;
	positions[positionIndex].occupant.Velocity = vect(0,0,0);

	// When putting player in vehicle SetRelativeRotation at the end to get the hard attach matrix updated correctly.

	if (!positions[positionIndex].hideOccupant)
	{
		// put occupant in correct position
		positions[positionIndex].occupant.SetLocation(Location + (positions[positionIndex].occupantRelativeLocation >> Rotation));
		positions[positionIndex].occupant.SetRotation(rot(0, 0, 0));
	}
	else
		positions[positionIndex].occupant.SetLocation(Location);

	positions[positionIndex].occupant.SetPhysics(PHYS_None);

	positions[positionIndex].occupant.bHardAttach = true;
	positions[positionIndex].occupant.SetBase(None); 

	// needs to be called here because Driver.SetBase(None) may call SetPhysics(PHYS_Falling)
	positions[positionIndex].occupant.SetPhysics(PHYS_None);

	positions[positionIndex].occupant.SetBase(self);
	positions[positionIndex].occupant.SetPhysics(PHYS_None);

	if (!positions[positionIndex].hideOccupant)
	{
		positions[positionIndex].occupant.SetRelativeRotation(positions[positionIndex].occupantRelativeRotation);
		positions[positionIndex].occupant.SetRelativeLocation(positions[positionIndex].occupantRelativeLocation);
	}
}

simulated function clientDriverLeave(Controller c, Character oldDriver)
{
	local int workIndex;
	local PlayerController pc;

	pc = PlayerController(c);
	
	if (pc != None)
	{
		pc.bBehindView = false;
		pc.bFixedCamera = true;
		pc.bFreeCamera = false;
	}

	oldDriver.bOwnerNoSee = true;

	// turn off all effects
	for (workIndex = 0; workIndex < effects.length; ++workIndex)
	{
		if (effects[workIndex].flag)
		{
			//log("UnTriggerEffectEvent(" $ effects[workIndex].effectName $ ")");
			UnTriggerEffectEvent(effects[workIndex].effectName);
			effects[workIndex].flag = false;
		}
	}
}

// Called from when an occupant wants to get out.
function bool driverLeave(bool bForceLeave, int positionIndex)
{
	local Controller c;
	local PlayerController pc;
	local int exitI;
	local bool havePlaced;
	local vector HitLocation, HitNormal;
	local vector rootLocation;
	local Character oldOccupant;
	local int minorPositionEntryIndex;
	local vector exitLocation;

	// do nothing if we're not being driven
	if (positions[positionIndex].occupant == None)
		return false;

	positions[positionIndex].occupant.bSpawningAtVehicle = false;

	oldOccupant = positions[positionIndex].occupant;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.
	
	positions[positionIndex].occupant.bHardAttach = false;
	positions[positionIndex].occupant.bCollideWorld = true;
	positions[positionIndex].occupant.SetCollision(true, true, true);
	
	havePlaced = false;
	rootLocation = GetBoneCoords(rootBone).origin;
	if (vehicleEntries.length == 0)
		warn("no entries thus no way to exit");

	// use exit points

	// ... firstly try to place at exit corresponding to position we are in
	for (exitI = 0; exitI < exits.length && !havePlaced; exitI++)
	{
		if (exits[exitI].position != positions[positionIndex].type)
			continue;

		exitLocation = Location + (exits[exitI].offset >> Rotation);

		// first, do a line check (stops us passing through things on exit)
		if (vehicleTransitionTrace(HitLocation, HitNormal, exitLocation, rootLocation) != None)
			continue;

		// then see if we can place the player there
		if (!positions[positionIndex].occupant.SetLocation(exitLocation))
			continue;

		havePlaced = true;
	}

	// ... secondly try to place at exit not corresponding to position we are in
	for (exitI = 0; exitI < exits.length && !havePlaced; exitI++)
	{
		if (exits[exitI].position == positions[positionIndex].type)
			continue;

		exitLocation = Location + (exits[exitI].offset >> Rotation);

		// first, do a line check (stops us passing through things on exit)
		if (vehicleTransitionTrace(HitLocation, HitNormal, exitLocation, rootLocation) != None)
			continue;

		// then see if we can place the player there
		if (!positions[positionIndex].occupant.SetLocation(exitLocation))
			continue;

		havePlaced = true;
	}

	// if we could not find a place to put the driver, leave driver inside as before
	if(!havePlaced && !bForceLeave)
	{
		Log("Could not place driver.");
	
		positions[positionIndex].occupant.bHardAttach = true;
		positions[positionIndex].occupant.bCollideWorld = false;
		positions[positionIndex].occupant.SetCollision(true, false, false);
	
		return false;
	}

	// scripting message
	if (positionIndex == driverIndex)
		dispatchMessage(new class'MessageDriverLeave'(label, positions[positionIndex].occupant.label));
	else
		dispatchMessage(new class'MessageGunnerLeave'(label, positions[positionIndex].occupant.label));

	// get controller
	if (positions[positionIndex].toBePossessed != None)
		c = positions[positionIndex].toBePossessed.Controller;
	else
		c = positions[positionIndex].occupant.controller;

	pc = PlayerController(c);

	// signal to client that occupant has left
	if (positions[positionIndex].toBePossessed == self)
	{
		clientDriverLeave(c, positions[positionIndex].occupant);
	}
	else if (VehicleMountedTurret(positions[positionIndex].toBePossessed) != None)
	{
		clientDriverLeave(c, positions[positionIndex].occupant);
	}
	else
	{
		clientDriverLeave(c, positions[positionIndex].occupant);

		// clear minor entry signal
		minorPositionEntryIndex = getMinorPositionEntryIndex(positionIndex);
		if (minorPositionEntryIndex != -1)
		{
			minorPositionEntrySignals[minorPositionEntryIndex].controller = None;
			minorPositionEntrySignals[minorPositionEntryIndex].occupant = None;
			minorPositionEntrySignals[minorPositionEntryIndex].newData = false;
			minorPositionEntrySignals[minorPositionEntryIndex].flipFlop = !minorPositionEntrySignals[minorPositionEntryIndex].flipFlop;
		}
	}

	// update character flag
	positions[positionIndex].occupant.bHiddenVehicleOccupant = false;

	// do major position specific processing
	if (positions[positionIndex].toBePossessed != None)
	{
		// reconnect PlayerController to Driver
		c.Unpossess();
		c.Possess(positions[positionIndex].occupant);

		// set playercontroller to view the person that got out
		if (pc != None)
			pc.ClientSetViewTarget(positions[positionIndex].occupant);

		positions[positionIndex].toBePossessed.controller = None;
	}

	positions[positionIndex].occupant.PlayWaiting();

    positions[positionIndex].occupant.Acceleration = vect(0, 0, 24000);

	// do not do this stuff if character is in ragdoll
	if (positions[positionIndex].occupant.isAlive())
	{
		positions[positionIndex].occupant.SetPhysics(PHYS_Movement);
		positions[positionIndex].occupant.SetBase(None);
		occupantLeaveAnimationProcessing(positionIndex);

		// restore the driver's weapon
		if (positions[positionIndex].oldOccupantWeapon != None)
		{
			positions[positionIndex].oldOccupantWeapon.bHidden = false;
			positions[positionIndex].occupant.motor.setWeapon(positions[positionIndex].oldOccupantWeapon);
			positions[positionIndex].oldOccupantWeapon = None;
		}
	}

	// inherit vehicle velocity on exit
	positions[positionIndex].occupant.unifiedSetVelocity(unifiedGetVelocity()*velocityInheritOnExitScale);

	// return to default draw type
	if (positions[positionIndex].occupant.DrawType != DT_Mesh)
		positions[positionIndex].occupant.setDrawType(DT_Mesh);

	// mark as unoccupied
	positions[positionIndex].occupant = None;
	clientPositions[positionIndex].occupant = None;

	// put brakes on before you get out
    ThrottleInput = 0;
    StrafeInput = 0;
	RotationInput = rot(0,0,0);
	ThrustInput = 0;
	DiveInput = false;

	otherClientOccupantLeave(positionIndex, oldOccupant);

    return true;
}

// Called on all machines when an occupant leaves this vehicle.
simulated function otherClientOccupantLeave(int positionI, Character oldOccupant)
{
	// animation
	if (positions[positionI].exitAnimation != 'None')
	{
		PlayAnim(positions[positionI].exitAnimation);
		animationFinishThenLoop[positionI] = positions[positionI].unoccupiedAnimation;
	}

	if (oldOccupant != None)
		oldOccupant.showJetpack();

	// driver exit effect
	if (positionI == driverIndex)
		TriggerEffectEvent('DriverExited');

	// turn on shadow
	if (oldOccupant.Shadow != None)
		oldOccupant.Shadow.bShadowActive = true;
}

simulated function vector getCameraLookAt(rotator cameraRotation, int positionIndex)
{
	local rotator cameraWorkRotation;
	cameraWorkRotation = cameraRotation;
	cameraWorkRotation.Roll = 0;
	if (!positions[positionIndex].lookAtInheritPitch)
		cameraWorkRotation.Pitch = 0;
	return positions[positionIndex].toBePossessed.Location + (TPCameraLookat >> cameraWorkRotation);
}

simulated function bool specialCalcViewProcessing(out actor viewActor, out vector cameraLocation,
		out rotator cameraRotation, int positionIndex)
{
	local vector lookAt;
	local vector HitLocation, HitNormal, OffsetVector;
	local PlayerController pc;

	pc = PlayerController(positions[positionIndex].toBePossessed.Controller);

	// only do this mode we have a playercontroller viewing this vehicle
	if (pc == None || positions[positionIndex].toBePossessed == None || pc.ViewTarget != positions[positionIndex].toBePossessed)
		return false;

	// always third person

	ViewActor = positions[positionIndex].toBePossessed;

	lookAt = getCameraLookAt(cameraRotation, positionIndex);

	// calculate camera location
	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCameraDistance;
	CameraLocation = lookAt + (OffsetVector >> cameraRotation);

	// ... handle case of obstruction between vehicle and camera location
	if (cameraTrace(HitLocation, HitNormal, CameraLocation, Location, false, vect(10, 10, 10)) != None)
		CameraLocation = HitLocation;

	// ... handle case vehicle obstructs trace between camera look at and camera location
	if (bVehicleCameraTrace && !vehicleTrace(HitLocation, HitNormal, CameraLocation, lookAt, vehicleCameraTraceExtents))
		CameraLocation = HitLocation;

	if (bDrawDriverInTP)
		positions[positionIndex].occupant.bOwnerNoSee = false;
	else
		positions[positionIndex].occupant.bOwnerNoSee = true;

	return true;
}

// Special calc-view for vehicles.
simulated function bool specialCalcView(out actor viewActor, out vector cameraLocation, out rotator cameraRotation)
{
	local bool retVal;

	retVal = specialCalcViewProcessing(viewActor, cameraLocation, cameraRotation, driverIndex);
	cachedCameraLocation = cameraLocation;

	return retVal;
}

simulated function vector EyePosition()
{
	return cachedCameraLocation - Location;
}

simulated function Destroyed()
{
    local int workIndex;

	// turn off all effects and destroy observers
	for (workIndex = 0; workIndex < effects.length; ++workIndex)
	{
		// switch off
		if (effects[workIndex].flag)
		{
			UnTriggerEffectEvent(effects[workIndex].effectName);
			effects[workIndex].flag = false;
		}

		// destroy
		if (effects[workIndex].observer != None)
		{
			effects[workIndex].observer.cleanup();
			effects[workIndex].observer.delete();
			effects[workIndex].observer = None;
		}
	}

	// destroy entries
	for (workIndex = 0; workIndex < vehicleEntries.length; ++workIndex)
		vehicleEntries[workIndex].destroy();

	// destroy flip triggers
	for (workIndex = 0; workIndex < vehicleFlipTriggers.length; ++workIndex)
		vehicleFlipTriggers[workIndex].destroy();

	// destroy driver weapon
	if (driverWeapon != None)
		driverWeapon.destroy();

	if (motor != None)
		motor.destroy();

	Super.Destroyed();
}

simulated function bool isOccupied()
{
	local int index;
	for (index = 0; index < positions.length; ++index)
		if (clientPositions[index].occupant != None)
			return true;
	return false;
}

simulated event tick(float deltaSeconds)
{
	local bool gotOut;
	local int index;
	local int doNotEjectI;
	local bool doNotEject;
	local bool oldSettledUpsideDown;
	local bool vehicleIsOccupied;
	local name animationSequence;
	local float animationFrame;
	local float animationRate;

	vehicleIsOccupied = isOccupied();

	// kill ourselves if we are outside the boundary volume
	if ((Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer) && Level.game.boundaryVolume != None &&
			!Level.game.boundaryVolume.encompasses(self))
		TakeDamage(health + 1, None, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'DamageType');

	// stop firing driver weapon if no occupant
	if (driverWeapon != None && driverWeapon.IsInState('FirePressed') && Controller == None)
		driverWeapon.releaseFire();

	// initial invincibility processing
	if (Role == ROLE_Authority && bInvincible && Level.TimeSeconds > loseInitialInvincibilityTime)
		bInvincible = false;

	// handle case an occupant wants to get out
	if (vehicleIsOccupied && Level.NetMode != NM_Client)
	{
		for (index = 0; index < positions.length; ++index)
		{
			if (positions[index].wantsToGetOut)
			{
				gotOut = driverLeave(false, index);
				if (!gotOut )
				{
					Log("Couldn't Leave - staying in!");
				}
			}
			positions[index].wantsToGetOut = false;
		}
	}

	// boot occupants if settled upside down
	if (vehicleIsOccupied && Level.NetMode != NM_Client && bSettledUpsideDown)
	{
		for (index = 0; index < positions.length; ++index)
		{
			if (positions[index].occupant != None)
			{
				// check if this functionality has been overridden
				doNotEject = false;
				for (doNotEjectI = 0; doNotEjectI < doNotEjectOnFlip.length; ++doNotEjectI)
				{
					if (doNotEjectOnFlip[doNotEjectI] == positions[index].type)
					{
						doNotEject = true;
						break;
					}
				}
				if (doNotEject)
					continue;

				aboutToSettleUpsideDown();

				driverLeave(true, index);
			}
		}
	}

	// kick dead occupants (controller will possess dead character which appears to be OK)
	if (vehicleIsOccupied && Level.NetMode != NM_Client)
	{
		for (index = 0; index < positions.length; ++index)
		{
			if (positions[index].occupant != None && !positions[index].occupant.isAlive())
			{
				driverLeave(true, index);
				generateAIDeathSpeechEvents( index );
			}
		}
	}

	// vehicle effects processing
	if (Level.NetMode != NM_DedicatedServer)
	{
		updateEffectsStates();
		updateDynamicEffectStates();
	}

	// if server and not spawning process input and pack output for replication
	if (Level.NetMode != NM_Client && !spawning)
	{
		processInput();
		if ((Level.NetMode != NM_Standalone) && ((Level.TimeSeconds > maximumNextNetUpdateTime) || (HavokIsActive() &&
				needToPushStateToClient())))
		{
			maximumNextNetUpdateTime = Level.TimeSeconds + maximumNetUpdateInterval;
			pushStateToClient();
		}
	}

	applyOutput();

	// abandonment destruction functionality
	if (Level.NetMode != NM_Client && abandonmentDestruction)
	{
		if (!vehicleIsOccupied)
		{
			currentAbandonmentDuration += deltaSeconds;
			if (currentAbandonmentDuration > abandonmentDestructionPeriod)
				destroy();
		}
		else
			currentAbandonmentDuration = 0;
	}

	// always active if we have a driver
	if (clientPositions[driverIndex].occupant != None)
		HavokActivate(true);

	// do animation processing
	for (index = 0; index < animationFinishThenLoop.length; ++index)
	{
		if (animationFinishThenLoop[index] != 'None')
		{
			if (!IsAnimating(index))
			{
				LoopAnim(animationFinishThenLoop[index], 1, 0, index);
				animationFinishThenLoop[index] = 'None';
			}
		}
	}

	// settled upside down processing
	oldSettledUpsideDown = bSettledUpsideDown;
	bSettledUpsideDown = isSettledUpsideDown();
	if (oldSettledUpsideDown != bSettledUpsideDown && Level.NetMode != NM_Client)
		settledUpsideDownChanged();

	// check for client side tearoff
    if (bTearOff)
    {
        if ( !bPlayedDeath )
            PlayDying(HitDamageType, TakeHitLocation);
    }

	// AI debug display
	if ( bShowTyrionCharacterDebug || bShowSensingDebug )
		displayTyrionDebugHeader();
	if ( bShowSensingDebug )
		displayEnemiesList();
	if ( bShowTyrionCharacterDebug && vehicleAI != None )
	{
		vehicleAI.displayTyrionDebug();
		for ( index = 0; index < positions.length; ++index )
			if ( positions[index].toBePossessed != None)
				positions[index].toBePossessed.mountAI.displayTyrionDebug();
	}

	// verify all occupants are in correct position and playing correct animation
	if (vehicleIsOccupied)
	{
		for (index = 0; index < positions.length; ++index)
		{
			if (clientPositions[index].occupant != None)
			{
				// position
				if (clientPositions[index].occupant.relativeLocation != positions[index].occupantRelativeLocation)
					clientPositions[index].occupant.setRelativeLocation(positions[index].occupantRelativeLocation);
				if (clientPositions[index].occupant.relativeRotation != positions[index].occupantRelativeRotation)
					clientPositions[index].occupant.setRelativeRotation(positions[index].occupantRelativeRotation);

				// animation
				if (!positions[index].hideOccupant)
				{
					clientPositions[index].occupant.GetAnimParams(0, animationSequence, animationFrame, animationRate);
					if (animationSequence != positions[index].occupantAnimation)
						clientPositions[index].occupant.LoopAnim(positions[index].occupantAnimation);
				}
			}
		}
	}

	// water damage
	if (Level.NetMode != NM_Client && PhysicsVolume.bWaterVolume)
		takeDamage(waterDamagePerSecond * deltaSeconds, self, Location, vect(0,0,0), class'DamageType');

}

function aboutToSettleUpsideDown();

simulated function bool isSettledUpsideDown()
{
	local vector vehicleUp;
	vehicleUp = vect(0,0,1) >> rotation;
	return ((vehicleUp dot vect(0,0,1)) < settledUpsideDownCosAngle) && (VSizeSquared(velocity) < (settledUpsideDownSpeed *
			settledUpsideDownSpeed));
}

simulated event bool isUpright()
{
	local vector vehicleUp;
	vehicleUp = vect(0,0,1) >> rotation;
	return ((vehicleUp dot vect(0,0,1)) > inverseCosUprightAngle);
}

function useEnergy(float amount)
{

}

simulated function updateEffectsStates()
{
	local int workIndex;
	local bool effectUntriggered;

	for (workIndex = 0; workIndex < effects.length; ++workIndex)
	{
		if (effects[workIndex].flag && !isEffectCauserActive(workIndex))
		{
			//log("UnTrigger Effect: " $ effects[workIndex].effectName);
			UnTriggerEffectEvent(effects[workIndex].effectName);
			effects[workIndex].flag = false;
			effectUntriggered = true;
		}
	}
	for (workIndex = 0; workIndex < effects.length; ++workIndex)
	{
		if ((!effects[workIndex].flag || (effectUntriggered && retriggerEffectEvents)) && isEffectCauserActive(workIndex))
		{
			//log("Trigger Effect: " $ effects[workIndex].effectName);
			TriggerEffectEvent(effects[workIndex].effectName, , , , , , , effects[workIndex].observer);
			effects[workIndex].flag = true;
		}
	}
}

simulated function updateDynamicEffectStates();

// Reurns true if a particular effect within the 'effects' array should be active. Classes that overload this function should call
// super.isEffectCauserActive after doinf their own processing becuase Vehicle.isEffectCauserActive assumes nothing will be called after.
simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	switch (effectCauserIndex)
	{
	case throttleForwardEffectIndex:
		return ThrottleInput > 0;
	case throttleBackEffectIndex:
		return ThrottleInput < 0;
	case strafeLeftEffectIndex:
		return StrafeInput > 0;
	case strafeRightEffectIndex:
		return StrafeInput < 0;
	case engineIdlingEffectIndex:
		return clientPositions[driverIndex].occupant != None;
	case throttleForwardOrThrustEffectIndex:
		return ThrottleInput > 0 || ThrustInput > 0;
	case strafeLeftOrThrustEffectIndex:
		return StrafeInput > 0 || ThrustInput > 0;
	case strafeRightOrThrustEffectIndex:
		return StrafeInput < 0 || ThrustInput > 0;
	case thrustingEffectIndex:
		return ThrustInput > 0;
	}
	
	// if we are here effect was not handled
	warn("unknown effect causer index");
}

function toggleShowPhysicsDebug()
{
	bShowPhysicsDebug = !bShowPhysicsDebug;
	showPhysicsDebug(bShowPhysicsDebug);
}

function displayWorldSpaceDebug(HUD displayHUD)
{
	local int vehicleEntryI;
	local color workColor;
	local vector workVector;
	local int exitI;

	super.displayWorldSpaceDebug(displayHUD);

	// draw entry points
	workColor.R = 0;
	workColor.G = 255;
	workColor.B = 255;
	for (vehicleEntryI = 0; vehicleEntryI < vehicleEntries.length; ++vehicleEntryI)
	{
		displayHud.draw3DLine(vehicleEntries[vehicleEntryI].location, location, workColor);
		drawActorCollision(vehicleEntries[vehicleEntryI], displayHUD, workColor);
	}

	// draw exit points
	workColor.R = 255;
	workColor.G = 0;
	workColor.B = 0;
	for (exitI = 0; exitI < exits.length; ++exitI)
	{
		workVector = Location + (exits[exitI].offset >> Rotation);
		displayHud.draw3DLine(workVector, location, workColor);
		displayHud.draw3DLine(workVector - vect(0, 0, 30), workVector + vect(0, 0, 30), workColor);
	}

	motor.displayWorldSpaceDebug(displayHUD);

	workColor.R = 0;
	workColor.G = 0;
	workColor.B = 255;

	// destination
	if (!isHumanControlled())
	{
		displayHud.draw3DLine(location, localMoveDestination, workColor);	
	}

	workColor.R = 100;
	workColor.G = 100;
	workColor.B = 100;

	// rotation input
	workVector = vect(1,0,0) >> rotationInput;
	displayHud.draw3DLine(location, location + workVector * 500, workColor);
}

// Draws approximation of an actors collision cylinder.
function drawActorCollision(Actor actor, HUD displayHUD, Color color)
{
	local vector workVector;

	workVector.X = 0;
	workVector.Y = 0;
	workVector.Z = actor.collisionHeight;
	displayHud.draw3DLine(actor.location + workVector, actor.location - workVector, color);
	workVector.X = 0;
	workVector.Y = actor.collisionRadius;
	workVector.Z = 0;
	displayHud.draw3DLine(actor.location + workVector, actor.location - workVector, color);
	workVector.X = actor.collisionRadius;
	workVector.Y = 0;
	workVector.Z = 0;
	displayHud.draw3DLine(actor.location + workVector, actor.location - workVector, color);
}

function showPhysicsDebug(bool show);

function vector getProjectileSpawnLocation()
{
	// temporary
	return location;
}

function onShotFiredNotification()
{
	// ignore
}

function float getEnergy()
{
	return 1000;
}

function bool aimAdjustViewRotation()
{
	return false;
}

simulated function vector getFirstPersonEquippableLocation(Equippable subject)
{
	warn("not implemented");
	return location;
}

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart);

simulated function rotator getFirstPersonEquippableRotation(Equippable subject)
{
	warn("not implemented");
	return rotation;
}

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	warn("not implemented");
}

function Rook getPhysicalAttachment()
{
	return self;
}

function Weapon getWeapon()
{
	return driverWeapon;
}

simulated function Actor getEffectsBaseActor()
{
	return None;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local DynamicObject destructionObject;

	if (bPlayedDeath)
		return;

    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	// note: these are replicated if need be, but we dont use em (for the moment)
	//HitDamageType = DamageType;
    //TakeHitLocation = HitLoc;

	if (Level.NetMode != NM_DedicatedServer)
	{
		// destruciton clientside rigid body
		if (destructionObjectClass != None)
		{
			destructionObject = spawn(destructionObjectClass, , , Location, Rotation);
			if (destructionObject != None)
				destructionObject.NextVersion();
		}

		// effect event
		TriggerEffectEvent('Destroyed');
	}

	// destruction explosion client and server
	spawn(destroyedExplosionClass, , , Location, Rotation).Trigger(self, None);

	GotoState('Dying');
}

State Dying
{
	simulated function BeginState()
	{
		// added this function because the default calls setPhysics(PHYS_Falling)

		if (Controller != None)
			Controller.PawnDied(self);

		// NOTE: this 'technique' for deferred client fx copied straight from ut2k4
		// If server, wait a second for replication of bTearOff so that client will do playdying (c
		if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
			SetTimer(1.f, false);
		// otherwise destroy straight away
		else
			Destroy();
	}

	simulated function Timer()
	{
		if ( !bDeleteMe )
			Destroy();
	}
}

singular event BaseChange()
{
	// nothing
}

simulated event collisionDamage(float magnitude)
{
	if (bCollisionDamageEnabled && magnitude >= minimumCollisionDamageMagnitude)
	{
		// apply damage on the server
		if (ROLE == ROLE_Authority)
			TakeDamage(collisionDamageMagnitudeScale * magnitude, self, Location, vect(0,0,0), class'DamageType');
	}
}

simulated function playerMoveProcessing(float deltaTime)
{
	// nothing
}

function bool flip()
{
	if (bSettledUpsideDown && !bFlipping)
	{
		performFlip();
		return true;
	}
	else
	{
		return false;
	}
}

// If switch class is None the default class will be used.
simulated function switchClass(class<Vehicle> switchClass)
{
	currentSwitchClass = switchClass;
}

simulated function startedSpawnFromVehicleSpawnPoint()
{
	// disable collision damage
	if (ROLE == ROLE_Authority)
		bCollisionDamageEnabled = false;
}

simulated function finishedSpawnFromVehicleSpawnPoint()
{
	setPhysics(PHYS_Havok);

	if (ROLE == ROLE_Authority)
		bCollisionDamageEnabled = class.default.bCollisionDamageEnabled;

	TriggerEffectEvent('SpawnedFromSpawnPoint');
}

simulated function int getTargetPositionIndex(byte selectedPosition)
{
	return selectedPosition - 1;
}

function switchPosition(int currentPositionIndex, byte selectedPosition)
{
	local int targetPositionIndex;
	local Controller c;
	local PlayerController pc;
	local Character character;
	local ClientOccupantEnterData data;

	if (!canSwitchPosition(currentPositionIndex, selectedPosition))
		return;

	targetPositionIndex = getTargetPositionIndex(selectedPosition);

	// !!!!!!!!!! do not allow switching to minor positions
	if (positions[targetPositionIndex].toBePossessed == None)
		return;

	character = positions[currentPositionIndex].occupant;

	// get controller
	if (positions[currentPositionIndex].toBePossessed != None)
		c = positions[currentPositionIndex].toBePossessed.Controller;
	else
		c = positions[currentPositionIndex].occupant.controller;

	pc = PlayerController(c);

	// leave old position

	c.Unpossess();

	// ... do major position specific processing
	if (positions[currentPositionIndex].toBePossessed != None)
	{
		positions[currentPositionIndex].toBePossessed.controller = None;
	}

	otherClientOccupantLeave(currentPositionIndex, positions[currentPositionIndex].occupant);

	// ... mark as unoccupied
	positions[currentPositionIndex].occupant = None;
	clientPositions[currentPositionIndex].occupant = None;

	// enter new position

	// ... store occupant
	positions[targetPositionIndex].occupant = character;
	clientPositions[targetPositionIndex].occupant = character;

	if (positions[targetPositionIndex].hideOccupant)
	{
		if (positions[targetPositionIndex].occupant.drawType != DT_None)
			positions[targetPositionIndex].occupant.setDrawType(DT_None);
	}
	else
	{
		if (positions[targetPositionIndex].occupant.drawType != DT_Mesh)
			positions[targetPositionIndex].occupant.setDrawType(DT_Mesh);
	}

	attachToVehicle(targetPositionIndex);

	// ... do major position specific processing
	if (positions[targetPositionIndex].toBePossessed != None)
	{
		positions[targetPositionIndex].occupant.SetOwner(c); // keeps the driver relevant
		c.Possess(positions[targetPositionIndex].toBePossessed);

		// ... player specific processing
		if (pc != None)
		{
			// ... set playercontroller to view the vehicle
			pc.ClientSetViewTarget(positions[targetPositionIndex].toBePossessed);

			// ... change controller state to driver
			pc.GotoState(positions[targetPositionIndex].occupantControllerState);
		}
	}

	// ... handle case we are going from a major position to a minor position
	if (positions[targetPositionIndex].toBePossessed == None && positions[targetPositionIndex].occupant.controller == None)
		c.Possess(positions[targetPositionIndex].occupant);

	// ... signal to client that driver has entered
	data.controller = c;
	data.occupant = positions[targetPositionIndex].occupant;
	data.positionIndex = targetPositionIndex;
	if (positions[targetPositionIndex].toBePossessed == self)
	{
		clientOccupantEnter(data);
	}
	else if (VehicleMountedTurret(positions[targetPositionIndex].toBePossessed) != None)
	{
		// ... go through VehicleMountedTurret because otherwise the function is not replicated, call will
		// ... simply be forwarded to the vehicle on the client side
		VehicleMountedTurret(positions[targetPositionIndex].toBePossessed).clientOccupantEnter(pc, positions[targetPositionIndex].occupant,
				targetPositionIndex);
	}

	// ... update character flag
	positions[targetPositionIndex].occupant.bHiddenVehicleOccupant = positions[targetPositionIndex].hideOccupant;

	occupantEnterAnimationProcessing(targetPositionIndex);

	otherClientOccupantEnter(targetPositionIndex);

	occupantSwitchPosition(positions[targetPositionIndex].occupant, targetPositionIndex);
}

function int getMinorPositionEntryIndex(int positionIndex)
{
	return -1;
}

function occupantSwitchPosition(Character occupant, int targetPositionIndex)
{

}

function UnPossessed()
{
	NetPriority = Default.NetPriority;
	
	Super.UnPossessed();
}

function bool canSwitchPosition(int currentPositionIndex, byte selectedPosition)
{
	local int targetPositionIndex;

	if (bDisablePositionSwitching)
		return false;

	// check someone in current position
	if (positions[currentPositionIndex].occupant == None)
		return false;

	targetPositionIndex = getTargetPositionIndex(selectedPosition);

	// check target position exists
	if (targetPositionIndex >= positions.length)
		return false;

	// check no one in target position
	if (positions[targetPositionIndex].occupant != None)
		return false;

	// check armour
	if (!canArmorOccupy(positions[targetPositionIndex].type, positions[currentPositionIndex].occupant))
		return false;

	return true;
}

function InventoryStationAccess getCorrespondingInventoryStation()
{
	return None;
}

simulated function byte getPositionPromptIndex(VehiclePositionType positionType)
{
	switch (positionType)
	{
	case VehiclePositionType.VP_DRIVER:
		return DRIVER_PROMPT_INDEX;
	case VehiclePositionType.VP_GUNNER:
		return GUNNER_PROMPT_INDEX;
	case VehiclePositionType.VP_LEFT_GUNNER:
		return LEFT_GUNNER_PROMPT_INDEX;
	case VehiclePositionType.VP_RIGHT_GUNNER:
		return RIGHT_GUNNER_PROMPT_INDEX;
	case VehiclePositionType.VP_INVENTORY_STATION_ONE:
	case VehiclePositionType.VP_INVENTORY_STATION_TWO:
	case VehiclePositionType.VP_INVENTORY_STATION_THREE:
	case VehiclePositionType.VP_INVENTORY_STATION_FOUR:
		return INVENTORY_STATION_PROMPT_INDEX;
	default:
		warn("unknown vehicle position prompt");
	}

	return 255;
}

static function string getPrompt(byte promptIndex)
{
	switch (promptIndex)
	{
	case DRIVER_PROMPT_INDEX:
		return default.driverPrompt;
	case GUNNER_PROMPT_INDEX:
		return default.gunnerPrompt;
	case LEFT_GUNNER_PROMPT_INDEX:
		return default.leftGunnerPrompt;
	case RIGHT_GUNNER_PROMPT_INDEX:
		return default.rightGunnerPrompt;
	case INVENTORY_STATION_PROMPT_INDEX:
		return default.inventoryStationPrompt;
	case FULL_VEHICLE_PROMPT_INDEX:
		return default.fullVehiclePrompt;
	case VEHICLE_PROHIBITED_OBJECT_PROMPT_INDEX:
		return default.vehicleProhibitedObjectPrompt;
	case FLIP_PROMPT_INDEX:
		return default.flipPrompt;
	case CANNOT_STEAL_VEHICLE_PROMPT_INDEX:
		return default.cannotStealPrompt;
	case ENEMY_OCCUPIED_VEHICLE_PROMPT_INDEX:
		return default.enemyOccupiedPrompt;
	case ENEMY_INVENTORY_STATION_PROMPT_INDEX:
		return default.enemyInventoryStationPrompt;
	case HEAVY_ATTEMPT_TO_PILOT:
		return default.heavyAttemptedToPilot;
	default:
		warn("unknown vehicle position prompt");
	}

	return "unknown";
}

simulated function Material GetOverlayMaterial(int Index)
{
	if (bInvincible)
		return invicibilityMaterial;

	return super.GetOverlayMaterial(Index);
}

simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	// do not collide if it originated from us
	if (self == projInstigator)
		return false;

	return super.ShouldProjectileHit(projInstigator);
}

simulated function bool customFiredEffectProcessing()
{
	return false;
}

simulated function doCustomFiredEffectProcessing()
{
	assert(false);
}

static function rotator interpolateRotation(rotator current, rotator target, float rate, float deltaSeconds)
{
	local rotator result;
	local float pitchDelta;
	local float yawDelta;

	pitchDelta = target.Pitch - current.Pitch;
	yawDelta = target.Yaw - current.Yaw;

	if (pitchDelta > 32768)
		pitchDelta = pitchDelta - 65536;
	if (pitchDelta < -32768)
		pitchDelta = 65536 + pitchDelta;

	if (yawDelta > 32768)
		yawDelta = yawDelta - 65536;
	if (yawDelta < -32768)
		yawDelta = 65536 + yawDelta;

	if (abs(pitchDelta) > deltaSeconds * rate)
		if (pitchDelta < 0)
			pitchDelta = -deltaSeconds * rate;
		else
			pitchDelta = deltaSeconds * rate;

	if (abs(yawDelta) > deltaSeconds * rate)
		if (yawDelta < 0)
			yawDelta = -deltaSeconds * rate;
		else
			yawDelta = deltaSeconds * rate;

	result = current;
	result.Pitch += pitchDelta;
	result.Yaw += yawDelta;

	result = Normalize(result);

	return result;
}

function InventoryStationAccess getUnusedInventoryStation()
{
	return None;
}

simulated function bool canCharacterRespawnAt()
{
	return false;
}

simulated function String GetHumanReadableName()
{
	return localizedName;
}

function settledUpsideDownChanged();

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(0,255,0);

	Canvas.SetPos(4,YPos);

	// spawning flag
	Canvas.DrawText("Spawning:" @ spawning);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	// last state received time
	if (Level.NetMode == NM_Client)
	{
		Canvas.DrawText("Last Server State Receive Time:" @ lastStateReceiveTime);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	// havok state
	if (Physics == PHYS_Havok)
	{
		Canvas.DrawText("Havok Is Active:" @ HavokIsActive() $ ", Havok Is Completely Initialised:" @ isHavokCompletelyInitialised());
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	// make sure we are being ticked
	Canvas.DrawText("Tick:" @ LastTick);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

static function int packPitchAndYaw(rotator pitchAndYaw)
{
	local int workAngle;
	local int result;
	pitchAndYaw = Normalize(pitchAndYaw);
	workAngle = pitchAndYaw.Yaw;
	if (workAngle < 0)
		workAngle += 65536;
	result = workAngle << 16;
	workAngle = pitchAndYaw.Pitch;
	if (workAngle < 0)
		workAngle += 65536;
	result = result | workAngle;
	return result;
}

static function rotator unpackPitchAndYaw(int pitchAndYaw)
{
	local rotator result;
	result.pitch = pitchAndYaw & (65535);
	if (result.pitch > 32768)
		result.pitch -= 65536;
	result.yaw = pitchAndYaw >> 16;
	if (result.yaw > 32768)
		result.yaw -= 65536;
	return result;
}

defaultproperties
{
	bEdShouldSnap=True
	bStatic=False
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=False
	bProjTarget=True
	bBlockActors=True
	bBlockNonZeroExtentTraces=True
	bBlockZeroExtentTraces=True
	bBlockPlayers=True
	bWorldGeometry=False
	bBlockKarma=True
	CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bAcceptsProjectors=False
	bCanBeBaseForPawns=True
	bAlwaysRelevant=false
	RemoteRole=ROLE_SimulatedProxy
	bNetInitialRotation=true
	bUseCompressedPosition=false
	bSpecialCalcView=true
	//bSpecialHUD=true

	playerControllerState = "TribesPlayerDriving"

	cameraDistance=1000

	TPCameraLookat=(X=100,Y=0,Z=100)
	TPCameraDistance=600

	exits(0)=(offset=(X=0,Y=300,Z=100))
	exits(1)=(offset=(X=0,Y=-300,Z=100))

	bShowPhysicsDebug=false

	entries(0)=(radius=200,height=200,offset=(X=0,Y=250,Z=150))
	entries(1)=(radius=200,height=200,offset=(X=0,Y=-250,Z=150))

	bActorShadows=true
	ShadowLightDistance = 2000
	MaxShadowTraceDistance = 800

	bNetNotify=true

	maximumNetUpdateInterval=0.5

	bRotateToDesired = false

	bUpdateSimulatedPosition = false

	// required to replicate physics
	bReplicateMovement = true

	AI_LOD_Level = AILOD_MINIMAL

	motorClass = class'VehicleMotor'

	minimumObstacleLookAhead = 600
	obstacleLookAheadVeloocityScale = 1
	distanceToMaximumDurationScale = 0.005
	cornerSlowDownDistance = 2000
	cornerSlowDownMinimumCosAngle = -0.5
	cornerSlowDownSpeedCoefficient = 10

	abandonmentDestruction = false
	currentAbandonmentDuration = 0

	Physics = PHYS_Havok

	TopSpeed = 2000

	minimumCollisionDamageMagnitude = 100
	collisionDamageMagnitudeScale = 0.0025

	flipRotationStrength = 4
	flipRotationDamping = 0.9
	flipPushUpImpulse = 170000
	flipPushUpDuration = 0.5

	bCollisionDamageEnabled = true

	healthModifier = 1

	bCanBeStolen = true

	driverPrompt = "**enter driver position"
	gunnerPrompt = "**enter gunner position"
	leftGunnerPrompt = "**enter left gunner position"
	rightGunnerPrompt = "**enter right gunner position"
	inventoryStationPrompt = "**enter inventory station position"
	fullVehiclePrompt = "**vehicle is full"
	vehicleProhibitedObjectPrompt = "you cannot enter a vehicle carrying fuel, flags or balls"
	flipPrompt = "press <USE> to flip the vehicle"
	cannotStealPrompt = "you cannot steal an enemy vehicle before it has been driven off the vehicle spawn"
	enemyOccupiedPrompt = "you cannot enter a vehicle that is occupied by the enemy"
	enemyInventoryStationPrompt = "you cannot use enemy base objects"
	heavyAttemptedToPilot = "you can't pilot a vehicle when in heavy armour"

	teamSpecificHavokCollisionFiltering = true

	initialInvincibilityDuration = 6

	invicibilityMaterial = Shader'FX.ScreenShader'

	settledUpsideDownCosAngle = -0.1
	settledUpsideDownSpeed = 50
	
	velocityInheritOnExitScale = 1

	waterDamagePerSecond = 10

	stopForEnemies = true

	bOwnerNoSee = false

	bNeedPostRenderCallback = true	// required for DoIdentify to work

	driveYawCoefficient = 0.05
	drivePitchCoefficient = 0.05

	clientInterpolationSnapDistance = 150
	clientInterpolationPeriod = 0.2

	flipMaximumRotationDuration = 3

	heavyAttemptedToPilotSwitchPromptDuration = 3

	driverMinimumPitch = -16202
	driverMaximumPitch = 16202
	
	bIsVehicle = true

	vehicleCameraTraceExtents = (X=60,Y=60,Z=60)

	inverseCosUprightAngle = 0.6
}