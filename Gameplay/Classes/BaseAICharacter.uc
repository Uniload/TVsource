class BaseAICharacter extends Character
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//=====================================================================
// Constants

enum FiringWhileMovingStates
{
	FWM_NEVER,			// never fire unless moving towards target or standing still
	FWM_POOR,			// can fire while moving but accuracy diminishes
	FWM_GOOD			// no restrictions on firing
};

enum CombatRangeCategories
{
	CR_STAND_GROUND,	// don't leave position
	CR_CLOSE_TO_RANGE,	// close to optimal combat range, adjust if opponent moves away
	CR_STAY_AT_RANGE,	// ditto, except back away if necessary
	CR_FLANKING,		// try to move to attack from sides
	CR_DRAW_OUT			// try to bait opponent
};

enum CombatMovementCategories
{
	CM_SIDE_STEP,		// occasionally step from side to side, but stay in the same general area
	CM_SEEK_COVER,		// seek cover and pop out to make a shot
	CM_ZIGZAG,			// jetpack frequently
	CM_DONT_REPOSITION	// don't reposition yourself during combat!
};

enum DodgingCategories
{
	DODGING_POOR,
	DODGING_GOOD
};

enum PainReactionCategories
{
	PR_NONE,			// pain is ignored
	PR_FLINCH,			// interrupts attack with a long pause before firing again, but doesn’t prevent movement
	PR_FREEZE			// interrupts attack with a long pause before firing again, and prevents movement
};

enum GrenadeUseCategories
{
	GU_NONE,			// doesn't carry hand grenades
	GU_NEVER,			// carries hand grenades but doesn't use them
	GU_USE				// uses hand grenades
};

enum SpeedPackUseCategories
{
	SP_ON_FIRST_ATTACK,	// when attack is first initiated
	SP_WHEN_CLOSE,		// when close to the target
	SP_ESTHER			// special case for Esther boss
};

const MIN_BUMP_TIME = 0.3f;		// minimum time you have to bump an AI before it reacts
const MAX_BUMP_TIME = 1.0f;		// maximum time allowed between two bumps to make AI react

const PAIN_REACTION_FLINCH_TIME = 1.0f;
const PAIN_REACTION_FREEZE_TIME = 1.5f;
const DODGING_DELAY_TIME = 0.5f;

const SPEEDPACK_DISTANCE = 1500.0f;	// when SP_WHEN_CLOSE, at what distance is speedpack activated

//=====================================================================
// Variables

// setting to none implies no jetpack
var (BaseAICharacter) class<Jetpack> jetpackClass;
var (BaseAICharacter) Mesh armsMesh;
var (BaseAICharacter) float healthModifier;

var(AI) FiringWhileMovingStates firingWhileMovingState;
var(AI) CombatRangeCategories combatRangeCategory;
var(AI) CombatMovementCategories combatMovementCategory;
var(AI) DodgingCategories dodgingCategory;
var(AI) PainReactionCategories painReactionCategory;
var(AI) GrenadeUseCategories grenadeUseCategory;
var(AI) SpeedPackUseCategories speedPackUseCategory;
var(AI) float tauntAnimFrequency "percentage of time AI's plays taunt animation if you miss him";
var(AI) bool bCanSeeIntoWater;
var(AI) bool bUsePackActiveEffect;
var(AI) bool bTaunt "should this AI taunt his/her enemies?";

var bool bLogEnergyUsage;		// debug: log energy used and predicted

var float noAttackUntil;		// time after which it's ok to shoot
var float noMovementUntil;		// time after which it's ok to move

var float firstBumpTime;		// first time the "lastBumpActor" bumped this AI
var Actor lastBumpActor;

//=====================================================================
// Functions

//---------------------------------------------------------------------

simulated function Tick(float Delta)
{
	Super.Tick(Delta);

	// miss taunts
	if ( attacker != None && expectedImpactTime < level.TimeSeconds &&
		level.TimeSeconds - expectedImpactTime <= 1.0 )
	{
		//log( "YOU GOT BAD AIM:" @ attacker.name @ "missed" @ name );
		level.speechManager.PlayDynamicSpeech( self, 'TauntMissed' );
		if ( FRand() < tauntAnimFrequency )
			playTauntAnim();
		attacker = None;
	}

	// AI Debug: Call Boston's action/goal debug display
	if ( bShowTyrionCharacterDebug || bShowTyrionMovementDebug || bShowTyrionWeaponDebug || bShowTyrionHeadDebug || bShowSensingDebug )
		displayTyrionDebugHeader();

	if ( bShowSensingDebug )
		displayEnemiesList();

	if ( bShowTyrionCharacterDebug && characterAI != None )
		characterAI.displayTyrionDebug();

	if ( bShowTyrionMovementDebug && movementAI != None )
		movementAI.displayTyrionDebug();

	if ( bShowTyrionWeaponDebug && weaponAI != None )
		weaponAI.displayTyrionDebug();
	
	if ( bShowTyrionHeadDebug && headAI != None )
		headAI.displayTyrionDebug();

	//DrawDebugLine( loaStartPoint, loaEndPoint, 255,0,0 );
	//DrawDebugLine( loaEndPoint, loaEndPoint + vect(0,0,1000), 0,255,0 );

	//level.AI_Setup.enemyListSanityCheck( self );
}

//---------------------------------------------------------------------

function Bump( Actor Other )
{
	local Rook rook;
	local float timeSinceFirstBump;

	super.Bump(Other);

	rook = Rook(Other);
	if ( rook != None )
	{
		timeSinceFirstBump = Level.timeSeconds - firstBumpTime;

		// touched by the same rook again within MIN_BUMP_TIME seconds?
		if ( lastBumpActor == rook && timeSinceFirstBump >= MIN_BUMP_TIME && timeSinceFirstBump <= MAX_BUMP_TIME )
		{
			//log( Other.name @ "BUMPED" @ name );
			if ( VSize( Velocity ) == 0 && isFriendly( rook ) )
				Level.AI_Setup.sendGetOutOfWayMessage( self, Location - Other.Location );
		}

		if ( lastBumpActor != rook || timeSinceFirstBump > MAX_BUMP_TIME )
			firstBumpTime = Level.timeSeconds;
		lastBumpActor = rook;
	}
}

//---------------------------------------------------------------------

function PostBeginPlay()
{
	// Create Low Level Sensing Notifiers (before sensors are set up)
	if ( SightRadius > 0 )
		CreateVisionNotifier();
	CreateHearingNotifier();

	super.PostBeginPlay();

	// spawn and attach jetpack if necessary
	if (jetpackClass != None)
	{
		setJetpack(Spawn(jetpackClass, self));
	}

	initCharacterAI();

	// debug
/*	if ( name == 'AIGrenadier2Imperial1' || name == 'AIDuelist1Phoenix9' )
	{
		//logTyrion = true;
		//logNavigationSystem = true;
		//logDLM = true;
		//bShowSensingDebug = true;
		bShowTyrionCharacterDebug = true;
		bShowTyrionMovementDebug = true;
		bShowTyrionWeaponDebug = true;
		//bShowTyrionHeadDebug = true;
		if ( squad() != None )
			squad().logTyrion = true;
	}*/
}

//---------------------------------------------------------------------

function initCharacterAI()
{
	local int i;

	// Since resources (objects) don't have PostBeginPlay functions, initialize them here explicitly
	characterAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_CharacterResource", class'Class'));
	movementAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_MovementResource", class'Class'));
	weaponAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_WeaponResource", class'Class'));
	headAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_HeadResource", class'Class'));

	characterAI.setResourceOwner( self );
	movementAI.setResourceOwner( self );
	weaponAI.setResourceOwner( self );
	headAI.setResourceOwner( self );

	// Put designer-assigned goals and abilities (actions) into the correct resource
	for ( i = 0; i < goals.length; i++ )
	{
		if ( goals[i] != None )
			goals[i].static.findResource( self ).assignGoal( goals[i] );
	}

	for ( i = 0; i < abilities.length; i++ )
	{
		if ( abilities[i] != None )
			abilities[i].static.findResource( self ).assignAbility( abilities[i] );
	}
}

//---------------------------------------------------------------------
// cleanup AI when character dead

event bool cleanupAI()
{
	if ( super.cleanupAI() )
		return true;

	if ( characterAI == None )
		return true;			// AI resources already destroyed for some inexplicable reason...

	//log( "AI for" @ name @ "CLEANING UP" );

	characterAI.cleanup();
	movementAI.cleanup();
	weaponAI.cleanup();
	headAI.cleanup();

	//log( p.name @ "sensor deletion starting" );
	characterAI.deleteSensors();
	movementAI.deleteSensors();
	weaponAI.deleteSensors();
	headAI.deleteSensors();
 
	//log( p.name @ "action deletion starting" );
	characterAI.deleteRemovedActions();
	movementAI.deleteRemovedActions();
	weaponAI.deleteRemovedActions();
	headAI.deleteRemovedActions();

	return false;
}

//---------------------------------------------------------------------
// Cause all resources attached to this pawn to re-check their goals

function rematchGoals()
{
	characterAI.bMatchGoals = true;
	movementAI.bMatchGoals = true;
	weaponAI.bMatchGoals = true;
	headAI.bMatchGoals = true;
}

//---------------------------------------------------------------------

function initialiseEquipment()
{
	local Weapon w;

	super.initialiseEquipment();

	// AIs never run out of ammo
	w = Weapon(nextEquipment(None, class'Weapon'));
	while (w != None)
	{
		if (!w.IsA('Buckler'))
			w.ammoUsage = 0;

		w = Weapon(nextEquipment(w, class'Weapon'));
	}

	healthMaximum *= healthModifier;
	health = healthMaximum;

	if (GameInfo(Level.Game) != None)
		GameInfo(Level.Game).modifyAI(self);
}

//---------------------------------------------------------------------

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	local Rook attackerRook;

	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);

	attackerRook = Rook(EventInstigator);

	// a human player attacked an AI
	if ( bTaunt && attackerRook != None && attackerRook != self && !isFriendly( attackerRook ) && attackerRook.isHumanControlled() )
	{
		if ( health > 0 && scaleByWeaponRefireRate( attackerRook.firingMotor().getWeapon() ))
			level.speechManager.PlayDynamicSpeech( self, 'TauntStillAlive' );
	}

	// low health speech event
	if ( health > 0 && health < 0.25f * healthMaximum )
		level.speechManager.PlayDynamicSpeech( self, 'LowHealth' );
}

//---------------------------------------------------------------------

function bool weaponUseEnergy(float quantity)
{
	return useEnergy(quantity);
}

//---------------------------------------------------------------------
// returns false if a speech event shoudl not be uttered based on the character weapon's refire rate
// pass in the weapon unless you want to use the AI's weapon

final function bool scaleByWeaponRefireRate( optional Weapon _weapon )
{
	if ( _weapon == None )
		_weapon = weapon;

	return ( _weapon == None || FRand() < 1.0f/_weapon.roundsPerSecond );
}

//---------------------------------------------------------------------

final function playTauntAnim()
{
	local String animName;
	local int rand;

	rand = 4.0f * FRand();
	switch( rand )
	{
	case 0:
		animName = "A_Taunt1";
		break;
	case 1:
		animName = "A_Taunt2";
		break;
	case 2:
		animName = "A_Taunt3";
		break;
	case 3:
		animName = "A_Taunt4";
		break;
	}

	if ( !hasAnim( Name(animName) ) )
	{
		return;
	}

	playUpperBodyAnimation( animName );
}

//=====================================================================

cpptext
{
	virtual UBOOL shouldLookForPawns();

}


defaultproperties
{
     healthModifier=1.000000
     firingWhileMovingState=FWM_GOOD
     combatRangeCategory=CR_STAY_AT_RANGE
     dodgingCategory=DODGING_GOOD
     grenadeUseCategory=GU_USE
     tauntAnimFrequency=0.100000
     bCanSeeIntoWater=True
     bUsePackActiveEffect=True
     bTaunt=True
     visionMemory=10.000000
     Alertness=ALERTNESS_Neutral
     AI_LOD_Level=AILOD_IDLE
     PeripheralVision=0.100000
     VisionUpdateRange=(Min=0.400000,Max=0.600000)
     RotationRate=(Yaw=40000)
}
