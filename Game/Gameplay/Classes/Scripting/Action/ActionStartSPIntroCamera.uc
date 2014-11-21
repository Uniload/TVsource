class ActionStartSPIntroCamera extends Scripting.Action;

var() float length		"The length of time that the effect takes";

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.level.getLocalPlayerController());

	if (pcc != None)
	{
		pcc.introCameraOldState = pcc.GetStateName();
		pcc.camera.clearTransitions();
		pcc.camera.transition('LevelStartPan', length);
		pcc.GotoState('SPIntroduction');
		pcc.introCameraScript = parentScript;
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Start SP Intro Camera";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Start SP Intro Camera"
	actionHelp			= "The camera pans around the player and zooms into his head"
	category			= "Other"
	length				= 4.5
}