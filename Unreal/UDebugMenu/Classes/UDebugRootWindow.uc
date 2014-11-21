// ====================================================================
//  Class:  UDebugMenu.UDebugRootWindow
//  Parent: UWindow.UWindowRootWindow
//
//  <Enter a description here>
// ====================================================================

class UDebugRootWindow extends UWindow.UWindowRootWindow;

var class<UWindow.UWindowMenuBar> MenuBarClass;				
var UDebugMenuBar		 MenuBar;					  

function Created() 
{
	Super.Created();

	MenuBar = UDebugMenuBar(CreateWindow(class'UDebugMenuBar', 50, 0, 500, 16));
	MenuBar.HideWindow();

	Resized();
}


function Resized()
{
	Super.Resized();
	
	MenuBar.WinLeft = 0;;
	MenuBar.WinTop = 0;
	MenuBar.WinWidth = WinWidth;;
	MenuBar.WinHeight = 16;
}

function DoQuitGame()
{
	MenuBar.SaveConfig();
	if ( Root.GetLevel().Game != None )
	{
		Root.GetLevel().Game.SaveConfig();
		Root.GetLevel().Game.GameReplicationInfo.SaveConfig();
	}
	Super.DoQuitGame();
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if ( (Action == IST_Press) && (Key == 
#if IG_TRIBES3	// michaelj:  Use Pause key instead (to free up escape key)
		IK_Pause
#else
		IK_Escape
#endif
		) )
	{
#if IG_TRIBES3	// dbeswick:
		if (!class'Console'.default.bAllowed)
			return Super.KeyEvent(Key,Action,Delta);
#endif
		bAllowConsole = false;
		GotoState('UWindows');
		return true;
	}
	 
	return Super.KeyEvent(Key,Action,Delta);
}

state UWindows
{
	function BeginState()
	{
		if (!bAllowConsole)
			MenuBar.ShowWindow();
			
		Super.BeginState();
		
	}
	
	function EndState()
	{
		MenuBar.HideWindow();
		Super.EndState();			
	}

}	


defaultproperties
{
	LookAndFeelClass="UDebugMenu.UDebugBlueLookAndFeel"
}
