//=====================================================================
// AI_TalkGoal
//=====================================================================

class AI_TalkGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name lipsyncAnimName "The name of the lipsync animation to play";
var(Parameters) Name subtitleTag "The localization tag for the subtitle text of the dialogue";
var(Parameters) Name targetName "The pawn to talk to";
var(Parameters) Rotator facing "Where the AI turns to before talking if targetName is none";
var(Parameters) bool bNeedsToTurn "If true the targetName and facing values will be used";
var(Parameters) bool bPositional "Whether the sound is to be positional or 2D";
var(Parameters) bool bWaitForSpeech "Whether the action should wait till the sound has finished playing before continuing";

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Name aLipsyncAnimName, Name aSubtitleTag, Pawn aTarget, Rotator aFacing, bool needsToTurn, bool waitForSpeech, bool positional)
{
	priority = pri;
	lipsyncAnimName = aLipsyncAnimName;
	subtitleTag = aSubtitleTag;
	target = aTarget;
	facing = aFacing;
	bNeedsToTurn = needsToTurn;
	bPositional = positional;
	bWaitForSpeech = waitForSpeech;

	super.construct( r );
}

//=====================================================================

defaultproperties
{
	bNeedsToTurn = true
	bInactive = false
	bPermanent = false
}

