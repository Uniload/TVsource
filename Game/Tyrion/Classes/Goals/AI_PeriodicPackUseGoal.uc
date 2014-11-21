//=====================================================================
// AI_PeriodicPackUseGoal
//=====================================================================

class AI_PeriodicPackUseGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float period "Time between pack activations";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, float _period )
{
	super.construct( r );

	priority = pri;
	period = _period;
}

//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false

	period = 7.0f
}

