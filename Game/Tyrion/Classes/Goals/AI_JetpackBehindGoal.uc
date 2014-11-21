//=====================================================================
// AI_JetpackBehindGoal
//=====================================================================

class AI_JetpackBehindGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) editinline vector destination "Where to jetpack to? (if (0,0,0) the action will chose a point)";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, optional vector _destination,
							  optional float _proximity, optional IFollowFunction _followFunction )
{
	priority = pri;
	target = _target;
	destination = _destination;

	if ( _proximity == 0.0f )
		proximity = default.proximity;
	else
		proximity = _proximity;

	followFunction = _followFunction;

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

