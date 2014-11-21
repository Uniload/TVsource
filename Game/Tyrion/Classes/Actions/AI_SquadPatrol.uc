//=====================================================================
// AI_SquadPatrol
//=====================================================================

class AI_SquadPatrol extends AI_SquadAction
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
var Actor node;

var AI_Goal moveGoal;

//=====================================================================
// Functions

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( moveGoal != None )
	{
		moveGoal.Release();
		moveGoal = None;
	}
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

	// find closest patrolPoint; initialize patrolPoints array
	for ( patrolIndex = 0; patrolIndex < patrolPointNames.length; ++patrolIndex )
	{
		node = squad().findStaticByLabel( class'Pathfinding.PlacedNode', patrolPointNames[patrolIndex] );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ squad().name @ ") can't find specified path node" @ patrolPointNames[patrolIndex] );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		patrolPoints[patrolIndex] = node.Location;

		// todo: use the center of gravity of the squad instead of squad().Location
		//distSquared = VDistSquared( node.Location, squad().Location );

		//if ( distSquared < closestDistSquared )
		//{
		//	closestDistSquared = distSquared;
		//	closestIndex = patrolIndex;
		//}
	}

	patrolIndex = closestIndex;

	if ( squad().logTyrion )
		log( name @ "(" @ squad().name @ ") started patrolling at node" @ closestIndex );

	while ( !bExecuteOnce || patrolIndex != patrolPoints.length )
	{
		if ( patrolIndex == patrolPoints.length )
			patrolIndex = 0;

		moveGoal = (new class'AI_SquadMoveToGoal'( resource, achievingGoal.priority, patrolPoints[patrolIndex], ,,, groundMovement )).myAddRef();
		waitForGoal( moveGoal.postGoal( self ) );

		if ( !moveGoal.wasAchieved() )
		{
			if ( squad().logTyrion )
				log( name @ "(" @ squad().name @ ") aborted due to SquadMoveToGoal failing." );
			fail( ACT_CANT_REACH_DESTINATION );
		}

		patrolIndex++;
	}

	if ( squad().logTyrion )
		log( name @ "(" @ squad().name @ ") succeeded." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_SquadPatrolGoal'

	closestDistSquared = 99999999999999.9f
}