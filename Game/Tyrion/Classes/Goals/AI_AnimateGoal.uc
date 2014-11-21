//=====================================================================
// AI_AnimateGoal
//=====================================================================

class AI_AnimateGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name animName "Name of the animation to play";
var(Parameters) int numIterations "The number of times the animation should loop, 0 means forever";
var(Parameters) Name targetName "The pawn to turn towards before animating";
var(Parameters) Rotator facing "Where the AI turns to before animating if targetName is none";
var(Parameters) bool bNeedsToTurn "If true the targetName and facing values will be used";
var(Parameters) bool bFreezeMovement "If true the target will not move while playing the animation";

var(InternalParameters) editconst Actor target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Name _animName, int _numIterations, Actor _target, Rotator _facing,
							  bool _bNeedsToTurn, bool _bFreezeMovement )
{
	priority = pri;
	animName = _animName;
	numIterations = _numIterations;
	target = _target;
	facing = _facing;
	bNeedsToTurn = _bNeedsToTurn;
	bFreezeMovement = _bFreezeMovement;

	super.construct( r );
}

//=====================================================================

defaultproperties
{
	numIterations = 1
	bInactive = false
	bPermanent = false
	bNeedsToTurn = true
	bFreezeMovement = false
}