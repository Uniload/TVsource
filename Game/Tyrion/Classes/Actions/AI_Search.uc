//=====================================================================
// AI_Search
//=====================================================================

class AI_Search extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Constants

const SEARCH_DISTANCE1 = 1.0f;		// what percentage of searchDistance you run in the direction of target when searching on first search
const SEARCH_DISTANCE2 = 0.75f;
const SEARCH_ROTATION1 = +1.1780972f;	// 3/8 * PI: how far to turn for first search
const SEARCH_ROTATION2 = -1.1780972f;

//=====================================================================
// Variables

var(Parameters) float searchDistance "how far the AI moves when searching for something";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst Character.GroundMovementLevels searchSpeed "how fast the AI moves while searching";

var BaseAICharacter ai;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;						// destination node
var Vector orgLocation;				// location of pawn when search started
var Rotator orgRotation;			// rotation of pawn when search started

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	errorCode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------
// get search destination

private final function Vector getDestination( float searchDistance, float searchRotation )
{
	local Vector targetVector;
	local Vector dest;
	local Vector lastValidLocation;

	local array<Actor> ignore;

	if ( target != None )
		targetVector = target.Location - ai.Location;
	else
		targetVector = ai.Location;

	targetVector *= searchDistance / VSize(targetVector);

	dest = rotateZ( targetVector, PI/4 * FRand() - PI/8 + searchRotation ) + ai.Location;

	AI_Controller(ai.controller).canPointBeReached( ai.Location, dest, ai, ignore, lastValidLocation );

	return lastValidLocation;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		AI_Controller(resource.pawn().controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is searching for" @ target.name @ "( searchDistance:" @ searchDistance @ ")" );

	orgLocation = ai.Location;
	orgRotation = ai.Rotation;

	// run to place in the approximate direction of the enemy, look around a bit
	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(ai.controller),
					self, getDestination( SEARCH_DISTANCE1 * searchDistance, SEARCH_ROTATION1 ), None,,, searchSpeed, ));

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );

	// wait till movement has stopped
	while ( !isZero( ai.Velocity ))
		yield();
	ai.PlayAnimation( "AI_Searching" );
	Sleep(2.0);		//ai.FinishAnim();

	if ( class'Pawn'.static.checkDead( ai ) )
		fail( ACT_ALL_RESOURCES_DIED );

	// run to another place
	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(ai.controller),
					self, getDestination( SEARCH_DISTANCE2 * searchDistance, SEARCH_ROTATION2 ), None,,, searchSpeed, ));

	// wait till movement has stopped
	while ( !isZero( ai.Velocity ))
		yield();
	ai.PlayAnimation( "AI_Searching" );
	Sleep(2.0);		//ai.FinishAnim();

	if ( class'Pawn'.static.checkDead( ai ) )
		fail( ACT_ALL_RESOURCES_DIED );

	// return back to where you started
	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(ai.controller),
					self, orgLocation, None,,, searchSpeed, ));

	// face the way you were originally facing
	waitForAction( class'NS_Turn'.static.startAction( AI_Controller(ai.controller), self, orgRotation ));

	if ( ai.logTyrion )
		log( name @ "stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_SearchGoal'

	searchDistance = 600
}