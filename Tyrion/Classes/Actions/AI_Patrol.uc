//=====================================================================
// AI_Patrol
// Moves along a series of waypoints
//=====================================================================

class AI_Patrol extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editconst array<Name> patrolPointNames;
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement speed";
var(Parameters) bool bExecuteOnce "Go through the patrol nodes just once";

var array<Vector> patrolPoints;
var int patrolIndex;
var int closestIndex;
var float distSquared, closestDistSquared;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	//log("AI_Patrol: child succeeded");
	errorcode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	//log("AI_Patrol: child failed");
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------

function cleanup()
{
	local AI_Controller c;

	super.cleanup();

	c = AI_Controller(resource.pawn().controller);

	// when Patrol deactivates, AI keeps on moving with his last direction
	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		c.stopMove();

	c.bPatrolling = false;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( patrolPointNames.length == 0 )
	{
		log( "AI WARNING:" @ name @ "has no patrol points" );
		succeed();
	}

	AI_Controller(resource.pawn().controller).bPatrolling = true;

	// find closest patrolPoint; initialize patrolPoints array
	for ( patrolIndex = 0; patrolIndex < patrolPointNames.length; ++patrolIndex )
	{
		node = resource.pawn().findStaticByLabel( class'Pathfinding.PlacedNode', patrolPointNames[patrolIndex] );
		//log("AI_Patrol: Looking for " $ patrolPointNames[patrolIndex] $ "; found: " $ node );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ resource.pawn().name @ ") can't find specified path node" @ patrolPointNames[patrolIndex] );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		patrolPoints[patrolIndex] = node.Location;

		distSquared = VDistSquared( node.Location, resource.pawn().Location );

		if ( distSquared < closestDistSquared )
		{
			closestDistSquared = distSquared;
			closestIndex = patrolIndex;
		}
	}

	patrolIndex = closestIndex;

	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") started patrolling at node" @ closestIndex );

	while ( !bExecuteOnce || patrolIndex != patrolPoints.length )
	{
		if ( patrolIndex == patrolPoints.length )
			patrolIndex = 0;

		//log( "AI_Patrol: Heading from (" @ resource.pawn().Location @ ") to (" @ patrolIndex @ ")" );
		waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(resource.pawn().controller),
						self, patrolPoints[patrolIndex], None,,, groundMovement ) );

		if ( errorCode != ACT_SUCCESS )
		{
			if ( resource.pawn().logTyrion )
				log( name @ "(" @ resource.pawn().name @ ") aborted due to error" @ errorCode @ "from MoveToLocation." );
			fail( ACT_CANT_REACH_DESTINATION );
		}

		patrolIndex++;
	}

	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") succeeded." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_PatrolGoal'

	closestDistSquared = 99999999999999.9f
}