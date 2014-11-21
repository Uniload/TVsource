//=====================================================================
// AI_PanicGoal
//=====================================================================

class AI_PanicGoal extends AI_CharacterGoal;

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

