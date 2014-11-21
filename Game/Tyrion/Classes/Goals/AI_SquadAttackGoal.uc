//=====================================================================
// AI_SquadAttackGoal
//=====================================================================

class AI_SquadAttackGoal extends AI_SquadGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target pawn or squad";

var(InternalParameters) editconst SquadInfo targetSquad;
var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, SquadInfo aTargetSquad )
{
	priority = pri;
	target = aTarget;
	targetSquad = aTargetSquad;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

