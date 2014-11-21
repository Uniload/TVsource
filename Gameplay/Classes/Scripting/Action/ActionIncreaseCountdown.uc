class ActionIncreaseCountDown extends Scripting.Action;

var() float seconds;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.level.getLocalPlayerController());

	if (pcc != None)
	{
		if (pcc.bCountDown)
			pcc.countDown += seconds;
		else
			logError("Count down wasn't running, must start a count down before trying to increase it.");
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Increases the count down by " $ propertyDisplayString('seconds') $ " seconds";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Increase Count Down"
	actionHelp			= "Increases the count down by a given number of seconds"
	category			= "Other"
}