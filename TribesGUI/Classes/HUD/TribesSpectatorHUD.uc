class TribesSpectatorHUD extends TribesHUD;

simulated function Character GetCharacter()
{
	if(Character(Controller.ViewTarget) != None)
		return Character(Controller.ViewTarget);

	return None;
}

simulated function UpdateHUDData()
{
	super.UpdateHUDData();
	UpdateHUDHealthData();

	clientSideChar.UserPrefColorType = COLOR_Team;

	if (Pawn(Controller.ViewTarget) != None && Pawn(Controller.ViewTarget).PlayerReplicationInfo != None)
		clientSideChar.watchedPlayerName = Pawn(Controller.ViewTarget).PlayerReplicationInfo.PlayerName;
	else
		clientSideChar.watchedPlayerName = "";
}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesSpectatorHUDScript"
	HUDScriptName = "default_SpectatorHUD"
	bAllowInteractions	= true
	bAllowCommandHUDSwitching = true
}