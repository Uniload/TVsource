class ActionStopHeadTalking extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());

	if (pcc != None)
	{
		parentScript.stopTalkingHead = None;
		pcc.hideTalkingHead(parentScript);
	}
	else
	{
		logError("Couldn't get the players controller");
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Stop viewing from the current talking head camera";
}

defaultproperties
{
	actionDisplayName	= "Stop talking head camera"
	actionHelp			= "Turns off the talking head HUD element"
	category			= "AudioVisual"
}