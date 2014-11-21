//=====================================================================
// AI_SquadPatrolGoal
//=====================================================================

class AI_SquadPatrolGoal extends AI_SquadGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline array<Name> patrolPointNames "A list of named pathfinding nodes (PlacedNode's)";
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement speed";
var(Parameters) bool bExecuteOnce "Go through the patrol nodes just once";

//=====================================================================
// Functions
// (constructor not complete)

overloaded function construct( AI_Resource r, int pri )
{
	super.construct( r );

	priority = pri;
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	priority = 30

	groundMovement = GM_Walk
	bExecuteOnce = false
}

