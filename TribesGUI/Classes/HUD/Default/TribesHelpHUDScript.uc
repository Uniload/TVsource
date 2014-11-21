class TribesHelpHUDScript extends TribesHUDScript;

// health & energy indicators
var HUDContainer healthEnergyContainer;
var HUDHealthBar health;
var HUDEnergyBar energy;

// radar & misc stuff
var HUDContainer radarContainer;
var HUDRadar radar;
var HUDObjectiveNotification objectiveNotify;

// scoreboard
var HUDContainer scoreboardGroup;
var LabelElement teamOneScoreLabel;
var LabelElement teamOneLabel;
var HUDIcon teamOneIcon;
var HUDCountDown countDown;
var HUDIcon teamTwoIcon;
var LabelElement teamTwoLabel;
var LabelElement teamTwoScoreLabel;

// weapons
var HUDContainer weaponContainer;
var HUDWeaponIcon fallbackWeapon;
var HUDWeaponIcon weapons[3];
var HUDDeployableIcon deployable;
var HUDCarryableIcon carryable;

// other items
var HUDContainer itemContainer;
var HUDHealthKitIcon healthKit;
var HUDPackIcon pack;
var HUDGrenadesIcon grenades;

var HUDContainer		messageContainer;
var HUDMessageWindow	messageWindow;

//
// Initalises the component
//
overloaded function Construct()
{
	// health & energy
	healthEnergyContainer	= HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_healthEnergyGroup"));
	health = HUDHealthBar(healthEnergyContainer.AddClonedElement("TribesGUI.HUDHealthBar", "default_health"));
	energy = HUDEnergyBar(healthEnergyContainer.AddClonedElement("TribesGUI.HUDEnergyBar", "default_energy"));

	// radar
	radarContainer = HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_radarContainer"));
	radar = HUDRadar(radarContainer.AddClonedElement("TribesGUI.HUDRadar", "default_radar"));
	objectiveNotify = HUDObjectiveNotification(radarContainer.AddClonedElement("TribesGUI.HUDObjectiveNotification", "default_ObjectiveNotification"));

	messageContainer = HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_MessageContainer"));
	messageWindow = HUDMessageWindow(messageContainer.AddClonedElement("TribesGUI.HUDMessageWindow", "default_MessageWindow"));

	// weapon bar
	weaponContainer = HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_weaponContainer"));
	fallbackWeapon = HUDWeaponIcon(weaponContainer.AddClonedElement("TribesGUI.HUDWeaponIcon", "default_FallbackWeapon"));
	fallbackWeapon.weaponIdx = -1;
	fallbackWeapon.bDrawQuantity = false;
	weapons[0] = HUDWeaponIcon(weaponContainer.AddClonedElement("TribesGUI.HUDWeaponIcon", "default_weapon0"));
	weapons[0].weaponIdx = 0;
	weapons[0].bDrawQuantity = false;
	weapons[1] = HUDWeaponIcon(weaponContainer.AddClonedElement("TribesGUI.HUDWeaponIcon", "default_weapon1"));
	weapons[1].weaponIdx = 1;
	weapons[1].bDrawQuantity = false;
	weapons[2] = HUDWeaponIcon(weaponContainer.AddClonedElement("TribesGUI.HUDWeaponIcon", "default_weapon2"));
	weapons[2].weaponIdx = 2;
	weapons[2].bDrawQuantity = false;
	deployable = HUDDeployableIcon(weaponContainer.AddClonedElement("TribesGUI.HUDDeployableIcon", "default_deployable"));
	deployable.bDrawQuantity = false;
	carryable = HUDCarryableIcon(weaponContainer.AddClonedElement("TribesGUI.HUDCarryableIcon", "default_Carryable"));
	carryable.bDrawQuantity = false;

	// item bar
	itemContainer = HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_itemContainer"));
	healthKit = HUDHealthKitIcon(itemContainer.AddClonedElement("TribesGUI.HUDHealthKitIcon", "default_healthKit"));
	pack = HUDPackIcon(itemContainer.AddClonedElement("TribesGUI.HUDPackIcon", "default_pack"));
	pack.bDrawQuantity = false;
	grenades = HUDGrenadesIcon(itemContainer.AddClonedElement("TribesGUI.HUDGrenadesIcon", "default_grenades"));
	grenades.bDrawQuantity = false;

	scoreboardGroup	= HUDContainer(AddClonedElement("TribesGUI.HUDContainer", "default_scoreboardGroup"));
	teamOneScoreLabel = LabelElement(scoreboardGroup.AddClonedElement("TribesGUI.LabelElement", "default_teamOneScore"));
	teamOneLabel = LabelElement(scoreboardGroup.AddClonedElement("TribesGUI.LabelElement", "default_teamOneLabel"));
	countDown = HUDCountDown(scoreboardGroup.AddClonedElement("TribesGUI.HUDCountDown", "default_countDown"));
	teamTwoLabel = LabelElement(scoreboardGroup.AddClonedElement("TribesGUI.LabelElement", "default_teamTwoLabel"));
	teamTwoScoreLabel = LabelElement(scoreboardGroup.AddClonedElement("TribesGUI.LabelElement", "default_teamTwoScore"));

	// add help labels
	health.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Health", "Localisation\\GUI\\HelpLabels");
	energy.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Energy", "Localisation\\GUI\\HelpLabels");
	radar.HelpLabel	= static.Localize("HelpLabels", "MSG_HelpLabels_Radar", "Localisation\\GUI\\HelpLabels");
	messageWindow.HelpLabel	= static.Localize("HelpLabels", "MSG_HelpLabels_ChatWindow", "Localisation\\GUI\\HelpLabels");
	fallbackWeapon.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_FallbackWeapon", "Localisation\\GUI\\HelpLabels");
	weapons[0].HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_WeaponOne", "Localisation\\GUI\\HelpLabels");
	weapons[1].HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_WeaponTwo", "Localisation\\GUI\\HelpLabels");
	weapons[2].HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_WeaponThree", "Localisation\\GUI\\HelpLabels");
	deployable.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Deployable", "Localisation\\GUI\\HelpLabels");
	carryable.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Carryable", "Localisation\\GUI\\HelpLabels");
	pack.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Pack", "Localisation\\GUI\\HelpLabels");
	grenades.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_HandGrenades", "Localisation\\GUI\\HelpLabels");
	scoreboardGroup.HelpLabel = static.Localize("HelpLabels", "MSG_HelpLabels_Scoreboard", "Localisation\\GUI\\HelpLabels");
}

defaultproperties
{
	bIsChatEnabled = true
	bIsQuickChatEnabled = false
	bEventMessagesEnabled = false
	bIsAnnouncmentsEnabled = false
}