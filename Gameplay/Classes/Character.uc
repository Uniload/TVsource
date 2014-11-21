class Character extends Ragdoll implements IVisionNotification
	native;

// --------------- movement system ----------------

// READ ONLY

var const float movementSpeed;		            // speed in kph
var const float movementVerticalSpeed;		    // vertical speed in kph
var const float movementHorizontalSpeed;	    // horizontal speed in kph
var const float movementTangentialSpeed;	    // tangential speed in kph
var const float movementDirectionalSpeed;	    // directional speed in kph

var const float movementAltitude;               // altitude in meters

var const bool movementCollided;                // true if collided last immediate update
var const bool movementClose;                   // true if close to a surface last update
var const bool movementTouching;                // true if recently collided
var const bool movementGrounded;                // true if touching a walkable slope
var const bool movementAirborne;                // true if not touching and not in water
var const bool movementWater;                   // true if in any part of character is touching water
var const bool movementUnderWater;              // true if character is entirely submerged in water
var const bool movementZeroGravity;             // true if character is in a zero gravity volume
var const bool movementElevator;                // true if character is in an elevator volume

var const bool movementResting;                 // true if currently resting
var const bool movementDynamic;                 // true if touching a dynamic object (cannot come to rest)
var const bool movementPushing; 		        // true if touching a pushable object (not allowed to apply smoothing)

var const Vector movementNormal;                // best floor normal last update relative to (0,0,1)

var const float movementWaterPenetration;       // water penetration [0,1]

var const float movementSplashChaos;            // splash chaos [0,1]
var const float movementImpulseChaos;           // impulse chaos [0,1]

var const float movementSphereRadius;           // radius of character's bounding sphere
var const float movementSphyllRadius;           // radius of the character's sphyll caps
var const float movementSphyllHalfHeight;       // half the height of the character's sphyll cylinder component

var const int movementGroundState;              // ground movement state (GroundMovement_Standing/Walking/Running/Sprinting/Any)

var const int movementCollisionMaterial;        // most recent movement collision material

var const bool movementThrusting;               // true if thrusting last update
var const bool movementOldThrusting;            // true if thrusting before last update

var const Vector movementDisplacement;          // change in position last movement update
var const float movementDisplacementRate;       // change in position rate last movement update
var const Vector movementStrafe;                // unit length strafe vector (zero if no strafe)

var const Vector movementOldVelocity;           // movement velocity for previous update (current is in "Velocity")

var const bool movementSkiInput;                // ski input state for previous update (true if enabled, false if not)

// READ/WRITE DATA

var (Movement) float movementKnockbackScale;            // scales knockback applied to characters from weapons only. defaults to 1. overridden by armor if wearing any.
var (Movement) float movementExtraMass;                 // extra mass passed into movement physics so you can simulate carrying heavy objects
var (Movement) bool movementFrozen;                     // if this is set to true, movement is frozen and the guy wont respond to knockback or be able to move at all

var float lastMovementDamageTime;                       // last time a movement damage event occured (used to filter damage effects occuring too closely together)
var float lastMovementCollisionTime;                    // last time a movement collision event occured (used to filter collision effects occuring too closely together)

var bool blockMovementDamage;                           // if this is set to true, movement damage is blocked for the next tick

// SIM PROXY DATA

var Material collisionMaterialObject;                   // most recent movement collision material object (for effect system)

enum MovementDirectionalInput
{
    MovementInput_Zero,
    MovementInput_Positive,
    MovementInput_Negative,
};

var const byte movementSimProxyPitch;                   // filled in native code from compressed position rotator

var const MovementDirectionalInput movementSimProxyInputX;
var const MovementDirectionalInput movementSimProxyInputY;
var const bool movementSimProxyInputThrust;
var const bool movementSimProxyInputJump;
var const bool movementSimProxyInputSki;

// -------------- animation system ----------------

enum AnimationStateEnum
{
    AnimationState_None,
	AnimationState_Stand,
	AnimationState_Walk,
	AnimationState_Run,
	AnimationState_Sprint,
	AnimationState_Ski,
	AnimationState_Slide,
	AnimationState_Stop,
	AnimationState_Airborne,
	AnimationState_AirControl,
	AnimationState_Thrust,
	AnimationState_Swim,
	AnimationState_Count,
};

var (Animation) float walkAnimationSpeed;           // walk animation speed in unreal units per second
var (Animation) float runAnimationSpeed;            // run animation speed in unreal units per second
var (Animation) float sprintAnimationSpeed;         // sprint animation speed in unreal units per second

var (Animation) Name neutralAimAnimationRootBone;   // root bone name for aiming animations in neutral pose
var (Animation) Name alertAimAnimationRootBone;     // root bone name for aiming animations in alert pose
var (Animation) Name combatAimAnimationRootBone;    // root bone name for aiming animations in combat pose
var (Animation) Name upperBodyAnimationRootBone;    // root bone name for upper body animations
var (Animation) Name armAnimationRootBone;          // root bone name for arm animations

var transient AnimationManager animationManager;              // animation manager performs the animation update method
var transient array<AnimationState> animationStates;          // each animation state corresponds to a movement state
var transient array<AnimationChannel> animationChannels;      // each animation channel corresponds to an AnimationChannel enum value
var transient AnimationLayer primaryAnimationLayer;           // primary animation layer
var transient AnimationLayer secondaryAnimationLayer;         // secondary animation layer

var transient AnimationSpring animationHeightSpring;          // height animation spring (for airborne up/down)
var transient AnimationSpring animationVelocitySpring;        // velocity animation spring (for ski up/down)

var private bool m_bManualAnimation;
var private bool m_bOldManualAnimation;

import enum AnimationChannelIndex from AnimationChannel;

// ------------------------------------------------

var (Damage) float vehicleTeamCrushingDamageModifier;         // multiplies the amount of crushing damage taken by a vehicle belonging to the same team

const DAMAGE_LARGE = 50.0f;		// how much damage constitutes

enum HitPosition
{
	HP_IGNORE,
	HP_HEAD,
	HP_FRONT,
	HP_BACK
};

// Speech Manager requires this characters VoiceSet
var(Speech)	String VoiceSetPackageName		    "Package name of the voice set for this character";
var(Speech) String CharacterNameLocalisationTag	"Localise tag for the character name";
var(Speech) String CharacterName				"Actual Character name used in speech subtitles";

// player name - caches TRI player name because the TRI may be set to None when player does certain things such as driving a vehicle
var String playerNameMP;

var() float packDrawScale;

var() Material invicibilityMaterial;

// effects system

var EPhysics previousPhysics;                       // previous physics mode (used to stop movement effects when you leave PHYS_Movement)


enum SkiCompetencyLevels
{
	SC_Default,				// use character's competency
	SC_None,
	SC_LevelNovice,
	SC_LevelMedium,
	SC_LevelExpert
};

enum JetCompetencyLevels
{
	JC_Default,				// use character's competency
	JC_None,
	JC_LevelNovice,
	JC_LevelMedium,
	JC_LevelExpert
};

enum GroundMovementLevels
{
    GM_Any,
	GM_Sprint,
	GM_Run,
	GM_Walk,
	GM_None
};

// hack to allow me to compare these enums to a int/float (which Unreal doesn't allow)
const GM_Any_Int = 0;
const GM_Sprint_Int = 1;
const GM_Run_Int = 2;
const GM_Walk_Int = 3;

var bool	bTempInvincible;
var bool	bLocalTempInvincible;

// this character is an occupant of a vehicle that cannot be seen - this is a special case as they collide with actors for the sake of triggers
// but should be invisible to everything else and thus not take damage
var bool	bHiddenVehicleOccupant;

// Replication Info
var TribesReplicationInfo tribesReplicationInfo;

// Motor
var CharacterMotor motor;

var Weapon	weapon;
var Name	weaponBone;

var bool weaponPlayingArmAnimation;         // true if playing an arm animation for weapon hold. eg. buckler
var float weaponNotHeldTime;                // amount of time in seconds since a weapon has been held (eg. seconds since weapon!=none)

var Weapon altWeapon;				// Grenades

var Weapon fallbackWeapon;

const NUM_WEAPON_SLOTS = 3;
var Weapon weaponSlots[NUM_WEAPON_SLOTS];

var Name            eyeBoneName;	// Where we "See" from
var const int       eyeBoneIndex;
var const vector	eyeBoneOffset;	// cached value for AI vision system

var Controller		lastPossessor; // the last controller to possess this pawn

var float			HeadHeight "The height above the pivot at which the character head starts";

// god mode
var bool	bGodMode;

// Loadout
var() editinlineuse class<Loadout>	loadoutClass	"What is this character's equipment loadout? (Singleplayer use, use class browser to select a class without inheriting)";
var() class<Armor>					armorClass		"What is this character's armor class?";

var Loadout loadout;

var() bool bDisallowEquipmentDropOnDeath;

// Equipment linked list
var private Equipment m_equipmentHead;
var Equipment potentialEquipment; // Used for prompting the player to pickup a piece of equipment, and picking it up if they want to

// MP objects
var() bool bDontAllowCarryablePickups				"If true, this character won't be able to pickup any carryables";
var() bool bDontInteractWithTerritories				"If true, this character won't interact with territories at all";
var MPCarryable carryableReference;					// An instance of the carryables being carried
var array<MPCarryable> carryables;					// Stores all carryables being carried
var int numCarryables;								// Used to replicate the length of the carryables array
var MPCarryableThrower pseudoWeapon;				// Used for throwing carryables
var int numPermanentCarryables;						// The player keeps this number of carryables at all times, except on death (i.e.
													// this number of carryables can't be thrown)
var int lastCarryableNumber;						// Used to restrict broadcast messages

// Zooming
var() bool bCanZoom;
var private bool bZoomed;

// Misc UI
var() bool bDontAllowCommandScreen					"If true, this character won't be able to use the command screen";

// Jetpacking and skiing competency
var(AI) JetCompetencyLevels jetCompetency "How well can this character jetpack";
var(AI) SkiCompetencyLevels skiCompetency "How well can this character ski";
var(AI) bool bApplyHealthFilter "If false, the health filter for the chosen difficulty level is not applied.";

var class<CombatRole> combatRole;
var class<CombatRole> localCombatRole;

var name needToPlayArmAnim; // Used to resync arms with weapons if an animation plays while the character has no arms

var() bool bDisableSkiing;

var() bool bDisableJetting;
var name jetpackBone;
var private Jetpack jetpack;

var Arms arms;

// functionality used by packs
var bool regenerationActive;
var int regenerationRateHealthPerSecond;

var bool shieldActive;
var float shieldFractionDamageBlocked;

var Pack pack;

var class<Pack> heldPackClass;
var class<Pack> localPackClass;

var name packLeftBone;
var name packRightBone;

var StaticMeshAttachment leftPack;
var StaticMeshAttachment rightPack;

// Pack effect flags
var bool bActivatingEffect;
var bool bLocalActivatingEffect;
var bool bActiveEffect;
var bool bLocalActiveEffect;
var bool bDeactivatingEffect;
var bool bLocalDeactivatingEffect;
var bool bActivatingEffectStarted;
var bool bLocalActivatingEffectStarted;
var bool bActiveEffectStarted;
var bool bLocalActiveEffectStarted;

var bool bUnactivatingEffect;
var bool bLocalUnactivatingEffect;
var bool bUnactiveEffect;
var bool bLocalUnactiveEffect;
var bool bUndeactivatingEffect;
var bool bLocalUndeactivatingEffect;
var bool bUnactivatingEffectStarted;
var bool bLocalUnactivatingEffectStarted;
var bool bUnactiveEffectStarted;
var bool bLocalUnactiveEffectStarted;

var bool bSpawningAtVehicle;

// deployables
var Deployable deployable;

var private float healthInjectionRatePerSecond;
var private float healthInjectionAmount;

// Character visualisation debug object
var CharacterVisualisation visualisation;

// Grappler related variables
const ROPE_MESH_LENGTH = 512;

var class<Grappler>			grapplerClass;

var GrapplerProjectile		proj;
var GrapplerRope			rope;
var float                   ropeNaturalLength;

var Array<Character>		grapplerCharacters; // Characters that are grappling this character

var bool					bAttached;
var bool					bLocalAttached;

var bool					bReelIn;
// End grappler related variables

// The last object hit by the character's weapon
var Pawn	lastHitObject;
var bool	bObjectHit;
var bool	bLocalObjectHit;
var bool	bHitRegistered;

var bool bIsLocalCharacter;

// character movement support

var String movementConfiguration;       // overridden by armor if wearing any

var float energy;                       // current energy - read/write
var float energyMinimum;                // minimum energy for jetpack - read only output from fusion
var float energyMaximum;                // maximum energy - read only output from fusion
var float energyRechargeRate;           // energy recharge rate - read only output from fusion, includes scale factor below
var float energyRechargeScale;          // energy recharge scale - read/write
var float energyWeaponDepleted;			// the amount of energy a weapon depleted in the last tick

// camera
var bool bZoomOutOnSpawn;

// Skins
var class<SkinInfo> userSkinClass; // for reference only, change in attached tribesReplicationInfo

// clientside pain sounds
enum EClientPainType
{
	CLIENTPAIN_Hurt,
	CLIENTPAIN_BigHurt,
	CLIENTPAIN_Death,
	CLIENTPAIN_Cratered,
	CLIENTPAIN_Burnt
};

var float localHealth;
var EClientPainType clientPainType;

struct native QuickChatInfo
{
	var bool bSwitch;
	var String TagID; 
};

// for animation
var QuickChatInfo QCAnimData;
var QuickChatInfo LocalQCAnimData;

// for speech
var QuickChatInfo QCTalkData;
var QuickChatInfo LocalQCTalkData;

// ***************************************************************************************

// dummy space for native csiro jetpack pointer - this must be the last data in character!

var transient const noexport byte dummy[4];

// ***************************************************************************************

// Estimate enough needed to jetpack between two points
native function float energyRequiredToJet(Vector a, Vector b, float velocity, bool jump);

// prefix movement configuration
native function prefixMovement(String name);

// Force movement configuration
native function forceMovement(String name);

// set debug movement flag
native function debugMovement(bool flag);

replication
{
	reliable if (ROLE == ROLE_Authority || bDemoRecording)
		combatRole, weapon, altWeapon, deployable, armorClass, carryableReference, numCarryables, pseudoWeapon, heldPackClass,
		m_bManualAnimation, proj, bAttached, bReelIn, ropeNaturalLength, lastHitObject, bObjectHit, bTempInvincible, HeadHeight,
		numPermanentCarryables, pack, bSpawningAtVehicle,
		QCTalkData, QCAnimData;

	// variables that are relevant only to owner
	unreliable if ((ROLE == ROLE_Authority && bNetOwner) || bDemoRecording)
		m_equipmentHead, weaponSlots, potentialEquipment, fallbackWeapon, healthInjectionAmount;

	// variables that are relevant only to others, not owner
	unreliable if ((ROLE == ROLE_Authority && !bNetOwner) || bDemoRecording)
		bActivatingEffect, bActiveEffect, bDeactivatingEffect, bActivatingEffectStarted, bActiveEffectStarted,
		bUnactivatingEffect, bUnactiveEffect, bUndeactivatingEffect, bUnactivatingEffectStarted, bUnactiveEffectStarted,
		clientPainType;

	// movement sim proxy data
	unreliable if ((ROLE == ROLE_Authority && !bNetOwner) || bDemoRecording)
        movementSimProxyInputX,
        movementSimProxyInputY,
        movementSimProxyInputThrust,
        movementSimProxyInputJump,
        movementSimProxyInputSki;

 	// replication from client to server
	reliable if (ROLE < ROLE_Authority)
		switchEquipment, serverDoInventoryRefill;
}

simulated function PrecacheSpeech(SpeechManager Manager)
{
	if (!self.IsA('AITalkingHead'))
		Manager.PrecacheAIVoiceSet(VoiceSetPackageName);
}


function destroyFallbackWeapon()
{
	if (fallbackWeapon != None)
	{
		fallbackWeapon.Destroy();
		fallbackWeapon = None;
	}
}

function spawnFallbackWeapon()
{
	if (armorClass != None && armorClass.default.fallbackWeaponClass != None)
	{
		fallbackWeapon = Spawn(armorClass.default.fallbackWeaponClass, self);
		fallbackWeapon.rookMotor = motor;
		fallbackWeapon.GotoState('Held');
	}
}

function equipFallbackWeapon()
{
	if (fallbackWeapon == None)
		spawnFallbackWeapon();

	motor.setWeapon(fallbackWeapon);
}

function bool canBeSensed()
{
	return bCanBeSensed && Controller != None;
}

simulated function String GetHumanReadableName()
{
	// handle MP case
	if (Level.NetMode != NM_StandAlone)
		return playerNameMP;

	if(CharacterName == "" && CharacterNameLocalisationTag != "")
		CharacterName = Localize("Names", CharacterNameLocalisationTag, "Localisation\\Speech\\CharacterNames");

	return CharacterName;
}

function Timer()
{
	removeTempInvincibility();
}

function removeTempInvincibility()
{
	UnTriggerEffectEvent('Invincible');
	bTempInvincible = false;
}

simulated function Material GetOverlayMaterial(int Index)
{
	local Material m;

	if (bTempInvincible)
		return invicibilityMaterial;
	else
	{
		if (pack != None)
		{
			m = pack.GetOverlayMaterialForOwner(Index);
			if (m != None)
				return m;
		}
	}

	return super.GetOverlayMaterial(Index);
}

simulated function PlayMovementSpeech(Name eventName)
{
	// ensure the voice set exists on the character
	if(Level.NetMode != NM_Standalone && TribesReplicationInfo != None)
		VoiceSetPackageName = TribesReplicationInfo.VoiceSetPackageName;

	if (VoiceSetPackageName != "")
		Level.speechManager.PlayMovementSpeech(self, eventName);
}

function serverDoInventoryRefill(float healthPerSecond)
{
	local Weapon w;

	if(health < HealthMaximum)
	{
		stopHealthInjection();
		healthInjection(healthPerSecond, HealthMaximum - Health);
	}

	w = Weapon( nextEquipment( None, class'Weapon' ));
	while(w != None)
	{
		w.increaseAmmo(w.getMaxAmmo() - w.AmmoCount);
		w = Weapon( nextEquipment( w, class'Weapon' ));
	}

	if(armorClass.static.getHandGrenadeClass() != None)
		newGrenades(armorClass.static.getHandGrenadeClass());
}

// healthInjection
// Adds a health injection to this character. The specified health amount shall be applied to this
// character at the specified rate.
function healthInjection(float healthPerSecond, float healthAmount)
{
	healthInjectionRatePerSecond = healthPerSecond;
	healthInjectionAmount += healthAmount; 
}

// clampHealthInjection
// Clamps current health injection such that it will not apply excess health.
function clampHealthInjection()
{
	if (healthInjectionAmount > (healthMaximum - health))
		healthInjectionAmount = healthMaximum - health;
}

function stopHealthInjection()
{
	healthInjectionAmount = 0;
}

function float getHealthInjectionAmount()
{
	return healthInjectionAmount;
}

simulated function IFiringMotor firingMotor()
{
	return motor;
}

// Returns the character (if it exists) that is controlling this rook (i.e. turret or vehicle)
simulated function Character getControllingCharacter()
{
	return self;
}

// getDrivenVehicle
// Returns None if no vehicle is begin driven.
simulated native function Vehicle getDrivenVehicle();

// get the vehicle or turret the character is in (or None)
simulated native function Rook getMount();

// try to exit a vehicle or turret (may not succeed)
function exitMount( Pawn vehicleOrTurret )
{
	local int i;
	local Vehicle vehicle;
	local Turret turret;

	vehicle = Vehicle( vehicleOrTurret );
	turret = Turret( vehicleOrTurret );

	// Vehicle
	if ( vehicle != None )
	{
		for ( i = 0; i < vehicle.positions.length; ++i )
		{
			if ( self == vehicle.positions[i].occupant )
				vehicle.positions[i].wantsToGetOut = true;
		}
	}
	// Turret
	else if ( turret != None )
	{
		if ( self == turret.Driver )
			turret.bGetOut = true;
	}
}

// is the character in a specified vehicle or turret?
function bool bIsInMount( Pawn vehicleOrTurret )
{
	local int i;
	local Vehicle vehicle;
	local Turret turret;

	vehicle = Vehicle( vehicleOrTurret );
	turret = Turret( vehicleOrTurret );

	// Vehicle
	if ( vehicle != None )
	{
		for ( i = 0; i < vehicle.positions.length; ++i )
		{
			if ( self == vehicle.positions[i].occupant )
				return true;
		}
	}
	// Turret
	else if ( turret != None )
	{
		if ( self == turret.Driver )
			return true;
	}
	return false;
}

// updateCasts
// Do your derived-class casts here, or they will not update properly on network clients
simulated function updateCasts()
{
	tribesReplicationInfo = TribesReplicationInfo(PlayerReplicationInfo);
}

// Destroyed
simulated function Destroyed()
{
	//log( name @ "DESTROYED CALLED" );

	detachGrapple();

	UnregisterVisionNotification(self);

	destroyEquipment();
	
	if (jetpack != None)
		jetpack.destroy();

	if (arms != None)
		arms.destroy();

	if (rope != None)
		rope.Destroy();

	destroyThirdPersonMesh();

    destroyAnimationSystem();
	
	if (motor != None)
		motor.Destroy();

    // todo: release animation states and channels

    // stop movement effects

    stopMovementEffects();

	UnTriggerEffectEvent('Invincible');
    
    // call super

	Super.Destroyed();
}

simulated function setJetpack(Jetpack newJetpack)
{
	if (jetpack != None)
	{
		jetpack.destroy();
		jetpack = None;
	}

	if (newJetpack != None)
	{
		jetpack = newJetpack;
		attachToBone(jetpack, jetpackBone);
	}
}

simulated function hideJetpack()
{
	if (jetpack != None)
		jetpack.bHidden = true;
}

simulated function showJetpack()
{
	if (jetpack != None)
		jetpack.bHidden = false;
}

function setArmsMesh(Mesh armsMesh)
{
	if (armsMesh == None)
		return;

	if (arms == None)
		arms = Spawn(class'Arms', self);

	arms.LinkMesh(armsMesh);
}

function OnViewerSawPawn(Pawn Viewer, Pawn Seen)
{

}

function OnViewerLostPawn(Pawn Viewer, Pawn Seen)
{

}

// OnHitObject
//
// Called when the character has hit an object with a weapon
// used for updating the HUD with feedback in PlayerCharacterController.
function OnHitObject(Pawn victim)
{
	lastHitObject = victim;
	bObjectHit = ! bObjectHit;
	// need to register a hit for the listen server
	bHitRegistered = true;
}

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	//if (vision != None)
	//	vision.RegisterVisionNotification(self);

	updateCasts();
	
	Health = healthMaximum;
	
	debugMovement(false);

    wake();
}

// PostNetBeginPlay
simulated function PostNetBeginPlay()
{
	grapplerClass = class<Grappler>(DynamicLoadObject("EquipmentClasses.WeaponGrappler", class'Class'));

	if (grapplerClass == None)
		Log("Couldn't find EquipmentClasses.WeaponGrappler, grapplers will use default settings");

	motor = new class'CharacterMotor'(self);

	initialiseEquipment();

	super.PostNetBeginPlay();

    // Set ownership of TribesReplicationInfo
    if ( TribesReplicationInfo != None && TribesReplicationInfo.Owner == None )
	    TribesReplicationInfo.SetOwner(Controller);
    
    initializeAnimationSystem();
    
	collisionMaterialObject = new class'Material'();
	
	PlayEffect("CharacterStart");
	
	debugMovement(false);

	wake();
	
	// fill sim proxy data with initial position
	
	movementSimProxyPosition = Location;
	movementSimProxyVelocity = vect(0,0,0);
	movementSimProxyRotation = Rotation;
	movementSimProxyPending = true;
	
	// always holding a weapon in multiplayer
	
	weaponNotHeldTime = 0;
	
	// clear last collision time to ensure no crunch sound occurs first land
	
	lastMovementCollisionTime = 0;
}

simulated function PostLoadGame()
{
	super.PostLoadGame();

    initializeAnimationSystem();
	
	debugMovement(false);

	wake();
}

function initialiseEquipment()
{
	if ( loadoutClass != None )
	{
		loadout = new loadoutClass;
		loadout.equip( self );
		giveDefaultWeapon();
	}

	if ( armorClass != None )
	{
		armorClass.static.equip( self );

		// Reset the personalShield
		resetPersonalShield();
	}
}

function TravelPreAccept()
{
	destroyEquipment();
}

function TravelPostAccept()
{
	giveDefaultWeapon();
}

// PostNetReceive
simulated function PostNetReceive()
{
	updateCasts();

	// Just in case it breaks something important:
	//
	// I added check to ensure we don't try and do this until the 
	// TribesReplicationInfo is replicated. It seems that sometimes
	// the character doesn't have the replication info and thus may 
	// end up with the wrong jetpack.
	//
	if (combatRole != localCombatRole && tribesReplicationInfo != None) // detect combat role change
	{
		if (arms == None)
			arms = Spawn(class'Arms', self);

		arms.LinkMesh(m_team.getArmsMeshForRole(combatRole));

		if (needToPlayArmAnim != '')
			arms.PlayAnim(needToPlayArmAnim);

		setJetpack(m_team.getJetpackForRole(self, combatRole, tribesReplicationInfo.bIsFemale));

		localCombatRole = combatRole;
	}

	updatePackEffects();

	if (bAttached && !bLocalAttached)
		playAttachedAnim();

	bLocalAttached = bAttached;

	if(bObjectHit != bLocalObjectHit)
		bHitRegistered = true;

	bLocalObjectHit = bObjectHit;

	if (bTempInvincible != bLocalTempInvincible)
	{
		if (bTempInvincible)
			TriggerEffectEvent('Invincible');
		else
			UnTriggerEffectEvent('Invincible');

		bLocalTempInvincible = bTempInvincible;
	}

	if (localHealth != health && !bNetOwner)
	{
		if (health < localHealth)
		{
			switch(clientPainType)
			{
			case CLIENTPAIN_Hurt:
				PlayHurtSound(localHealth - health);
				break;
			case CLIENTPAIN_Death:
				PlayDeathSound(false, false);
				break;
			case CLIENTPAIN_Cratered:
				PlayDeathSound(true, false);
				break;
			case CLIENTPAIN_Burnt:
				PlayDeathSound(false, true);
				break;
			}
			
			PlayFlinchAnimation();
		}
		localHealth = health;
	}

	if(QCTalkData.bSwitch != LocalQCTalkData.bSwitch)
	{
		LocalQCTalkData.bSwitch = QCTalkData.bSwitch;
		if(TribesReplicationInfo != None)
			Level.speechManager.PlayQuickChatSpeech(TribesReplicationInfo, TribesReplicationInfo.VoiceSetPackageName, Name(QCTalkData.TagID), self);
	}

	if(QCAnimData.bSwitch != LocalQCAnimData.bSwitch)
	{
		LocalQCAnimData.bSwitch = QCAnimData.bSwitch;
		
		if (movementAirborne)
		{
		    if(!IsPlayingUpperBodyAnimation())
			    playUpperBodyAnimation(QCAnimData.TagID);
	    }
	    else
	    {
		    if(!IsPlayingAnimation())
			    playAnimation(QCAnimData.TagID);
	    }
	}

	checkManualAnimation();
}

function PlayQCSpeech(String Tag)
{
	QCTalkData.bSwitch = ! QCTalkData.bSwitch;
	QCTalkData.TagID = Tag;

	if(Level.NetMode == NM_ListenServer && TribesReplicationInfo != None)
		Level.speechManager.PlayQuickChatSpeech(TribesReplicationInfo, TribesReplicationInfo.VoiceSetPackageName, Name(QCTalkData.TagID), self);
}

function PlayQCAnimation(String AnimationName)
{
	QCAnimData.bSwitch = ! QCAnimData.bSwitch;
	QCAnimData.TagID = AnimationName;

	if(Level.NetMode == NM_ListenServer)
	{
		if (movementAirborne)
		{
		    if(!IsPlayingUpperBodyAnimation())
			    playUpperBodyAnimation(QCAnimData.TagID);
	    }
	    else
	    {
		    if(!IsPlayingAnimation())
			    playAnimation(QCAnimData.TagID);
	    }
	}
}

simulated function updatePackEffects()
{
	if (heldPackClass != localPackClass) // detect pack change
	{
		destroyThirdPersonMesh();

		if (heldPackClass != None)
			createThirdPersonMesh(heldPackClass);

		localPackClass = heldPackClass;
	}

	if (heldPackClass != None)
	{
		// play pack effects
		if (bActivatingEffect != bLocalActivatingEffect)
		{
			playPackEffect(heldPackClass.default.activatingEffectName);
			bLocalActivatingEffect = bActivatingEffect;
		}

		if (bActiveEffect != bLocalActiveEffect)
		{
			playPackEffect(heldPackClass.default.activeEffectName);
			bLocalActiveEffect = bActiveEffect;
		}

		if (bDeactivatingEffect != bLocalDeactivatingEffect)
		{
			playPackEffect(heldPackClass.default.deactivatingEffectName);
			bLocalDeactivatingEffect = bDeactivatingEffect;
		}

		if (bActivatingEffectStarted != bLocalActivatingEffectStarted)
		{
			playPackEffect(heldPackClass.default.activatingEffectStartedName);
			bLocalActivatingEffectStarted = bActivatingEffectStarted;
		}

		if (bActiveEffectStarted != bLocalActiveEffectStarted)
		{
			playPackEffect(heldPackClass.default.activeEffectStartedName);
			bLocalActiveEffectStarted = bActiveEffectStarted;
		}

		// Stop pack effects
		if (bUnactivatingEffect != bLocalUnactivatingEffect)
		{
			stopPackEffect(heldPackClass.default.activatingEffectName);
			bLocalUnactivatingEffect = bUnactivatingEffect;
		}

		if (bUnactiveEffect != bLocalUnactiveEffect)
		{
			stopPackEffect(heldPackClass.default.activeEffectName);
			bLocalUnactiveEffect = bUnactiveEffect;
		}

		if (bUndeactivatingEffect != bLocalUndeactivatingEffect)
		{
			stopPackEffect(heldPackClass.default.deactivatingEffectName);
			bLocalUndeactivatingEffect = bUnactiveEffect;
		}

		if (bUnactivatingEffectStarted != bLocalUnactivatingEffectStarted)
		{
			stopPackEffect(heldPackClass.default.activatingEffectStartedName);
			bLocalUnactivatingEffectStarted = bUnactivatingEffectStarted;
		}

		if (bUnactiveEffectStarted != bLocalUnactiveEffectStarted)
		{
			stopPackEffect(heldPackClass.default.activeEffectStartedName);
			bLocalUnactiveEffectStarted = bUnactiveEffectStarted;
		}
	}
}

simulated function playPackEffect(Name effectEvent)
{
	if (leftPack != None)
		leftPack.TriggerEffectEvent(effectEvent);

	if (rightPack != None)
		rightPack.TriggerEffectEvent(effectEvent);
}

simulated function stopPackEffect(Name effectEvent)
{
	if (leftPack != None)
		leftPack.UnTriggerEffectEvent(effectEvent);

	if (rightPack != None)
		rightPack.UnTriggerEffectEvent(effectEvent);
}

simulated function destroyThirdPersonMesh()
{
	if (leftPack != None)
		leftPack.destroy();
	if (rightPack != None)
		rightPack.destroy();
}

simulated function createThirdPersonMesh(class<Pack> packClass)
{
	if (packClass != None && packClass.default.thirdPersonMesh != None)
	{
		leftPack = new class'StaticMeshAttachment';
		leftPack.SetStaticMesh(packClass.default.thirdPersonMesh);
		leftPack.setDrawScale(packDrawScale);
		leftPack.CullDistance = packClass.default.CullDistance;
		attachToBone(leftPack, packLeftBone);

		rightPack = new class'StaticMeshAttachment';
		rightPack.SetStaticMesh(packClass.default.thirdPersonMesh);
		rightPack.setDrawScale(packDrawScale);
		rightPack.CullDistance = packClass.default.CullDistance;
		attachToBone(rightPack, packRightBone);
	}
}

// Tick
simulated function Tick(float Delta)
{
    local string configuration;
	local float tickHealthInjectionAmount;

	Super.Tick(Delta);

	if (!bIsLocalCharacter && Owner == Level.GetLocalPlayerController())
		bIsLocalCharacter = true;

	// kill ourselves if we are outside the boundary volume
	if ((Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer) && Level.game.boundaryVolume != None &&
			!Level.game.boundaryVolume.encompasses(self))
		TakeDamage(health + 1, None, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'DamageType');

	// update MP player name
	if (Level.NetMode != NM_StandAlone && tribesReplicationInfo != None)
		playerNameMP = tribesReplicationInfo.playerName;
	
	tickGrappler(Delta);

    // update critical movement values from armor if wearing any

    if (armorClass!=None)
    {
        if (pack!=none && SpeedPack(pack)!=none)
        {
            // speed pack movement configurations specific to armor
            
            if (SpeedPack(pack).IsInState('Active'))
                configuration = armorClass.default.movementConfigurationFastActive;
            else
                configuration = armorClass.default.movementConfigurationFastPassive;
        }
        else
        {        
            // standard armor movement configuration
        
            configuration = armorClass.default.movementConfiguration;
        }
        
        // armor specific knockback scale

        movementKnockBackScale = armorClass.default.knockBackScale;
    }
    else
    {
        // default movement configuration and knockback scale
    
        configuration = default.movementConfiguration;
        movementKnockBackScale = default.movementKnockBackScale;
    }
    
    if (configuration!=movementConfiguration)
    {
        //log("switching movement configuration: "$movementConfiguration$" -> "$configuration);

        movementConfiguration = configuration;
    }
    
    // apply current weapon arm animation loop
    
    if (weapon!=none && animationManager!=none)
    {
        if (weapon.equippedArmAnim!="")
        {
            if (!isLoopingArmAnimation() || getArmAnimation()!=weapon.equippedArmAnim)
            {
                loopArmAnimation(weapon.equippedArmAnim);
                weaponPlayingArmAnimation = true;
            }
        }
        else if (weaponPlayingArmAnimation)
        {
            stopArmAnimation();
            weaponPlayingArmAnimation = false;
        }
    }
	else if (weaponPlayingArmAnimation)
    {
        stopArmAnimation();
        weaponPlayingArmAnimation = false;
    }
    
    // update weapon not held time
    
    if (weapon==none)
    {
        weaponNotHeldTime += delta;
    }
    else
    {
        weaponNotHeldTime = 0;
    }

    // save for ragdoll velocity inheritance
    
    ragdollInheritedVelocity = velocity;

	// stop movement effects when we leave movement physics
	
	if (previousPhysics==PHYS_Movement && Physics!=PHYS_Movement)
	    stopMovementEffects();
	    
	previousPhysics = Physics;

    // setup last movement collision time to avoid crunch landing sound right after spawning
    
    if (lastMovementCollisionTime==0)
        lastMovementCollisionTime = level.timeSeconds + 1.0;
        
    // make sure that arms are hidden if not holding a weapon

	if (weapon == None && arms != None)
		arms.bHidden = true;

	// **** anything below this line will not get called when you are dead! ****
	    
    if (!isAlive())
        return;

	// **** server code ****
	
	if (Level.NetMode != NM_Client)
	{
        checkManualAnimation();

		if (tribesReplicationInfo != None)
		{
			tribesReplicationInfo.health = Health;
		}
		
		// clear blocked movement damage flag if set
		
		blockMovementDamage = false;

		// do regeneration functionality if necessary
		if (regenerationActive)
		{
			health += regenerationRateHealthPerSecond * Delta;
			if (health > healthMaximum)
				health = healthMaximum;
		}

		// do health injection functionality
		if (healthInjectionAmount > 0)
		{
			tickHealthInjectionAmount = Delta * healthInjectionRatePerSecond;

			// update total health injection amount
			if (tickHealthInjectionAmount > healthInjectionAmount)
			{
				tickHealthInjectionAmount = healthInjectionAmount;
				healthInjectionAmount = 0;
			}
			else
			{
				healthInjectionAmount -= tickHealthInjectionAmount;
			}

			health += tickHealthInjectionAmount;
			if (health > healthMaximum)
				health = healthMaximum;
		}
	}

	// **** client and server code ****

	// update skin
	updateUserSkin();

	// update animation springs

    animationHeightSpring.target = Location.z;
    animationVelocitySpring.target = Velocity.z;

    animationHeightSpring.Update(delta);
    animationVelocitySpring.Update(delta);
}

native simulated function checkManualAnimation();

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
	
	// Setup Vision Bone
    setupVisionBone();

	lastPossessor = C;

	updateCasts();
}

function Unpossessed()
{
	Super.Unpossessed();

	if (arms != None)
		arms.bHidden = true;
}

// Sets the eyeBoneIndex to the correct bone index for the bone set in eyeBoneName
native function setupVisionBone();

native function bool isInAir();

native function float getAirSpace();

// use energy.
// returns true if enough energy was available,
// false if not enough energy is available.

function bool useEnergy(float quantity)
{
	if (quantity>energy)
		return false;

	energy -= quantity;

	return true;
}

function changeEnergy(float delta)
{
	energy += delta;

	// Clamp
	if (energy < 0)
		energy = 0;
	if (energy > energyMaximum)
		energy = energyMaximum;
}

function changeHealth(float delta)
{
	health += delta;

	// Clamp
	if (health < 0)
		health = 0;
	if (health > healthMaximum)
		health = healthMaximum;
}

// Special weapon useEnergy variant to pass data down
// to the client side character class for display
function bool weaponUseEnergy(float quantity)
{
	if(useEnergy(quantity))
	{
		PlayerCharacterController(Controller).clientWeaponUseEnergy(quantity);
		return true;
	}

	return false;
}

simulated function clientWeaponUseEnergy(float quantity)
{
	if (Level.NetMode == NM_Client)
	{
		energy -= quantity;

		if (energy < 0.0)
			energy = 0.0;
	}

	energyWeaponDepleted += quantity;
}

simulated function useHealthKit()
{
	local HealthKit hk;

	hk = HealthKit(nextEquipment(None, class'HealthKit'));

	if (hk != None)
	{
	    PlayEffect("CharacterUseHealthKit");
		hk.use();
	}
	else
		ClientMessage("You don't have a health kit");
}

// if a pseudoweapon is attached to a carryable that the player has picked up, then pass "Alt Weapon Fire" function to that.
// Otherwise, pass it to the standard alt weapon.
// MJ edit:  We'll never allow carryables to be thrown via alt fire
simulated event Weapon GetAltWeapon()
{
//	if(carryableReference != None && !carryableReference.Class.default.bIsWeaponType)
//		return pseudoWeapon;
//	else
		return altWeapon;
}

simulated function dropWeapon()
{
	local Rotator droppedRotation;

	droppedRotation.yaw = rotation.yaw;

	if(deployable != None)
	{
		// rotate deployables to be upright for visibility
		deployable.SetRotation(droppedRotation);
		deployable.drop();
	}

	if (Weapon != None)
	{
	    PlayEffect("CharacterDropWeapon");
		weapon.SetRotation(droppedRotation);
		weapon.drop();
	}
}

function switchEquipment()
{
	if (potentialEquipment != None)
	{
	    PlayEffect("CharacterSwitchEquipment");
		potentialEquipment.doSwitch(self);
	}
}

function dropCarryables()
{
	local int i;

	if (carryableReference == None)
		return;

	// Before dropping all the carryables, compose them into the largest possible denominations (if applicable)
	composeCarryables(true);

	// Drop the rest with random spread
	for (i=1; i<carryables.Length; i++)
	{
		carryables[i].drop(true);
	}

	// Drop the first carryable without random spread
	carryables[0].drop(false);

	clearCarryables();
}

function pickupCarryable(MPCarryable c)
{
	carryables[carryables.Length] = c;
	numCarryables = numCarryables + 1;

	movementExtraMass += c.extraMass;

	// If this is the first pickup, remember the instance for replication purposes
	if (carryableReference == None)
	{
		// pickup() returns an instance, which is self in the case of regular MPCarryables or
		// the first instance in the case of metacarryables
		carryableReference = c;

		// Also create a new pseudoWeapon for it, which is used for throwing the carryable
		pseudoWeapon = new carryableReference.carriedObjectClass();
		pseudoWeapon.setCarryable(carryableReference);
		pseudoWeapon.SetOwner(self);
		pseudoWeapon.rookOwner = self;
		pseudoWeapon.rookMotor = motor;
		pseudoweapon.GotoState('Held');

		// We want this carryable to work just like a weapon does.
		if (carryableReference.bIsWeaponType)
		{
			// add pseudoweapon to inventory
			addEquipment(pseudoWeapon);
		}
		else
		{
			//pseudoweapon.equip();
		}
	}
}

function clearCarryables()
{
	// Make sure it hasn't already been cleared (can be called twice if, for example, a ball
	// is thrown and a goal is scored in the same tick)
	if (carryableReference == None)
		return;

	movementExtraMass -= numCarryables * carryableReference.extraMass;
	carryableReference = None;
	carryables.Length = 0;
	numCarryables = 0;

	// Remove pseudoweapon from player's inventory
	pseudoWeapon.GotoState('Dropped');

	// Destroy it since it is no longer needed
	pseudoWeapon.Destroy();
}

// If current carryable class has denominations, compose all carryables into largest denominations
function composeCarryables(optional bool bDropAll)
{
	local int i, j;
	local array<MPCarryable> newArray;
	local MPMetaCarryable metaCarryable;
	local int numToDrop;

	if (carryableReference == None || carryableReference.denominations.Length == 0)
		return;

	if (bDropAll)
		numToDrop = numCarryables;
	else
		numToDrop = numDroppableCarryables();

	// Start at the largest denomination.  For each denomination, try to compose a metacarryable
	for (i=carryableReference.denominations.Length-1; i>=0; i--)
	{
		// If there are enough carryables to compose a denomination
		while (numToDrop / carryableReference.denominations[i].default.maxCarryables > 0)
		{
			//Log("Creating denomination of size "$carryableReference.denominations[i].default.maxCarryables);
			// Spawn a new metaCarryable and assign its data; make sure not to spawn it on the character otherwise
			// it gets picked up again immediately
			metaCarryable = spawn(carryableReference.denominations[i],,,Location + Normal(Vector(Rotation)) * pseudoWeapon.extraSpawnDistance);

			if (metaCarryable == None)
			{
				Log("MetaCarryable composition error:  could not spawn metaCarryable of type "$carryableReference.denominations[i]);
				return;
			}

			// Add enough carryables to fill up the denomination
			for (j=0; j<carryableReference.denominations[i].default.maxCarryables; j++)
			{
				//Log("Added "$carryables[j]$" to "$metaCarryable);
				metaCarryable.add(carryables[j]);
			}
			metaCarryable.bInitialized = true;

			// Put the metaCarryable in a new array to be copied later
			newArray[newArray.Length] = metaCarryable;

			// Remove the carryables that were transferred to the metaCarryable
			carryables.Remove(0, j);
			numCarryables = numCarryables - j;
			numToDrop = numToDrop - j;

			// After removal, this while loop will repeat if there are still enough carryables to
			// fill the current denomination
		}
	}

	// Copy the newArray to the rest of the character's carryables array
	for (i=0; i<newArray.Length; i++)
	{
		carryables[carryables.Length] = newArray[i];
	}

	//Log("Contents of carryables array after composition:");
	//for (i=0; i<carryables.Length; i++)
	//	Log("  carryables array: "$carryables[i]);
}

simulated function int numDroppableCarryables()
{
	return numCarryables - numPermanentCarryables;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(4,YPos);
	if (Weapon != None)
		Canvas.DrawText("Weapon State: "$Weapon.GetStateName());
	else
		Canvas.DrawText("Weapon State: no weapon");
	YPos += YL;

	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Energy:" @ energy);
	YPos += YL;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local MPAreaTrigger areaTrigger;
	local Name squadLabel;
	local Rook killerRook;

	if (!bDisallowEquipmentDropOnDeath)
		dropEquipment();

	destroyEquipment();

    Super.Died( Killer, damageType, HitLocation );

	detachGrapple();

	if (squad() != None)
		squadLabel = squad().Label;

	if ( Killer!= None && Killer.Pawn != None)
	{
		killerRook = Rook(Killer.Pawn);
		if (killerRook != None)
			dispatchMessage(new class'MessageDeath'(killerRook.getKillerLabel(), label, Killer.Pawn.PlayerReplicationInfo, PlayerReplicationInfo, squadLabel));
		else
			dispatchMessage(new class'MessageDeath'(Killer.Pawn.label, label, Killer.Pawn.PlayerReplicationInfo, PlayerReplicationInfo, squadLabel));
	}
	else
		dispatchMessage(new class'MessageDeath'(self.label, label, PlayerReplicationInfo, PlayerReplicationInfo, squadLabel));
		
	PlayEffect("CharacterDied");

	if (PlayerCharacterController(Controller) != None)
	{
		if (weapon != None)
			PlayerCharacterController(Controller).lastWeaponClass = weapon.Class;
		else
			PlayerCharacterController(Controller).lastWeaponClass = None;
	}

	if (carryableReference != None)
		carryableReference.onCarrierDeath(Killer);

	// Force immediate UnTouch on MPAreaTriggers
	ForEach TouchingActors(class'MPAreaTrigger', areaTrigger)
	{
		areaTrigger.UnTouch(self);
	}

	dropCarryables();

	if (arms != None)
		arms.bHidden = true;
}

// return gravity in Unreal units
native function float gravity();

// effect system code

simulated function StopMovementEffects()
{
    // stop movement looping effects
    
	StopLoopingEffect("MovementWater");

	StopLoopingEffect("MovementSki");
	StopLoopingEffect("MovementSkiGrounded");
	StopLoopingEffect("MovementSkiAirborne");

	StopLoopingEffect("MovementThrust");
	StopLoopingEffect("MovementThrustUnderWater");
	StopLoopingEffect("MovementThrustAboveWater");

	StopLoopingEffect("MovementStand");
	StopLoopingEffect("MovementStop");
	StopLoopingEffect("MovementWalk");
	StopLoopingEffect("MovementRun");
	StopLoopingEffect("MovementSprint");
	StopLoopingEffect("MovementSlide");
	StopLoopingEffect("MovementSwim");
	StopLoopingEffect("MovementFloat");
	StopLoopingEffect("MovementAirborne");
	StopLoopingEffect("MovementAirControl");
	StopLoopingEffect("MovementZeroGravity");
	StopLoopingEffect("MovementElevator");
}

simulated function string VelocityTag(Vector velocity)
{
    local float scale;

    scale = VSize(velocity) / 80;
    
    //log("scale: "$scale);

	if (scale<10)
    	return "Tiny";
	else if (scale<20)
    	return "Small";
    else if (scale<30)
    	return "Medium";
    else if (scale<40)
    	return "Large";
    else
    	return "Extreme";
}

simulated function string DamageTag(float damage)
{
	if (damage<2.5)
	    return "Tiny";
	else if (damage<5)
	    return "Small";
    else if (damage<10)
        return "Medium";
    else if (damage<25)
        return "Large";
    else
        return "Extreme";
}

simulated function StartGroundBasedLoopingEffect(String EffectName, optional String Tag)
{   
	StartLoopingEffect(EffectName, Tag, None, collisionMaterialObject);
}

// on movement collision.
// this method is called by fusion whenever a collision occurs

simulated event OnMovementCollision(Vector point, Vector normal, Vector impulse, int material)
{
    local bool feet;
    local string tag;
    
    if (level.timeSeconds<lastMovementCollisionTime+0.25)
        return;
        
    lastMovementCollisionTime = level.timeSeconds;
    
    tag = VelocityTag(impulse / Mass);

    if (point.z<location.z-CollisionHeight/2)
        feet = true;

    collisionMaterialObject.MaterialSoundType = material;
    collisionMaterialObject.MaterialVisualType = EMaterialVisualType(material);
    
    if (feet && movement!=MovementState_Ski)
    {
        if (movementTouching)
            return;
    
	    if (PlayEffect("MovementCollisionFeet", tag, None, collisionMaterialObject, point, Rotator(normal)))
            return;
    }

    if (movement==MovementState_Ski && tag=="Tiny")
        return;
    
   	PlayEffect("MovementCollision", tag, None, collisionMaterialObject, point, Rotator(normal));
}

// on movement collision damage.
// this method is called by fusion whenever a collision in the movement
// is suffiently large as to cause damage to the character.

simulated event OnMovementCollisionDamage(float damage)
{
    local class<MovementCollisionDamageType> collisionDamageType;

    if (blockMovementDamage)
        return;

    if (level.timeSeconds<lastMovementDamageTime+0.1)
        return;
        
    if (movement==MovementState_Elevator)       // no damage in elevator volumes
        return;
    
    // determine collision damage type
    
    collisionDamageType = class'MovementCollisionDamageType';
                                                                                                            
    if (armorClass!=None && armorClass.default.movementDamageTypeClass!=none)
        collisionDamageType = armorClass.default.movementDamageTypeClass; 
	
	TakeDamage(damage, self, vect(0,0,0), vect(0,0,0), collisionDamageType);

    PlayEffect("MovementCollisionDamage", DamageTag(damage));

    lastMovementDamageTime = level.timeSeconds;
}

// on movement crushing damage.
// this method is called by fusion when a heavy object such as a vehicle
// applies crushing the character by pushing into it.

simulated event OnMovementCrushingDamage(float damage, Pawn source)
{
    local Vehicle vehicle;
    local class<MovementCrushingDamageType> crushingDamageType;
    
    // determine crushing damage type
    
    crushingDamageType = class'MovementCrushingDamageType';
                                                                                                            
    if (armorClass!=None && armorClass.default.movementCrushingDamageTypeClass!=none)
        crushingDamageType = armorClass.default.movementCrushingDamageTypeClass; 
    
    if (source.IsA('Vehicle'))
    {
        // vehicle crushing damage

        vehicle = Vehicle(source);

        if (vehicle.CrushingDamageTypeClass!=None)
            crushingDamageType = vehicle.CrushingDamageTypeClass;
            
        if (vehicle.getControllingCharacter()!=None)
            source = vehicle.getControllingCharacter();
    }
    else
    {
        // crushed by havok object
        
        source = self;
    }

    // apply damage

    TakeDamage(damage, source, vect(0,0,0), vect(0,0,0), crushingDamageType);

    // play crushing damage effect

    PlayEffect("MovementCrushingDamage", DamageTag(damage));
}

// called when a movement jump occurs.

simulated event OnMovementJump()
{
    if (!movementSimProxyInputThrust)
        PlayEffect("MovementJump");
}

// on change airborne.
// called when a character's airborne state changes.

simulated event OnChangeAirborne(bool previous, bool current)
{
    if (previous==current)
    {
        log("*** on change airborne: no state change detected! ***");
        return;
    }

    //log("change airborne: "$previous$"->"$current);
}

// on change water.
// called when a character's water state changes.

simulated event OnChangeWater(bool previous, bool current)
{
    if (previous==current)
    {
        log("*** on change water: no state change detected! ***");
        return;
    }

    //log("change water: "$previous$"->"$current);
}

// on change underwater.
// called when a character's underwater state changes.

simulated event OnChangeUnderwater(bool previous, bool current)
{
    if (previous==current)
    {
        log("*** on change underwater: no state change detected! ***");
        return;
    }

    //log("change underwater: "$previous$"->"$current);
}

// on change collision material.
// called when the collision material changes.

simulated event OnChangeCollisionMaterial(int previous, int current)
{
    if (previous==current)
    {
        log("*** on change collision material: no state change detected! ***");
        return;
    }

    //log("change collision material: "$previous$"->"$current);
}

// on change ski input.
// called when the ski input changes.

simulated event OnChangeSkiInput(bool previous, bool current)
{
    if (previous==current)
    {
        log("*** on change collision material: no state change detected! ***");
        return;
    }

    //log("change ski input: "$previous$"->"$current);
}

// on change movement.
// This method is called when the character movement state changes

simulated event OnChangeMovement(MovementState previous, MovementState current)
{
    if (previous==current)
    {
        log("*** on change movement: no state change detected! ***");
        return;
    }

	// movement state change occured

	//log("movement state change: "$previous$" -> "$current);
}                            

// on change effects.
//
// called when one or more of the following states change:
// 
// 1. movement state (walk, run, thrust etc...)
// 2. airborne (true/false)
// 3. underwater (true/false)
// 4. water (true/false)
// 5. collision material (enum)
// 6. ski input (true/false)

simulated event OnChangeEffects( MovementState previousMovementState, MovementState currentMovementState, 
                                 bool previousAirborne, bool currentAirborne, 
                                 bool previousWater, bool currentWater, 
                                 bool previousUnderWater, bool currentUnderWater,
                                 int previousMaterial, int currentMaterial,
                                 bool previousSkiInput, bool currentSkiInput )
{
    if (previousMovementState==currentMovementState &&
        previousAirborne==currentAirborne &&
        previousWater==currentWater &&
        previousUnderWater==currentUnderWater &&
        previousMaterial==currentMaterial && 
        previousSkiInput==currentSkiInput)
    {
        log("*** on change effects: no state change detected! ***");
        return;
    }

    // ski input changes

    if (previousSkiInput==false && currentSkiInput==true)
	    StartLoopingEffect("MovementSki");
	else if (previousSkiInput==true && currentSkiInput==false)
	    StopLoopingEffect("MovementSki");

    // airborne changes

    if (previousAirborne==false && currentAirborne==true)
    {
        // not airborne -> airborne
        
        if (currentMovementState==previousMovementState && currentMovementState==MovementState_Ski)
            StopLoopingEffect("MovementSkiGrounded");
    }
    else
    {
        // airborne -> not airborne    

        if (currentMovementState==previousMovementState && currentMovementState==MovementState_Ski)
    		StartGroundBasedLoopingEffect("MovementSkiGrounded");
    }    

    // material changes
    
    if (previousMaterial!=currentMaterial)
    {
        if (currentMovementState==previousMovementState && currentMovementState==MovementState_Ski && previousAirborne==currentAirborne)
        {
            StopLoopingEffect("MovementSkiGrounded");
            StartGroundBasedLoopingEffect("MovementSkiGrounded");
        }
    }

    // movement state changes
    
    if (previousMovementState!=currentMovementState)
    {
	    // stop previous movement state effects
    	
	    switch (previousMovementState)
	    {
		    case MovementState_Thrust:
		        StopLoopingEffect("MovementThrust");
			    break;
			    
 		    case MovementState_Ski:
			    StopLoopingEffect("MovementSkiGrounded");
			    break;

		    case MovementState_Stand:
			    StopLoopingEffect("MovementStand");
			    break;

		    case MovementState_Stop:
			    StopLoopingEffect("MovementStop");
			    break;

		    case MovementState_Walk:
			    StopLoopingEffect("MovementWalk");
			    break;			
			    
		    case MovementState_Run:
			    StopLoopingEffect("MovementRun");
			    break;
			    
		    case MovementState_Sprint:
			    StopLoopingEffect("MovementSprint");
			    break;
			    
 		    case MovementState_Slide:
			    StopLoopingEffect("MovementSlide");
			    break;
			    
 		    case MovementState_Swim:
			    StopLoopingEffect("MovementSwim");
			    break;
			    
 		    case MovementState_Float:
			    StopLoopingEffect("MovementFloat");
			    break;
			    
 		    case MovementState_Skim:
			    StopLoopingEffect("MovementSkim");
			    break;
			    
		    case MovementState_Airborne:		
			    StopLoopingEffect("MovementAirborne");
			    break;			

		    case MovementState_AirControl:		
			    StopLoopingEffect("MovementAirControl");
			    break;			

		    case MovementState_ZeroGravity:		
			    StopLoopingEffect("MovementZeroGravity");
			    break;			

		    case MovementState_Elevator:		
			    StopLoopingEffect("MovementElevator");
			    break;			
	    }

        // start effects for current movement state
        
        if (currentMovementState==MovementState_Ski && !currentAirborne)
    		StartGroundBasedLoopingEffect("MovementSkiGrounded");
    	else if (currentMovementState==MovementState_Thrust)
    	    StartLoopingEffect("MovementThrust");

	    switch (currentMovementState)
	    {
		    case MovementState_Stand:
		        StartGroundBasedLoopingEffect("MovementStand");
		        break;

		    case MovementState_Stop:
		        StartGroundBasedLoopingEffect("MovementStop");
		        break;

		    case MovementState_Walk:
		        StartGroundBasedLoopingEffect("MovementWalk");
			    break;
    			
		    case MovementState_Run:
		        StartGroundBasedLoopingEffect("MovementRun");
			    break;
    			
		    case MovementState_Sprint:
		        StartGroundBasedLoopingEffect("MovementSprint");
			    break;
    			
		    case MovementState_Slide:
    		    StartGroundBasedLoopingEffect("MovementSlide");
			    break;
    			
		    case MovementState_Airborne:
    		    StartLoopingEffect("MovementAirborne");
			    break; 
    			
		    case MovementState_AirControl:
    		    StartLoopingEffect("MovementAirControl");
			    break; 
    			
		    case MovementState_Swim:
		        StartLoopingEffect("MovementSwim");
			    break;
    			
		    case MovementState_Float:
		        StartLoopingEffect("MovementFloat");
			    break;
    			
		    case MovementState_Skim:
		        StartLoopingEffect("MovementSkim");
			    break;
    			
		    case MovementState_ZeroGravity:
		        StartLoopingEffect("MovementZeroGravity");
			    break;
    			
		    case MovementState_Elevator:
		        StartLoopingEffect("MovementElevator");
			    break;
        }
    }

    // water changes

    if (currentWater && !previousWater)
    {
        // start water loop
    
        StartLoopingEffect("MovementWater");
        
    	PlayEffect("MovementEnterWater", VelocityTag(Velocity));
    }
    else if (!currentWater && previousWater)
    {
        // leave water
    
        StopLoopingEffect("MovementWater");
        
        PlayEffect("MovementLeaveWater", VelocityTag(Velocity));
    }

    // underwater changes

    if (currentUnderWater && !previousUnderWater)
    {
        // start UnderWater loop
    
        StartLoopingEffect("MovementUnderWater");
        
    	PlayEffect("MovementEnterUnderWater", VelocityTag(Velocity));
    }
    else if (!currentUnderWater && previousUnderWater)
    {
        // leave UnderWater
    
        StopLoopingEffect("MovementUnderWater");
        
        PlayEffect("MovementLeaveUnderWater", VelocityTag(Velocity));
    }
}

// enterManualAnimationState
// Call this function to disable the automatic movement animations
// This will allow you to play any animation you like on the character without interruption
function enterManualAnimationState()
{
	m_bManualAnimation = true;
}

// exitManualAnimationState
// Call this function to re-enable the automatic movement animations
function exitManualAnimationState()
{
	m_bManualAnimation = false;
}

simulated function initializeAnimationSystem()
{
    setupAnimationManager();
	setupAnimationStates();
	setupAnimationChannels();
	setupAnimationLayers();
	setupAnimationSprings();

	checkManualAnimation();
}

simulated function destroyAnimationSystem()
{
    local int i;

    if (animationManager!=None)
    {
        animationManager.delete();
        animationManager = None;
	}
	
	for (i=0; i<animationStates.Length; i++)
	    animationStates[i].delete();
	animationStates.length = 0;
	
	for (i=0; i<animationChannels.Length; i++)
	    animationChannels[i].delete();
	animationChannels.length = 0;
	
	if (primaryAnimationLayer!=none)
	{
	    primaryAnimationLayer.delete();
	    primaryAnimationLayer = none;
	}
	
	if (secondaryAnimationLayer!=none)
	{
	    secondaryAnimationLayer.delete();
	    secondaryAnimationLayer = none;
	}

    if (animationHeightSpring!=none)
    {
        animationHeightSpring.delete();
        animationHeightSpring = none;
    }
    
    if (animationVelocitySpring!=none)
    {
        animationVelocitySpring.delete();
        animationVelocitySpring = none;	
    }
}

simulated function setupAnimationManager()
{
	animationManager = new class'AnimationManager'();

    StopAnimating();
}

simulated function setupAnimationStates()
{
    local AnimationState animation;

    allocateAnimationStates(AnimationState_Count);
    
    // none
    
    animation = new class'AnimationState'();
    
    animation.name = "none";
    animation.type = AnimationType_IdleWithTurn;
    animation.blendInTime = 0.1;
    animation.blendTightness = 0.1;
    animation.centre = "";
    animation.forward = "";
    animation.back = "";
    animation.left = "";
    animation.right = "";
    animation.up = "";
    animation.down = "";
    
    setAnimationState(AnimationState_None, animation);
    
    // stand
    
    animation = new class'AnimationState'();
    
    animation.name = "stand";
    animation.type = AnimationType_IdleWithTurn;
    animation.blendInTime = 0.25;
    animation.blendTightness = 0.1;
    animation.centre = "stand";
    animation.forward = "";
    animation.back = "";
    animation.left = "turn_left";
    animation.right = "turn_right";
    animation.up = "";
    animation.down = "stand_down";
    
    setAnimationState(AnimationState_Stand, animation);
    
    // walk    
    
    animation = new class'AnimationState'();
    
    animation.name = "walk";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.25;
    animation.blendTightness = 0.1;
    animation.centre = "stand";
    animation.forward = "walk_forward";
    animation.back = "walk_back";
    animation.left = "walk_left";
    animation.right = "walk_right";
    animation.up = "";
    animation.down = "";
    animation.speed = walkAnimationSpeed;
    
    setAnimationState(AnimationState_Walk, animation);

    // run
    
    animation = new class'AnimationState'();
    
    animation.name = "run";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.25;
    animation.blendTightness = 0.1;
    animation.centre = "stand";
    animation.forward = "run_forward";
    animation.back = "run_back";
    animation.left = "run_left";
    animation.right = "run_right";
    animation.up = "";
    animation.down = "";
    animation.speed = runAnimationSpeed;
    
    setAnimationState(AnimationState_Run, animation);

    // sprint
    
    animation = new class'AnimationState'();
    
    animation.name = "sprint";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.25;
    animation.blendTightness = 0.1;
    animation.centre = "stand";
    animation.forward = "sprint_forward";
    animation.back = "sprint_back";
    animation.left = "sprint_left";
    animation.right = "sprint_right";
    animation.up = "";
    animation.down = "";
    animation.speed = sprintAnimationSpeed;
    
    setAnimationState(AnimationState_Sprint, animation);

    // ski
    
    animation = new class'AnimationState'();
    
    animation.name = "ski";
    animation.type = AnimationType_VelocitySpringAndAirborneUpDown;
    animation.blendInTime = 0.3;
    animation.blendTightness = 0.1;
    animation.centre = "ski";
    animation.forward = "";
    animation.back = "";
    animation.left = "ski_airborne_up";
    animation.right = "ski_airborne_down";
    animation.up = "ski_up";
    animation.down = "ski_down";
    
    setAnimationState(AnimationState_Ski, animation);

    // slide
    
    animation = new class'AnimationState'();
    
    animation.name = "slide";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.1;
    animation.blendTightness = 0.2;
    animation.centre = "slide";
    animation.forward = "slide_forward";
    animation.back = "slide_back";
    animation.left = "slide_left";
    animation.right = "slide_right";
    animation.up = "";
    animation.down = "";
    
    setAnimationState(AnimationState_Slide, animation);

    // stop
    
    animation = new class'AnimationState'();
    
    animation.name = "stop";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.1;
    animation.blendTightness = 0.1;
    animation.centre = "stop";
    animation.forward = "stop_forward";
    animation.back = "stop_back";
    animation.left = "stop_left";
    animation.right = "stop_right";
    animation.up = "";
    animation.down = "stop_down";
    
    setAnimationState(AnimationState_Stop, animation);

    // airborne
    
    animation = new class'AnimationState'();
    
    animation.name = "airborne";
    animation.type = AnimationType_AirborneUpDown;
    animation.blendInTime = 0.3;
    animation.blendTightness = 0.1;
    animation.centre = "airborne";
    animation.forward = "airborne_forward";
    animation.back = "airborne_back";
    animation.left = "airborne_left";
    animation.right = "airborne_right";
    animation.up = "airborne_up";
    animation.down = "airborne_down";
    
    setAnimationState(AnimationState_Airborne, animation);

    // air control
    
    animation = new class'AnimationState'();
    
    animation.name = "aircontrol";
    animation.type = AnimationType_StrafeDirectional;
    animation.blendInTime = 0.3;
    animation.blendTightness = 0.25;
    animation.centre = "airborne";
    animation.forward = "thrust_forward";
    animation.back = "thrust_back";
    animation.left = "thrust_left";
    animation.right = "thrust_right";
    animation.up = "";
    animation.down = "";
    
    setAnimationState(AnimationState_AirControl, animation);

    // thrust
    
    animation = new class'AnimationState'();
    
    animation.name = "thrust";
    animation.type = AnimationType_StrafeDirectional;
    animation.blendInTime = 0.3;
    animation.blendTightness = 0.25;
    animation.centre = "thrust";
    animation.forward = "thrust_forward";
    animation.back = "thrust_back";
    animation.left = "thrust_left";
    animation.right = "thrust_right";
    animation.up = "";
    animation.down = "";
    
    setAnimationState(AnimationState_Thrust, animation);

    // swim
    
    animation = new class'AnimationState'();
    
    animation.name = "swim";
    animation.type = AnimationType_DisplacementDirectional;
    animation.blendInTime = 0.3f;
    animation.blendTightness = 0.25;
    animation.centre = "thrust";
    animation.forward = "thrust_forward";
    animation.back = "thrust_back";
    animation.left = "thrust_left";
    animation.right = "thrust_right";
    animation.up = "";
    animation.down = "";
    
    setAnimationState(AnimationState_Swim, animation);
}

simulated function setupAnimationChannels()
{
    allocateAnimationChannels(AnimationChannel_Count);
}

simulated function setupAnimationLayers()
{
    primaryAnimationLayer = new class'AnimationLayer'();
    secondaryAnimationLayer = new class'AnimationLayer'();
}

simulated function setupAnimationSprings()
{
    animationHeightSpring = new class'AnimationSpring'(0.001,100);
    animationVelocitySpring = new class'AnimationSpring'(0.0001,500);
}

// allocate animation states.
// workaround because you cannot assign an enum as the length of an array directly.

simulated function allocateAnimationStates(AnimationStateEnum size)
{
    local int count;
    count = int(size);
    animationStates.Length = count;
}

// set animation state.
// workaround because enums cannot currently be used as array index

simulated function setAnimationState(AnimationStateEnum slot, AnimationState state)
{
    local int index;
    index = int(slot);
    animationStates[index] = state;
}

// allocate animation channels.
// workaround because you cannot assign an enum as the length of an array directly.

simulated function allocateAnimationChannels(AnimationChannelIndex size)
{
    local int i;
    local int count;
    
    count = int(size);
    
    animationChannels.Length = count;

    for (i=0; i<count; i++)
        animationChannels[i] = new class'AnimationChannel'();
}

// reset movement animations

simulated function resetMovementAnimations()
{
    if (animationManager!=None)
    {
        animationManager.stopAnimating(self);
        animationManager.startAnimating(self);
    }
}

// extra animation channel

simulated function playAnimation(string animation)
{
    if (animationManager!=None)
        animationManager.playAnimation(animation);
}

simulated function loopAnimation(string animation)
{
    if (animationManager!=None)
        animationManager.loopAnimation(animation);
}

simulated function bool isPlayingAnimation()
{
    if (animationManager!=None)
        return animationManager.isPlayingAnimation();
    return false;
}

simulated function bool isLoopingAnimation()
{
    if (animationManager!=None)
        return animationManager.isLoopingAnimation();
    return false;
}

simulated function stopAnimation()
{
    if (animationManager!=None)
        animationManager.stopAnimation();
}

// fire animation

simulated function playFireAnimation(string weapon)
{
	if (PlayerCharacterController(controller)!=none)
	    PlayerCharacterController(controller).enterCombat();
	
    if (animationManager!=None)
        animationManager.playFireAnimation(weapon);
}

// upper body animation

simulated function playUpperBodyAnimation(string animation)
{
    if (animationManager!=None)
        animationManager.playUpperBodyAnimation(animation);
}

simulated function loopUpperBodyAnimation(string animation)
{
    if (animationManager!=None)
        animationManager.loopUpperBodyAnimation(animation);
}

simulated function bool isPlayingUpperBodyAnimation()
{
    if (animationManager!=None)
        return animationManager.isPlayingUpperBodyAnimation();
    return false;
}

simulated function bool isLoopingUpperBodyAnimation()
{
    if (animationManager!=None)
        return animationManager.isLoopingUpperBodyAnimation();
    return false;
}

simulated function stopUpperBodyAnimation()
{
    if (animationManager!=None)
        animationManager.stopUpperBodyAnimation();
}

// arm animation

simulated function loopArmAnimation(string animation)
{
    if (animationManager!=None)
        animationManager.loopArmAnimation(animation);
}

simulated function bool isLoopingArmAnimation()
{
    if (animationManager!=None)
        return animationManager.isLoopingArmAnimation();
    return false;
}

simulated function string getArmAnimation()
{
    if (animationManager!=None)
        return animationManager.getArmAnimation();
    return "";
}

simulated function stopArmAnimation()
{
    if (animationManager!=None)
        animationManager.stopArmAnimation();
}

// flinch animation

simulated function playFlinchAnimation()
{
    if (animationManager!=None)
        animationManager.playFlinchAnimation();
}

// force movement state.
// sets the character and fusion movement state to a specific value.
// this method should be used only for network replication, as the movement
// state is automatically updated as a result of the physics simulation.

simulated function forceMovementState(MovementState state)
{
   	movementObject.forceMovementState(state);

    //log("force movement: "$state);

	movement = state;
}   

// wake movement physics

simulated function wake()
{
    if (movementObject!=None)
        movementObject.wake();
}

// tell movement object to recalculate its extents

simulated function calculateExtents()
{
    movementObject.calculateExtents();
}

// bump notification

simulated function Bump(Actor other)
{
	local float combinedVelocity;
	local float impactDamage;
	local Buckler buckler;
	local Vector bucklerDir;

    //log(Name$" bumped by "$other.Name);

	if (Role == ROLE_Authority)
	{
		buckler = Buckler(weapon);

		if (buckler != None && buckler.hasAmmo() &&
			Level.TimeSeconds - buckler.lastCheckTime > buckler.default.minCheckRate)
		{
			combinedVelocity = VSize(Velocity) + VSize(other.Velocity);

			if (combinedVelocity < buckler.default.minCheckVelocity)
				return;

			bucklerDir = Normal(Vector(motor.GetViewRotation()));

			if ((bucklerDir Dot Normal(other.Location - Location)) > buckler.cosDeflectionAngle)
			{
				buckler.lastChecktime = Level.TimeSeconds;

				impactDamage = buckler.checkingDamage + buckler.checkingDmgVelMultiplier * combinedVelocity;

				if (Character(Other) != None)
					Character(Other).blockMovementDamage = true;

				Other.TakeDamage(impactDamage, self, other.Location, bucklerDir * buckler.checkingMultiplier * combinedVelocity, class'DamageType');
				buckler.TriggerEffectEvent('BucklerCheck');
			}
		}
	}
}

// add impulse to character - only works when in fusion physics
// note: impulse is an instantaneous change in momentum, ie. its units are mass*velocity

simulated function addImpulse(Vector impulse)
{
    if (Physics==PHYS_Movement)
        movementObject.addImpulse(impulse);
}

simulated function setVelocity(Vector newVelocity)
{
	if (Physics==PHYS_Movement)
		movementObject.setVelocity(newVelocity);
}


// updated view bob for fusion movement

function CheckBob(float DeltaTime, vector Y)
{
	local float Speed;

    if (physics!=PHYS_Movement)
        super.CheckBob(DeltaTime, Y);

    if( !bWeaponBob )
    {
		BobTime = 0;
		WalkBob = Vect(0,0,0);
        return;
    }
 	Bob = FClamp(Bob, -0.01, 0.01);

	speed = vsize(velocity);

	if (movement==MovementState_SPRINT || Movement==MovementState_RUN || Movement==MovementState_WALK || Movement==MovementState_SLIDE || Movement==MovementState_STOP  || Movement==MovementState_STAND)
	{
		if ( speed < 10 )
			BobTime += 0.2 * DeltaTime;
		else
			BobTime += DeltaTime * (0.3 + 0.7 * speed/GroundSpeed);
		WalkBob = Y * Bob * speed * sin(8 * BobTime);
		AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		WalkBob.Z = AppliedBob;
		if ( speed > 10 )
			WalkBob.Z = WalkBob.Z + 0.75 * Bob * speed * sin(16 * BobTime);
		if ( LandBob > 0.01 )
		{
			AppliedBob += FMin(1, 16 * deltatime) * LandBob;
			LandBob *= (1 - 8*Deltatime);
		}
	}
	else if (movement==MovementState_SWIM || movement==MovementState_FLOAT)
	{
		WalkBob = Y * Bob *  0.5 * speed * sin(4.0 * Level.TimeSeconds);
		WalkBob.Z = Bob * 1.5 * speed * sin(8.0 * Level.TimeSeconds);
	}
	else
	{
		BobTime = 0;
		WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
	}
}

// team
// Get the Character's team object
simulated function TeamInfo team()
{
	if (tribesReplicationInfo == None)
		return Super.team();
	else
		return tribesReplicationInfo.team;
}

function class<TeamInfo> teamClass()
{
	local TeamInfo ti;
	ti = team();

	if (ti == None)
		return None;
	else
		return ti.class;
}

// setTeam
// Sets the Character's team object
function setTeam(TeamInfo info)
{
	local PlayerCharacterController pcc;

	pcc = PlayerCharacterController(Controller);
	if (tribesReplicationInfo != None)
	{
		tribesReplicationInfo.setTeam(info);
		if (tribesReplicationInfo.bTeamChanged)
		{
			tribesReplicationInfo.bTeamChanged = false;
			dispatchMessage(new class'MessageClientChangedTeam'(pcc, info, m_team));
			BroadcastLocalizedMessage(Level.Game.GameMessageClass, 3, playerReplicationInfo,, info);
		}
	}

	Super.setTeam(info);
}

// DAMAGE FUNCTIONS

function bool InGodMode()
{
	return bGodMode || Super.InGodMode();
}

function float getTeamDamagePercentage()
{
	// The Character's teamDamagePercentage overrides value set in TeamInfo if it's anytying
	// other than 0%
	if (self.teamDamagePercentage != 0.0)
		return self.teamDamagePercentage;
	
	return GameInfo(Level.Game).playerTeamDamagePercentage;
}

function HitPosition CalculateHitPosition(Vector HitLocation)
{
	if ((HitLocation.Z - Location.Z) >= HeadHeight)
		return HP_HEAD;

	if (motor != None)
	{
		if (((Location - HitLocation) Dot Vector(Rotation)) < 0)
			return HP_FRONT;
		else
			return HP_BACK;
	}

	return HP_IGNORE;
}

function PostTakeDamage( float Damage, Pawn instigatedBy, Vector hitlocation, 
						 Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	local float actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	local Rook attackerRook;
	local HitPosition hp;
	local int minimumTeamDamageHealth;
	local float positiveDamageAmount;
	local ModeInfo mode;
	local Vehicle vehicle;
	local Rook mount;
	
	local class<ProjectileDamageType> projectileDamageType;

	if ( Role < ROLE_Authority )
	{
		//log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

    // scale crushing damage from same team vehicles

    vehicle = Vehicle(instigatedBy);

    if (class<MovementCrushingDamageType>(damageType)!=none && vehicle!=None)
    {
        // check if vehicle on same team and scale crushing damage by modifier
        
        if (vehicle.lastOccupantTeam!=None && team()!=none && vehicle.lastOccupantTeam==team())
            damage *= VehicleTeamCrushingDamageModifier;    
    }
	
	// do nothing if a hidden vehicle occupant
	if (bHiddenVehicleOccupant)
		return;
		
	bAlreadyDead = (Health <= 0);
	mode = ModeInfo(Level.Game);
	actualDamage = Damage;

	if (damageType.static.doesPositionDamage())
	{
		hp = CalculateHitPosition(hitlocation);

		switch (hp)
		{
		case HP_HEAD:
			actualDamage *= damageType.static.getHeadDamageModifier();

			if (mode != None)
				mode.OnHeadShot(instigatedBy, self, damageType, actualDamage);
			break;
		case HP_BACK:
			actualDamage *= damageType.static.getBackDamageModifier();

			if (mode != None)
				mode.OnBackstab(instigatedBy, self, damageType, actualDamage);
			break;	
		}
	}

	if (shieldActive)
		actualDamage = actualDamage * (1.0 - shieldFractionDamageBlocked);

	if (personalShieldActive())
	{
		actualDamage = personalShield.applyDamage(actualDamage, health);
	}

	attackerRook = Rook(instigatedBy);

	if (instigatedBy == self)
		removeTempInvincibility();

	if (!InGodMode() && !bTempInvincible)
	{
		// Enforce team damage exclusivity (if specified, only someone on a certain team can affect this Character)
		if (attackerRook != None && team() != None && attackerRook.team() != None && (team().onlyDamagedByTeam == None || attackerRook.team() == team().onlyDamagedByTeam))
		{
			minimumTeamDamageHealth = healthMaximum * getTeamDamagePercentage();
			// Apply damage if it's enemy damage or self-inflicted
			if (!team().isFriendlyRook(attackerRook) || attackerRook == self)
			{
				ApplyDamage(instigatedBy, actualDamage);

				if (attackerRook != self && mode != None)
				{
					positiveDamageAmount = actualDamage;

					// Only report the amount of damage above what it took to kill
					if (Health < 0)
						positiveDamageAmount += Health;
					mode.OnPlayerDamage(instigatedBy, self, damageType, positiveDamageAmount);
				}
			}
			// Otherwise, only apply damage if health is above the minimum percentage
			else if (Health > minimumTeamDamageHealth)
			{
				ApplyDamage(instigatedBy, actualDamage);

				// If the friendly fire is not self-inflicted, clamp health if applicable
				if (self != attackerRook)
				{
					// Enforce team damage percentage by clamping
					if (Health / healthMaximum < getTeamDamagePercentage())
						Health = minimumTeamDamageHealth;
				}
			}
		}
		else if (team()!=none && team().onlyDamagedByTeam != None && !bAlreadyDead)     // glenn: safe to push around team ragdolls for fun
		{
			// Otherwise, if onlyDamagedByTeam has been set, get rid of momentum to prevent people from affecting this
			// Character at all
			
			momentum = vect(0,0,0);
		}
		else
			ApplyDamage(instigatedBy, actualDamage);
	}

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
	{
		Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
		ChunkUp(Rotation, DamageType);
		return;
	}

	if ( damageType == None )
		Warn(self @ "damageType is None; applying" @ actualDamage @ "damage from" @ InstigatedBy @ "at" @ Level.TimeSeconds);
	else
		PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// give vehicle an opportunity to boot us before we ragdoll
		mount = getMount();
		if (mount != None)
		{
			vehicle = Vehicle(mount);
			if (vehicle != None)
			{
				vehicle.driverLeave(true, vehicle.getOccupantPositionIndex(self));

				// user tear off location as client may still think we are in the vehicle when we die
				TearOffLocation = Location;
				bTearOffLocationValid = true;
			}
		}

		// Set TRI health here since it won't get properly set in Tick() on death
		if (tribesReplicationInfo != None)
		{
			tribesReplicationInfo.health = Health;
		}

        // glenn: remove fusion collision response for movement damage to ensure correct ragdoll impact

        if ( ClassIsChildOf(damageType, class'MovementCollisionDamageType'))
            momentum = movementOldVelocity - Velocity;

		// pawn died
		if (instigatedBy!=None)
			Killer = instigatedBy.GetKillerController();
			
		TearOffMomentum = momentum;
			
		Died(Killer, damageType, HitLocation);

		// play death sound
		PlayDeathSound( ClassIsChildOf( damageType, class'MovementCollisionDamageType' ), flameDamagePerSecond > 0 );
	}
	else
	{
	    // knockback without death
	
	    // scale knockback in movement physics
    	
	    if (Physics==PHYS_Movement)
    	    momentum *= movementKnockbackScale;
        	
        // scale based on projectile alive knockback scale
        	
	    projectileDamageType = class<ProjectileDamageType>(damageType);

	    if (projectileDamageType!=none)
	        momentum *= 1.0 - projectileFactor;
	
		unifiedAddImpulse(momentum);
		
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);

		// play hurt sounds
		PlayHurtSound(actualDamage);
	}
	MakeNoise(1.0);

	// Hit feedback for character objects
	if(Character(instigatedBy) != None && Character(instigatedBy) != self && ! bAlreadyDead)
		Character(instigatedBy).OnHitObject(self);

	generateAISpeechEvents( attackerRook );
}

simulated function PlayHurtSound(int actualDamage)
{
	if (Level.NetMode != NM_Client)
		clientPainType = CLIENTPAIN_Hurt;

	if ( actualDamage > 0 )
	{
		if ( actualDamage >= DAMAGE_LARGE )
		{
			if (Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
			{
				if (PlayerCharacterController(Controller) != None)
					PlayerCharacterController(Controller).PlayPainSound(CLIENTPAIN_BigHurt);
			}

			PlayMovementSpeech( 'HurtLarge' );
		}
		else
		{
			if (Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
			{
				if (PlayerCharacterController(Controller) != None)
					PlayerCharacterController(Controller).PlayPainSound(CLIENTPAIN_Hurt);
			}

			PlayMovementSpeech( 'Hurt' );
		}
	}
}

simulated function PlayDeathSound(bool bCratered, bool bFlame)
{
	if ( bFlame )
	{
		PlayMovementSpeech( 'DeathScream' );

		if (Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
		{
			if (PlayerCharacterController(Controller) != None)
				PlayerCharacterController(Controller).PlayPainSound(CLIENTPAIN_Burnt);
			
			clientPainType = CLIENTPAIN_Burnt;
		}
	}
	else if ( bCratered )
	{
		PlayMovementSpeech( 'DeathCrater' );

		if (Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
		{
			if (PlayerCharacterController(Controller) != None)
				PlayerCharacterController(Controller).PlayPainSound(CLIENTPAIN_Cratered);

			clientPainType = CLIENTPAIN_Cratered;
		}
	}
	else
	{
		PlayMovementSpeech( 'Death' );

		if (Level.NetMode != NM_Standalone && Level.NetMode != NM_Client)
		{
			if (PlayerCharacterController(Controller) != None)
				PlayerCharacterController(Controller).PlayPainSound(CLIENTPAIN_Death);

			clientPainType = CLIENTPAIN_Death;
		}
	}
}

//---------------------------------------------------------------------
// Equipment functions

// equipmentHead
function Equipment equipmentHead()
{
	return m_equipmentHead;
}

// equipmentTail
function Equipment equipmentTail()
{
	local Equipment e;

	e = m_equipmentHead;
	while (e != None && e.next != None)
		e = e.next;

	return e;
}

function HandGrenade newGrenades(class<HandGrenade> grenadeClass)
{
	if (altWeapon != None)
		altWeapon.Destroy();

	addGrenades(new grenadeClass(self));

	return HandGrenade(altWeapon);
}

function addGrenades(HandGrenade newGrenades)
{
	altWeapon = newGrenades;

	if (altWeapon == None)
		return;

	if (altWeapon.Owner != self)
		altWeapon.SetOwner(self);

	altWeapon.Instigator = self;

	altWeapon.gotoHeldState();

	dispatchMessage(new class'MessageEquipmentPickedUp'(newGrenades.Label, newGrenades.class));
}

// newPack
function Pack newPack(class<Pack> packClass)
{
	local Pack result;
	
	result = Pack(newEquipment(packClass));
	pack = result;

	if (pack != None)
		heldPackClass = pack.class;
	else
		heldPackClass = None;

	return result;
}

// addPack
function addPack(Pack newPack)
{	
	addEquipment(newPack);
	pack = newPack;

	if (pack != None)
		heldPackClass = pack.class;
	else
		heldPackClass = None;

	PlayEffect("CharacterAddPack");
}

simulated function putInWeaponSlot(Weapon w)
{
	local int i;

	if (w == altWeapon || w == fallbackWeapon)
		return;

	// Check if the weapon is already in a slot
	for (i = 0; i < NUM_WEAPON_SLOTS; ++i)
		if (weaponSlots[i] == w)
			return;

	for (i = 0; i < NUM_WEAPON_SLOTS; ++i)
	{
		if (weaponSlots[i] == None)
		{
			weaponSlots[i] = w;
			return;
		}
	}
}

simulated function removeFromWeaponSlot(Weapon w)
{
	local int i;

	if (w == altWeapon || w == fallbackWeapon)
		return;

	for (i = 0; i < NUM_WEAPON_SLOTS; ++i)
	{
		if (weaponSlots[i] == w)
		{
			weaponSlots[i] = None;
			return;
		}
	}
}

// newEquipment
function Equipment newEquipment(class<Equipment> itemClass)
{
	local Equipment item;

	item = spawn(itemClass, self);

	addEquipment(item);

	return item;
}

// addEquipment
function addEquipment(Equipment item)
{
	if (item.Owner != self)
		item.SetOwner(self);

	item.Instigator = self;

	item.next = m_equipmentHead;
	item.prev = None;

	if (m_equipmentHead != None)
		m_equipmentHead.prev = item;

	m_equipmentHead = item;

	item.startHeldByCharacter(self);

	item.gotoHeldState();

	PlayEffect("CharacterAddEquipment");

	dispatchMessage(new class'MessageEquipmentPickedUp'(item.Label, item.class));
}

// removeEquipment
function removeEquipment(Equipment item)
{
	local Equipment e;

	e = m_equipmentHead;
	while (e != None)
	{
		if (e == item)
		{
			if (e.prev != None)
				e.prev.next = item.next;
			else
				m_equipmentHead = item.next;

			if (e.next != None)
				e.next.prev = item.prev;

			if (item == weapon)
				weapon = None;
			if (item == altWeapon)
				altWeapon = None;

			item.endHeldByCharacter(self);

			dispatchMessage(new class'MessageEquipmentDropped'(item.Label, item.class));

			return;
		}

		e = e.next;
	}

	PlayEffect("CharacterRemoveEquipment");
}

// nextEquipment
// Returns the next piece of equipment of the given type, or returns None if no more equipment.
// Searches from the actor referenced by 'from', or if 'from' is None, searches from the start of the list.
function Equipment nextEquipment(Equipment from, optional class<Equipment> type)
{
	local Equipment e;

	if (from == None)
	{
		// start at beginning of list
		e = m_equipmentHead;
	}
	else
	{
		e = from.next;
	}

	while (e != None)
	{
		if (type == None || e.IsA(type.name))
		{
			// HACK: MPCarryableThower is not really a weapon
			if(! (type == class'Weapon' && e.IsA('MPCarryableThrower')))
				return e;
		}

		e = e.next;
	}

	return None;
}

// prevEquipment
// Returns the previous piece of equipment of the given type, or returns None if no more equipment.
// Searches from the actor referenced by 'from', or if 'from' is None, searches from the end of the list.
function Equipment prevEquipment(Equipment from, optional class<Equipment> type)
{
	local Equipment e;

	if (from == None)
	{
		// start at end of list
		e = equipmentTail();
	}
	else
	{
		e = from.prev;
	}

	while (e != None)
	{
		if (type == None || e.IsA(type.name))
		{
			// HACK: MPCarryableThower is not really a weapon
			if(! (type == class'Weapon' && e.IsA('MPCarryableThrower')))
				return e;
		}

		e = e.prev;
	}

	return None;
}

function dropEquipment()
{
	local Array<Equipment> droppables;
	local Equipment e;
	local int i;
	local Vector zAxis;
	local Vector baseVector;
	local float angle;

	e = m_equipmentHead;

	while (e != None)
	{
		if (e.bCanDrop)
			droppables[droppables.length] = e;

		e = e.next;
	}

	if (altWeapon != None)
	{
		if (altWeapon.bCanDrop)
			droppables[droppables.length] = altWeapon;

		altWeapon = None;
	}

	zAxis.Z = 1.0;
	baseVector.X = 300.0;
	angle = (2 * Pi) / droppables.length;

	for (i = 0; i < droppables.length; ++i)
	{
		droppables[i].GotoState('Dropped');
		droppables[i].Velocity += QuatRotateVector(QuatFromAxisAndAngle(zAxis, angle * i), baseVector);
		removeEquipment(droppables[i]);
	}
}

// destroyEquipment
function destroyEquipment()
{
	local Equipment e, d;

	e = m_equipmentHead;
	while (e != None)
	{
		d = e;
        e = e.next;

		d.endHeldByCharacter(self);

		d.Destroy();
	}
	m_equipmentHead = None;

	weapon = None;
	pack = None;
	deployable = None;

	if (altWeapon != None)
	{
		altWeapon.Destroy();
		altWeapon = None;
	}

	destroyFallbackWeapon();
}

function int numWeaponsCarried()
{
	local int count;
	local int i;

	count = 0;

	for (i = 0; i < NUM_WEAPON_SLOTS; ++i)
		if (weaponSlots[i] != None)
			++count;

	return count;
}

function int numHealthKitsCarried()
{
	local int count;
	local Equipment e;

	count = 0;
	e = m_equipmentHead;

	while (e != None)
	{
		if (e.IsA('HealthKit'))
			++count;

		e = e.next;
	}

	return count;
}

// give default weapon to AI
function giveDefaultWeapon()
{
	local Weapon w;

	w = Weapon( nextEquipment( None, class'Spinfusor' ));	// for now: just pick spinfusor if it's available

	if ( w == None )
		w = Weapon( nextEquipment( None, None ));			// and pick the first weapon in the list if not

	//w = Weapon( nextEquipment( None, class'Chaingun' ));	// debug
	//w = Weapon( nextEquipment( None, class'GrenadeLauncher' ));	//debug

	if ( w != None )
	{
		motor.setWeapon(w);
	}
}

// GetKillerController
function Controller GetKillerController()
{
	return lastPossessor;
}

function activatePack()
{
	local Pack workPack;

	// get pack
	workPack = Pack(nextEquipment(None, class'Gameplay.Pack'));

	// do nothing if no pack is carried
	if (workPack == None)
		return;

	PlayEffect("CharacterActivatePack");

	workPack.activate();
}

singular event BaseChange()
{
    // stub it out to do nothing
}

// Set Acceleration
simulated function unifiedSetAcceleration(Vector newAcceleration)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
		movementObject.setAcceleration(newAcceleration);
    else
        Super.unifiedSetAcceleration(newAcceleration);
}

// Set Position
simulated function unifiedSetPosition(Vector newPosition)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
	{
		movementObject.setPosition(newPosition);
		setLocation(newPosition);
	}
	else
	    Super.unifiedSetPosition(newPosition);
}

// Set Velocity
simulated function unifiedSetVelocity(Vector newVelocity)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
	{
		setVelocity(newVelocity);
		Velocity = newVelocity;
	}
	else
	    Super.unifiedSetVelocity(newVelocity);
}

// Add velocity
simulated function unifiedAddVelocity(Vector deltaVelocity)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
	{
		movementObject.addVelocity(deltaVelocity);
		Velocity += deltaVelocity;
	}
	else
	    Super.unifiedAddVelocity(deltaVelocity);
}

// Add Impulse
simulated function unifiedAddImpulse(Vector impulse)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
	{
		addImpulse(impulse);
		velocity += impulse / unifiedGetMass();
	}
	else
	    Super.unifiedAddImpulse(impulse);
}

simulated function unifiedAddImpulseAtPosition(Vector impulse, Vector position)
{
    if (movementFrozen && health>0)
        return;

	// calls the existing implementation in Character
	// position is ignored for fusion physics at the moment
	if (Physics==PHYS_Movement)
	{
		addImpulse(impulse);
		velocity += impulse / unifiedGetMass();
	}
	else
	    Super.unifiedAddImpulseAtPosition(impulse, position);
}

// Add Force
simulated function unifiedAddForce(Vector force)
{
    if (movementFrozen && health>0)
        return;

	if (Physics==PHYS_Movement)
		movementObject.addForce(force);        // note: the effect of the force wont be seen until next update
	else
	    Super.unifiedAddForce(force);
}

simulated function unifiedAddForceAtPosition(Vector force, Vector position)
{
    if (movementFrozen && health>0)
        return;

	// position is ignored for fusion physics at the moment
	if (Physics==PHYS_Movement)
		movementObject.addForce(force);        // note: the effect of the force wont be seen until next update
	else
	    Super.unifiedAddForce(force);
}

simulated function float unifiedGetGravity()
{
	if (Physics==PHYS_Movement)
		return gravity();
	else
	    return Super.unifiedGetGravity();
}                                      

// Speech system
function playScriptedSpeech(Name lipsyncLocTag, Name dialogueLocTag, optional bool bPositional)
{
	Level.speechManager.PlayScriptedSpeech(self, lipsyncLocTag, bPositional);
/*
	local Name intLipsyncAnimName;
	local String intDialogue;

	intLipsyncAnimName = Name(LocalizeMapText("LipSync", String(lipsyncLocTag)));

	if (HasLIPSincAnim(intLipsyncAnimName))
		PlayLIPSincAnim(intLipsyncAnimName);

	intDialogue = LocalizeMapText("Dialogue", String(dialogueLocTag));
	// TODO: Send subtitle dialogue to message window in the HUD, for now just log it
	Log(intDialogue);
*/
}

function playPlayerScriptedSpeech(Sound scriptedSpeech, Name dialogueLocTag)
{
	local String intDialogue;

	PlaySound(scriptedSpeech, 1.0,,, 1000);

	intDialogue = LocalizeMapText("Dialogue", String(dialogueLocTag));
	// TODO: Send subtitle dialogue to message window in the HUD, for now just log it
	Log(intDialogue);
}

function playDynamicSpeech(Sound dynamicSpeech, Name dialogueLocTag)
{
	local String intDialogue;

	PlaySound(dynamicSpeech, 1.0,,, 1000);

	intDialogue = Localize("DynamicSpeech", String(dialogueLocTag), "Gameplay");
	// TODO: Send subtitle dialogue to message window in the HUD, for now just log it
	Log(intDialogue);
}

function playQuickChatSpeech()
{
}

// End speech system


// Grappler related stuff

function addGrapplerCharacter(Character c)
{
	local int i;

	for (i = 0; i < grapplerCharacters.length; ++i)
		if (grapplerCharacters[i] == c)
			return;

	grapplerCharacters[grapplerCharacters.length] = c;
}

function removeGrapplerCharacter(Character c)
{
	local int i;

	for (i = 0; i < grapplerCharacters.length; ++i)
	{
		if (grapplerCharacters[i] == c)
		{
			grapplerCharacters.remove(i, 1);
			return;
		}
	}
}

simulated function tickGrappler(float Delta)
{
	if (proj != None)
	{
		if (rope == None)
			createRope();

		updateGrapplerRopeThirdPerson();

		if (!shouldBreakRope())
		{
			if (bAttached && bReelIn)
				ropeNaturalLength = FMax(0.0, ropeNaturalLength - grapplerClass.default.reelinLengthRate * Delta);
		}
		else 
			breakGrapple();
	}
	else if (rope != None)
	{
		rope.Destroy();
		rope = None;
	}
}

simulated function updateGrapplerRopeEquippedFirstPerson()
{
	if (proj != None)
	{
		if (rope == None)
			createRope();

		if (rope != None)
		{
			rope.Move(weapon.GetBoneCoords(weapon.projectileSpawnBone).origin - rope.Location);
			rope.SetRotation(Rotator(proj.Location - rope.Location));
			updateRopeDrawScale();
		}
	}
}

simulated function updateGrapplerRopeThirdPerson()
{
	local Vector locationOffset;

	if (rope != None)
	{
		if (weapon == None || !weapon.bIsFirstPerson || Grappler(weapon) == None)
		{
			locationOffset = Location;
			locationOffset.Z += 20;
			rope.Move(locationOffset - rope.Location);
		}

		rope.SetRotation(Rotator(proj.Location - rope.Location));

		updateRopeDrawScale();
	}
}

simulated function createRope()
{
	rope = new grapplerClass.default.ropeClass;

	if (bAttached)
	{
		rope.PlayAnim('Straight');
	}
	else
	{
		rope.AnimBlendParams(1, 0.0);
		rope.AnimBlendToAlpha(1, 1.0, 2.0);

		rope.PlayAnim('Flap', 2.0);
		rope.PlayAnim('Straight',,,1);
	}
}

function bool shouldBreakRope()
{
	local float ropeLength;

	if (Level.NetMode == NM_Client)
		return false;

	ropeLength = VSize(proj.Location - rope.Location);

	if (Controller == None)
	{
		//Log("!!!!!!!!Break grapple: Controller was None");
		return true;
	}

	if (bAttached && (proj.Base == None || proj.Base.bDeleteMe))
	{
		//Log("!!!!!!!!Break grapple: Projectiles base was None or destroyed");
		return true;
	}

	if (ropeLength > grapplerClass.default.maxRopeLength)
	{
		//Log("!!!!!!!!Break grapple: Rope got too long");
		return true;
	}

	if (ropeObstructionTrace(ropeLength - grapplerClass.default.ropeNonCollisionLength))
	{
		//Log("!!!!!!!!Break grapple: Rope was obstructed");
		return true;
	}

	return false;
}

// Returns true if the rope is obstructed, false otherwise
native function bool ropeObstructionTrace(float traceLength);

simulated function updateRopeDrawScale()
{
	local Vector newDrawScale3D;

	newDrawScale3D = grapplerClass.default.ropeClass.default.DrawScale3D;
	newDrawScale3D.X = VSize(rope.Location - proj.Location) / ROPE_MESH_LENGTH;

	rope.SetDrawScale3D(newDrawScale3D);
}

function attachGrapple()
{
	bAttached = true;
	playAttachedAnim();

	if (rope != None)
		ropeNaturalLength = VSize(proj.Location - rope.Location);
	else
		ropeNaturalLength = 0.0;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{	
	// remove third person packs
	if (Level.NetMode == NM_Client)
		destroyThirdPersonMesh();

	super.PlayDying(DamageType, HitLoc);
}

simulated function playAttachedAnim()
{
	if (rope != None)
	{
		rope.StopAnimating(true);
		rope.PlayAnim('Straight');
	}

	if (Grappler(weapon) != None)
		grapplerClass.default.animClass.static.playEquippableAnim(weapon, 'Attach');
}

simulated event BreakGrapple()
{
    // call this when the grapple breaks because it will play the breaking sound
    
    detachGrapple();
}

simulated function detachGrapple(optional bool bNoRemove)
{
	if (bAttached && Grappler(weapon) != None)
		grapplerClass.default.animClass.static.playEquippableAnim(weapon, 'Deattach');

	bAttached = false;

	if (proj != None)
	{
		if (Character(proj.Base) != None && !bNoRemove)
			Character(proj.Base).removeGrapplerCharacter(self);

		if (Level.NetMode != NM_Client)
			proj.Destroy();

		proj = None;
	}

	if (rope != None)
	{
		rope.Destroy();
		rope = None;
	}
}

simulated event bool GetGrappleData(out Actor attachedTo, out Vector attachedPoint, out float naturalLength)
{
	if (bAttached && proj != None && proj.Base != None)
	{
		if (proj.Base.bWorldGeometry || MPCarryableContainer(proj.Base) != None)
		{
			attachedTo = None;
			attachedPoint = proj.Location;
		}
		else
		{
			attachedTo = proj.Base;
			attachedPoint = Vect(0.0, 0.0, 0.0);
		}

        naturalLength = ropeNaturalLength;

		return true;
	}

	return false;
}

simulated event GetOtherGrappleCount(out int count)
{
    count = grapplerCharacters.length;
}

simulated event GetOtherGrappleData(int index, out Character other, out float naturalLength)
{
    // note: other will always be a character (only characters can be the source of a grapple!)

    other = grapplerCharacters[index];

	if (other != None)
		naturalLength = other.ropeNaturalLength;
}

simulated event SetNaturalRopeLength(float length)
{
    ropeNaturalLength = length;
}

// End grappler related stuff

//
// This is the main version of GetRadarInfoClass, because most items to be 
// displayed on the radar will be of type rook
//
simulated function class GetRadarInfoClass()
{
	if(armorClass != None)
		return armorClass.default.radarInfoClass;

	return super.GetRadarInfoClass();
}

// updateUserSkin
// sets the skin on the character specified in the tribesReplicationInfo
simulated function updateUserSkin()
{
	// apply skin
	if (tribesReplicationInfo != None)
	{
		if (tribesReplicationInfo.userSkinClass != userSkinClass)
		{
			userSkinClass = tribesReplicationInfo.userSkinClass;
			userSkinClass.static.applyToCharacter(self);
		}

		if (jetpack != None && tribesReplicationInfo.userSkinClass != jetpack.userSkinClass)
		{
			jetpack.userSkinClass = tribesReplicationInfo.userSkinClass;
			jetpack.userSkinClass.static.applyToJetpack(jetpack);
		}

		if (arms != None && tribesReplicationInfo.userSkinClass != arms.userSkinClass)
		{
			arms.userSkinClass = tribesReplicationInfo.userSkinClass;
			arms.userSkinClass.static.applyToArms(arms);
		}
	}
}

// projectiles should not hit us if shot by a turret we are driving
simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	local Turret t;
	local Vehicle vehicle;
	local VehicleMountedTurret vehicleTurret;

	if (!Super.ShouldProjectileHit(projInstigator))
		return false;

	t = Turret(projInstigator);
	if (t != None)
	{
		if (t.driver == self)
			return false;
	}

	// handle case character is an occupant of a vehicle
	vehicle = Vehicle(projInstigator);
	if (vehicle == None)
	{
		vehicleTurret = VehicleMountedTurret(projInstigator);
		if (vehicleTurret != None)
			vehicle = vehicleTurret.ownerVehicle;
	}
	if (vehicle != None && vehicle.isOccupant(self))
		return false;

	return true;
}

simulated function Touch(Actor other)
{
    if (other.bBlockPlayers)
        wake();
}

simulated function UnTouch(Actor other)
{
    if (other.bBlockPlayers)
        wake();
}

simulated function bool isZoomed()
{
	return bZoomed && bCanZoom;
}

simulated function setZoomed(bool b)
{
	bZoomed = b;
}

simulated event bool isFemale()
{
    local PlayerCharacterController player;

    player = PlayerCharacterController(controller);

    if (player==none)
        return false;
        
    if (player.isSinglePlayer())
        return bIsFemale;
    else
        return TribesReplicationInfo.bIsFemale;
}

simulated function int getModifiedAmmo(int baseAmmo)
{
	return baseAmmo;
}

simulated function int getMaxAmmo(class<Weapon> wc)
{
	return getModifiedAmmo(armorClass.static.maxAmmo(wc));
}

native function bool isTouchingEnergyBarrier();

simulated event bool ShouldActorsBlockSplash()
{
	return Turret(getMount()) != None;
}

function KilledBy( pawn EventInstigator )
{
	local Controller Killer;

	Health = 0;
	if ( EventInstigator != None )
		Killer = EventInstigator.Controller;

	if( armorClass != None && armorClass.default.suicideDamageTypeClass != None )
		Died( Killer, armorClass.default.suicideDamageTypeClass, Location );
	else
		Died( Killer, class'Suicided', Location );
}

function teleportTo(Vector newLoc, Rotator newRot)
{
	// un-grapple if we're grappled
	while (grapplerCharacters.length > 0)
	{
		grapplerCharacters[0].detachGrapple(true);
		grapplerCharacters.remove(0, 1);
	}
	detachGrapple();

	unifiedSetPosition(newLoc);
	unifiedSetRotation(newRot);
}

defaultproperties
{
     movementKnockbackScale=1.000000
     walkAnimationSpeed=100.000000
     runAnimationSpeed=300.000000
     sprintAnimationSpeed=500.000000
     neutralAimAnimationRootBone="Bip01 Head"
     alertAimAnimationRootBone="Bip01 Head"
     combatAimAnimationRootBone="Bip01 Neck"
     upperBodyAnimationRootBone="Bip01 Spine1"
     armAnimationRootBone="Bip01 R Clavicle"
     packDrawScale=1.000000
     invicibilityMaterial=Shader'FX.ScreenShader'
     weaponBone="bip01 r hand"
     weaponNotHeldTime=1.000000
     eyeBoneName="Bip01 Head"
     bApplyHealthFilter=True
     jetpackBone="jetpack"
     regenerationRateHealthPerSecond=5
     packLeftBone="PackLeft"
     packRightBone="PackRight"
     grapplerClass=Class'Grappler'
     energy=100.000000
     energyMinimum=10.000000
     energyMaximum=100.000000
     energyRechargeScale=1.000000
     HUDType="TribesGUI.TribesCharacterHUD"
     Alertness=ALERTNESS_Combat
     playerControllerState="CharacterMovement"
     grapplerRetentionScale=0.200000
     bHavokCharacterCollisions=True
     bHavokCharacterCollisionExtraRadius=75.000000
     SightRadius=6000.000000
     PeripheralVision=0.500000
     VisionUpdateRange=(Min=0.600000,Max=0.800000)
     bPhysicsAnimUpdate=True
     bNeedPostRenderCallback=True
     Physics=PHYS_Movement
     bActorShadows=True
     MovementObjectClass="Gameplay.CharacterMovementObject"
     Mesh=SkeletalMesh'LightArmour.PhoenixLight'
     bNetNotify=True
     bNoRepMesh=False
     bTriggerEffectEventsBeforeGameStarts=True
}
