//=====================================================================
// AI_CombatMovementGoal
//=====================================================================

class AI_CombatMovementGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float proximity;
var(Parameters) float energyUsage;
var(Parameters) float sideStepInterval "how frequently AI's side steps when in CM_SIDE_STEP";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, optional float aProximity,
							  optional IFollowFunction aFollowFunction, optional float aEnergyUsage,
							  optional float aSideStepInterval )
{
	priority = pri;
	target = aTarget;

	proximity = aProximity;
	followFunction = aFollowFunction;
	energyUsage = aEnergyUsage;

	if ( aSideStepInterval == 0 )
		sideStepInterval = default.sideStepInterval;
	else
		sideStepInterval = aSideStepInterval;

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

	sideStepInterval = 6.0f
}

