class ActionStartCountDown extends Scripting.Action;

var() float seconds;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.level.getLocalPlayerController());

	if (pcc != None)
	{
		pcc.bCountDown = true;
		pcc.countDown = seconds;
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Start a count down for " $ propertyDisplayString('seconds') $ " seconds";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Start Count Down"
	actionHelp			= "Starts a count down that will last for the given number of seconds"
	category			= "Other"
}