class ActionFor extends Action
	native;

cpptext
{
	virtual void CleanupDestroyed();
	virtual UAction* FixOwnership(AScript* ownerScript);
	virtual void CheckForErrors(FString& prefix, int index, AScript* ownerScript);
	bool IsMember(UAction* action);
}

var() actionnoresolve name counterName;
var() float beginValue;
var() float endValue;
var() deepcopy editinline Array<Action> forActions;


simulated function PrecacheSpeech(SpeechManager Manager)
{
	local int i;

	for (i = 0; i < forActions.Length; ++i)
		if (forActions[i] != None)
			forActions[i].PrecacheSpeech(Manager);
}

function setParentScript(Script s)
{
	local int i;

	super.setParentScript(s);
	
	for (i = 0; i < forActions.Length; ++i)
		if (forActions[i] != None)
			forActions[i].setParentScript(s);
}

// execute
latent function Variable execute()
{
	local int i;
	local VariableFloat counterVar;
	local float end;

	super.execute();

	// Get the counter variable
	counterVar = VariableFloat(newVariable(counterName, class'VariableFloat'));

	// The counter variable must be a float
	if (counterVar == None)
	{
		logError("The counter variable must be a float variable");
		return None;
	}

	counterVar.value = beginValue;
	end = endValue;

	while (counterVar.value <= end)
	{
		for (i = 0; (i < forActions.Length) && parentScript.keepLooping(); ++i)
		{
			if (forActions[i] != None) // Some wallies put None actions in their scripts :/
				forActions[i].execute();
		}

		counterVar.add("1");
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "For " $ counterName $ " = " $ propertyDisplayString('beginValue') $ " to " $ propertyDisplayString('endValue');
}

defaultproperties
{
	counterName			= "forCounter"
	returnType			= None
	actionDisplayName	= "For Statement"
	actionHelp			= "Executes a list of actions n times."
	category			= "Script"
}