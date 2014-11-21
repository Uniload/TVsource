// ====================================================================
//  Class:  TribesGui.TribesMPProfilePanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPProfilePanel extends TribesMPPanel
     ;

// Just store a player name for now, until player profiles are implemented
var(TribesGui) private EditInline Config GUIComboBox ProfileBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton NewButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton DeleteButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel PlayerNameDataLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox GenderCombo "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox VoiceChatCombo "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton LoadoutButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton UseGamespy "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton SaveGamespyPassword "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel SaveGamespyPasswordTitle "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton CreateGamespy "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton UseTeam "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton SaveTeamPassword "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel SaveTeamPasswordTitle "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton CreateTeam "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton LoginGamespy "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton LoginTeam "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel GamespyEmailLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel GamespyEmailTitleLabel "A component of this page which has its behavior defined in the code for this page's class.";
//var(TribesGui) private EditInline Config GUILabel StatPasswordLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel TeamLoginLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel TeamLoginTitleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel TeamNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel TeamNameTitleLabel "A component of this page which has its behavior defined in the code for this page's class.";

var ProfileManager			playerProfileManager;
var PlayerProfile			ActiveProfile;

var(TribesGui) private EditInline Config localized String femaleText;
var(TribesGui) private EditInline Config localized String maleText;
var(TribesGui) private EditInline Config localized String StoredText;
var(TribesGui) private EditInline Config localized String NotStoredText;
var(TribesGui) private EditInline Config localized String NotSetText;
var(TribesGui) private EditInline Config localized String needGameSpyLoginString;
var(TribesGui) private EditInline Config localized String createProfileText;

var Array<String> VoiceChatPreviewType;
var int MaxQCPool;

function InitComponent(GUIComponent MyOwner)
{
	local int i;
	local Array<string> QuickChatNames;
	local string newItem;

	Super.InitComponent(MyOwner);

	// add gender items, with the boolean value mapping to bIsFemale
	GenderCombo.AddItem(maleText, , , , false);
	GenderCombo.AddItem(femaleText, , , , true);

	TribesGUIController(Controller).FindQuickChatNames(QuickChatNames);
	LOG("Found"@QuickChatNames.Length@"quick chat voice sets");
	for (i = 0; i < QuickChatNames.Length; i++)
	{
		newItem = Localize("QuickChatNames", QuickChatNames[i], "Localisation\\Speech\\QuickChat");
		if (newItem != "")
			VoiceChatCombo.AddItem(newItem,,QuickChatNames[i]);
		else
			VoiceChatCombo.AddItem(QuickChatNames[i],,QuickChatNames[i]);
	}

	// Setup response delegates
	OnShow=InternalOnShow;
    OnHide=InternalOnHide;
	NewButton.OnClick=InternalOnClick;
	DeleteButton.OnClick = OnActiveProfileDelete;
	LoadoutButton.OnClick = OnActiveProfileEditLoadouts;
	CreateGamespy.OnClick = OnCreateGamespy;
	LoginGamespy.OnClick = OnLoginGamespy;
	UseGamespy.OnClick = OnClickUseGamespy;
	GenderCombo.OnChange = OnGenderChange;

	// michaelj:  Disable team support until it's fully working
	//CreateTeam.OnClick = OnCreateTeam;
	//LoginTeam.OnClick = OnLoginTeam;
	//UseTeam.OnClick = OnClickUseTeam;
	CreateTeam.SetEnabled(false);
	LoginTeam.SetEnabled(false);
	UseTeam.SetEnabled(false);
}

function InternalOnClick(GUIComponent Sender)
{
	switch( Sender )
	{
		case NewButton:
			Controller.OpenMenu("TribesGui.TribesDefaultTextEntryPopup", "TribesDefaultTextEntryPopup", createProfileText, "NewProfile", 20);
			break;
		case DeleteButton:
			break;
	}	
}

function InternalOnShow()
{
	// store a reference to the playerprofilemanager
	playerProfileManager = TribesGUIController(Controller).profileManager;
	ActiveProfile = playerProfileManager.GetActiveProfile();
	LoadSettings();
}

function InternalOnHide()
{
    SaveSettings();
}

function SaveSettings()
{
	if (ActiveProfile == None)
	{
		log("No profile.");
		return;
	}

	ActiveProfile.voiceSet = VoiceChatCombo.GetExtra();
	ActiveProfile.bIsFemale = GenderCombo.GetText() == femaleText;

	ActiveProfile.bUseStatTracking = UseGamespy.bChecked;
	ActiveProfile.bSaveStatTrackingPassword = SaveGamespyPassword.bChecked;

	ActiveProfile.bUseTeamAffiliation = UseTeam.bChecked;
	ActiveProfile.bSaveTeamPassword = SaveTeamPassword.bChecked;

	playerProfileManager.Store();
}

function LoadSettings()
{
	local int i;
	local PlayerProfile tempProfile;

	// modify controls based on profile read-only status
	DeleteButton.SetEnabled(!ActiveProfile.bReadOnly);
	GenderCombo.SetEnabled(!ActiveProfile.bReadOnly);
	VoiceChatCombo.SetEnabled(!ActiveProfile.bReadOnly);

	UseGamespy.bChecked = ActiveProfile.bUseStatTracking;
	SaveGamespyPassword.bChecked = ActiveProfile.bSaveStatTrackingPassword;

	UseTeam.bChecked = ActiveProfile.bUseTeamAffiliation;
	SaveTeamPassword.bChecked = ActiveProfile.bSaveTeamPassword;

	// MJ:  statTrackingNick should be automatically set by profile nick instead
	//if (ActiveProfile.statTrackingNick == "")
	//	GamespyNickLabel.Caption = NotSetText;
	//else
	//	GamespyNickLabel.Caption = ActiveProfile.statTrackingNick;

	// No need to display password
	//if (!ActiveProfile.bSaveStatTrackingPassword || ActiveProfile.statTrackingPassword == "")
	//	GamespyPasswordLabel.Caption = NotStoredText;
	//else
	//	GamespyPasswordLabel.Caption = StoredText;

	if (ActiveProfile.statTrackingEmail == "")
		GamespyEmailLabel.Caption = NotSetText;
	else
		GamespyEmailLabel.Caption = ActiveProfile.statTrackingEmail;

	if (ActiveProfile.affiliatedTeamTag == "")
		TeamLoginLabel.Caption = NotSetText;
	else
		TeamLoginLabel.Caption = ActiveProfile.affiliatedTeamTag;

	if (ActiveProfile.affiliatedTeamName == "")
		TeamNameLabel.Caption = NotSetText;
	else
		TeamNameLabel.Caption = ActiveProfile.affiliatedTeamName;

	// load profile data into controls
	ProfileBox.OnChange = None;
	ProfileBox.Clear();
	for(i = 0; i < playerProfileManager.NumProfiles(); i++)
	{
		tempProfile = playerProfileManager.GetProfile(i);
		ProfileBox.AddItem(tempProfile.PlayerName, tempProfile);
	}
	ProfileBox.SetText(ActiveProfile.playerName);
	ProfileBox.OnChange = OnActiveProfileChange;

	PlayerNameDataLabel.Caption = ActiveProfile.playerName;

	VoiceChatCombo.OnChange = None;
	VoiceChatCombo.SetFromExtra(ActiveProfile.voiceSet);
	if (VoiceChatCombo.GetText() == "")
		VoiceChatCombo.SetText(VoiceChatCombo.GetItem(0));
	VoiceChatCombo.OnChange = OnVoiceChatComboChange;

	if(ActiveProfile.bIsFemale)
		GenderCombo.SetText(femaleText);
	else
		GenderCombo.SetText(maleText);

	Refresh();
}

function Refresh()
{
	SaveTeamPassword.SetEnabled(UseTeam.bChecked);
	SaveTeamPasswordTitle.SetEnabled(UseTeam.bChecked);
	CreateTeam.SetEnabled(UseTeam.bChecked);
	TeamLoginLabel.SetEnabled(UseTeam.bChecked);
	TeamNameLabel.SetEnabled(UseTeam.bChecked);
	TeamLoginTitleLabel.SetEnabled(UseTeam.bChecked);
	TeamNameTitleLabel.SetEnabled(UseTeam.bChecked);
	LoginTeam.SetEnabled(UseTeam.bChecked);

	SaveGamespyPassword.SetEnabled(UseGamespy.bChecked);
	SaveGamespyPasswordTitle.SetEnabled(UseGamespy.bChecked);
	CreateGamespy.SetEnabled(UseGamespy.bChecked);
	GamespyEmailLabel.SetEnabled(UseGamespy.bChecked);
	GamespyEmailTitleLabel.SetEnabled(UseGamespy.bChecked);
	LoginGamespy.SetEnabled(UseGamespy.bChecked);
}

function OnActiveProfileDelete(GUIComponent component)
{
	local PlayerProfile profileToDelete;
	local int indexToDelete;

	if(playerProfileManager.NumProfiles() <= 1)
		return;

	profileToDelete = PlayerProfile(ProfileBox.GetObject());
	indexToDelete = ProfileBox.GetIndex();

	// delete the profile
	playerProfileManager.DeleteProfile(profileToDelete);
	ProfileBox.RemoveItem(indexToDelete, 1);

	// move the active Index
	if(ProfileBox.GetIndex() > 0)
		ProfileBox.SetIndex(ProfileBox.GetIndex() - 1);
	else
		ProfileBox.SetIndex(ProfileBox.GetIndex() + 1);
}

//
// called when the user selects a new active profile
function OnActiveProfileChange(GUIComponent box)
{
	local String newPlayerName;

	newPlayerName = ProfileBox.GetText();

	if(playerProfileManager.HasProfile(newPlayerName))
	{
		// save the old profile first
		SaveSettings();
		ActiveProfile = PlayerProfile(ProfileBox.GetObject());
		playerProfileManager.SetActiveProfile(ActiveProfile);
		LoadSettings();
	}
	else
	{
		log("Warning: User tried to select a profile which did NOT exist!!");
	}
}

function OnActiveProfileEditLoadouts(GUIComponent Sender)
{
	// the fun begins...
	local TribesInventorySelectionMenu InvMenu;
	local String TeamClassName, InvAccessClassName;
	local Class<TeamInfo> TeamClass;
	local Class<InventoryStationAccess> InvAccessClass;

	TeamClassName = "GameClasses.TeamInfoImperial";
	InvAccessClassName = "BaseObjectClasses.InventoryStationAccessDefault";

	InvMenu	= TribesInventorySelectionMenu(Controller.CreateMenu(class'PlayerCharacterController'.default.inventoryStationMenuClass));
	InvMenu.bNotInGame = true;
	TeamClass = Class<TeamInfo>(DynamicLoadObject(TeamClassName, class'Class'));
	InvMenu.playerTeam = PlayerOwner().spawn(teamClass);
	InvAccessClass = Class<InventoryStationAccess>(DynamicLoadObject(InvAccessClassName, class'Class'));
	InvMenu.inventory = PlayerOwner().spawn(InvAccessClass);
	InvMenu.inventory.clientSetupInventoryStation(None);
	InvMenu.bIsFemale = ActiveProfile.bIsFemale;

	Controller.InternalOpenMenu(InvMenu);
}

function OnGenderChange(GUIComponent Sender)
{
	SaveSettings();
}

function OnVoiceChatComboChange(GUIComponent Sender)
{
	local int ChatNumber;
	local String ChatNumberString;

	if(VoiceChatCombo.GetExtra() != "")
	{
		ChatNumber = Clamp(Rand(MaxQCPool), 1, MaxQCPool);
		if(ChatNumber < 10)
			ChatNumberString = "0";
		ChatNumberString $= ChatNumber;
		PlayerOwner().PlayStream("..\\System\\Localisation\\Speech\\"
								$ VoiceChatCombo.GetExtra() $ "\\"
								$ VoiceChatPreviewType[Rand(VoiceChatPreviewType.Length)]
								$ ChatNumberString $ ".ogg");
	}

	SaveSettings();
}

function CreateProfile( string playerName )
{
	local PlayerProfile newProfile;

	if(playerName == "")
		return;

	// We should check first for the existing name:
	if(playerProfileManager.HasProfile(playerName))
	{
		// had it already, select it in the box
		ProfileBox.SetText(playerName);
	}
	else
	{
		newProfile = playerProfileManager.NewActiveProfile(playerName, "Default");
		if(newProfile != None)
		{
			ProfileBox.AddItem(playerName, newProfile);
			ProfileBox.SetText(playerName);

			SaveSettings();
		}
		else
			log("Warning: Could not create a new profile");
	}

	LoadSettings();
}

function OnCreateGamespy(GUIComponent Who)
{
	SaveSettings();
	Controller.OpenMenu("TribesGUI.TribesGamespyCreate");
}

function OnLoginGamespy(GUIComponent Who)
{
	SaveSettings();
	Controller.OpenMenu("TribesGUI.TribesGamespyLogin");
}

function OnClickUseGamespy(GUIComponent Who)
{
	Refresh();
}

function OnCreateTeam(GUIComponent Who)
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (p.statTrackingNick != "" && p.statTrackingEmail != "")
	{
		SaveSettings();
		Controller.OpenMenu("TribesGUI.TribesGamespyTeamCreate");
	}
	else
	{
		Log("Must have a GameSpy nick and email address");
		Log("Current nick = '" $ p.statTrackingNick $ "'");
		Log("Current email address = '" $ p.statTrackingEmail $ "'");
		GUIPage(MenuOwner.MenuOwner).OpenDlg(needGameSpyLoginString, QBTN_Ok);
	}
}

function OnLoginTeam(GUIComponent Who)
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (p.statTrackingID != 0)
	{
		SaveSettings();
		Controller.OpenMenu("TribesGUI.TribesGamespyTeamLogin");
	}
	else
	{
		Log("Must have a GameSpy profile id");
		GUIPage(MenuOwner.MenuOwner).OpenDlg(needGameSpyLoginString, QBTN_Ok);
	}
}

function OnClickUseTeam(GUIComponent Who)
{
	Refresh();
}

defaultproperties
{
	femaleText="FEMALE"
	maleText="MALE"
	StoredText="STORED"
	NotStoredText="NOT STORED"
	NotSetText="NOT SET"

	VoiceChatPreviewType(0)=DYN_QKC_QCTAUNT_
	VoiceChatPreviewType(1)=DYN_QKC_QCEXCLAIM_
	VoiceChatPreviewType(2)=DYN_QKC_QCINTENTIONS_
	VoiceChatPreviewType(3)=DYN_QKC_QCALERTS_
	VoiceChatPreviewType(4)=DYN_QKC_QCCOORD_
	MaxQCPool=14
	needGameSpyLoginString="You need to create a GameSpy login first."
	createProfileText="Enter the name of your new profile"
}
