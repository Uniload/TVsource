//=====================================================================
// AI_TakeCoverGoal
//=====================================================================

class AI_TakeCoverGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(Parameters) bool bSearch "look around if no cover is found?";
var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, bool _bSearch, optional float _energyUsage )
{
	priority = pri;

	target = _target;
	bSearch = _bSearch;
	energyUsage = _energyUsage;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}
