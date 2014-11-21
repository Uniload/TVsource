//=====================================================================
// Rook
//=====================================================================

class Rook extends Engine.Pawn implements IEffectObserver
	native
	dependsOn(SingleplayerGameInfo);

//=====================================================================
// Constants

enum AlertnessLevels
{
	ALERTNESS_Neutral,      // gun lowered
	ALERTNESS_Alert,        // gun halfway
	ALERTNESS_Combat,       // gun aimed
};

const DAMAGE_OVERKILL = -50.0f;	// health value that justifies an "overkill" speech event 
const N_PAST_POSITIONS = 4;	// number of past positions stored in the pastPositions array (manually keep in snych with ARook.cpp version!)

//=====================================================================
// Variables

// health (default value is default.health)
var float healthMaximum;

var string hudType;

// if true, players can repair this object
var bool bCanRepair;

// the object's team
var()	protected
		editdisplay(displayActorLabel)
		editcombotype(enumTeamInfo)
		TeamInfo m_team							"The team that the object belongs to. Note: Base Devices assume the team of the BaseInfo to which they belong";

var private TeamInfo m_localTeam;

// the object's squad
var()	private
		editdisplay(displayActorLabel)
		editcombotype(enumSquadInfo)
		SquadInfo m_squad;

// Variables relating to common sensing code
var TribesVisionNotifier vision;						// Our Vision Notifier
var HearingNotifier hearing;							// Our Hearing Notifier
var ShotNotifier shotNotifier;							// Our Shot Notifier

// vision
var(AI) float PeripheralVisionZAngle "limits of peripheral vision in Z (radians)";
var(AI) float SightRadiusToPlayer "maximum distance at which player characters can be seen";

// AI Variables
var(AI) Tyrion_ResourceBase.AI_LOD_Levels AI_LOD_LevelMP "AI Level of detail for MP games";
var(AI) float AI_LOD_ActivationDistance "Distance at which AI's go into AILOD_NORMAL state";
var(AI) float AI_LOD_DeactivationDistance "Distance at which AI's leave AILOD_NORMAL state";
var(AI) bool bAIThreat "Is this a rook AI's should shoot at if it's an enemy?";
var(AI) float shotAngularDeviation "Max angular deviation from ideal line of fire in degrees";
var(AI) float shotAngularDeviationMP "Max angular deviation from ideal line of fire in degrees (MP games)";
var(AI) Range shotLeadAbility "Range from which the multiplier for the shot leading aiming component is chosen; (1,1) is totally accurate leading, numbers less than 1 undershoot, greater than 1 overshoot";
var(AI) Range shotLeadAbilityMP "Range from which the multiplier for the shot leading aiming component is chosen; (1,1) is totally accurate leading, numbers less than 1 undershoot, greater than 1 overshoot (MP games)";
var(AI) float reactionDelay "Time between spotting a new enemy and actually shooting at it"; 
var(AI) float reactionDelayMP "Time between spotting a new enemy and actually shooting at it (MP games)"; 
var(AI) float visionMemory "how long (in seconds) after losing a target does the AI still know where it is?";
var AlertnessLevels alertness;				// Alertness level
var int AI_LOD_deactivation_exemption_ticks;// when set, lets AI's stay in AILOD_NORMAL without a deactivation check
var Vector pastPositions[N_PAST_POSITIONS];	// past positions of the rook stored to compute average velocity
var int pastPositionsIndex;					// index of next position value in pastPositions
var float pastPositionsTimeAccu;			// deltaTime accumulator for pastPositions update
var Pawn attacker;							// entity who is attacking this rook
var float expectedImpactTime;				// time at which a projectile from "attacker" should have hit by
var float lastShotFiredTime;				// last time this AI fired a shot
var bool bUnobstructedLOF;					// does this rook have line of fire to its target?
var bool bDeferredAICleanup;				// true when state code is being run on AI's

var float tickTime;				// when tickTime < 0, we tick the AI
var float tickTimeOrg;			// last generated tickTime value
var Range tickTimeUpdateRange;  // min and max time that will be used to make a random tickTime

var Tyrion_ResourceBase vehicleAI;	// AI for the vehicle/turret as a whole
var Tyrion_ResourceBase mountAI;	// AI for gunner positions / drivers

// AI debug stuff
var bool bShowLOADebug;		// switch on local obstacle avoidance debugging
var bool bShowSensingDebug;	// switch on sensing debug
var Vector loaStartPoint;	// the point the lookAhead function is looking ahead from
var Vector loaEndPoint;		// and to
var Vector loaStartPoint2;	// and for the ramp/stairs segment...
var Vector loaEndPoint2;
var bool loaHit;			// true when lookAhead found an obstacle

// Boston's action/goal display
var bool bShowTyrionCharacterDebug;	// also activates vehicle/turret AI display
var bool bShowTyrionMovementDebug;
var bool bShowTyrionWeaponDebug;
var bool bShowTyrionHeadDebug;
var bool bShowNavigationDebug;

// Jetpacking/skiing debug stuff
var bool bShowJSDebug;		// switch on jetting/skiing debugging
var Vector estLocation;
var Vector movementForce;

// Squad/Formation debug stuff
var bool bShowSquadDebug;	// switch on squad/formation debugging
var Vector desiredLocation;	// where rook is trying to go

// alertness system debug
var bool logAlertnessChanges;

// shadow stuff
var (Shadow) float ShadowLightDistance;
var (Shadow) float MaxShadowTraceDistance;

// used by the sensor system
var() bool bCanBeSensed;
var() bool bIsDetectableByEnemies;
var bool sensorUpdateFlag;
var float lastDetectedTime;

// Set if this item should be always marked, even if it cannot be sensed
var() bool bAlwaysMarked;

// used to establish whether to mark this class or not:
var(Rook) class<RadarInfo> radarInfoClass;

// used for stat tracking
var array<Character> repairers;

// Damage Component system
struct native DamageComponent
{
	var() class<DynamicObject>	objectType	"Class type of the dynamic object attached at this location";
	var() name					attachmentPoint				"Bone or socket to attach object to. If None will attach to pivot";
	var DynamicObject			objectInstance;
};
var() array<DamageComponent> damageComponents;
var byte	clientDamageComponentMask;
var byte	damageComponentMask;	// this mask (and its client side dirty component) state which panels have been destroyed
var float	componentBreakThreshold;

// The PlayerCharacterController sets its state to this variable when possessing this Rook
var Name	playerControllerState;

// Ownership badge
var() bool	bUseAlternateOwnershipMaterial;
// Alternate Ownership Self-Illumination flag
var() bool	bUseAlternateSelfIllumMaterial;
var Name	teamSelfIllumSkinName;


// Fire damage
var Pawn				flameSource;
var class<DamageType>	flameDamageType;
var float				flameDamagePerSecond;
var float				flameDamageReductionPerSecond;

// Regenerating personalShields
var () class<Shield> personalShieldClass				"Class of regenerating Shield to use, or None to disable personal shields.  For Characters this should be set in the Armor class, not here.";
var Shield personalShield;

// Damage restrictions
var () float	teamDamagePercentage					"Members of this Rook's team can only reduce its health to this percentage of health.  Overrides any setting in TeamInfo.";

// effects system
var bool effectLogging;                                 // true if effect logging is enabled   
var Array<String> loopingEffects;                       // currently looping effects

// Grappler
var (Grappler) float grapplerRetentionScale                   "Scales breaking force for grapple attached to this object";

// Repair variables
var float repDepLastRateAddition;
var float repDepRepairRate;
var float repPakLastRateAddition;
var float repPakRepairRate;

// this array of useable points is replicated to the client
const MAX_USEABLE_POINTS = 10;
enum EUseablePointValid
{
	UP_Unused,
	UP_NotValid,
	UP_Valid
};
var Vector UseablePoints[MAX_USEABLE_POINTS];
var EUseablePointValid UseablePointsValid[MAX_USEABLE_POINTS];

// Havok team specific collision filtering
var  bool teamSpecificHavokCollisionFiltering;

// used to detect team changes
var private TeamInfo m_lastTeam;

replication
{
	reliable if (ROLE == ROLE_Authority)
		healthMaximum, m_team, UseablePoints, UseablePointsValid;

	reliable if ((ROLE == ROLE_Authority && !bNetOwner) || bDemoRecording)
        alertness;

	reliable if (ROLE == ROLE_Authority && personalShieldClass != None)
		personalShield;

	reliable if (ROLE == ROLE_Authority && damageComponents.Length != 0)
		damageComponentMask;
}

//=====================================================================
// Functions

function ApplyDamage(Pawn instigatedBy, float Damage, optional Name teamLabel)
{
	local Rook r;

	r = Rook(instigatedBy);
	if (r != None && r.m_team != None)
		teamLabel = r.m_team.Label;

	super.ApplyDamage(instigatedBy, Damage, teamLabel);
}

static simulated function PrecacheDamageComponents(LevelInfo Level, class<Rook> RookClass)
{
	local int i;

	// recurse through children
    for (i=0; i<RookClass.default.damageComponents.Length; i++)
	{
		if (RookClass.default.damageComponents[i].objectType != None)
			class'DynamicObject'.Static.PrecacheDynamicObjectRenderData(Level, RookClass.default.damageComponents[i].objectType);
	}
}

simulated function UpdatePrecacheRenderData()
{
	Super.UpdatePrecacheRenderData();
	PrecacheDamageComponents(Level, Class);
}


//
// Updates Havok collision data. Should be called when team changes.
//
simulated native function updateHavokCollisionFilter();

//
// Special function for returning the location of this actor
// if it is associated with an objective. This is mostly for the
// MPCarryables, because they have the problem of being attached
// to a charater & then having their location set to 0,0,0
//
simulated function Vector GetObjectiveLocation()
{
	return Location;
}

//
// For the useable points / prompts. Returns true if the
// character can use this rook. There is an array of useable
// points which is updated from server->client. Each time the
// player targets a rook, this method is called to see if the
// object is useable by them.
//
// In summary, the points are filtered on the server in case
// a particular point is unavilable (eg: someone is already using 
// an inventory station access), and the object is filtered
// on the client in case there is some character specific reason
// as to why the object cannot be accessed (eg: being on the 
// opposing team).
//
simulated function bool CanBeUsedBy(Character CharacterUser)
{
	return IsFriendly(CharacterUser);
}

function bool canBeSensed()
{
	return bCanBeSensed;
}

simulated function IFiringMotor firingMotor()
{
	return None;
}

// Returns the character (if it exists) that is controlling this rook (i.e. turret or vehicle)
simulated function Character getControllingCharacter()
{
	return None;
}

simulated function TeamInfo getControllingCharacterTeam()
{
	local Character controllingCharacter;

	controllingCharacter = getControllingCharacter();

	if ( controllingCharacter != None )
		return controllingCharacter.team();
	else
		return team();
}

// Repair functions ------------------------------------------------------------------------
simulated function addRepairFromDeployable(float repairRate, float accumulationScale)
{
	if (GameInfo(Level.Game) != None)
		repairRate = GameInfo(Level.Game).modifyRepairRate(self, repairRate);

	if (repDepLastRateAddition == 0.0)
	{
		repDepRepairRate = repairRate;
		repDepLastRateAddition = repairRate;
	}
	else
	{
		repDepLastRateAddition *= accumulationScale;
		repDepRepairRate += repDepLastRateAddition;
	}
}

simulated function removeRepairFromDeployable(float accumulationScale)
{
	repDepRepairRate -= repDepLastRateAddition;
	if (accumulationScale != 0)
		repDepLastRateAddition /= accumulationScale;
}

simulated function addRepairFromPack(float repairRate, float accumulationScale, Character repairer)
{
	//log("Old = "$repairRate);
	if (GameInfo(Level.Game) != None)
		repairRate = GameInfo(Level.Game).modifyRepairRate(self, repairRate);
	//log("New = "$repairRate);

	// Remember who is repairing for stat tracking purposes
	repairers[repairers.Length] = repairer;

	if (repPakLastRateAddition == 0.0)
	{
		repPakRepairRate = repairRate;
		repPakLastRateAddition = repairRate;
	}
	else
	{
		repPakLastRateAddition *= accumulationScale;
		repPakRepairRate += repPakLastRateAddition;
	}
}

simulated function removeRepairFromPack(float accumulationScale, Character repairer)
{
	local int i;

	repPakRepairRate -= repPakLastRateAddition;
	repPakLastRateAddition /= accumulationScale;

	// Stop remembering this repairer for stat tracking purposes
	for (i=0; i<repairers.Length; i++)
	{
		if (repairers[i] == repairer)
		{
			repairers.Remove(i, 1);
			return;
		}
	}
}

simulated event ProcessRepair(float delta)
{
	if (!isAlive())
		return;

	IncreaseHealth((repPakRepairRate + repDepRepairRate) * delta);
}
// End repair functions --------------------------------------------------------------------

simulated event ProcessBurnDamage(float delta)
{
	if (flameDamagePerSecond > 0.0)
	{
		if (PhysicsVolume.bWaterVolume)
		{
			removeFlameDamage();
			TriggerEffectEvent('Extinguished');
		}
		else
		{
			if (Role == ROLE_Authority)
				TakeDamage(flameDamagePerSecond * delta, flameSource, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), flameDamageType);

			if (flameDamageReductionPerSecond > 0.0)
				flameDamagePerSecond -= flameDamageReductionPerSecond * delta;

			if (flameDamagePerSecond <= 0.0)
				removeFlameDamage();
		}
	}
}

simulated function removeFlameDamage()
{
	flameDamagePerSecond = 0.0;
	UntriggerEffectEvent('Burning');
}

function displayWorldSpaceDebug(HUD displayHUD);

simulated function Destroyed()
{
	UntriggerEffectEvent('Burning');

	if (m_squad != None)
		m_squad.memberDestroyed(self);

	if (personalShield != None)
		personalShield.Destroy();

	cleanupAI();	// (requires vision pointer to still be around)
	cleanupSensing();
	
	cleanupDamageComponents();

	super.Destroyed();
}

event PreBeginPlay()
{
	// it is assumed that healthMaximum has neither been used or set prior to this point
	healthMaximum = default.health;

	super.PreBeginPlay();
}

//---------------------------------------------------------------------
// Called at start of gameplay.

simulated event PostBeginPlay()
{
 	local int i, damageComponentCount;
	
	Super.PostBeginPlay();

	if ( (Controller == None) && ControllerClassName == "Tyrion.AI_Controller" )
	{
		// create dummy AI controller for the rook -
		// so Unreal is happy and there's a place to store replicated data
		Controller = spawn(class<Controller>( DynamicLoadObject( ControllerClassName, class'Class')));
	}

	if ( Level.NetMode != NM_Client && Level.Game.IsA( 'MultiPlayerGameInfo' ) )
	{
		AI_LOD_Level = AI_LOD_LevelMP;
		shotAngularDeviation = shotAngularDeviationMP;
		shotLeadAbility = shotLeadAbilityMP;
		reactionDelay = reactionDelayMP;
	}
	AI_LOD_LevelOrig = AI_LOD_Level;

	CreateShotNotifier();	// a shot notifier is created for all rooks because AI's are interested in players' shots

	if ( Controller != None )
		Controller.Possess( self );

	// add this rook to his squad
	if ( squad() != None )
	{
		if ( logTyrion )
			log( self @ "added to squad" @ squad() );
		setSquad( squad() );
	}

	// fill in the damage component mask
	damageComponentCount = 0;
	for (i=0; i < damageComponents.length; ++i)
	{
		if (damageComponents[i].objectType != None)
		{
			damageComponentMask = damageComponentMask | (1 << i);
			++damageComponentCount;
		}
	}
	componentBreakThreshold = GetDamageComponentThresholdRange() / (damageComponentCount + 1);

	resetPersonalShield();

/*
	if ( label == 'aitestplatformer01' || label == 'aicustomesther1' )
	{
		logTyrion = true;
		//logNavigationSystem = true;
		bShowTyrionCharacterDebug = true;
		bShowTyrionMovementDebug = true;
		bShowTyrionWeaponDebug = true;
		bShowTyrionHeadDebug = true;
		bShowSensingDebug = true;
		bShowJSDebug = true;
		//logDLM = true;
		if ( squad() != None )
			squad().logTyrion = true;
	}
*/
}

simulated function float GetDamageComponentThresholdRange()
{
	return healthMaximum;
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (bActorShadows && Level.NetMode != NM_DedicatedServer)
	{
		Shadow = Spawn(class'ShadowProjector',self,'',Location);
		Shadow.ShadowActor = self;
        Shadow.bBlobShadow = false;
		Shadow.LightDirection = Normal(vect(1,1,5));
		Shadow.LightDistance = ShadowLightDistance;
		Shadow.MaxTraceDistance = MaxShadowTraceDistance;
		Shadow.RootMotion = true;
		Shadow.CullDistance = 8000;
		Shadow.Resolution = 256;
		Shadow.InitShadow();
	}

	if (damageComponents.length != 0)
	{
		clientDamageComponentMask = damageComponentMask;
		clientUpdateDamageComponents();

		// we need to snooop on net receive if we are using damage components
		bNetNotify = true;
	}

	// if we have a radar info which displays icons ina  viewport, then turn on 
	// the post render callback. Make sure that we dont turn it off, though
	if (GetRadarInfoClass() != None)
		bNeedPostRenderCallback = bNeedPostRenderCallback || class<RadarInfo>(GetRadarInfoClass()).default.bDisplayViewport;
}

simulated function bool ShouldBeMarked(PlayerCharacterController pcc)
{
	// if the radar info says no, then don't.
	if (! (GetRadarInfoClass() != None && class<RadarInfo>(GetRadarInfoClass()).default.bDisplayViewport))
		return false;

	// always marked, so return true
	if(bAlwaysMarked)
		return true;

	// add the rook to the list of markers to be marked on the HUD
	if(bCanBeSensed && IsAlive() && (IsA('MPCarryable') || pcc.IsFriendly(self) || // friendlies and carryables are always rendered
		(! pcc.IsFriendly(self) && pcc.GetControllerTeam() != None && pcc.GetControllerTeam().bSensorGridFunctional)))	// enemy players are rendered only if the sensor grid is up
			return true;

	return false;
}

//---------------------------------------------------------------------
// Damage Component functions
simulated function clientUpdateDamageComponents()
{
	local int i;
	//local DynamicObject component;

	for (i=0; i < damageComponents.length && i < 8; ++i)
	{
		if (damageComponents[i].objectType != None)
		{
			// unspawned components that need to be spawned
			if (damageComponents[i].objectInstance == None && (damageComponentMask & (1<<i))!=0 )
				createDamageComponent(i, false);

			// removed components need to be broken
			if (damageComponents[i].objectInstance != None && (damageComponentMask & (1<<i))==0 )
				breakDamageComponent(i, 0, vect(0,0,0));
		}
	}
}

simulated function cleanupDamageComponents()
{
	local int i;

	for (i=0; i < damageComponents.length && i < 8; ++i)
	{
		if (damageComponents[i].objectInstance != None)
			damageComponents[i].objectInstance.Destroy();
	}
}

// client/server side functions
simulated native final function breakDamageComponent(int index, float damage, vector momentum);
simulated native final function createDamageComponent(int index, bool fadeIn);

// server side only functions
function damageComponentsPostTakeDamage(float damage, vector hitLocation, vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	// we may not neccesarily process this call
	if (Level.NetMode != NM_Client && damageComponentMask != 0 && damage > 0)
		damageComponentsOnDamage(damage, HitLocation, Momentum, DamageType);
}

native final function damageComponentsOnDamage(float damage, vector hitLocation, vector momentum, class<DamageType> damageType);
native final function damageComponentsOnIncreaseHealth(float quantity);

simulated event onTeamChange()
{
	updateHavokCollisionFilter();
}

// need to snoop on damage so that we can drop damage components
function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	local float actualDamage, maxPercentageHealth;
	local Rook attackerRook;
	local VehicleMountedTurret attackerVehicleTurret;
	local Rook originalAttackerRook;
	
	actualDamage = Damage;

	// If personalShields are active, take damage from them instead
	if (personalShieldActive())
		actualDamage = personalShield.applyDamage(Damage, health);

	attackerRook = Rook(EventInstigator);
	originalAttackerRook = attackerRook;

	// handle vehicle case
	if (attackerRook != None && attackerRook.isA('Vehicle'))
		attackerRook = Vehicle(attackerRook).positions[Vehicle(attackerRook).driverIndex].occupant;

	// handle vehicle mounted turret case
	if (attackerRook != None && attackerRook.isA('VehicleMountedTurret'))
	{
		attackerVehicleTurret = VehicleMountedTurret(attackerRook);
		if (attackerVehicleTurret.positionIndex >= 0 && attackerVehicleTurret.ownerVehicle != None)
			attackerRook = attackerVehicleTurret.ownerVehicle.positions[attackerVehicleTurret.positionIndex].occupant;
	}
		
	// Restrict team damage if applicable
	if(attackerRook != None && attackerRook.team() != None && attackerRook.team().isFriendlyRook(self))
	{
		maxPercentageHealth = getTeamDamagePercentage();

		if (maxPercentageHealth > 0.0)
		{
			// Modify actual damage taken to only apply enough damage to bring the Rook's health down to maxPercentageHealth
			if ((health - actualDamage) / healthMaximum < maxPercentageHealth)
			{
				actualDamage = health - healthMaximum * maxPercentageHealth;
				if (actualDamage < 0)
					actualDamage = 0;
			}
		}		
	}

	Super.PostTakeDamage(actualDamage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);

	// Hit feedback for character objects
	if(EventInstigator != None && Health > 0 && bCanBeDamaged)
	{
		if(Character(EventInstigator) != None)
			Character(EventInstigator).OnHitObject(self);
		else if(VehicleMountedTurret(EventInstigator) != None && VehicleMountedTurret(EventInstigator).GetDriver() != None)
			VehicleMountedTurret(EventInstigator).GetDriver().OnHitObject(self);
		else if(Turret(EventInstigator) != None && Turret(EventInstigator).driver != None)
			Turret(EventInstigator).driver.OnHitObject(self);
		else if(Vehicle(EventInstigator) != None && Vehicle(EventInstigator).GetDriver() != None)
			Vehicle(EventInstigator).GetDriver().OnHitObject(self);
	}

	damageComponentsPostTakeDamage(actualDamage, HitLocation, Momentum, DamageType, projectileFactor);

	generateAISpeechEvents(originalAttackerRook);
}

function generateAISpeechEvents( Rook attackerRook )
{
	local BaseAICharacter controllingCharacter;

	//log( "@@@" @ attackerRook.name @ "hit" @ name );

	// Speech events when an AI hits something
	if ( static.checkAlive(attackerRook) && attackerRook != self && !isFriendly( attackerRook ) )
	{
		controllingCharacter = BaseAICharacter(attackerRook.getControllingCharacter());

		if ( controllingCharacter != None && controllingCharacter.bTaunt )
		{
			if ( health > 0 )
			{
				if ( controllingCharacter.scaleByWeaponRefireRate() )
					level.speechManager.PlayDynamicSpeech( controllingCharacter, 'Hit', controllingCharacter );
			}
			else
			{
				if ( health > DAMAGE_OVERKILL )
					level.speechManager.PlayDynamicSpeech( controllingCharacter, 'Kill', None, self );
				else
					level.speechManager.PlayDynamicSpeech( controllingCharacter, 'Kill', None, self, "OverKill" );
				if ( FRand() < controllingCharacter.tauntAnimFrequency )
					controllingCharacter.playTauntAnim();
			}
		}

		// if hit, cancel pending miss speech event
		if ( attackerRook == attacker )
			attacker = None;
	}
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	// check mask to see if any damage components have been added or removed
	if (Level.NetMode == NM_Client && damageComponents.length != 0 && clientDamageComponentMask != damageComponentMask)
	{
		clientUpdateDamageComponents();
		clientDamageComponentMask = damageComponentMask;
	}

	// check if team has changed
	if (m_localTeam != m_team)
	{
		onTeamChange();
		m_localTeam = m_team;
	}
}

simulated event Material GetOverlayMaterial(int Index)
{
	// our shield can put an overlay on us
	if (personalShield != None && personalShield.bActive)
		return personalShield.GetEffectMaterial();
}


//---------------------------------------------------------------------
// Health functions
final function IncreaseHealth(float quantity)
{
	health += quantity;

	if (health > healthMaximum)
		health = healthMaximum;

	// update damage components
	if (Level.NetMode != NM_Client && damageComponents.length != 0)
		damageComponentsOnIncreaseHealth(quantity);
}

// Overridden in subclasses
function float getTeamDamagePercentage()
{
	return teamDamagePercentage;
}

//---------------------------------------------------------------------
// personalShield functions
function bool personalShieldActive()
{
	if (personalShield == None)
		return false;

	return personalShield.bActive && personalShield.health > 0;
}

function activatePersonalShield()
{
	if (personalShield != None)
		personalShield.activate();
}

function deactivatePersonalShield()
{
	if (personalShield != None)
		personalShield.deactivate();
}

function resetPersonalShield()
{
	if (personalShield != None)
		personalShield.destroy();

	if (personalShieldClass != None)
		personalShield = spawn(personalShieldClass);
}
//---------------------------------------------------------------------

protected function CreateVisionNotifier()
{
    vision = new class'TribesVisionNotifier';
    assert(vision != None);

	vision.addRef();
    vision.InitializeVisionNotifier(self);

	//log( "VISION NOTIFIER CREATED FOR" @ name );
}

//---------------------------------------------------------------------

protected function CreateHearingNotifier()
{
	hearing = new class'HearingNotifier';
	assert(hearing != None);
	
	hearing.addRef();
	hearing.InitializeHearingNotifier(self);
}

//---------------------------------------------------------------------

protected function CreateShotNotifier()
{
    shotNotifier = new class'ShotNotifier';
    assert(shotNotifier != None);

    shotNotifier.InitializeShotNotifier(self);
}

//---------------------------------------------------------------------
// Low-Level Vision Implementation

// Register to be notified when we see / no longer see a Pawn
function RegisterVisionNotification(IVisionNotification Registrant)
{
    vision.RegisterVisionNotification(Registrant);
}

function UnregisterVisionNotification(IVisionNotification Registrant)
{
	if ( vision != None )
		vision.UnregisterVisionNotification(Registrant);
}

//---------------------------------------------------------------------
// Low-Level Hearing Implementation

// Register to be notified when we see / no longer see a Pawn
function RegisterHearingNotification(IHearingNotification Registrant)
{
    hearing.RegisterHearingNotification(Registrant);
}

function UnregisterHearingNotification(IHearingNotification Registrant)
{
	if ( hearing != None )
	    hearing.UnregisterHearingNotification(Registrant);
}

//---------------------------------------------------------------------
// Low-Level Shot Notification Implementation

// Register to be notified when we fire a shot
function RegisterShotNotification(IShotNotification Registrant)
{
	shotNotifier.RegisterShotNotification(Registrant);
}

function UnregisterShotNotification(IShotNotification Registrant)
{
	shotNotifier.UnregisterShotNotification(Registrant);
}

event OnShotFired( Projectile projectile )
{
    shotNotifier.OnShotFired( projectile );
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	Super.Died( Killer, damageType, HitLocation );

	cleanupAI();
	
	if (Killer!=None)
	    squadCleanupOnDeath( Killer.Pawn, damageType, HitLocation );
	else
	    squadCleanupOnDeath( None, damageType, HitLocation );
}

// returns true if cleanup should be deferred
event bool cleanupAI()
{
	local int i;

	if ( bDeferredAICleanup )
		return true;

	level.AI_Setup.shutDownVision( self );	// (handles updating enemy lists of squad mates)

	// make sure the outer of any classes is no longer pointing to this (soon to be destroyed) actor
	for ( i = 0; i < abilities.length; ++i )
	{
		level.AI_Setup.makeSafeOuter( self, abilities[i] );
	}

	// make sure the outer of any classes is no longer pointing to this (soon to be destroyed) actor
	for ( i = 0; i < goals.length; ++i )
	{
		level.AI_Setup.makeSafeOuter( self, goals[i] );
	}

	return false;
}

function squadCleanupOnDeath( Pawn InstigatedBy, class<DamageType> damageType, vector HitLocation )
{
	if ( m_squad != None )
	{
		m_squad.memberDied( self, InstigatedBy, damageType, HitLocation );	// let squad know a member died
	}
}

//---------------------------------------------------------------------

private function CleanupSensing()
{
    if (Vision != None)
    {
        Vision.CleanupVisionNotifier();
        Vision.Release();
        Vision = None;
    }
 
    if (Hearing != None)
    {
        Hearing.Release();
        Hearing = None;
    }

	if (shotNotifier != None)
	{
		shotNotifier.Delete();
		shotNotifier = None;
	}
}

//---------------------------------------------------------------------
// enumTeamInfo
// List all team info objects in the editor
function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

//---------------------------------------------------------------------
// List all SquadInfo objects in the editor

function enumSquadInfo(Engine.LevelInfo l, out Array<SquadInfo> s)
{
	local SquadInfo t;

	ForEach l.AllActors(class'SquadInfo', t)
	{
		s[s.Length] = t;
	}
}

//---------------------------------------------------------------------
// displayActorLabel
// Display an actor reference's label in the editor
function string displayActorLabel(Actor t)
{
	return string(t.label);
}

//---------------------------------------------------------------------
// team
// Get the Rook's team object
simulated function TeamInfo team()
{
	return m_team;
}

simulated function Name getTeamLabel()
{
	if (team() != None)
		return team().label;

	return '';
}

//---------------------------------------------------------------------
// setTeam
// Sets the Rook's team object
function setTeam(TeamInfo info)
{
	local TeamInfo oldTeam;

	oldTeam = m_team;

	m_team = info;

	if (oldTeam != info)
	{
		onTeamChange();
		level.notifyListenersTeamChanged( self );
	}
}

//---------------------------------------------------------------------
// isFriendly
// returns true if this rook is friendly to the given rook
// team values of "None" are defined to be friendly to everyone else
// if rook is a vehicle, takes team of occupant into account (use team version of isFriendly if you don't want this)
simulated event bool isFriendly(Rook otherGuy)
{
	local TeamInfo tiThisGuy;
	local TeamInfo tiOtherGuy;

	if (otherGuy == None)
		return true;

	tiThisGuy = getControllingCharacterTeam();
	tiOtherGuy = otherGuy.getControllingCharacterTeam();

	if (tiThisGuy == None || tiOtherGuy == None)
		return true;

	return tiThisGuy.isFriendly( tiOtherGuy );
}

//---------------------------------------------------------------------
// isRepairFriendly
// returns true if this rook is friendly to the given rook with respect to repairing
// team values of "None" are defined to be friendly to everyone else

simulated function bool canBeRepairedBy(Rook otherGuy)
{
	return isFriendly(otherGuy);
}

//---------------------------------------------------------------------
// Get the Rook's squad object

function SquadInfo squad()
{
	return m_squad;
}

//---------------------------------------------------------------------
// Sets the Rook's squad object

function setSquad(SquadInfo squad)
{
	// TODO: remove from squad if already in one

	m_squad = squad;

	if (squad != None)
		squad.addToSquad( self );
}

//---------------------------------------------------------------------
// getAlertnessLevel

function AlertnessLevels getAlertnessLevel()
{
	return alertness;
}

//---------------------------------------------------------------------
// setAlertnessLevel
// Sets the Rook's alertness level
// note: you should always set the alertness through this function
// because child classes (character) override this method and perform
// additional functionality to keep animations in sync with the alert level!
function setAlertnessLevel(AlertnessLevels alertness)
{
	self.alertness = alertness;
}

//---------------------------------------------------------------------
// sets AI to AILOD_NORMAL - deactivation checks suspended for specified number of ticks

event setLimitedTimeLODActivation( int ticksToKeepActivated )
{
	if ( AI_LOD_Level > AILOD_NONE && AI_LOD_Level < AILOD_NORMAL )
	{
		level.AI_Setup.setAILOD( self, AILOD_NORMAL );
		AI_LOD_deactivation_exemption_ticks = ticksToKeepActivated;
	}
}

//---------------------------------------------------------------------
// check whether to put a new position value into pastPositions array

native function updatePastPositions( float deltaSeconds );

//---------------------------------------------------------------------
// Returns the rook's average velocity over the last
// N_PAST_POSITIONS * PAST_POSITION_UPDATE_INTERVAL seconds

native function Vector averageVelocity();

//---------------------------------------------------------------------
// Estimate where character will be in t seconds

native function Vector predictedLocation( float t );

//---------------------------------------------------------------------
// Estimate where character will be in t seconds (while on the ground)

native function Vector groundPredictedLocation( float t );

//---------------------------------------------------------------------
// Vision debug

function DrawVisionCone(HUD DrawTarget)
{
	local float fDistance, fConeRadius, fRadians, fI, fPeripheralVisionAngle;
	local array<vector> VisionConePoints;
	local int i;
	local Vector ViewLocation, ViewDirection, X, Y, Z;
	local Coords ViewCoords;
	local color CurrentColor;

	fPeripheralVisionAngle = Acos(PeripheralVision);

	fDistance = Square(SightRadius) * cos(fPeripheralVisionAngle * 0.5);
	fConeRadius = tan(fPeripheralVisionAngle * 0.5) * fDistance;

	ViewDirection   = GetViewDirection();
	ViewDirection.Z = 0.0;

	GetAxes(rotator(ViewDirection), X, Y, Z);

	ViewLocation    = GetViewPoint();

	ViewCoords.Origin = ViewLocation;
	ViewCoords.XAxis  = X;
	ViewCoords.YAxis  = Y;
	ViewCoords.ZAxis  = Z;

    // @TODO:  Add in Color based on something
    CurrentColor = class'Canvas'.Static.MakeColor(200,155,0);

	for(i=0; i<8; ++i)
	{
		fI       = i;
		fRadians = (fI * Pi * 2.0) / 8;

		VisionConePoints[i]   = vect(0,0,0);
		VisionConePoints[i].X = fDistance;
		VisionConePoints[i].Y = cos(fRadians) * fConeRadius;
		VisionConePoints[i].Z = sin(fRadians) * fConeRadius;

//		log(self@"fRadians: "@fRadians@" i: "@i@" fI: "@fI@" VisionConePoints: "@VisionConePoints[i].X@" "@VisionConePoints[i].Y@" "@VisionConePoints[i].Z);

		VisionConePoints[i] = VisionConePoints[i] >> rotator(GetViewDirection());
//		log("VisionConePoints: "@VisionConePoints[i].X@" "@VisionConePoints[i].Y@" "@VisionConePoints[i].Z);

		DrawTarget.Draw3DLine(ViewLocation, VisionConePoints[i], CurrentColor);
	}
}

//---------------------------------------------------------------------

function displayTyrionDebugHeader()
{
	AddDebugMessage( Label @ "(LOD:" $ AI_LOD_Level $ ")", class'Canvas'.static.MakeColor(0,200,0) );
}

function displayEnemiesList()
{
	local int i;
	local string displayString;
	local array<Pawn> enemyList;

	if ( vision == None )
		return;

	// enemies in seenlist
	enemyList = vision.getEnemyList();

	for ( i = 0; i < enemyList.length; ++i )
	{
		displayString $= enemyList[i].label $ " ";
	}

	AddDebugMessage( displayString, class'Canvas'.static.MakeColor(255,0,0) );

	// todo: enemies in squadSeenList

	// enemy sensor list
	displayString = "";

	enemyList = level.AI_Setup.getEnemyListFromSensor( self );

	for ( i = 0; i < enemyList.length; ++i )
	{
		displayString $= enemyList[i].label $ " ";
	}

	AddDebugMessage( displayString, class'Canvas'.static.MakeColor(200,0,0) );
}

//---------------------------------------------------------------------
// script version of native function
// (used in AI debugging)

native function bool IsInVisionCone( Actor Other, float SightRadius );

//---------------------------------------------------------------------
// wrapper function for playing effects

simulated function bool PlayEffect(String effect, optional String tag, optional Actor other, optional Material material, optional Vector location, optional Rotator rotator)
{
    if (effectLogging)
    {
        if (tag=="")
            log("play effect: "$effect);
        else
            log("play effect: "$effect$" ("$tag$")");
    }
    
	return TriggerEffectEvent(Name(effect), other, material, location, rotator, false, false, none, Name(tag)); //self, Name(tag));
}

simulated function bool StopEffect(String effect)
{
    if (effectLogging)
        log("stop effect: "$effect);
    
	UnTriggerEffectEvent(Name(effect));
	
	return true;            // how to detect if effect was actually stopped?
}

simulated function bool StartLoopingEffect(String effect, optional String tag, optional Actor other, optional Material material, optional Vector location, optional Rotator rotator)
{
	if (PlayEffect(effect$"Loop", tag, other, material, location, rotator))
    {
    	PlayEffect(effect$"Start", tag, other, material, location, rotator);

        loopingEffects[loopingEffects.length] = effect;
        
        if (effectLogging)
            log("started looping effect: "$effect$"["$loopingEffects.length-1$"]");

    	return true;
    }
    
    return false;
}

simulated function bool EffectIsLooping(String effect)
{
    local int i;

    for (i=0; i<loopingEffects.length; i++)
    {
        if (loopingEffects[i]~=effect)
            return true;
    }
    
    return false;
}

simulated function bool StopLoopingEffect(String effect)
{
    // exit if effect is not in looping sounds array

    local int i, index;
    
    if (EffectIsLooping(effect))
    {
	    StopEffect(effect$"Loop");
	    PlayEffect(effect$"Stop");
	    
	    if (effectLogging)
	        log("stopping loop: "$effect);
	    
	    // remove from looping effects array
	    
        index = -1;

        for (i=0; i<loopingEffects.length; i++)
        {
            if (loopingEffects[i]~=effect)
            {
                index = i;
                break; 
            }
        }
        
        if (index>=0)
            loopingEffects.remove(index, 1);
        
	    return true;
	}
	else
	{   
	    if (effectLogging)
	        log(effect$" was not looping. no need to stop it");
	
    	return false;
    }
}

// callbacks

function OnEffectInitialized(Actor effect)
{
    //log("effect initialized: "$effect);
}

function OnEffectStarted(Actor effect)
{
    /*
    local int i, index;
    local IGSoundEffectsSubsystem.SoundInstance sound;
    
    sound = IGSoundEffectsSubsystem.SoundInstance(effect);
    
    if (sound==None || sound.isEndPredictable)
        return;
        
    index = loopingSounds.length;

    loopingSounds[index] = sound.SchemaName;

    log("looping sound started: "$sound.SchemaName$" ["$index$"]");
    
    log("************************");
    for (i=0; i<loopingSounds.length; i++)
        log(i$": "$loopingSounds[i]);
    log("************************");
    */
}

function OnEffectStopped(Actor effect, bool completed)
{
    /*
    local int i, index;
    local IGSoundEffectsSubsystem.SoundInstance sound;
    
    sound = IGSoundEffectsSubsystem.SoundInstance(effect);
                       
    if (sound==None || sound.isEndPredictable)
        return;
        
    index = -1;

    for (i=0; i<loopingSounds.length; i++)
    {
        if (loopingSounds[i]==sound.SchemaName)
        {
            index = i;
            break; 
        }
    }
    
    if (index>=0)
    {
        log("looping sound stopped: "$sound.SchemaName$" ["$index$"]");
        loopingSounds.remove(index, 1);
    }
    else
        log("stopped sound not in looping sounds array: "$sound.SchemaName);
    
    log("************************");
    for (i=0; i<loopingSounds.length; i++)
        log(i$": "$loopingSounds[i]);
    log("************************");
    */
}

//---------------------------------------------------------------------
// ChunkUp
simulated function ChunkUp( Rotator HitRotation, class<DamageType> D ) 
{
}

//
// This is the main version of GetRadarInfoClass, because most items to be 
// displayed on the radar will be of type rook
//
simulated function class GetRadarInfoClass()
{
	return radarInfoClass;
}

//
// Returns the label of the killer corrsponding to this Rook.
//
simulated function Name getKillerLabel()
{
	return label;
}

//=====================================================================

defaultproperties
{
	bNetInitialRotation			= true
	bCanBeBaseForPawns			= true
	bIgnoreForces				= true
	
	bBlockHavok					= true

	// No longer any need for LandMovementState
	LandMovementState			= ""

	bCanBeSensed				= true
	bIsDetectableByEnemies		= true

	bCanRepair					= false
	DrawType					= DT_Mesh
//	hudType						= "legacy_Gameplay.LegacyHUD"
//	hudType						= "TribesGUI.TribesHUD"

	bShowTyrionCharacterDebug	= false
	bShowTyrionMovementDebug	= false
	bShowTyrionWeaponDebug		= false
	bShowNavigationDebug		= false
	logNavigationSystem			= false
	logTyrion					= false
	logDLM						= false
	logAlertnessChanges			= false
	bShowLOADebug				= false
	bShowJSDebug				= false
	bAcceptsProjectors			= false

	AI_LOD_Level				= AILOD_NONE
	AI_LOD_LevelMP				= AILOD_NONE
	AI_LOD_ActivationDistance	= 6000
	AI_LOD_DeactivationDistance = 8000
	bAIThreat					= true
	shotAngularDeviation		= 0
	shotAngularDeviationMP		= 0
	shotLeadAbility				= (Min=1,Max=1)
	shotLeadAbilityMP			= (Min=1,Max=1)
	reactionDelay				= 0
	reactionDelayMP				= 0
	tickTimeUpdateRange			= (Min=0.095,Max=0.105)
	bUnobstructedLOF			= true

	// default vision values for vehicles and vehicleMountedTurrets
	peripheralVision			= 0.1				// nearly 180 degrees
	peripheralVisionZAngle		= 0.7854			// 45 degrees up/down
	SightRadius					= 10000.0
	SightRadiusToPlayer			= 12000.0
	VisionUpdateRange			= (Min=0.4,Max=0.6)
	visionMemory				= 15.0

	alertness					= ALERTNESS_Neutral

	radarInfoClass				= class'Gameplay.RadarInfo'

	ShadowLightDistance			= 1200
	MaxShadowTraceDistance		= 600

	teamDamagePercentage		= 0.0
	teamSelfIllumSkinName		= "BaseLumNeutralPanner"

	grapplerRetentionScale      = 1.0
	bAlwaysMarked				= false
}