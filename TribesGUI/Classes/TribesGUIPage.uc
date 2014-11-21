class TribesGUIPage extends GUI.GUIPage
	native;

var(DynamicConfig) EditInline EditConst protected   TribesGUIConfig   GC "Config class for the GUI";

// Allow pressing of escape to close some pages
// Don't expose this since EscapePages tend to be set dynamically
var bool bEscapeable								"If true, pressing escape will close this menu.";
var string PageOpenedAfterEscape					"If set, pressing escape will also open this menu.";
var bool bSuppressLevelRender						"If set, when this page is the active page it will suppress rendering the level behind it";

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

function InitComponent(GUIComponent MyOwner)
{
	GC = TribesGUIController(Controller).GuiConfig;
	Super.InitComponent(MyOwner);
    OnKeyEvent=InternalOnKeyEvent;
}

function OnPreLevelChange(String DestURL, LevelSummary NewSummary);

function DisplayMainMenu()
{
    Controller.CloseAll();
    Controller.OpenMenu( class'GameEngine'.default.MainMenuClass );
}

function Quit()
{
    //may need to add saving info routines here
	TribesGUIController(Controller).Quit(); 
}

function GameStart()
{
    //start of game hook
	TribesGUIController(Controller).GameStart(); 
}

function GameAbort()
{
    //end of game hook -- should signal GameEvent OnMissionFailed here ... TODO!
	//TribesGUIController(Controller).Repo.OnMissionEnded();
}

function GameRestart()
{
    //end of game hook
	//TribesGUIController(Controller).Repo.OnMissionEnded();
	TribesGUIController(Controller).GameStart(); 
}

function GameResume()
{
    //resume game hook
    TribesGUIController(Controller).GameResume();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bEscapeable && bVisible && bActiveInput &&
        Key == EInputKey.IK_Escape && State == EInputAction.IST_Press )	
	{
        Controller.CloseMenu();
		if (PageOpenedAfterEscape != "")
			Controller.OpenMenu(PageOpenedAfterEscape);
        return true;
    }
    return false;
}

defaultproperties
{
	WinTop=0
	WinLeft=0
	WinWidth=1
	WinHeight=1
	bAcceptsInput=true
	bPersistent=true
	DialogClassName="TribesGui.TribesGUIDlg"

	bSuppressLevelRender=false
}