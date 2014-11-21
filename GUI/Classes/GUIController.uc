// ====================================================================
//  Class:  Engine.GUIController
//
//  The GUIController is a simple FILO menu stack.  You have 3 things
//  you can do.  You can Open a menu which adds the menu to the top of the
//  stack.  You can Replace a menu which replaces the current menu with the
//  new menu.  And you can close a menu, which returns you to the last menu
//  on the stack.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUIController extends Engine.BaseGUIController
        Config(GuiBase)
        HideCategories(Menu,Object)
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum eComponentAlign
{
    cALIGN_Left,
    cALIGN_Right,
    cALIGN_Top,
    cALIGN_Bottom,
};

enum eComponentSize
{
    cSIZE_Width,
    cSIZE_Height,
};

struct sMoveGroup
{
    var() Editinline EditConst array<GUIComponent> CtrlGroup "Group of controls that can be moved/sized together";
};

var(MiscState) config                      bool                    bDontDisplayHelpText "If true, help text will never be displayed for this page";

var(EditorState) EditInline EditConst array<sMoveGroup> MoveGroups "Array of groups of controls";

var(Grid) config int                 GridSize "Size of grid";
var(Grid) config bool                bSnapToGrid "If set will snap to grid in edit mode";
var(Grid) EditConst config int                 ResolutionX "Screen width in pixels.  Set using console command \"SetGuiRes X Y\"";
var(Grid) EditConst config int                 ResolutionY "Screen height in pixels.  Set using console command \"SetGuiRes X Y\"";
var(EditorState) EditConst	 bool                bMousePositioning "the mouse is being used to position a component";
var(ActorAdjustments) config      float           GUI_TO_WORLD_X "minor adjustment to all actors in the X direction";
var(ActorAdjustments) config      float           GUI_TO_WORLD_Y "minor adjustment to all actors in the Y direction";
var(EditorState) EditConst bool                        bLastScaled "used for pagewide scale toggling";

var(GUIController) config array<string> PackageNames "FileNames of packages to autoload when running the gui editor";
var(EditorState) editconst bool bHasLoadedPackages "will only load packages the first time (when this is false)";

//dkaplan - Persistency stack now holds all components set as bPersistent (see GUIMultiComponent for creation of non-GUIPages)
var(GUIPages) Editinline EditConst Array<GUIComponent>	PersistentStack "Holds the set of Components which are persistent across close/open/reopen; only instanciated once";
var(EditorState) EditConst	Editinline export	array<GUIPage>		MenuStack "Holds the stack of menus";
var(EditorState) EditConst	Editinline	GUIPage				ActivePage "Points to the currently active page";
var(GUIController) editinline config     			Array<String>		FontNames "Holds all the possible font names";
var(EditorState) EditConst	Editinline  Array<GUIFont>		FontStack "Holds all the possible fonts";
var(EditorState) EditConst	Editinline  Array<GUIStyles>	StyleStack "Holds all of the possible styles";
var(GUIController) editinline config 				Array<string>		StyleNames "Holds the name of all styles to use";
var(Cursors) editinline config              Array<Material>		MouseCursors "Holds a list of all possible mouse";
var(Cursors) editinline config              Array<vector>		MouseCursorOffset "Only X,Y used, between 0 and 1. 'Hot Spot' of cursor material.";

var(MiscState) Editconst byte				ControllerMask "Used to mask input for various Controllers";
var(MiscState) Editconst byte				ControllerId "The current Controller ID #";
var(MiscState) Editconst float				MouseX,MouseY "Where is the mouse currently located";
var(MiscState) Editconst float				LastMouseX, LastMouseY;

var(MiscState) Editconst bool				ShiftPressed "Shift key is being held";
var(MiscState) Editconst bool				AltPressed "Alt key is being held";
var(MiscState) Editconst bool				CtrlPressed "Ctrl key is being held";

var(MiscState) Config float				    DblClickWindow "How long do you have for a double click";
var(MiscState) Editconst float				LastClickTime "When did the last click occur";
var(MiscState) Editconst int				LastClickX,LastClickY "Who was the active component";

var(MiscState) Editconst float				ButtonRepeatDelay "The amount of delay for faking button repeats";
var(MiscState) Editconst byte				RepeatKey[4] "Used to determine what should repeat";
var(MiscState) Editconst float				RepeatDelta[4] "Data var";
var(MiscState) Editconst float				RepeatTime[4] "How long until the next repeat;";

var(MiscState) Editconst float				CursorFade "How visible is the cursor";
var(MiscState) Editconst int				CursorStep "Are we fading in or out";
var(MiscState) Editconst float				FastCursorFade "How visible is the cursor";
var(MiscState) Editconst int				FastCursorStep "Are we fading in or out";

var(MiscState) Editconst GUIComponent		FocusedControl "Top most Focused control";
var(MiscState) Editconst GUIComponent 		ActiveControl "Which control is currently active";
var(MiscState) Editconst GUIComponent		SkipControl "This control should be skipped over and drawn at the end";
var(MiscState) Editconst GUIComponent		MoveControl "Used for visual design";

#if IG_TRIBES3 // dbeswick: for player design mode
var(MiscState) Editconst float				SavedMoveOffsetX;
var(MiscState) Editconst float				SavedMoveOffsetY;
#endif

var(MiscState) config bool bModAuthor "Allows bDesign Mode";
var(MiscState) Editconst bool bDesignMode "Are we in design mode";
#if IG_TRIBES3 // dbeswick: added a 'player design mode' to be used by players, i.e. to move a hud around
var(MiscState) Editconst bool bPlayerDesignMode; // set in conjunction with bDesignMode
#endif
var(MiscState) Editconst bool bHighlightCurrent "Highlight the current control being edited";

var(EditorState) EditConst	bool				bStyleCreate "Are we creating a new style";
var(EditorState) EditConst	bool				bStylesDisplay "Are we displaying available styles/fonts";
var(EditorState) EditConst	bool				bMemberDisplay "Are we displaying member properties";
var(EditorState) EditConst	bool				bMemberEdit "Are we editing member properties";
var(EditorState) EditConst	bool				bEditing "Are we currently editing a member's properties";
var(EditorState) EditConst	bool				bHelpDisplay "Are we showing the help menu";
var(EditorState) EditConst	bool				bShowConfigMembers "Are we showing the Config members?";
var(EditorState) EditConst	bool				bShowGUIMembers "Are we showing the GUI members?";
var(EditorState) EditConst	bool				bShowPageList "Are we showing the page list?";
var(EditorState) EditConst	bool				bComponentMenu "Are we showing the available components?";

var(Clipboard)  EditConst Editinline GUIComponent SaveControl             "The Clipboard component for storing component's config members";
var(Clipboard)	EditConst Editinline GUIStyles SaveStyle               "The Clipboard style for storing style's config members";
var(EditorState) EditConst	string              CurrentMemberObjName "currently active (for edit) member";
var(EditorState) EditConst	array<string>       CurrentMemberObjValue "current text entry for current member";
var(EditorState) EditConst	int                 CurrentMember "current position in member list";
var(EditorState) EditConst	int                 MemberEditLevel "current position in edit history";
var(EditorState) EditConst	int                 MemberEditPosition "current position in edit string";
var(GUIController) editinline config localized    array<string>       HelpStack "List of GUI editor commands";
var(GUIController) editinline config              array<string>       ComponentClassList "List of available GUI components";

var(Misc) config				float				MenuMouseSens "Mouse Sensitivity in the gui";

// Sounds
var(Sounds) config				sound				MouseOverSound "Sound played when the mouse moves over something";
var(Sounds) config				sound				ClickSound "Sound played when the mouse clicks something";
var(Sounds) config				sound				EditSound "Sound played when a change is made";
var(Sounds) config				sound				UpSound "Sound played on an up-click";
var(Sounds) config				sound				DownSound "Sound played on a down-click";

var(MiscState) Editconst bool bForceMouseCheck "Forces the gui to check the mouse immediately following the open/close of a page to get what is underneath";
var(MiscState) Editconst bool bSwallowNextKeyType "Forces the gui to drop and swallow the next key type";

var(GUIController) editinline config	array<GUI.ControlSpec>	AutoLoad "Any components specified in here will be automatically loaded on startup, usefull for pages, panels, and other intensively functional components";

var private array<GUIComponent> InterestedResolutionChanged;    //GUIComponents who are interested in receiving notification when resolution changes

// Joystick/JoyPad/Console Specific

var(Misc) config	bool	bEmulatedJoypad "Have the cursor keys emulate a XBox controller";
var(Misc) config	bool	bJoyMouse "When true, right control stick acts as a 1 button mouse";
var(Misc) config  bool	bHideMouseCursor "When true, the mouse cursor will be hidden";
var(Misc) config  float	JoyDeadZone "The DeadZone for joysticks";

var		Float	JoyLeftXAxis[4];
var		Float 	JoyLeftYAxis[4];
var		Float	JoyRightXAxis[4];
var		Float	JoyRightYAxis[4];
var		Byte	JoyButtons[64];

var float JoyControlsDelta[16];	// How long since a joystick was converted

// Temporary for Design Mode
var Material WhiteBorder;

var(DEBUG) private bool CaptureScriptExec "When non-zero, does not allow other interactions to process script exec functions";

native event GUIFont GetMenuFont(string FontName); 	// Finds a given font in the FontStack
native event GUIStyles GetStyle(string StyleName); 	// Find a style on the stack
native function string GetCurrentRes();				// Returns the current res as a string

// Utility functions for the UI

native function GetMapList(string Prefix, GUIList list);

native function ResetKeyboard();
native function MouseEmulation(bool On);

#if IG_TRIBES3	// michaelj:  Integrated demo functions from UT2004
// Used by a demo manager
native function GetDEMList(out array<string> DEMFiles);
native function bool GetDEMHeader(string DemoName, out string MapName, out string GameType,
								  out int ScoreLimit, out int TimeLimit, out int ClientSide,
                                  out string RecordedBy, out string Timestamp, out String ReqPackages);

// michaelj:  Function to retrieve level summary using LOAD_NoVerify
native function LevelSummary LoadLevelSummary(string LevelSummaryName);
#endif

delegate bool OnNeedRawKeyPress(byte NewKey);

////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////

// Initialize the controller
event InitializeController()
{
	local int i;
	
	GetGuiResolution();
	
    FontStack.Remove(0,FontStack.Length);
    StyleStack.Remove(0,StyleStack.Length);
	for (i=0;i<FontNames.Length;i++)
    {
	    if (!RegisterFont(FontNames[i]))
		    log("Could not create requested font"@FontNames[i]);
    }
	for (i=0;i<StyleNames.Length;i++)
	{
	    if (!RegisterStyle(StyleNames[i]))
				log("Could not create requested style"@StyleNames[i]);
	}
	if( bModAuthor )
	{
	    SaveStyle = new( none ) class'GUI.GUIStyles';
        //create the move groups
	    for( i = 0; i < 10; i++ )
	    {
	        MakeMoveGroup();
	    }
	}
	
	bActive = true;

	AutoLoadMenus();
}

// Register a single font
event bool RegisterFont(String FontClass)
{
    local GUIFont NewFont;
    
	NewFont = new(None, FontClass) class'GUI.GUIFont';

	if (NewFont != None)
	{
		NewFont.Controller = self;
		FontStack[FontStack.Length] = NewFont;
		return true;
	}
	return false;
}

// Register a single style
event bool RegisterStyle(String StyleClass)
	{
    local GUIStyles NewStyle;

	NewStyle = new(None, StyleClass) class'GUI.GUIStyles';

		if (NewStyle != None)
		{
			StyleStack[StyleStack.Length] = NewStyle;
		NewStyle.KeyName = StyleClass;
			NewStyle.Controller = self;
			NewStyle.Initialize();
			return true;
		}
	return false;
}

// Set the state of the controller (true == controller is active)
function SetControllerStatus(bool On)
{
	//bActive = On;
	bVisible = On;
	bRequiresTick=On;

	// Attempt to Pause as well as show the windows mouse cursor.
    //	ViewportOwner.Actor.Level.Game.SetPause(On, ViewportOwner.Actor);
	
	//off, unless active page is a non-HUD menu
	ViewportOwner.bShowWindowsMouse=(On && !ActivePage.bIsHUD);
        
	// Add code to pause/unpause/hide/etc the game here.

	if (!On)
		ViewportOwner.Actor.ConsoleCommand("toggleime 0");
}

// Load everything in the AutoLoad stack
event AutoLoadMenus()
{
	local GUIComponent NewMenu;
    local int i;

	log("GUIController: Autoloading Components...");

    super.AutoLoadMenus();

    for (i=0;i<AutoLoad.Length;i++)
	{
    	NewMenu = CreateComponent(AutoLoad[i].ClassName,AutoLoad[i].ObjName);
		if (NewMenu==None)
        	log("  Could not Autoload"@AutoLoad[i].ObjName);
        else
		{
	        if (!NewMenu.bInited)
				NewMenu.InitComponent(None);
            log("AutoLoaded Menu "$AutoLoad[i].ObjName);
		}
	}
}

#if IG_TRIBES3	// michaelj:  Added ability to inform GUIPages of gameplay messages
function onGameplayMessage(Message msg)
{
	local int i;
	local bool bFoundActivePage;

	// Inform all GUIPages
	if( MenuStack.Length <= 0 )
        return;
        
	for (i=0;i<MenuStack.Length-1;i++)
	{
		MenuStack[i].onGameplayMessage(msg);
		if (MenuStack[i] == ActivePage)
			bFoundActivePage = true;
	}

	// Inform the active page too, since it doesn't seem to necessarily be on the stack
	if (!bFoundActivePage)
		ActivePage.onGameplayMessage(msg);
}
#endif

function String FixGUIComponentName( String ComponentName )
{
	if( Len(ComponentName) > 64 )
	    ComponentName = Left(ComponentName,45)$"X"$Right(ComponentName,17); //weird, not failsafe, but this prevents more problems then it would ever potentially create
	return ComponentName;
}

////////////////////////////////////////////////////////////////////////////////
// Component Creation
////////////////////////////////////////////////////////////////////////////////

// ================================================
// CreateComponent - Attempts to Create a component.  Returns none if it can't
event GUIComponent CreateComponent(string ComponentClass,optional string ComponentName)
{
	local class<GUIComponent> NewComponentClass;
	local GUIComponent NewComponent;

    //if one already exists with the current name in the persistent stack, return it
    if(ComponentName == "" )
    {
        //no name passed in so construct a default one, based off of the class name
        ComponentName = Right(ComponentClass,Len(ComponentClass)-InStr(ComponentClass,".")-1);
	}
	
    ComponentName = FixGUIComponentName( ComponentName );

    NewComponent = FindPersistentComponent(ComponentName,true);
    if( NewComponent != None )
	{
		//log("Persistent component found: "$ComponentName);
        return NewComponent;
	}

	NewComponentClass = class<GUIComponent>(DynamicLoadObject(ComponentClass,class'class'));
	if (NewComponentClass != None)
	{

        //ALL GUI COMPONENTS ARE CREATED RIGHT HERE!!!
		NewComponent = new(None, ComponentName ) NewComponentClass(self);

		// Check for errors
		if (NewComponent == None)
		{
			log("Could not create requested component"@ComponentClass);
				return None;
		}
						
		// Save in PersistentStack if it's persistent.
		if( NewComponent.bPersistent )
		{
			PersistentStack[PersistentStack.Length] = NewComponent;
		}
		//assign self as controller - if needed change, will update later on InitComponent
        NewComponent.Controller = self;

    	return NewComponent;
	}
	else
	{
		log("Could not DLO component '"$ComponentClass$"'");
		return none;
	}
}

////////////////////////////////////////////////////////////////////////////////
// Component Creation support
////////////////////////////////////////////////////////////////////////////////

//dkaplan - reloads things in the AutoLoad list
event ReloadGUI()
{
    PersistentStack.Remove( 0, PersistentStack.Length );
    AutoLoadMenus();
}

// dkaplan, left in for consistency; now handled by Create Component
event GUIPage CreateMenu(string NewMenuName,optional string MenuNameOverride)
{
    return GUIPage(CreateComponent( NewMenuName, MenuNameOverride ));
}

// find a persistent component by name
event GUIComponent FindPersistentComponent( string theName, optional bool bExact )
{
    local int i;
    for( i=0; i<PersistentStack.length; i++ )
    {
        //disregard case
        if( ( theName ~= string(PersistentStack[i].Name) ) || ( !bExact && InStr(Caps(PersistentStack[i].Name), Caps(theName)) >= 0 ) )
            return( PersistentStack[i] );
    }
    return None;
}

// remove a persistent component by name
function RemovePersistentComponent( GUIComponent Ctrl )
{
    local int i;
    for( i=0; i<PersistentStack.length; i++ )
    {
        if( Ctrl == PersistentStack[i] )
        {
            PersistentStack[i]=None;
            PersistentStack.Remove( i, 1 );
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// GUI Page management
////////////////////////////////////////////////////////////////////////////////

// ================================================
// OpenMenu - Opens a new menu and places it on top of the stack
event bool OpenMenu(string NewMenuName, optional string MenuNameOverride, optional string Param1, optional string Param2, optional int param3)
{
	return InternalOpenMenu( CreateMenu(NewMenuName, MenuNameOverride), Param1, Param2, Param3 );
}

event bool InternalOpenMenu( GUIPage NewMenu, optional string Param1, optional string Param2, optional int param3 )
{
	if (NewMenu!=None)
	{
        if (!NewMenu.bInited)
			NewMenu.InitComponent(None);

		ResetFocus();

        if( ActivePage != None )
        {
            ActivePage.DeActivate();
            if( !newMenu.bIsOverlay )
    		    ActivePage.Hide(); //only keep this active if new page is just an overlay
        }

#if IG_TRIBES3 // dbeswick: stop sticky keys
		ViewportOwner.Actor.ConsoleCommand("RESETALLINPUT");
#endif

        //NEW MENU NOW ACTIVE PAGE!!!
		ActivePage = NewMenu;
		MenuStack[MenuStack.Length] = ActivePage;

		ActivePage.Show();
		if( !ActivePage.bIsHUD )
    		ActivePage.Activate();
		ActivePage.HandleParameters(Param1, Param2, param3);

		SetControllerStatus(true);
		bForceMouseCheck = true;
		return true;
	}
	else
	{
		return false;
	}
}

// ================================================
// Replaces a menu in the stack.  returns true if success

event bool ReplaceMenu(string NewMenuName, optional string MenuNameOverride, optional string Param1, optional string Param2, optional int param3)
{
	local GUIPage NewMenu;

	NewMenu = CreateMenu(NewMenuName, MenuNameOverride);
	if (NewMenu!=None)
	{
        if (!NewMenu.bInited)
			NewMenu.InitComponent(None);

		ResetFocus();

		if (ActivePage!=None)
        {
            ActivePage.DeActivate();
            if( !newMenu.bIsOverlay )
    		    ActivePage.Hide(); //only keep this active if new page is just an overlay
            MenuStack.Remove( MenuStack.Length-1, 1);
        }

        //NEW MENU NOW ACTIVE PAGE!!!
		ActivePage = NewMenu;
    	
    	MenuStack[MenuStack.Length] = ActivePage;
    	
        ActivePage.Show();
		if( !ActivePage.bIsHUD )
            ActivePage.Activate();
		ActivePage.HandleParameters(Param1, Param2, Param3);

		SetControllerStatus(true);
		bForceMouseCheck = true;

		return true;
	}
	else
		return false;
}

event bool CloseMenu()	// Close the top menu.  returns true if success.
{
	if (MenuStack.Length <= 0)
	{
		log("Attempting to close a non-existing menu page");
		return false;
	}

    ActivePage.DeActivate();
    ActivePage.Hide();
	MenuStack.Remove(MenuStack.Length-1,1);

	ResetFocus();

	MoveControl = None;
	SkipControl = None;
	ActiveControl = None;
	ActivePage = None;
	FocusedControl = None;

	// Gab the next page on the stack
	if (MenuStack.Length>0)	// Pass control back to the previous menu
	{
		ActivePage = MenuStack[MenuStack.Length-1];
        ActivePage.Show();
		if( !ActivePage.bIsHUD )
            ActivePage.Activate();
        SetControllerStatus(true);
	}
	else
	{
 		SetControllerStatus(false);
	}

	bForceMouseCheck = true;

#if IG_TRIBES3 // dbeswick: stop sticky keys
		ViewportOwner.Actor.ConsoleCommand("RESETALLINPUT");
#endif

	return true;
}

// Close all pages in the gui
event CloseAll()
{
	local int i;

	if( MenuStack.Length <= 0 )
        return;
        
	for (i=0;i<MenuStack.Length-1;i++)
	{
	    if( MenuStack[i].bActiveInput )
    	    MenuStack[i].DeActivate();
	    if( MenuStack[i].bVisible )
            MenuStack[i].Hide();
    	if (!MenuStack[i].bPersistent)
        	MenuStack[i].Free();
		MenuStack[i] = None;
	}

    MenuStack.Remove(0,MenuStack.Length-1);

    //ActivePage is now last on the stack, so close it
	CloseMenu();
}

// accessor to the top (active) page
function GUIPage TopPage()
{
	return ActivePage;
}

function GUIPage ParentPage()
{
    if( MenuStack.Length > 1 )
    	return MenuStack[MenuStack.Length-2];
    return None;
}

////////////////////////////////////////////////////////////////////////////////
// Level change hooks
////////////////////////////////////////////////////////////////////////////////

#if IG_TRIBES3 // dbeswick: needed reference to the level
event PreLevelChange(string DestURL, LevelSummary NewSummary)
{
    Super.PreLevelChange(DestUrl, NewSummary);
}

event PostLevelChange(LevelInfo newLevel, bool bSaveGame)
{
    Super.PostLevelChange(newLevel, bSaveGame);
}
#else
event PreLevelChange()
{
    Super.PreLevelChange();
}

event PostLevelChange()
{
    Super.PostLevelChange();
}
#endif

////////////////////////////////////////////////////////////////////////////////
// Focused Component management
////////////////////////////////////////////////////////////////////////////////

event ChangeFocus(GUIComponent NewFocus)
{
	if (FocusedControl!=None && FocusedControl!=NewFocus)
	{
		FocusedControl.LoseFocus();
	}
	FocusedControl=NewFocus;
	FocusedControl.SetFocusInstead( None );
}

function ResetFocus()
{
	local int i;

	if (ActiveControl!=None)
	{
		ActiveControl.EnableComponent();
		ActiveControl=None;
	}

    for (i=0;i<4;i++)
    {
		RepeatKey[i]=0;
		RepeatTime[i]=0;
    }
}


function SetCaptureScriptExec(bool bCapture)
{
    CaptureScriptExec=bCapture;
//    if( bCapture )
//        CaptureScriptExec++;
//    else
//        CaptureScriptExec--;
}

////////////////////////////////////////////////////////////////////////////////
// Editor utilities
////////////////////////////////////////////////////////////////////////////////

function MakeMoveGroup()
{
    local sMoveGroup mtGroup;
    MoveGroups[MoveGroups.Length]=mtGroup;
}

event GroupControl( GUIComponent Ctrl, int group )
{
    local int i;

    // remove from previous group
    if( Ctrl.MoveGroup >= 0 )
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            if( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i] == Ctrl )
            {
                MoveGroups[Ctrl.MoveGroup].CtrlGroup.Remove( i, 1 );
                break;
            }
        }
        //remove only
        if( Ctrl.MoveGroup == group )
        {
            Ctrl.MoveGroup = -1;
            return;
        }
    }
        
    // not remove only, so group it
    MoveGroups[group].CtrlGroup[MoveGroups[group].CtrlGroup.Length]=Ctrl;
    Ctrl.MoveGroup = group;
}

event KillControlGroup( int group )
{
    local int i;

    for( i = 0; i < MoveGroups[group].CtrlGroup.Length; i++ )
    {
        MoveGroups[group].CtrlGroup[i].MoveGroup = -1;
    }
        
    // not remove only, so group it
    MoveGroups[group].CtrlGroup.Remove( 0, MoveGroups[group].CtrlGroup.Length );
}

event MoveControlGroup( int fromGroup, int toGroup )
{
    while( MoveGroups[fromGroup].CtrlGroup.Length > 0 )
    {
        GroupControl( MoveGroups[fromGroup].CtrlGroup[0], toGroup );
    }
}

event AlignControlsInGroup( GUIComponent Ctrl, eComponentAlign align )
{
    local int i;
    local GUIComponent ChangeCtrl;
    
    if( Ctrl == None || Ctrl.MoveGroup < 0 )
        return;
    
    for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
    {
        ChangeCtrl = MoveGroups[Ctrl.MoveGroup].CtrlGroup[i];
        switch( align )
        {
            case cALIGN_Left:
                ChangeCtrl.WinLeft = Ctrl.WinLeft;
                break;
            case cALIGN_Top:
                ChangeCtrl.WinTop = Ctrl.WinTop;
                break;
            case cALIGN_Right:
                ChangeCtrl.WinLeft = Ctrl.WinLeft + Ctrl.WinWidth - ChangeCtrl.WinWidth;
                break;
            case cALIGN_Bottom:
                ChangeCtrl.WinTop = Ctrl.WinTop + Ctrl.WinHeight - ChangeCtrl.WinHeight;
                break;
        }
        UpdateControl( ChangeCtrl, false );
    }
}

event SizeControlsInGroup( GUIComponent Ctrl, eComponentSize size )
{
    local int i;
    local GUIComponent ChangeCtrl;
    
    if( Ctrl == None || Ctrl.MoveGroup < 0 )
        return;
    
    for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
    {
        ChangeCtrl = MoveGroups[Ctrl.MoveGroup].CtrlGroup[i];
        switch( size )
        {
            case cSIZE_Width:
                ChangeCtrl.WinWidth = Ctrl.WinWidth;
                break;
            case cSIZE_Height:
                ChangeCtrl.WinHeight = Ctrl.WinHeight;
                break;
        }
        UpdateControl( ChangeCtrl, true );
    }
}

event SelectNextControlInMoveGroup()
{
    local int i;
    
    if( MoveControl == None || MoveControl.MoveGroup < 0 )
        return;
    
    for( i = 0; i < MoveGroups[MoveControl.MoveGroup].CtrlGroup.Length; i++ )
    {
        if( MoveControl == MoveGroups[MoveControl.MoveGroup].CtrlGroup[i] )
        {
            if( i+1 >= MoveGroups[MoveControl.MoveGroup].CtrlGroup.Length )
                MoveControl = MoveGroups[MoveControl.MoveGroup].CtrlGroup[0];
            else
                MoveControl = MoveGroups[MoveControl.MoveGroup].CtrlGroup[i+1];
            return;
        }
    }
}

event MoveFocused(GUIComponent Ctrl, int bmLeft, int bmTop, int bmWidth, int bmHeight, float ClipX, float ClipY, optional bool bMoveGroup)
{
	local float val;
    local bool bResized;
    local int i;

	if( bMoveGroup && Ctrl.MoveGroup>=0)
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            MoveFocused( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i], bmLeft, bmTop, bmWidth, bmHeight, ClipX, ClipY, false );
        }
        //dont re-move this control
        return;
    }

	val = 1;

	if (bmLeft!=0)
	{
		if (Ctrl.bScaled)
			Ctrl.WinLeft = Ctrl.WinLeft + ( (Val/ClipX) * bmLeft);
		else
			Ctrl.WinLeft += (Val*bmLeft);
	}

	if (bmTop!=0)
	{
		if (Ctrl.bScaled)
			Ctrl.WinTop = Ctrl.WinTop + ( (Val/ClipY) * bmTop);
		else
			Ctrl.WinTop+= (Val*bmTop);
	}

	if (bmWidth!=0)
	{
		if (Ctrl.bScaled)
			Ctrl.WinWidth = Ctrl.WinWidth + ( (Val/ClipX) * bmWidth);
		else
			Ctrl.WinWidth += (Val*bmWidth);
        bResized=true;
	}

	if (bmHeight!=0)
	{
		if (Ctrl.bScaled)
			Ctrl.WinHeight = Ctrl.WinHeight + ( (Val/ClipX) * bmHeight);
		else
			Ctrl.WinHeight += (Val*bmHeight);
        bResized=true;
	}
    if( !bMousePositioning )
    {
        UpdateControl(Ctrl, bResized);
    }
}

#if IG_TRIBES3 // dbeswick: for player design mode
// use screen coordinates. they will be translated into relative coordinates
event SetFocusedPos(GUIComponent Ctrl, float bmLeft, float bmTop, int ClipX, int ClipY)
{
	if (Ctrl == None)
		return;

	Ctrl.WinLeft = bmLeft / ClipX;
	Ctrl.WinTop = bmTop / ClipY;

	if (Ctrl.WinLeft + Ctrl.WinWidth > 1)
		Ctrl.WinLeft = 1 - Ctrl.WinWidth;
	if (Ctrl.WinTop + Ctrl.WinHeight > 1)
		Ctrl.WinTop = 1 - Ctrl.WinHeight;
	if (Ctrl.WinLeft < 0)
		Ctrl.WinLeft = 0;
	if (Ctrl.WinTop < 0)
		Ctrl.WinTop = 0;

    if( !bMousePositioning )
    {
        UpdateControl(Ctrl, false);
    }
}
#endif

event UpdateControl(GUIComponent Ctrl, bool bResized)
{
    if( bSnapToGrid )
        SnapToGrid(Ctrl,bResized);
    Ctrl.OnChangeLayout();
}

//resolution get/set to be used only for gui placement system!
event GetGuiResolution()
{
    local String CurrentRes;
	local int i;
	
    CurrentRes = ViewportOwner.Actor.ConsoleCommand( "GETCURRENTRES" );
    i = InStr( CurrentRes, "x" );
    if( i > 0 )
    {
		ResolutionX = int( Left ( CurrentRes, i )  );
		ResolutionY = int( Mid( CurrentRes, i+1 ) );
    }
log( "[dkaplan] GetGuiResolution, CurrentRes = "$CurrentRes$", ResolutionX = "$ResolutionX$", ResolutionY = "$ResolutionY );
}

//tcohen: support for notification when resolution changes

#if IG_TRIBES3 // dbeswick: added to support resolution changes
function SetChildrenDirty(GUIMultiComponent C)
{
    local int i;
	
	for (i=0; i < C.Controls.Length; i++)
	{
		C.Controls[i].SetDirty();
		if (GUIMultiComponent(C.Controls[i]) != None)
			SetChildrenDirty(GUIMultiComponent(C.Controls[i]));
	}
}
#endif

event OnResolutionChanged(int OldResolutionX, int OldResolutionY, int NewResolutionX, int NewResolutionY)
{
    local int i;

#if IG_TRIBES3 // dbeswick: added to support resolution changes
	// set all controls dirty
    for (i=0;i<MenuStack.Length;i++)
	{
    	SetChildrenDirty(MenuStack[i]);
	}
#endif

	for (i=0; i<InterestedResolutionChanged.length; ++i)
        InterestedResolutionChanged[i].OnResolutionChanged(OldResolutionX, OldResolutionY, ResolutionX, ResolutionY);
}

function RegisterNotifyResolutionChanged(GUIComponent Component)
{
    //I'm calling this function inside an assertWithDescription() to save the expense for shipping build
    assertWithDescription(!ComponentIsRegisteredForResolutionChanged(Component),
        "[tcohen] "$Component$" is registering for notification that the resolution changed.  But it is already registered for that notification.");

    //add interest
    InterestedResolutionChanged[InterestedResolutionChanged.length] = Component;
}

function bool ComponentIsRegisteredForResolutionChanged(GUIComponent Component)
{
    local int i;

    for (i=0; i<InterestedResolutionChanged.length; ++i)
        if (InterestedResolutionChanged[i] == Component)
            return true;

    return false;
}

//it is not an error to UnRegister if Component is not registered
function UnRegisterNotifyResolutionChanged(GUIComponent Component)
{
    local int i;

    for (i=0; i<InterestedResolutionChanged.length; ++i)
    {
        if (InterestedResolutionChanged[i] == Component)
        {
           InterestedResolutionChanged.Remove(i, 1);
           return;  //entries in InterestedResolutionChanged are guaranteed to be unique (as long as RegisterNotifyResolutionChanged() is used)
        }
    }
}

function SetGuiResolution()
{
	ViewportOwner.Actor.ConsoleCommand("SETRES"@ResolutionX$"x"$ResolutionY);
}


function ScaleToResolution(GUIComponent Ctrl, optional bool bPropagate)
{
    DoScalingOnComponent( Ctrl, false, bPropagate );
    }

function ResolutionToScale(GUIComponent Ctrl, optional bool bPropagate)
    {
    DoScalingOnComponent( Ctrl, true, bPropagate );
    }

private function DoScalingOnComponent( GUIComponent Ctrl, bool bScaleIt, optional bool bPropagate )
    {
    local int i;
    
    if( !bScaleIt && Ctrl.bScaled )
    {
        Ctrl.WinLeft *= ResolutionX;        
        Ctrl.WinWidth *= ResolutionX;        
        Ctrl.WinTop *= ResolutionY;        
        Ctrl.WinHeight *= ResolutionY;        
    }
    else if( bScaleIt && !Ctrl.bScaled )
    {
        Ctrl.WinLeft /= float(ResolutionX);        
        Ctrl.WinWidth /= float(ResolutionX);        
        Ctrl.WinTop /= float(ResolutionY);        
        Ctrl.WinHeight /= float(ResolutionY); 
    }
    Ctrl.bScaled = bScaleIt;        
    
    if( bPropagate && GUIMultiComponent(Ctrl) != None )
    {
        for( i = 0; i < GUIMultiComponent(Ctrl).Controls.Length; i++ )
        {
            DoScalingOnComponent( GUIMultiComponent(Ctrl).Controls[i], bScaleIt, true );
    }
}
}



event ToggleSnapToGrid()
{
    bSnapToGrid = !bSnapToGrid;
}

// snap the component to the grid after a move
function SnapToGrid(GUIComponent Ctrl, bool bResized)
{
    local int i;
    local bool bWasScaled;
    
    bWasScaled = Ctrl.bScaled;

    if( bWasScaled )
        ScaleToResolution(Ctrl);
        
    //if width/height is same, snap t&l, else snap w&h
    if( !bResized )
    {
        //snap t&l
        i = int(Ctrl.WinTop/GridSize)*GridSize;
        //log("[DPK]: i = int(Ctrl.WinTop/GridSize)*GridSize = "$i);
        if( Ctrl.WinTop-float(i) > float(GridSize)/2.0 )
        {
            Ctrl.WinTop=i+GridSize;
        }
        else
        {
            Ctrl.WinTop=i;
        }    

        i = int(Ctrl.WinLeft/GridSize)*GridSize;
        if( Ctrl.WinLeft-float(i) > float(GridSize)/2.0 )
        {
            Ctrl.WinLeft=i+GridSize;
        }
        else
        {
            Ctrl.WinLeft=i;
        }    
    }
    else
    {
        //snap w&h
        i = int(Ctrl.WinHeight/GridSize)*GridSize;
        if( Ctrl.WinHeight-float(i) >= float(GridSize)/2.0 )
        {
            Ctrl.WinHeight=i+GridSize;
        }
        else
        {
            Ctrl.WinHeight=i;
        }    

        i = int(Ctrl.WinWidth/GridSize)*GridSize;
        if( Ctrl.WinWidth-float(i) >= float(GridSize)/2.0 )
        {
            Ctrl.WinWidth=i+GridSize;
        }
        else
        {
            Ctrl.WinWidth=i;
        }    
    }

    if( bWasScaled )
        ResolutionToScale(Ctrl);
}

event ToggleActiveComponentSizing(GUIComponent Ctrl, optional bool bPropagate, optional bool bMoveGroup)
{
    local int i;
	if( bMoveGroup && Ctrl.MoveGroup>=0)
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            ToggleActiveComponentSizing( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i], bPropagate );
        }
        //dont re-save this control
        return;
    }

    if( Ctrl!=None )
    {
        if( Ctrl.bScaled )
		{
#if ! IG_TRIBES3 // Paul: Tribes doesn't use this and it really hurts when you 
				 //	save a page out in absolute coords when you didnt want to
            ScaleToResolution(Ctrl, bPropagate);
#endif
		}
        else
            ResolutionToScale(Ctrl, bPropagate);
}
}

//save currently active component
event SaveActiveComponent(GUIComponent Ctrl, optional bool bMoveGroup)
{
    local int i;
	if( bMoveGroup && Ctrl.MoveGroup>=0)
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            SaveActiveComponent( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i] );
        }
        //dont re-save this control
        return;
    }

    if( Ctrl!=None )
        SaveComponent(Ctrl);
}

function SaveComponent(GUIComponent Ctrl)
{
    Ctrl.SaveLayout(true);
}

function ChangeActiveStyle(String newStyle)
{
    if( MoveControl!=None )
        MoveControl.ChangeStyle(newStyle);
}

function ChangeGridSize(int newSize)
{
    GridSize=newSize;
}

function ChangeResolutionX(int newSize)
{
    ResolutionX=newSize;
}

function ChangeResolutionY(int newSize)
{
    ResolutionY=newSize;
}

event UndoActiveComponent(GUIComponent Ctrl, optional bool bMoveGroup)
{
    local int i;
	if( bMoveGroup && Ctrl.MoveGroup>=0)
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            UndoActiveComponent( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i] );
        }
        //dont re-move this control
        return;
    }

    if( Ctrl!=None )
        Ctrl.UndoLayout();
}

event RedoActiveComponent(GUIComponent Ctrl, optional bool bMoveGroup)
{
    local int i;
	if( bMoveGroup && Ctrl.MoveGroup>=0)
    {
        for( i = 0; i < MoveGroups[Ctrl.MoveGroup].CtrlGroup.Length; i++ )
        {
            RedoActiveComponent( MoveGroups[Ctrl.MoveGroup].CtrlGroup[i] );
        }
        //dont re-move this control
        return;
    }

    if( Ctrl!=None )
        Ctrl.RedoLayout();
}


///////////////////////////
//Utility functions used for relating spinny's to controls
///////////////////////////
function CenterOfControl( GUIComponent Ctrl, out float left, out float top )
{
    left = Ctrl.WinLeft + Ctrl.WinWidth/2;
    top = Ctrl.WinTop + Ctrl.WinHeight/2;
    if( Ctrl.bScaled )
    {
        left*=ResolutionX;
        top*=ResolutionY;
    }
}

function SizeOfControl( GUIComponent Ctrl, out float size )
{
    local float sizedW, sizedH;
    if( Ctrl.bScaled )
    {
        sizedW=Ctrl.WinWidth;
        sizedH=Ctrl.WinHeight;
    }
    else
    {
        sizedW=Ctrl.WinWidth/float(ResolutionX);
        sizedH=Ctrl.WinHeight/float(ResolutionY);
    }

    size = sqrt( sizedW * sizedH ); 
}

function bool HasMouseMoved()
{
	if (MouseX==LastMouseX && MouseY==LastMouseY)
		return false;
	else
		return true;
}

event NotifyLevelChange()
{
	local int i;

    for (i=0;i<MenuStack.Length;i++)
    	MenuStack[i].NotifyLevelChange();
}

#if IG_SHARED // dbeswick: added remove of menu by name
native function RemoveMenu(string MenuName);
#endif


////////////////////////////////////////////////////////////////////////////////
// Logging/debugging utilities
////////////////////////////////////////////////////////////////////////////////

event LogGUI()
{
    local int i;
    for( i = 0; i < PersistentStack.Length; i++ )
        if( GUIPage(PersistentStack[i]) != None )
            LogGUIPage( GUIPage(PersistentStack[i]) );
}

event LogGUIPage( GUIPage Page )
{
    log( "LogGui: ***************************************************************" );
    log( "LogGui: Logging GUI for"@Page.Name ); 
    log( "LogGui: " );
    LogGUIComponent( Page );
}

event LogGUIComponent( GUIComponent Ctrl, optional int level )
{
    local int i;
    local GUIMultiComponent MC;
    local string Msg;

    Msg = "LogGui: ";
    for( i = 0; i < level; i++ )
        Msg = Msg $ "    ";
    Msg = Msg $ " -> " $ Ctrl.Name;
    
    Log( Msg );
    
    MC = GUIMultiComponent(Ctrl);
    if( MC!=None )
        for( i = 0; i < MC.Controls.Length; i++ )
            LogGUIComponent( MC.Controls[i], level+1 );
}

#if IG_SHARED // Carlos: This *should* go into Tribes/SwatGuiController, but I'll put it here for now.
// These exec functions do the dirty work of localizing perobject config classes.
// All PerObjectConfig classes need to be specified in the appropriate ContentDump/GuiDump ini file
// with the associated object name.  These functions actually load *all* of those objects, regardless of game state.
//
exec function LoadLocalizedPerObjectConfig()
{
    local Object NewObj;
    local int i;
    local class<ContentDumper> dumper;
    local class NewClass;

log("[carlos] LoadLocalizedPerObjectConfig()");
    dumper = class<ContentDumper>(DynamicLoadObject("SwatGui.ContentDumper",class'class'));
log("[carlos] Dumping Content... dumper = "$dumper$", dumper.default.ClassName.Length= "$dumper.default.ClassName.Length);

    for (i=0;i<dumper.default.ClassName.Length;i++)
	{
        NewClass = class( DynamicLoadObject(dumper.default.ClassName[i], class'Class') );
    	NewObj = new( None, dumper.default.ObjName[i] ) NewClass;
		if (NewObj == None)
        	log("  Could not load"@dumper.default.ObjName[i]);
        else
		{
            log("Loaded object"$dumper.default.ObjName[i]);
		}
	}

    LoadLocalizedPerObjectConfigGUI();
}

// Dan: loads the entire gui as specified by the GUIDUMP.ini;  command line capable for localization commandlet purposes
exec function LoadLocalizedPerObjectConfigGUI()
{
	local GUIComponent NewMenu;
    local int i;
    local class<GUIDumper> loader;
log("[dkaplan] Loading GUI");
    loader = class<GUIDumper>(DynamicLoadObject("SwatGui.GUIDumper",class'class'));
log("[dkaplan] Loading GUI... loader = "$loader$", loader.default.ClassName.Length= "$loader.default.ClassName.Length);

    for (i=0;i<loader.default.ClassName.Length;i++)
	{
    	NewMenu = CreateComponent(loader.default.ClassName[i],loader.default.ObjName[i]);
		if (NewMenu==None)
        	log("  Could not load"@loader.default.ObjName[i]);
        else
		{
	        if (!NewMenu.bInited)
				NewMenu.InitComponent(None);
            log("Loaded Menu "$loader.default.ObjName[i]);
		}
	}
}
#endif // IG_SHARED

#if IG_TRIBES3 // dbeswick: added GUIController PaintProgress
// PaintProgress
// Call this to force the renderer to redraw while the level is loading
native function PaintProgress();
#endif

#if IG_TRIBES3 // dbeswick: all download notification is done through the GUI system
function OnProgress(string Str1, string Str2)
{
	local int i;
	for (i = 0; i < MenuStack.Length; i++)
		MenuStack[i].OnProgress(Str1, Str2);
}
#endif

#if IG_TRIBES3 // dbeswick:
event bool IsPageActive(string MenuClass)
{
	local class c;

	if (ActivePage == None)
		return false;

	c = class(DynamicLoadObject(MenuClass, class'Class'));

	return c != None && ClassIsChildOf(ActivePage.class, c);
}
#endif

cpptext
{
        UBOOL ScriptConsoleExec( const TCHAR* Str, FOutputDevice& Ar, UObject* Executor );
		void  NativeMessage(const FString Msg, FLOAT MsgLife);
		UBOOL NativeKeyType(BYTE& iKey, TCHAR Unicode );
		UBOOL NativeKeyEvent(BYTE& iKey, BYTE& State, FLOAT Delta );
		void  NativeTick(FLOAT DeltaTime);
		void  NativePreRender(UCanvas* Canvas);
		void  NativePostRender(UCanvas* Canvas);

		virtual void LookUnderCursor(FLOAT dX, FLOAT dY);
		UGUIComponent* UnderCursor(FLOAT MouseX, FLOAT MouseY);

		UBOOL virtual MousePressed(UBOOL IsRepeat);
		UBOOL virtual MouseReleased();

		UBOOL HasMouseMoved();

		void PlayInterfaceSound(USound* sound);
		void PlayClickSound(BYTE SoundNum);

        virtual void Modify(); //callback from the object browser

        void GroupAllControlsInBounds( UGUIMultiComponent* Ctrl, FLOAT top, FLOAT bottom, FLOAT left, FLOAT right );

}


defaultproperties
{
     bDontDisplayHelpText=True
     GridSize=2
     ResolutionX=720
     ResolutionY=540
     GUI_TO_WORLD_X=160.000000
     GUI_TO_WORLD_Y=125.000000
     ControllerMask=255
     DblClickWindow=0.500000
     ButtonRepeatDelay=0.250000
     CursorStep=3
     FastCursorStep=3
     bHighlightCurrent=True
     bShowGUIMembers=True
     MenuMouseSens=1.000000
     JoyDeadZone=0.300000
     WhiteBorder=Texture'GUITribes.outline'
}
