// ====================================================================
//  Class:  TribesGui.TribesMainMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMainMenu extends TribesGUIPage
     native;

var(TribesGui) private EditInline Config GUIButton		    NewGameButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    LoadGameButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    MultiplayerButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    OptionsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CreditsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    QuitButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DebugLoadMapButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ContinueButton "A component of this page which has its behavior defined in the code for this page's class.";


var(TribesGui) private EditInline Config GUILabel			VersionLabel;

var bool bActivated;

native function string GetVersionString();

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    NewGameButton.OnClick=InternalOnClick;
    LoadGameButton.OnClick=InternalOnClick;
    MultiplayerButton.OnClick=InternalOnClick;
    OptionsButton.OnClick=InternalOnClick;
    QuitButton.OnClick=InternalOnClick;
    DebugLoadMapButton.OnClick=InternalOnClick;
    ContinueButton.OnClick=InternalOnClick;
	CreditsButton.OnClick=InternalOnClick;
    OnActivate=InternalOnActivate;
	OnShow=InternalOnShow;

	VersionLabel.Caption=GetVersionString();
}

function InternalOnActivate()
{
	GC.CurrentCampaign = None;
	if (GC.EntryMenuClass != "" && !GC.bShownEntryMenu)
	{
		Controller.OpenMenu(GC.EntryMenuClass);
		GC.bShownEntryMenu = true;
	}
}

function InternalOnShow()
{
	if (GetRecentSave() == "")
	{
		ContinueButton.bCanBeShown = false;
		ContinueButton.Hide();
	}
	else
	{
		ContinueButton.bCanBeShown = true;
		ContinueButton.Show();
	}

	// MJ TEMPORARY:  Disable and hide credits button because credits currently crash
	//CreditsButton.SetEnabled(false);
	//CreditsButton.bCanBeShown = false;
	//CreditsButton.Hide();

	// Prevent queued mouse clicks from being processed (the game was quitting if
	// you kept clicking during the initial slideshow because the queued clicks registered
	// as Quit button clicks)
	SetTimer(0.5, false);
}

function Timer()
{
	bActivated = true;
}

function InternalOnClick(GUIComponent Sender)
{
	if (!bActivated)
	{
		return;
	}

	switch (Sender)
	{
		case NewGameButton:	
			Controller.CloseMenu();
			Controller.OpenMenu("TribesGui.TribesDifficultyMenu", "TribesDifficultyMenu");
			break;
		case LoadGameButton:	
			Controller.CloseMenu();
			Controller.OpenMenu("TribesGui.TribesLoadGameMenu", "TribesLoadGameMenu");
			break;
		case MultiplayerButton:
			Controller.CloseMenu();
			Controller.OpenMenu("TribesGui.TribesMultiplayerMenu", "TribesMultiplayerMenu");
			break;
		case OptionsButton:
			Controller.CloseMenu();
			Controller.OpenMenu("TribesGUI.TribesOptionsMenu", "TribesOptionsMenu", "TribesMainMenu");
			break;
		case QuitButton:
			Quit();
			break;
		case DebugLoadMapButton:
			Controller.CloseMenu();
			Controller.OpenMenu("TribesGUI.TribesDebugLoadMapMenu");
			break;
		case ContinueButton:
			log(GetRecentSave());
			PlayerOwner().ConsoleCommand("LoadGame"@GetRecentSave());
			break;
		case CreditsButton:
			Controller.OpenMenu("TribesGUI.TribesCreditsMenu", "TribesCreditsMenu");
			break;
	}
}

native function string GetRecentSave();

defaultproperties
{
}