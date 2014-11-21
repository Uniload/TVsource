//=====================================================================
// AI_CivilianGuard
// Panics and cowers if any enemies are seen in the engagement area
//=====================================================================

class AI_CivilianGuard extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Constants

const UNPANIC_DIST = 3000.0f;		// closest the enemy who caused the panic can be before I stop cowering
const COWER_DURATION = 10;			// minimum time to cower for (seconds)

//=====================================================================
// Variables

var(InternalParameters) float engagementAreaRadius "Radius of engagement area";
var(InternalParameters) float movementAreaRadius "Radius of movement area";
var(InternalParameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

var BaseAICharacter ai;
var Pawn target;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;				// higher than normal GuardAttack
}

//---------------------------------------------------------------------
// Make the AI cower for a specified time - even if he gets bumped

latent function cower( BaseAICharacter ai, float time )
{
	local int i;

	// wait for movement to stop or animation will be clobbered
	AI_Controller(ai.controller).stopMove();

	while ( !isZero( ai.Velocity ) )
		yield();
	ai.LoopAnimation( "A_Cower" );

	// wait "time" seconds - restart animation if it was interrupted
	for ( i = 0; i < time; ++i )
	{
		if ( !ai.isLoopingAnimation() )
			ai.LoopAnimation( "A_Cower" );
		Sleep( 1.0f );
	}
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	// clear GuardSensor value so action can be activated again
	// (also important because GuardSensor doesn't terminate when LOS is lost - it relies on the action to do this)
	if ( achievingGoal.activationSentinel.sensor != None )
		achievingGoal.activationSentinel.sensor.setObjectValue( None );

	weaponSelection = None;
	followFunction = None;
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = BaseAICharacter(pawn);
	target = Pawn(achievingGoal.activationSentinel.sensor.queryObjectValue());
	AI_Guard(achievingGoal.parentAction).lastGuardTarget = target;

	if ( target == None )
	{
		log( "AI WARNING:" @ name $ ":" @ ai.name @ "has no guard target" );
	}
	else
	{
		if ( ai.logTyrion )
			log( name @ "started on" @ ai.name $ ". Spotted" @ target.name );

		if ( FRand() < 1.0f )	// <- panicChance
		{
			// Panic
			waitForGoal( (new class'AI_PanicGoal'( resource, 99 )).postGoal( self ), true );
		}

		if ( class'Pawn'.static.checkAlive( target ))
			waitForGoal( (new class'AI_TurnGoal'( movementResource(), 99, Rotator( target.Location - ai.Location ) )).postGoal( self ), true );

		// Cower
		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") cowering." );

		pawn.level.speechManager.PlayDynamicSpeech( pawn, 'Cower' );
		useResources( class'AI_Resource'.const.RU_LEGS );		// don't move while cowering

		// cower for COWER_DURATION seconds
		cower( ai, COWER_DURATION );

		//log( "Cower sleep finished!" @ characterResource().commonSenseSensorAction.enemySensor.queryIntegerValue() );

		// continue cowering until enemy has vanished
		while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) &&
				(VDistSquared( target.Location, ai.Location ) < UNPANIC_DIST * UNPANIC_DIST ||
					characterResource().commonSenseSensorAction.enemySensor.queryIntegerValue() != 0 ))
		{
			if ( !ai.isLoopingAnimation() )
				ai.LoopAnimation( "A_Cower" );
			yield();
		}

		//waitForGoal( (new class'AI_MoveToGoal'( movementResource(), achievingGoal.priority, orgLocation )).postGoal( self ), true );
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") succeeded" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GuardAttackGoal'
}