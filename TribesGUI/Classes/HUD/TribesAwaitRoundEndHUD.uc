class TribesAwaitRoundEndHUD extends TribesSpectatorHUD;

simulated function UpdateHUDData()
{
	super.UpdateHUDData();

	if(controller.bTeamMarkerColors)
		clientSideChar.UserPrefColorType = COLOR_Team;
	else
		clientSideChar.UserPrefColorType = COLOR_Relative;
}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesAwaitRoundEndHUDScript"
	HUDScriptName = "default_AwaitRoundEndHUD"
}