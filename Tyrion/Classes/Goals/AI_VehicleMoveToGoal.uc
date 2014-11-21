//=====================================================================
// AI_VehicleMoveToGoal
//=====================================================================

class AI_VehicleMoveToGoal extends AI_DriverGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) editinline float desiredSpeed;
var(Parameters) bool skipIntermediateNodes;
var(Parameters) editinline Name attackTargetName "keep oriented towards this rook to be able to shoot at it (currently only used by the Pod)";

var(InternalParameters) editconst Vector destination;
var(InternalParameters) editconst Rook attackTarget;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector _destination, float _desiredSpeed,
							  bool _skipIntermediateNodes, optional Rook _attackTarget )
{
	priority = pri;
	destination = _destination;
	desiredSpeed = _desiredSpeed;
	skipIntermediateNodes = _skipIntermediateNodes;
	attackTarget = _attackTarget;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	desiredSpeed = 1500
	skipIntermediateNodes = true
}
