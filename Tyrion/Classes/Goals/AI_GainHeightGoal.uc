//=====================================================================
// AI_GainHeightGoal
//=====================================================================

class AI_GainHeightGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, optional float aEnergyUsage )
{
	priority = pri;

	target = aTarget;
	energyUsage = aEnergyUsage;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = true
}

