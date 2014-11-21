class ActionStartHeadTalking extends Scripting.Action;

var() Name talkingHeadCamera;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;
	local TalkingHeadCamera thc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());

	if (pcc != None)
	{
		thc = TalkingHeadCamera(findByLabel(class'TalkingHeadCamera', talkingHeadCamera));

		if (thc != None)
		{
			parentScript.stopTalkingHead = pcc.hideTalkingHead;
			pcc.showTalkingHead(thc, parentScript);
		}
		else
		{
			logError("Couldn't find talking head camera " $ talkingHeadCamera);
		}
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
	s = "Start viewing from talking head camera " $ propertyDisplayString('talkingHeadCamera');
}

defaultproperties
{
	actionDisplayName	= "Start talking head camera"
	actionHelp			= "Turns on the talking head HUD element and starts rendering to it from the view of the given talking head camera"
	category			= "AudioVisual"
}