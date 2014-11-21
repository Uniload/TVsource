// ====================================================================
//  Class:  Engine.BaseGUIController
//
//  This is just a stub class that should be subclassed to support menus.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class BaseGUIController extends Interaction
		Native;
		
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var	Material	DefaultPens[3]; 	// Contain to hold some default pens for drawing purposes 					
var	bool		bIsConsole;			// If True, we are running on a console

// If this is true, then GUIPages will NOT receive
// PreDraw()/Draw()/ClientDraw() calls. This allows you to disable rendering
// of the GUI while keeping correct GUI state. It is intended to be used by
// CheatManagers, for example to hide all GUI pages so that screenshots can be
// taken. 
// 
// It's called bHackDoNotRenderGUIPages so that people don't use it as a
// fundamental part of GUI state management.
var bool bHackDoNotRenderGUIPages;

// Delegates
Delegate OnAdminReply(string Reply);	// Called By PlayerController

#if IG_GUI_LAYOUT //dkaplan- Notification of Level Changes
#if IG_TRIBES3 // dbeswick: needed reference to the level
event PreLevelChange(string DestURL, LevelSummary NewSummary);
event PostLevelChange(LevelInfo newLevel, bool bSaveGame);
event PostPrecache()
{
	OnPostPrecache();
}

Delegate OnPostPrecache();
// Paul: handle suppression of level rendering
event bool ShouldSuppressLevelRender()
{
	return false;
}
#else
event PreLevelChange();
event PostLevelChange();
#endif
#endif

// ================================================
// OpenMenu - Opens a new menu and places it on top of the stack

#if IG_GUI_LAYOUT //dkaplan-extra optional param for passing ints (used by gui dialogues)
event bool OpenMenu(string NewMenuName, optional string MenuNameOverride, optional string Param1, optional string Param2, optional int param3 )
#else
event bool OpenMenu(string NewMenuName, optional string Param1, optional string Param2)
#endif
{
	return false;
}

// ================================================
// Create a bunch of menus at start up

event AutoLoadMenus();	// Subclass me

#if IG_TRIBES3 // Alex:
event AutoLoadMenuClass(class<Object> menuClass);
#endif

// ================================================
// Replaces a menu in the stack.  returns true if success

#if IG_GUI_LAYOUT //dkaplan-extra optional param for passing ints (used by gui dialogues)
event bool ReplaceMenu(string NewMenuName, optional string MenuNameOverride, optional string Param1, optional string Param2, optional int param3 )
#else
event bool ReplaceMenu(string NewMenuName, optional string Param1, optional string Param2)
#endif
{
	return false;
}

#if IG_GUI_LAYOUT //dkaplan-removed annoying unused param
event bool CloseMenu()	// Close the top menu.  returns true if success.
#else
event bool CloseMenu(optional bool bCanceled)	// Close the top menu.  returns true if success.
#endif
{
	return true;
}
#if IG_GUI_LAYOUT //dkaplan-removed annoying unused param
event CloseAll();
#else
event CloseAll(bool bCancel);
#endif

#if IG_SHARED // dbeswick: added remove of menu by name
function RemoveMenu(string MenuName);
#endif

function SetControllerStatus(bool On)
{
	bActive = On;
	bVisible = On;
	bRequiresTick=On;

	// Add code to pause/unpause/hide/etc the game here.

}

event InitializeController();	// Should be subclassed.

#if !IG_GUI_LAYOUT //dkaplan- big bad hacks do nothing... bye bye
event bool NeedsMenuResolution(); // Big Hack that should be subclassed
event SetRequiredGameResolution(string GameRes);
#endif

#if IG_TRIBES3	// michaelj:  Added ability to inform GUIPages of gameplay messages
// Needed this in the base class in Engine because the message needs to be generated
// by Engine's PlayerController (Gameplay's PlayerCharacterController doesn't appear
// to get instantiated in Entry)


function onGameplayMessage(Message msg)
{
}
#endif

#if IG_MOJO // david: added event called when a mojo cutscene finished
event OnMojoFinished();
#endif

#if IG_TRIBES3 // dbeswick: all download notification is done through the GUI system
////////////////////////////////////////////////////////////////////////////////
// Network
////////////////////////////////////////////////////////////////////////////////
event OnProgress(string Str1, string Str2)
{
}
#endif

#if IG_TRIBES3 // dbeswick: make sure network URLs go through the join screen for gamespy compatibility
// return false to abort the browse
event bool OnNetworkBrowse(string URL, string ProfileOption, bool bSelectProfile)
{
	return true;
}
#endif

#if IG_TRIBES3 // dbeswick:
event bool IsPageActive(string MenuClass)
{
	return false;
}
#endif

cpptext
{
		virtual void InitializeController();

}


defaultproperties
{
     DefaultPens(0)=Texture'Engine_res.MenuWhite'
     DefaultPens(1)=Texture'Engine_res.MenuBlack'
     DefaultPens(2)=Texture'Engine_res.MenuGray'
     bActive=False
     bNativeEvents=True
}
