//=====================================================================
// AI_NonblockingFollowGoal
//=====================================================================

class AI_NonblockingFollowGoal extends AI_CharacterGoal
	;//editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "An actor to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

var(InternalParameters) editconst Actor target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;	// index of this pawn in a formation (starts at 0)

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Actor _target, optional float _proximity,
							  optional IFollowFunction _followFunction, optional int _positionIndex,
							  optional float _energyUsage, optional float _terminalVelocity, optional float _terminalHeight )
{
	priority = pri;
	target = _target;

	if ( _proximity == 0.0f )
		proximity = default.proximity;
	else
		proximity = _proximity;

	followFunction = _followFunction;
	positionIndex = _positionIndex;

	energyUsage = _energyUsage;
	terminalVelocity = _terminalVelocity;
	terminalHeight = _terminalHeight;

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
}

