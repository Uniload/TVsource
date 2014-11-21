//=====================================================================
// Setup
// Performs one-time initializations/setup for Tyrion AI
//=====================================================================

class Setup extends Engine.Tyrion_Setup
	native;

//=====================================================================
// Constants

const TARGET_DURATION = 0.5f;	// minimum time the player has to target an for the AI to think it's in the way
const MAX_TARGET_CHECK_RANGE = 10000.0f;	// maximum range for target detection ray traces 
const TIMETOHIT_FUDGE_TERM = 1.0f;			// added to timeToHit to get upper bound on impact time

//=====================================================================
// Variables

var Tyrion_ResourceBase sensorResource;	// resource that sensors are attached to

//=====================================================================
// Functions

native static final function Tyrion_ResourceBase GetStaticSensorResource();
native static final function SetStaticSensorResource(Tyrion_ResourceBase sr);

//---------------------------------------------------------------------
// Called at start of gameplay.

function postBeginPlay()
{
	sensorResource = new class'AI_SensorResource';
	SetStaticSensorResource(sensorResource);
	sensorResource.init();	// global sensors set up before resource ticks (other sensors rely on it)

	//log( "AI_SensorResource created!" );
}

function PostLoadGame()
{
	assert(sensorResource != None);
	SetStaticSensorResource(sensorResource);
}

//---------------------------------------------------------------------
// Called whenever time passes

function Tick( float deltaTime )
{
	sensorResource.Tick( deltaTime );
}

//---------------------------------------------------------------------
// Hook in Tyrion for the rook to call into at every tick
// The purpose of this function is to collect in place all
// general AI-related rook processing

event doRookRelatedAIProcessing( float deltaSeconds, Pawn pawn )
{
	local Rook rook;
	rook = Rook(pawn);	// will always be a rook; a pawn is passed in because this function has to be declared in engine

	rook.updatePastPositions( deltaSeconds );

	// more rook-specific processing to come...
}

//---------------------------------------------------------------------
// Hook in Tyrion for the Player to call into at every tick

function doPlayerRelatedAIProcessing( float deltaSeconds, Pawn pawn )
{
	local PlayerCharacterController pcc;
	local BaseAICharacter target;

	pcc = PlayerCharacterController(pawn.controller);
	assert( pcc != None );
	target = BaseAICharacter(pcc.lastIdentified);

	// Is an AI blocking the player's shot?
	if ( class'Pawn'.static.checkAlive( target ) &&
		pcc.lastIdentifiedDuration >= TARGET_DURATION &&
		target.isFriendly( Rook(pawn) ) &&
		enemyBehindTarget( Rook(pawn), target, pcc.lastIdentifiedHitLocation ) != None )
	{
		AI_CharacterResource(target.characterAI).commonSenseSensorAction.getOutOfWaySensor.setValue( pawn, target.Location );
	}
}

//---------------------------------------------------------------------
// stop all movement actions

event stopActions( Pawn pawn )
{
	if ( pawn.controller != None )
		AI_Controller(pawn.controller).stopActions();
}

//---------------------------------------------------------------------
// Continue a ray trace from "shooter" beyond the first target hit ("hitRook");
// return any enemy character hit

function Character enemyBehindTarget( Rook shooter, Rook hitRook, Vector startTrace )
{
	local Vector endTrace;
	local Character hit;

	endTrace = startTrace + Vector(shooter.firingMotor().getViewRotation()) * MAX_TARGET_CHECK_RANGE;
	hit = Character(hitRook.AITrace( endTrace, startTrace, Vect(32, 32, 32) ));

	if ( hit != None && !shooter.isFriendly( hit ) )
		return hit;
	else
		return None;
}

//---------------------------------------------------------------------
// Sends a message to GetOutOfWaySensor when a pawn was bumped by a friendly
// (this function is necessary because gameplay code calls this)

function sendGetOutOfWayMessage( Pawn bumpedPawn, Vector bumpDirection )
{
	AI_CharacterResource(bumpedPawn.characterAI).commonSenseSensorAction.getOutOfWaySensor.setValue( bumpedPawn, bumpDirection );
}

//---------------------------------------------------------------------
// Sends a message to painSensor of squad members when a member dies
// (this function is necessary because gameplay code calls this)

function sendAllyDiedMessage( Pawn ally, Pawn deadPawn, Pawn InstigatedBy, class<DamageType> damageType, vector HitLocation )
{
	if ( ally.characterAI != None )
		AI_CharacterResource(ally.characterAI).commonSenseSensorAction.painSensor.setValue( 100, InstigatedBy, HitLocation, damageType, lastTick );
}

//---------------------------------------------------------------------
// set the expected time this projectile will impact (for miss speech events)

static final function setTarget( Pawn attacker, Rook target, float timeToHit )
{
	// don't overwrite info for previous shot
	if ( target.expectedImpactTime < attacker.level.TimeSeconds )
	{
		//log( "Setting new attacker:" @ ai.name @ "Weapon:" @ BaseAICharacter(ai).weapon.name @ "impact:" @ timeToHit );
		target.attacker = attacker;
		target.expectedImpactTime = attacker.level.TimeSeconds + timeToHit + TIMETOHIT_FUDGE_TERM;
	}
}

//---------------------------------------------------------------------
// gets enemy list from the enemy sensor

function array<Pawn> getEnemyListFromSensor( Pawn ai )
{
	local AI_EnemySensor enemySensor;
	local int i;
	local array<Pawn> result;

	if ( ai.characterAI == None || Rook(ai).vision == None || AI_CharacterResource(ai.characterAI).commonSenseSensorAction == None )
		return result;

	enemySensor = AI_CharacterResource(ai.characterAI).commonSenseSensorAction.enemySensor;
	if ( enemySensor == None || enemySensor.queryUsage() == 0 )
		return result;

	for ( i = 0; i < enemySensor.enemies.length; i++ )
	{
		result[result.length] = enemySensor.enemies[i];
	}

	return result;
}

//---------------------------------------------------------------------
// Checks integrity of ai's enemies list (debug only)

event enemyListSanityCheck( Pawn ai )
{
	local AI_EnemySensor enemySensor;
	local int i, j;
	local array<Pawn> seenList;
	local Rook seenRook;
	local bool bFoundEnemy;

	if ( ai.characterAI == None || Rook(ai).vision == None || AI_CharacterResource(ai.characterAI).commonSenseSensorAction == None )
		return;

	enemySensor = AI_CharacterResource(ai.characterAI).commonSenseSensorAction.enemySensor;
	if ( enemySensor == None || enemySensor.queryUsage() == 0 )
		return;

	seenList = Rook(ai).vision.getSeenList();

	for ( i = 0; i < enemySensor.enemies.length; i++ )
	{
		if ( enemySensor.enemies[i] == None )
		{
			log( "ENEMY LIST sanity check failed for" @ ai.name $ ": contains None entry" );
			assert( enemySensor.enemies[i] != None );
		}
	}

	for ( i = 0; i < enemySensor.enemies.length; i++ )
	{
		if ( !Rook(ai).vision.isVisible( enemySensor.enemies[i] ) )
		{
			log( "ENEMY LIST sanity check failed for" @ ai.name $ ":" @ enemySensor.enemies[i].name @ "is in enemiesList but not in seenList" );
			assert( false );	
		}
	}

	for ( i = 0; i < seenList.length; i++ )
	{
		seenRook = Rook(seenList[i]);
		if ( !Rook(ai).isFriendly(seenRook) )
		{
			bFoundEnemy = false;
			for ( j = 0; j < enemySensor.enemies.length; j++ )
				if ( seenRook == enemySensor.enemies[j] )
					bFoundEnemy = true;

			if ( !bFoundEnemy )
			{
				log( "ENEMY LIST sanity check failed for" @ ai.name $ ":" @ seenRook.name @ "is in seenList but not in enemyList" );
				assert( bFoundEnemy );	
			}
		}
	}
}

defaultproperties
{
}
