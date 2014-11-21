///
/// Models a base in game hud which shares data & components with turret
/// and vehicle huds, as well as the main HUD shown as a character.
///
class TribesIngameHUD extends TribesHUD
	abstract;

simulated function UpdateHUDData()
{
	super.UpdateHUDData();

	UpdateHUDHealthData();
	UpdateHUDTargetData();
	UpdateHUDRadarData();
	UpdateHUDSensorData();
	UpdateHUDPromptData();
}

defaultproperties
{
	bAllowCommandHUDSwitching = true
}