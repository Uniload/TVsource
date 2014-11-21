//=====================================================================
// AI_DummyMovementGoal
//=====================================================================

class AI_DummyMovementGoal extends AI_MovementGoal;

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
}
