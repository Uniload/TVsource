//=====================================================================
// AI_VehiclePatrol
// Moves along a series of waypoints
//=====================================================================

class AI_VehiclePatrol extends AI_DriverAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editconst array<Name> patrolPointNames;
var(Parameters) editinline float desiredSpeed;
var(Parameters) bool bExecuteOnce "Go through the patrol nodes just once";
var(Parameters) bool skipIntermediateNodes;
var(Parameters) editinline Name attackTargetName "keep oriented towards this rook to be able to shoot at it (currently only used by the Pod)";

var Rook attackTarget;
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
	errorCode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------

function cleanup()
{
	local AI_Controller c;

	super.cleanup();

	c = AI_Controller(vehicle().controller);

	if ( vehicle().controller != None )
	{
		c.stopMove();
		c.bPatrolling = false;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( patrolPointNames.length == 0 )
	{
		log( "AI WARNING:" @ name @ "(" @ vehicle().name @ ") has no patrol points" );
		succeed();
	}

	AI_Controller(vehicle().controller).bPatrolling = true;

	if ( attackTargetName != '' )
		attackTarget = Rook(vehicle().findStaticByLabel( class'Gameplay.Rook', attackTargetName ));

	// find closest patrolPoint; initialize patrolPoints array
	for ( patrolIndex = 0; patrolIndex < patrolPointNames.length; ++patrolIndex )
	{
		node = vehicle().findStaticByLabel( class'Pathfinding.PlacedNode', patrolPointNames[patrolIndex] );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ vehicle().name @ ") can't find specified path node" @ patrolPointNames[patrolIndex] );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		patrolPoints[patrolIndex] = node.Location;

		distSquared = VDistSquared( node.Location, vehicle().Location );

		if ( distSquared < closestDistSquared )
		{
			closestDistSquared = distSquared;
			closestIndex = patrolIndex;
		}
	}

	patrolIndex = closestIndex;

	if ( vehicle().logTyrion )
		log( name @ "(" @ vehicle().name @ ") started patrolling at node" @ closestIndex @ "attackTarget:" @ attackTarget );

	while ( !bExecuteOnce || patrolIndex != patrolPoints.length )
	{
		if ( patrolIndex == patrolPoints.length )
			patrolIndex = 0;

		if ( vehicle().isA( 'Car' ) )
			waitForAction( class'CarMoveToLocation'.static.startAction( AI_Controller(vehicle().controller),
						self, patrolPoints[patrolIndex], desiredSpeed ));
		else
			waitForAction( class'AircraftMoveToLocation'.static.startAction( AI_Controller(vehicle().controller),
						self, patrolPoints[patrolIndex], skipIntermediateNodes, desiredSpeed, attackTarget ));

		if ( errorCode != ACT_SUCCESS )
		{
			if ( resource.pawn().logTyrion )
				log( name @ "(" @ vehicle().name @ ") aborted due to error" @ errorCode @ "from MoveToLocation." );
			fail( ACT_CANT_REACH_DESTINATION );
		}

		patrolIndex++;
	}

	if ( vehicle().logTyrion )
		log( name @ "(" @ vehicle().name @ ") succeeded." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehiclePatrolGoal'

	closestDistSquared = 99999999999999.9f
}