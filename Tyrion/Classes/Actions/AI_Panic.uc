//=====================================================================
// AI_Panic
//=====================================================================

class AI_Panic extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Constants

const MAX_ITERATIONS = 10;			// number of random locations to consider
const MAX_PANIC_DIST = 3000.0f;		// max dist to run
const MIN_PANIC_DIST = 1000.0f;		// min dist to run

//=====================================================================
// Variables

var BaseAICharacter ai;
var int i;
var Vector destination;

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	ai = BaseAICharacter(pawn);

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is PANICKING!" );

	ai.level.speechManager.PlayDynamicSpeech( ai, 'Panic' );
	useResources( class'AI_Resource'.const.RU_ARMS );		// don't use weapons while panicked!

	// find a place to run to...
	do
	{
		destination = AI_Controller(ai.controller).getRandomLocation( ai, ai.Location, MAX_PANIC_DIST, MIN_PANIC_DIST );
	}
	until ( ++i >= MAX_ITERATIONS || destination != ai.Location );

	//you can also play a one shot anim on the upper body:
	//	character.playUpperBodyAnimation("a_panic");

	ai.loopUpperBodyAnimation("a_panic");

	waitForGoal( (new class'AI_MoveToGoal'( movementResource(), achievingGoal.priority, destination )).postGoal( self ), true );

	ai.stopUpperBodyAnimation();

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_PanicGoal'
}