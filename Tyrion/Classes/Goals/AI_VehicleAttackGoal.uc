//=====================================================================
// AI_VehicleAttackGoal
//=====================================================================

class AI_VehicleAttackGoal extends AI_VehicleGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, optional IFollowFunction aFollowFunction )
{
	priority = pri;
	target = aTarget;
	followFunction = aFollowFunction;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called when a goal is removed

function cleanup()
{
	super.cleanup();

	followFunction = None;
}

//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

