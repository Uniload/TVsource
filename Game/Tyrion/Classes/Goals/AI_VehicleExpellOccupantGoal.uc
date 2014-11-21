//=====================================================================
// AI_VehicleExpellOccupantGoal
//=====================================================================

class AI_VehicleExpellOccupantGoal extends AI_VehicleGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name occupantName "Name of character to expell";

var(InternalParameters) Character occupant;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Character aOccupant )
{
	priority = pri;
	occupant = aOccupant;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

