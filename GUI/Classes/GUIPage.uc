// ====================================================================
//  Class:  GUI.GUIPage
//
//	GUIPages are the base for a full page menu.  They contain the
//	Control stack for the page.
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

class GUIPage extends GUIMultiComponent
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

// Variables
var(GUIPage) Editinline Editconst const	array<GUIComponent>		Timers "List of components with Active Timers if last on the stack.";
																			
var(GUIPage) config                      bool                    bIsOverlay "If true, underlaying components should remain active";
var(GUIPage) config                      bool                    bIsHUD "If true, underlaying systems should remain active for input (gui should not swallow invalid input)";

var(GUIPage) Editinline config GUILabel HelpText "The label that displays the hint for the watched component on this page";
#if IG_TRIBES3	// michaelj:  Allow subclasses to specify a different dialog class
var(GUIPage) config						string					DialogClassName;
#endif
// Delegates

delegate OnDlgReturned( int returnButton, optional string Passback );
delegate OnPopupReturned( GUIListElem returnObj, optional string Passback );

event Activate()
{
	EnableComponent();
	Super.Activate();
	Focus();
}

event DeActivate()
{
	DisableComponent();
	Super.DeActivate();
	if (!bPersistent)       // keep access to the controller if we are not up
	    Free();
}


event Show()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMenuLoop',,,,,,,,Style.EffectCategory);
    Super.Show();
}

event Hide()
{
    if( Style != None )
        PlayerOwner().UnTriggerEffectEvent('UIMenuLoop');
    Super.Hide();
}

//=================================================
// InitComponent is responsible for initializing all components on the page.

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	
	MapControls();		// Figure out links
}

event ChangeHint(string NewHint)
{
    if( HelpText == None )
        return;
        
    HelpText.SetCaption( NewHint );
    HelpText.SetVisibility( !Controller.bDontDisplayHelpText && NewHint != "" );
}

event HandleParameters(string Param1, string Param2, optional int param3);	// Should be subclassed

event NotifyLevelChange();

event Free( optional bool bForce ) 			// This control is no longer needed
{
	local int i;
    for (i=0;i<Timers.Length;i++)
    	Timers[i]=None;
    Timers.Remove( 0, Timers.Length );
    
    HelpText=None;

    Super.Free( bForce );
}

#if IG_TRIBES3 // dbeswick: return Dialog object
final function GUIDlg OpenDlg( String Caption, optional int TheButtons, optional string Passback, optional int TimeOut )
#else
final function OpenDlg( String Caption, optional int TheButtons, optional string Passback, optional int TimeOut )
#endif
{
    local GUIDlg Dialog;
    local bool bProp;
    
    bProp=PropagateState;
	DisableComponent();
	PropagateState=bProp;
    
    Dialog = GUIDlg(AddComponent( DialogClassName, self.Name$"_"$Passback, true ));
    Dialog.SetupDlg( Caption, Passback, TheButtons, TimeOut );
    
    Dialog.Show();
    Dialog.Activate();

#if IG_TRIBES3 // dbeswick: return Dialog object
	return Dialog;
#endif
}

final function DlgReturned( GUIDlg Dialog )
{
    local bool bProp;
    
    Dialog.DeActivate();
    Dialog.Hide();
    
    bProp=PropagateState;
	EnableComponent();
	PropagateState=bProp;
	Focus();
    
    OnDlgReturned( Dialog.Selection, Dialog.Passback ); //call the delegate

#if !IG_TRIBES3 // dbeswick: moved this to fix assert
    //remove the dialog after it has been closed and processed
    RemoveComponent( Dialog );
#endif
}

#if IG_TRIBES3	// michaelj:  Added ability for GUIPages to respond to gameplay messages
function onGameplayMessage(Message msg)
{
}
#endif

#if IG_TRIBES3 // dbeswick: all download notification is done through the GUI system
function OnProgress(string Str1, string Str2)
{
}
#endif

cpptext
{
		UBOOL NativeKeyEvent(BYTE& iKey, BYTE& State, FLOAT Delta );
		void UpdateTimers(float DeltaTime);
		UBOOL MousePressed(UBOOL IsRepeat);					// The Mouse was pressed
		UBOOL MouseReleased();								// The Mouse was released

        UBOOL XControllerEvent(int Id, eXControllerCodes iCode);


}


defaultproperties
{
     bIsOverlay=True
     DialogClassName="GUI.GUIDlg"
     WinTop=0.000000
     WinLeft=0.000000
     WinWidth=1.000000
     WinHeight=1.000000
     bSwallowAllKeyEvents=True
     bTabStop=False
     bPersistent=True
}
