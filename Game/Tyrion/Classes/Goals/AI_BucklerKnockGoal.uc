//=====================================================================
// AI_BucklerKnockGoal
//=====================================================================

class AI_BucklerKnockGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Constants

const DEACTIVATION_DELAY = 4;			// goal deactivates after this many seconds

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (should be Player)";
var(Parameters) float knockDistance "max ramming distance";

var(InternalParameters) Pawn target;	// pawn I want to ram

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _target, float _knockDistance )
{
	priority = pri;

	target = _target;
	knockDistance = _knockDistance;

	super.construct( r );
}

//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
	priority = 100

	targetName		= Player
	knockDistance	= 1000
}


