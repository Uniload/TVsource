//=====================================================================
// AI_WanderGoal
// Move randomly between specified path nodes
//=====================================================================

class AI_WanderGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline array<Name> wanderPointNames "A list of named pathfinding nodes (PlacedNode's)";
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement speed";
var(Parameters) float wanderRadius "when no path nodes are specified, wander inside this radius";
var(Parameters) Range pauseRange "min and max wait times between moves";

//=====================================================================
// Functions

// (not complete)
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
	priority = 20

	groundMovement	= GM_Walk
	wanderRadius	= 500
	pauseRange		= (Min=2.0f,Max=4.0f)
}

