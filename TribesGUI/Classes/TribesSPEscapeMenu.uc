// ====================================================================
//  Class:  TribesGui.TribesSPEscapeMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesSPEscapeMenu extends TribesGUIPage
     ;

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

var(TribesGui) private EditInline Config GUIButton		    RestartButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    LoadButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    SaveButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    OptionsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    QuitButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ReturnButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ExitGameButton "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config localized string   SaveConfirmText;
var(TribesGui) private EditInline Config localized string   ExitConfirmText;
var(TribesGui) private EditInline Config localized string   EndGameConfirmText;

var bool bHasSaved;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    RestartButton.OnClick=OnRestartClick;
    LoadButton.OnClick=OnLoadClick;
	SaveButton.OnClick=OnSaveClick;
	OptionsButton.OnClick=OnOptionsClick;
	QuitButton.OnClick=OnQuitClick;
	ReturnButton.OnClick=OnReturnClick;
	ExitGameButton.OnClick=OnExitGameClick;

	OnShow=InternalOnShow;
	OnActivate=InternalOnActivate;
	OnDlgReturned=InternalOnDlgReturned;
}

function PauseGame(bool bPause)
{
	if (bPause && PlayerOwner().Level.Pauser == None)
	{
		// Pause
		PlayerOwner().ConsoleCommand( "PAUSE" );
	}
	else if (!bPause && PlayerOwner().Level.Pauser != None)
	{
		// Unpause
		PlayerOwner().ConsoleCommand( "PAUSE" );
	}

}

function InternalOnShow()
{
	// Pause the game
	PauseGame(true);
	bHasSaved = false;
}

function InternalOnActivate()
{
	if (SingleplayerGameInfo(PlayerOwner().Level.Game).ReturnToGameAllowed())
		ReturnButton.EnableComponent();
	else
		ReturnButton.DisableComponent();

	if (PlayerOwner().Level.Game.SaveAllowed())
		SaveButton.EnableComponent();
	else
		SaveButton.DisableComponent();
}

function OnRestartClick(GUIComponent Sender)
{
	// Restart game here
	PlayerOwner().ConsoleCommand( "OPEN ?RESTART" );
}

function OnLoadClick(GUIComponent Sender)
{
	// Load game here
	Controller.OpenMenu("TribesGui.TribesLoadGameMenu", "TribesLoadGameMenu", "TribesSPEscapeMenu");
}

function OnSaveClick(GUIComponent Sender)
{
	// Save game here
	Controller.OpenMenu("TribesGui.TribesSaveGameMenu", "TribesSaveGameMenu", "TribesSPEscapeMenu");
}

function OnSaved()
{
	bHasSaved = true;
}

function InternalOnDlgReturned( int Selection, optional string Passback )
{
	if (passback == "confirmexit")
	{
		if ( Selection == QBTN_Yes )
		{
			DoExitGame();
		}
	}
	else if (passback == "confirmendgame")
	{
		if ( Selection == QBTN_Yes )
		{
			DoQuitToMainMenu();
		}
	}
	else
	{
		if ( Selection == QBTN_Yes )
		{
			Controller.OpenMenu("TribesGui.TribesSaveGameMenu", "TribesSaveGameMenu", "TribesSPEScapeMenu");
			TribesSaveGameMenu(Controller.ActivePage).OnUserSaved = OnSaved;
		}
		else if ( Selection == QBTN_No )
		{
			if (passback == "exit")
			{
				DoExitGame();
			}
			else if (passback == "endgame")
			{
				DoQuitToMainMenu();
			}
		}
	}
}

function OnOptionsClick(GUIComponent Sender)
{
	Controller.OpenMenu("TribesGui.TribesOptionsMenu", "TribesOptionsMenu", "TribesSPEscapeMenu");
}

function OnQuitClick(GUIComponent Sender)
{
	if (!bHasSaved && PlayerOwner().Level.Game.SaveAllowed())
		OpenDlg(SaveConfirmText, QBTN_YesNoCancel, "endgame");
	else
	{
		if (PlayerOwner().Pawn == None || PlayerOwner().Pawn.Health <= 0)
			OpenDlg(EndGameConfirmText, QBTN_YesNo, "confirmendgame");
		else
			DoQuitToMainMenu();
	}
}

function DoExitGame()
{
	Quit();
}

function DoQuitToMainMenu()
{
	// Unpause
	PauseGame(false);
	TribesGuiController(Controller).PlayerDisconnect(); 
	Controller.CloseMenu();
	Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
}

function OnReturnClick(GUIComponent Sender)
{
	// Unpause
	PauseGame(false);
	Controller.CloseAll();
}

function OnExitGameClick(GUIComponent Sender)
{
	if (!bHasSaved && PlayerOwner().Level.Game.SaveAllowed())
	{
		OpenDlg(SaveConfirmText, QBTN_YesNoCancel, "exit");
	}
	else
	{
		if (PlayerOwner().Pawn == None || PlayerOwner().Pawn.Health <= 0)
			OpenDlg(ExitConfirmText, QBTN_YesNo, "confirmexit");
		else
			DoExitGame();
	}
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bVisible && bActiveInput &&
        Key == EInputKey.IK_Escape && State == EInputAction.IST_Press && PlayerOwner().Level.Game.SaveAllowed() )
    {
		// Unpause
		PauseGame(false);
        Controller.CloseAll();
        return true;
    }
    return false;
}

defaultproperties
{
    OnKeyEvent=InternalOnKeyEvent;
	SaveConfirmText="Do you wish to save the game before exiting?"
	ExitConfirmText="Are you sure you wish to exit? Unsaved progress will be lost."
	EndGameConfirmText="Are you sure you wish to end the current game? Unsaved progress will be lost."
}
