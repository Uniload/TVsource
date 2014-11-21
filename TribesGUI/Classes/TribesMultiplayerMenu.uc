// ====================================================================
//  Class:  TribesGui.TribesMultiplayerMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMultiplayerMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    MainMenuButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    QuitButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui)			EditInline Config GUITabControl		MyTabControl "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPProfilePanel		MPProfilePanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPQuickPlayPanel		MPQuickPlayPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPHostPanel			MPHostPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui)			EditInline Config TribesMPGameGuidePanel		MPGameGuidePanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPCommunityPanel		MPCommunityPanel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config TribesMPRecordingsPanel		MPRecordingsPanel "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIButton GamespyJoin "A component of this page which has its behavior defined in the code for this page's class.";

var string					GamespyURL;


function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OnShow=InternalOnShow;

	MainMenuButton.OnClick=InternalOnClick;
	QuitButton.OnClick=InternalOnClick;
	GamespyJoin.OnClick = OnGamespyJoin;

	bEscapeable = true;
	PageOpenedAfterEscape = class'GameEngine'.default.MainMenuClass;
}

function InternalOnShow()
{
	SetGamespyMode(false, "");
}

function InternalOnClick(GUIComponent Sender)
{
	switch (Sender)
	{
		case MainMenuButton:
            Controller.CloseMenu(); 
			Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
            break;
		case QuitButton:
			Quit();
			break;
	}
}

function InternalOnPopupReturned( GUIListElem retVal, String passback )
{
	Log("PROFILE passback "$passback);
    switch (passback)
    {
        case "NewProfile":
            MPProfilePanel.CreateProfile(retVal.item);
            break;
		case "Password":
			MPGameGuidePanel.joinPassword = retVal.item;
			MPGameGuidePanel.connectToSelectedServer();
			break;
    }
}

// "Gamespy" mode is used when the player connects using gamespy arcade. The player needs to be able to select their profile and then join
// the game.
function SetGamespyMode(bool bOn, string URL)
{
	GamespyURL = URL;

	MyTabControl.SetTabEnabled(MPQuickPlayPanel, !bOn);
	MyTabControl.SetTabEnabled(MPHostPanel, !bOn);
	MyTabControl.SetTabEnabled(MPGameGuidePanel, !bOn);
	MyTabControl.SetTabEnabled(MPCommunityPanel, !bOn);

	if (bOn)
	{
		GamespyJoin.bCanBeShown = true;
		GamespyJoin.Show();
	}
	else
	{
		GamespyJoin.bCanBeShown = false;
		GamespyJoin.Hide();
	}
}

function OnGamespyJoin(GUIComponent Sender)
{
	JoinGamespy();
}

function JoinGamespy()
{
	if (GamespyURL != "")
	{
		MyTabControl.SetTabEnabled(MPGameGuidePanel, true);
		MyTabControl.OpenTab(MPGameGuidePanel);
		MPGameGuidePanel.AttemptURL(GamespyURL);
	}
}

defaultproperties
{
	OnPopupReturned=InternalOnPopupReturned
}
