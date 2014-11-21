class ActionSpeak extends ActionGoalAction;

var() Name	speechTag		"Tag for the speech, or mojo cutscene. This should NOT include the package name";
var() bool	bWaitForSpeech	"If true the script will wait until the speech has finished";
var() bool	bPositional		"Whether the speech is to be positional or not";

// AI goal parameters
var() float	AIGoal_priority		"Priority of AI goal (only valid if speaker is an AI)";
var() Name	AIGoal_listener		"Pawn the AI will speak to (only valid if target is an AI)";
var() actionnoresolve	Rotator	AIGoal_facing	"Direction the AI will turn to if AIGoal_listener is None (only valid if speaker is an AI)";
var() bool bNeedsToTurn			"If true the AIGoal_listener and AIGoal_facing values will be used";

// execute
latent function Variable execute()
{
	local float speechDuration, speechStartTime;
	local AI_TalkGoal goal, realGoal;
	local Character characterSpeaker;

	Super.execute();
	
	characterSpeaker = Character(FindByLabel(class'Character', target));

	if(! characterSpeaker.IsAlive())
	{
		log("Warning: Speaker " $target $" is not alive in ActionSpeak, speech cancelled");
		return None;
	}

	if(characterSpeaker != None && characterSpeaker.IsA('BaseAICharacter'))
	{
		// TODO: need code here to generate an AI_Talk goal
		goal = new(parentScript.Level.Outer) class'AI_TalkGoal'();

		// init goal parameters:
		goal.priority = AIGoal_priority + (parentScript.cutscenePriority * 10);
		goal.lipsyncAnimName = speechTag;
		goal.subtitleTag = speechTag;
		goal.targetName = AIGoal_listener;
		goal.facing = AIGoal_facing;
		goal.bPositional = bPositional;
		goal.bWaitForSpeech = bWaitForSpeech;
		goal.bNeedsToTurn = bNeedsToTurn;
		goal.goalName = name $ "_TalkGoal";	// uniquely identify this TalkGoal in case we need to remove it

		// call postGoal function defined in "ActionGoalAction":
		realGoal = AI_TalkGoal(postGoal(characterSpeaker, goal));
		realGoal.AddRef();

		// wait for the goal to finish
		if(bWaitForSpeech)
		{
			while(! realGoal.hasCompleted())
			{
				// if the script needs to exit, we should unpost the goal
				if(parentScript.continueExecution())
				{
					sleep(0.0);
				}
				else
				{
					parentScript.Level.SpeechManager.CancelSpeech(characterSpeaker);
					unpostGoal(characterSpeaker, realGoal.goalName);
					break;
				}				
			}
		}

		realGoal.Release();
	}
	else
	{
		speechStartTime = parentScript.Level.TimeSeconds;
		speechDuration = parentScript.Level.speechManager.PlayScriptedSpeech(characterSpeaker, speechTag, bPositional);
		if(bWaitForSpeech)
		{
			while((speechStartTime + speechDuration) > parentScript.Level.TimeSeconds)
			{
				if(parentScript.continueExecution())
				{
					sleep(0.0);
				}
				else
				{
					parentScript.Level.SpeechManager.CancelSpeech(characterSpeaker);
					break;
				}
			}
		}
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Character " $propertyDisplayString('target') $" speaking dialog tag " $propertyDisplayString('speechTag');
}

simulated function PrecacheSpeech(SpeechManager Manager)
{
	Manager.PrecacheVO(string(speechTag));
}


defaultproperties
{
	bWaitForSpeech		= true
	bPositional			= true
	bNeedsToTurn		= false
	AIGoal_priority		= 50

	returnType			= None
	actionDisplayName	= "Speak"
	actionHelp			= "Makes a character speak"
	category			= "AudioVisual"
}