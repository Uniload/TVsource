class ActionLoop extends Action
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() deepcopy editinline Array<Action> loopActions;


simulated function PrecacheSpeech(SpeechManager Manager)
{
	local int i;

	for (i = 0; i < loopActions.Length; ++i)
		if (loopActions[i] != None)
			loopActions[i].PrecacheSpeech(Manager);
}

function setParentScript(Script s)
{
	local int i;

	super.setParentScript(s);
	
	for (i = 0; i < loopActions.Length; ++i)
		if (loopActions[i] != None)
		loopActions[i].setParentScript(s);
}

// execute
latent function Variable execute()
{
	local int i;
	
	super.execute();

	parentScript.enterLoop();
	
	while (true)
	{
		for (i = 0; i < loopActions.Length; ++i)
		{
			if (parentScript.keepLooping())
			{
				if (loopActions[i] != None) // Some wallies put None actions in their scripts :/
				loopActions[i].execute();
			}
			else
			{
				goto END_LOOP;
			}
		}
	}

END_LOOP:
	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Loop";
}

cpptext
{
	virtual void CleanupDestroyed();
	virtual UAction* FixOwnership(AScript* ownerScript);
	virtual void CheckForErrors(FString& prefix, int index, AScript* ownerScript);
	bool IsMember(UAction* action);

}


defaultproperties
{
     actionDisplayName="Loop Statement"
     actionHelp="Continually loop over loopActions until ActionExitLoop is executed."
     category="Script"
}
