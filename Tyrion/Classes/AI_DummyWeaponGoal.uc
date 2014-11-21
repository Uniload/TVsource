//=====================================================================
// AI_DummyWeaponGoal
//=====================================================================

class AI_DummyWeaponGoal extends AI_WeaponGoal;

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
