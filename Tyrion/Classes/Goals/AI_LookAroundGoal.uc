//=====================================================================
// AI_LookAroundGoal
//=====================================================================

class AI_LookAroundGoal extends AI_MovementGoal;

//=====================================================================
// Variables

//=====================================================================
// Functions

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
}

