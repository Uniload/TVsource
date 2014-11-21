//=====================================================================
// AI_VehiclePatrolGoal
//=====================================================================

class AI_VehiclePatrolGoal extends AI_DriverGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline array<Name> patrolPointNames "A list of named pathfinding nodes (PlacedNode's)";
var(Parameters) editinline float desiredSpeed;
var(Parameters) bool bExecuteOnce "Go through the patrol nodes just once";
var(Parameters) bool skipIntermediateNodes;
var(Parameters) editinline Name attackTargetName "keep oriented towards this rook to be able to shoot at it (currently only used by the Pod)";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri )
{
	super.construct( r );

	priority = pri;
	// todo: if this goal is ever created in code: pass in parameters 
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false

	desiredSpeed = 1500
	bExecuteOnce = false
	skipIntermediateNodes = true
}

