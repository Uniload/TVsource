class ActionStopCountDown extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.level.getLocalPlayerController());

	if (pcc != None)
	{
		pcc.bCountDown = false;
		pcc.countDown = 0.0;
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Stop the current count down";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Stop Count Down"
	actionHelp			= "Stops the current count down"
	category			= "Other"
}