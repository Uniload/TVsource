//=====================================================================
// AI_DummyHeadGoal
//=====================================================================

class AI_DummyHeadGoal extends AI_HeadGoal;

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

