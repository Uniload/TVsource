class ActionFailCampaignMission extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerCharacterController pcc;

	Super.execute();

	pcc = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());

	TribesGUIControllerBase(pcc.Player.GUIController).GuiConfig.bMissionFailed = true;

	SingleplayerGameInfo(parentScript.Level.Game).showDeathScreen(pcc);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = actionDisplayName;
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Fail campaign mission"
	actionHelp			= "Fail the current campaign mission"
	category			= "Level"
}