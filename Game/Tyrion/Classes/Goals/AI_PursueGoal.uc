//=====================================================================
// AI_PursueGoal
//=====================================================================

class AI_PursueGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;	// index of this pawn in a formation (starts at 0)

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, optional float aProximity,
							  optional IFollowFunction aFollowFunction, optional int aPositionIndex,
							  optional float aEnergyUsage, optional float aTerminalVelocity, optional float aTerminalHeight )
{
	priority = pri;
	target = aTarget;

	if ( aProximity == 0.0f )
		proximity = default.proximity;
	else
		proximity = aProximity;

	followFunction = aFollowFunction;
	positionIndex = aPositionIndex;

	energyUsage = aEnergyUsage;
	terminalVelocity = aTerminalVelocity;
	terminalHeight = aTerminalHeight;

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
	proximity = 500
	bInactive = false
	bPermanent = false

	bTryOnlyOnce = true	// PursueGoal won't activate again if target becomes visible so you don't ever want failed PursueGoals hanging around
}

