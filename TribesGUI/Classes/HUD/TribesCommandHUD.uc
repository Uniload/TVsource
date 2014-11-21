class TribesCommandHUD extends TribesHUD;

simulated function UpdateHUDData()
{
	super.UpdateHUDData();

	UpdateHUDRadarData();
	UpdateHUDSensorData();
}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesCommandHUDScript"
	HUDScriptName = "default_CommandHUD"
	bAllowInteractions = true
}