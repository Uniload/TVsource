class TribesSpectatorHUDScript extends TribesHUDScript;

var LabelElement MessageLabel;
var HUDHealthBar HealthBar;
var HUDEnergyBar EnergyBar;

var localized string watchPlayerText;
var localized string floatText;

overloaded function Construct()
{
	super.Construct();

	MessageLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_SpectatorMessageLabel"));
	MessageLabel.SetText(floatText);

	HealthBar = HUDHealthBar(AddClonedElement("TribesGUI.HUDHealthBar", "default_health"));
	EnergyBar = HUDEnergyBar(AddClonedElement("TribesGUI.HUDEnergyBar", "default_energy"));
}

function UpdateData(ClientSideCharacter c)
{
	// Update viewtarget here
	if (c.watchedPlayerName != "")
	{
		MessageLabel.SetText(replaceStr(watchPlayerText, c.watchedPlayerName));

		HealthBar.bVisible = true;
		EnergyBar.bVisible = true;
		c.bShowEnergyBar = true;
	}
	else
	{
		MessageLabel.SetText(floatText);

		HealthBar.bVisible = false;
		EnergyBar.bVisible = false;
		c.bShowEnergyBar = false;
	}
}

defaultproperties
{
	watchPlayerText	= "You are watching %1.¼Press Jet to view other players."
	floatText = "You are spectating.¼Press Jet to view players."
}