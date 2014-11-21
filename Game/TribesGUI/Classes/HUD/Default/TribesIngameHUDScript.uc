//================================================================
// Class: TribesIngameHUDScript
//
// The default Tribes HUD script implementation.
//
//================================================================

class TribesIngameHUDScript extends TribesEditableHUDScript;

// health & energy indicators
var HUDHealthBar health;
var HUDEnergyBar energy;

// radar & misc stuff
var HUDRadar radar;
var HUDObjectiveNotification objectiveNotify;

// full screen stuff
var HUDMarkerDisplay markerDisplay;
var HUDWeaponReticule weaponReticule;
var HUDDeployableReticule deployableReticule;
var HUDUseableMarker useableMarker;
var HUDDamageIndicator damageIndicator;

var HUDTargetInfo targetInfo;
var HUDThrowMeter throwMeter;

var HUDTalkingHead talkingHead;
var LabelElement promptLabel;

var HUDPersonalMessageWindow PersonalMessageWindow;
var HUDPersonalScores PersonalScores;

var HUDIcon redJackIcon;

//
// Initalises the component
//
overloaded function Construct()
{
	super.Construct();

	// marker display  - goes first so it renders first
	markerDisplay = HUDMarkerDisplay(AddElement("TribesGUI.HUDMarkerDisplay", "default_markerDisplay"));
	useableMarker = HUDUseableMarker(AddElement("TribesGUI.HUDUseableMarker", "default_useableMarker"));

	damageIndicator = HUDDamageIndicator(AddElement("TribesGUI.HUDDamageIndicator", "default_DamageIndicator"));

	// health & energy
	health					= HUDHealthBar(AddElement("TribesGUI.HUDHealthBar", "default_health"));
	energy					= HUDEnergyBar(AddElement("TribesGUI.HUDEnergyBar", "default_energy"));

	// radar
	radar = HUDRadar(AddElement("TribesGUI.HUDRadar", "default_radar"));
	objectiveNotify = HUDObjectiveNotification(AddElement("TribesGUI.HUDObjectiveNotification", "default_ObjectiveNotification"));

	// reticules
	weaponReticule = HUDWeaponReticule(AddElement("TribesGUI.HUDWeaponReticule", "default_weaponReticule"));
	deployableReticule = HUDDeployableReticule(AddElement("TribesGUI.HUDDeployableReticule", "default_deployableReticule"));

	// other things for the center of the screen
	targetInfo = HUDTargetInfo(AddElement("TribesGUI.HUDTargetInfo", "default_targetInfo"));
	throwMeter = HUDThrowMeter(AddElement("TribesGUI.HUDThrowMeter", "default_ThrowMeter"));

	talkingHead = HUDTalkingHead(AddElement("TribesGUI.HUDTalkingHead", "default_talkingHead"));

	promptLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_InGamePromptLabel"));

	redJackIcon = HUDIcon(AddElement("TribesGUI.HUDIcon", "default_redJackIcon"));

	PersonalMessageWindow = HUDPersonalMessageWindow(AddElement("TribesGui.HUDPersonalMessageWindow", "default_PersonalMessageWindow"));
	PersonalScores = HUDPersonalScores(AddElement("TribesGui.HUDPersonalScores", "default_PersonalScores"));
}


function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	// update the prompt text
	promptLabel.bVisible = c.promptText != "";
	if(promptLabel.bVisible)
	{
		promptLabel.SetText(c.promptText);
	}

	if (c.ping >= 255)
		redJackIcon.bVisible = true;
	else
		redJackIcon.bVisible = false;
}
