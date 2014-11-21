//=====================================================================
// AI_VehicleLocalAttackGoal
//=====================================================================

class AI_VehicleLocalAttackGoal extends AI_DriverGoal
	;

//=====================================================================
// Variables

var(InternalParameters) editconst Vector destination;
var(InternalParameters) editconst float terminalDistance;
var(InternalParameters) editconst float speed;
var(InternalParameters) editconst Rook target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector aDestination, float aTerminalDistance, float aSpeed, Rook aTarget )
{
	priority = pri;
	destination = aDestination;
	terminalDistance = aTerminalDistance;
	speed = aSpeed;
	target = aTarget;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false

	speed = 1500
}

