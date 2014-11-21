// ====================================================================
//  Class:  TribesGui.TribesOptionsMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesOptionsMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    MainMenuButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DoneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUITabControl		MyTabControl "A component of this page which has its behavior defined in the code for this page's class.";

var string menuCallerName;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    DoneButton.OnClick=InternalOnClick;
	MainMenuButton.OnClick=InternalOnClick;
	Log("Options menu initialized");

	bEscapeable = true;
}

event HandleParameters( string Param1, string Param2, optional int param3)
{
	menuCallerName = Param1;

	if (menuCallerName == "TribesMainMenu")
	{
		DoneButton.bCanBeShown = false;
		DoneButton.Hide();
		MainMenuButton.bCanBeShown = true;
		MainMenuButton.Show();
		PageOpenedAfterEscape = class'GameEngine'.default.MainMenuClass;
	}
	else
	{
		MainMenuButton.bCanBeShown = false;
		MainMenuButton.Hide();
		DoneButton.bCanBeShown = true;
		DoneButton.Show();
		PageOpenedAfterEscape = "";
	}
}

function InternalOnClick(GUIComponent Sender)
{
	TribesSettingsPanel(MyTabControl.ActiveTab.TabPanel).OnOptionsEnding();
}

function EndOptions()
{
	if (MainMenuButton.bCanBeShown)
	{
        Controller.CloseMenu(); 
		Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
	}
	else
	{
		// Just close it.  Don't open the caller.
        Controller.CloseMenu();
	}
}

defaultproperties
{
}
