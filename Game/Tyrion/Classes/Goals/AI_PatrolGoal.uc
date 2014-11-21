//=====================================================================
// AI_PatrolGoal
// Patrol along a specified route
//=====================================================================

class AI_PatrolGoal extends AI_MovementGoal
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

