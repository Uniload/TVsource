//=====================================================================
// AI_VehiclePursueGoal
//=====================================================================

class AI_VehiclePursueGoal extends AI_DriverGoal;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight "How high to end up over the target - 0 means 'DONT_CARE'";
var(Parameters) float desiredSpeed	"Preferred travel speed";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;	// index of this pawn in a formation (starts at 0)

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget, optional float aProximity,
							  optional IFollowFunction aFollowFunction, optional int aPositionIndex,
							  optional float aTerminalVelocity, optional float aTerminalHeight, optional float aDesiredSpeed )
{
	priority = pri;
	target = aTarget;

	if ( aProximity == 0.0f )
		proximity = default.proximity;
	else
		proximity = aProximity;

	followFunction = aFollowFunction;
	positionIndex = aPositionIndex;

	terminalVelocity = aTerminalVelocity;
	terminalHeight = aTerminalHeight;
	desiredSpeed = aDesiredSpeed;

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
	proximity = 1000
	bInactive = false
	bPermanent = false
}

