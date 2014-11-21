class ActionNextCampaignMission extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerController PC;

	Super.execute();

	PC = parentScript.Level.GetLocalPlayerController();
	if (PC != None)
	{
		TribesGUIControllerBase(PC.Player.GUIController).FinishCampaignMission();
	}
	
	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Next campaign mission";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Next campaign mission"
	actionHelp			= "Loads the next mission in the campaign"
	category			= "Level"
}