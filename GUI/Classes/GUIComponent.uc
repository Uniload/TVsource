// ====================================================================
//  Class:  GUI.GUIComponent
//
//	GUIComponents are the most basic building blocks of menus.
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

class GUIComponent extends GUI
		Config(TribesGui)
		PerObjectConfig
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

// Used for Determining a dynamic position for this GUIComponent
struct sDynamicPositionSpec
{
    var() config float WinLeft "Left position of this spec";
    var() config float WinTop "Top position of this spec";
    var() config float WinWidth "Width of this spec";
    var() config float WinHeight "Height of this spec";
    var() config float TransitionTime "The amount of time that will be taken to transition to these coords on a RePosition() call";
    var() config name KeyName "Name used to reference this position spec";
};

// Used to specify a dynamic transition for this GUIComponent
struct sTransitionSpec
{
    var() EditConst sDynamicPositionSpec NewPos "New position spec";
    var() EditConst float OldWinLeft "Left position of this spec";
    var() EditConst float OldWinTop "Top position of this spec";
    var() EditConst float OldWinWidth "Width of this spec";
    var() EditConst float OldWinHeight "Height of this spec";
};

// Variables
var(GUIComponent) config editinline array<sDynamicPositionSpec> MovePositions "The PositionSpecs used to handle dynamic RePosition()ing";
var(GUIState) EditConst bool bRepositioning "If true, the timer for this component should be repositioning based on the current TransitionSpec";
var(GUIState) EditConst EditInline sTransitionSpec TransitionSpec "The current transitioning spec";
var(GUIComponent) config int CyclePosition "If set to a MovePositions index, the component will begin cycling from that index when activated";
var(GUIComponent) config bool bRepeatCycling "If set, this component will continue cycling after it processes to the end of the MovePositions array";

var(GUIState) EditConst int MoveGroup "What move group this component belongs to, -1 by default is none";

var(GUIState) Editinline EditConst	GUIComponent 		MenuOwner "Callback to the Component that owns this one";
var(GUIState) EditConst			eMenuState		MenuState "Used to determine the current state of this component";

var(GUIState) Editinline EditConst array<GUIComponent>   UndoHistory "Layout history used for undo/redo operations";
var(GUIState) EditConst int UndoLevel "Where in the undo history we currently are";
var(GUIState) EditConst bool bSaved "Have any updates to this component been saved?";
var(GUIState) EditConst      bool                bInited "has this component been initialized yet";

// RenderStyle and MenuColor are usually pulled from the Parent menu, unless specificlly overridden

var(GUIComponent) config  string		StyleName "Name of my Style";
var(GUIComponent) config  float		WinTop,WinLeft "Where does this component exist (in world space) - Grr.. damn Left()";
var(GUIComponent) config  float		WinWidth,WinHeight "Where does this component exist (in world space) - Grr.. damn Left()";
var(GUIComponent) config  bool				bScaled "Is this component using scaling";

var(GUIComponent) config  bool				bBoundToParent "Use the Parents Bounds for all positioning";
var(GUIComponent) config  bool				bScaleToParent "Use the Parent for scaling";

//global visibility switch
var(GUIComponent) config  bool				bCanBeShown "Should this control ever be drawn";

//global input switch
var(GUIComponent) config  bool				bAcceptsInput "Does this control ever accept input";

//specific input type switches
var(GUIComponent) config  bool				bCaptureTabs "This control wants tabs";  //TODO: dkaplan- this does not like it would work correctly... should be redesigned or removed
var(GUIComponent) config  bool				bCaptureMouse "Set this if the control should capture the mouse when pressed";  //process MousePressed()/MouseReleased()/Watched()

//should this always swallow input
var(GUIComponent) config  bool				bSwallowAllKeyEvents "Set this if the control should swallow all native key events";  

var(GUIComponent) config  bool				bHitTestOnClientBounds "Set this if the control should perform hit tests using the client bounds instead of the bounds";  

var(GUIComponent) config  bool				bAllowHTMLTextFormatting "If true, this control will parse out HTML style formatting codes from text strings";

var(GUIComponent) config  bool				bDrawStyle "If true, this control will draw its GUIStyle before any further drawing";
var(GUIComponent) config  bool				bNeverFocus "This control should never fully receive focus";
var(GUIComponent) config  bool				bRepeatClick "Have the system accept holding down of the mouse";
var(GUIComponent) config  bool				bRequireReleaseClick "If True, this component wants the click on release even if it's not active";
var(GUIComponent) config  localized string	Hint "The hint that gets displayed for this component";
var(GUIComponent) config  int					MouseCursorIndex "The mouse cursor to use when over this control";
var(GUIComponent) config  bool				bHideMouseCursor "If true, no mouse cursor will be displayed over this control (while the control is active)";
var(GUIComponent) config  bool				bTabStop "Does a TAB/Shift-Tab stop here";
var(GUIComponent) config  int					TabOrder "Used to figure out tabbing";
var(GUIComponent) config  bool				bFocusOnWatch "If true, watching focuses";
var(GUIComponent) config  bool				bMaintainFocus "If true, will not lose focus after a new control recieves focus";
var(GUIComponent) config  float				RenderWeight "Used to determine sorting in the controls stack";
var(GUIComponent) config  bool				bMouseOverSound "Should component bleep when mouse goes over it";
var(GUIComponent) private Editinline GUIComponent   FocusInstead "Who should get the focus instead of this control if bNeverFocus";

//from GUIPage, now all components may be persistent
var(GUIComponent) config  bool	            bPersistent "If set, component is saved across open/close/reopen, only instanciated once.";

var(GUIState)	EditConst bool	bVisible "Is this component currently visible";
var(Menu)	enum				EClickSound
{
	CS_None,
	CS_Click,
	CS_Edit,
	CS_Up,
	CS_Down
} OnClickSound;

// Style holds a pointer to the GUI style of this component.

var(GUIState)	Editinline EditConst		GUIStyles		 Style "My GUI Style";

// Notes about the Top/Left/Width/Height : This is a somewhat hack but it's really good for functionality.  If
// the value is <=1, then the control is considered to be scaled.  If they are >1 they are considered to be normal world coords.
// 0 = 0, 1 = 100%

var			float		Bounds[4];								// Internal normalized positions in world space
var			float		ClientBounds[4];						// The bounds of the actual client area (minus any borders)

var(GUIState) Editconst bool bActiveInput "is active for input";
var(GUIState) private Editconst bool bDirty "When true, will update the component on its next PreDraw";

// Timer Support
var const	int			TimerIndex;			// For easier maintenance
var(GUIState) Editconst  bool		bTimerRepeat "Does the Timer Repeat?";
var(GUIState) Editconst  float		TimerCountdown "Clock time";
var(GUIState) Editconst  float		TimerInterval "Timer interval";

#if IG_TRIBES3 // dbeswick: variable used to disallow movement in player design mode
var(GUIState) Editconst  bool		bPlayerMoveAllowed;
#endif

#if IG_TRIBES3	// michaelj:  don't allow repeated mouse click effect triggers when holding fire on a button
var bool bAllowPressedEffect;
#endif

// Used for Saving the last state before drawing natively

var		float 	SaveX,SaveY;
var 	color	SaveColor;
var		font	SaveFont;
var		byte	SaveStyle;

////////////////////////////////////////////////////////////////////////////
// These are used solely for XController events and should probably be removed [dkaplan]
//
// If you want to override a link to force this component to point to a given
// component on your page, set it here.
// 0 = Up
// 1 = Down
// 2 = Left
// 3 = Right
var GUIComponent LinkOverrides[4];
var GUIComponent Links[4];

var(GUIComponent) Editinline config  GUIRadioButton RadioGroup "If not None, this component will be enabled/disabled as part of the specified radio group.";

////////////////////////////////////////////////////////////////////////////
// Delegates
////////////////////////////////////////////////////////////////////////////
// Drawing delegates return true if you want to short-circuit the default drawing code
Delegate bool OnUpdateComponent(Canvas Canvas)
{
    return false;
}
Delegate bool OnPreDraw(Canvas Canvas)
{
    return false;
}
Delegate bool OnDraw(Canvas Canvas)
{
    return false;
}
Delegate OnClientDraw(Canvas Canvas);

Delegate OnMenuStateChanged(GUIComponent Sender, eMenuState NewState); //Called when a component's state changes
Delegate OnHide(); //Called after a Hide()
Delegate OnShow(); //Called after a Show()
Delegate OnActivate(); //Called after an Activate()
Delegate OnDeActivate(); //Called after a DeActivate()

Delegate OnChange(GUIComponent Sender);	// Called when a component changes it's value


Delegate OnRePositionCompleted(GUIComponent Sender, name NewPosLabel); // Called when a repositioning finishes
Delegate OnHitTest(float MouseX, float MouseY);							// Called when Hit test is performed for mouse input
Delegate OnRender(canvas Canvas);										// Called when the component is rendered
Delegate OnMessage(coerce string Msg, float MsgLife); 					// When a message comes down the line

// -- Input event delegates
Delegate OnClick(GUIComponent Sender);			// The mouse was clicked on this control
Delegate OnDblClick(GUIComponent Sender);		// The mouse was double-clicked on this control
Delegate OnRightClick(GUIComponent Sender);	// Control was right clicked.
Delegate OnMousePressed(GUIComponent Sender);		// Sent when a mouse is pressed (initially)
Delegate OnMouseRelease(GUIComponent Sender);		// Sent when the mouse is released. Happens before Click() event
Delegate OnWatched(GUIComponent Self);		// Sent when the mouse is placed over this component

Delegate OnFocused(GUIComponent Self) 		// Sent when the component gains focus, assign to apply a specific focus
{
    //change FocusInstead's state to focused instead of this
	if( FocusInstead != None )
	{
		FocusInstead.Focus();
	}
    else
    {
        Controller.ChangeFocus(self);
    }
}

Delegate OnLostFocus(GUIComponent Self);		// Sent when the component loses focus

Delegate bool OnCapturedMouseMove(float deltaX, float deltaY)
{
	return false;
}


//Key events
Delegate bool OnKeyType(out byte Key, optional string Unicode)
{
	return false;
}
Delegate bool OnKeyEvent(out byte Key, out byte State, float delta)
{
	return false;
}

// Allows a control to process raw Console controller events
Delegate bool OnRawXController(byte Id, out byte Key, out byte State, out float Axis)
{
	return false;
}
// XBox Controller Events
Delegate bool OnXControllerEvent(byte Id, eXControllerCodes iCode)
{
	return false;
}

////////////////////////////////////////////////////////////////////////////////
// Timer Processing
////////////////////////////////////////////////////////////////////////////////
event Timer();		// Should be subclassed
function native final SetTimer(float Interval, optional bool bRepeat);
function native final KillTimer();


////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////
Overloaded Function Construct(GUIController MyController)
{
	OnConstruct(MyController);
}

function OnConstruct(GUIController MyController)
{
    Controller = MyController;
}

function InitComponent(GUIComponent MyOwner)
{
//log("[dkaplan] Resetting config on "$self);
    ResetConfig();  //Loads the transient references from the config data for this object

	MenuOwner = MyOwner;

    if( Hint == "" && MenuOwner != None )
        Hint = MenuOwner.Hint;

	Style = Controller.GetStyle(StyleName);
	
	//perform the initial update
	SetDirty();
	
    if( Controller.bModAuthor )
        SaveLayoutToHistory();
    bInited = true;
}

function InitDelegates();

event final SetDirty()
{
    bDirty = true;
    if( MenuOwner != none )
        MenuOwner.SetDirty();
}
////////////////////////////////////////////////////////////////////////////////
// Input Events
////////////////////////////////////////////////////////////////////////////////
event MousePressed()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMousePressed',,,,,,,,Style.EffectCategory);
    Press();

	// michaelj: UIFX
	if (bAllowPressedEffect)
	{
		PlayerOwner().TriggerEffectEvent('Pressed',,,,,,,,Name(StyleName));
		bAllowPressedEffect = false;
	}

    OnMousePressed(self);
}

event MouseReleased()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMouseReleased',,,,,,,,Style.EffectCategory);
    //Focus();
 
	// michaelj: UIFX
	PlayerOwner().TriggerEffectEvent('Released',,,,,,,,Name(StyleName));
	bAllowPressedEffect = true;

    OnMouseRelease(self);
}

event Click()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMouseClicked',,,,,,,,Style.EffectCategory);
    OnClick(self);
}

event DblClick()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMouseDoubleClicked',,,,,,,,Style.EffectCategory);
    OnDblClick(self);
}

//State selections
event Watched()
{
    if( Style != None )
        PlayerOwner().TriggerEffectEvent('UIMouseWatched',,,,,,,,Style.EffectCategory);
    if( bFocusOnWatch )
        MenuStateChange( MSAT_Focused );
    else
        MenuStateChange( MSAT_Watched );

	// michaelj: UIFX
	PlayerOwner().TriggerEffectEvent('Watched',,,,,,,,Name(StyleName));

    OnWatched(self);
}

event Focus()
{
    if( bNeverFocus )
        MenuStateChange( MSAT_Blurry );
    else
    MenuStateChange( MSAT_Focused );
}

event Press()
{
    MenuStateChange( MSAT_Pressed );
}

function SetEnabled(bool newEnabled)
{
    if (newEnabled)
        EnableComponent();
    else
        DisableComponent();
}

event DisableComponent()
{
    MenuStateChange( MSAT_Disabled );
}

event EnableComponent()
{
        MenuStateChange( MSAT_Blurry );
}

////////////////////////////////////////////////////////////////////////////////
// Script Bounds Tests
////////////////////////////////////////////////////////////////////////////////

function bool IsInBounds()	// Script version of PerformHitTest
{
	return ( (Controller.MouseX >= Bounds[0] && Controller.MouseX<=Bounds[2]) && (Controller.MouseY >= Bounds[1] && Controller.MouseY <=Bounds[3]) );
}

function bool IsInClientBounds()
{
	return ( (Controller.MouseX >= ClientBounds[0] && Controller.MouseX<=ClientBounds[2]) && (Controller.MouseY >= ClientBounds[1] && Controller.MouseY <=ClientBounds[3]) );
}


////////////////////////////////////////////////////////////////////////////////
// State Changes
////////////////////////////////////////////////////////////////////////////////
//Change the MenuState
// Menu states are used to determine the state of the component and also
//  for drawing applicable GUIStyles
private function MenuStateChange(eMenuState Newstate)
{
	if( NewState==MSAT_Focused )
	{
//log("[dkaplan] OnFocused: "$self);
    OnFocused(self);
	}
	else if( MenuState == MSAT_Focused && NewState ==MSAT_Pressed && bMaintainFocus )
	{
		// do not transition to being pressed if maintaining focus
		return;
	}
    else if( MenuState == MSAT_Focused && NewState != MSAT_Pressed )
{
//log("[dkaplan] OnLostFocus: "$self);
	    OnLostFocus(self);
}

	if( MenuState == NewState )
	    return;
	    
	MenuState = NewState;
	OnMenuStateChanged(self,MenuState);
}

function SetFocusInstead( GUIComponent other )
{
    FocusInstead = other;
    if( MenuOwner != None )
        MenuOwner.SetFocusInstead( self );
}

function LoseFocus()
{
    if( !bMaintainFocus 
#if IG_TRIBES3 // Paul: Don't want to enable a disabled component on a focus event
		&& MenuState != MSAT_Disabled
#endif
		)
        EnableComponent();
}

////////////////////////////////////////////////////////////////////////////////
// Main Activation and Visibility switches
////////////////////////////////////////////////////////////////////////////////
event SetVisibility(bool newVisible)
{
    if (newVisible)
        Show();
    else
        Hide();
}

event Hide()
{
    bVisible = false;
    OnHide();
}

event Show()
{
    if( !bCanBeShown )
        return;

    //always update once when shown
	SetDirty();
	
    bVisible = true;
    OnShow();
}

event SetActive(bool bActive)
{
    //this should be just a helper function, and shouldn't do any real work

    if (bActive)
        Activate();
    else
        Deactivate();
}

event DeActivate()
{
    bActiveInput = false;

	OnDeActivate();
    if( CyclePosition >= 0 && CyclePosition < MovePositions.Length )
    	StopCycling();
}

event Activate()
{
    //ensure that this can be made active
    if( !bAcceptsInput )
        return;

    bActiveInput = true;

    OnActivate();
    if( CyclePosition >= 0 && CyclePosition < MovePositions.Length )
        CyclePositions();
}


////////////////////////////////////////////////////////////////////////////////
// Repositioning of Component
////////////////////////////////////////////////////////////////////////////////
// cycle to the next position in the MovePositions array
function CyclePositions()
{
    CyclePosition++;
    if( CyclePosition >= MovePositions.Length )
    {
        if( bRepeatCycling )
            CyclePosition = 0;
        else
            StopCycling();
    }
    RePositionTo( MovePositions[CyclePosition] );
}

//Stop all cycling on this component
function StopCycling()
{
    CyclePosition = -1;
    KillTimer();
}

//Callback when component has finished moving to a MovePosition
event RePositionCompleted()
{
    OnRePositionCompleted(self, TransitionSpec.NewPos.KeyName);
    if( CyclePosition >= 0 && CyclePosition < MovePositions.Length )
        CyclePositions();
}

//Reposition this component to the position specified by the given KeyName
function RePosition( name PositionLabel, optional bool bInstantly )
{
    local int i;
    for( i = 0; i < MovePositions.Length; i++ )
    {
        if( PositionLabel == MovePositions[i].KeyName )
        {
            if( bInstantly )
            {
                bRepositioning = false;
                WinLeft = MovePositions[i].WinLeft;
                WinTop =  MovePositions[i].WinTop;
                WinWidth = MovePositions[i].WinWidth;
                WinHeight = MovePositions[i].WinHeight;
				TransitionSpec.NewPos=MovePositions[i];
                RePositionCompleted();
            }
            else
            {
	            RePositionTo( MovePositions[i] );
            }
            return;
        }
    }
}

//Actually reposition this component to the specified PositionSpec
protected function RePositionTo( sDynamicPositionSpec NewPosition )
{
    TransitionSpec.OldWinLeft=WinLeft;
    TransitionSpec.OldWinTop=WinTop;
    TransitionSpec.OldWinHeight=WinHeight;
    TransitionSpec.OldWinWidth=WinWidth;
    TransitionSpec.NewPos=NewPosition;
    bRepositioning = true;
    if (TransitionSpec.NewPos.TransitionTime > 0)
    SetTimer( TransitionSpec.NewPos.TransitionTime );
    else    //reposition instantly
    {
        bRepositioning = false;
        WinLeft = NewPosition.WinLeft;
        WinTop =  NewPosition.WinTop;
        WinWidth = NewPosition.WinWidth;
        WinHeight = NewPosition.WinHeight;
    	SetDirty();
        RePositionCompleted();
    }
}

function bool IsAtPosition( name PositionLabel )
{
    local int i;
    for( i = 0; i < MovePositions.Length; i++ )
    {
        if( PositionLabel == MovePositions[i].KeyName )
        {
            return( WinLeft == MovePositions[i].WinLeft &&
                    WinTop ==  MovePositions[i].WinTop &&
                    WinWidth == MovePositions[i].WinWidth &&
                    WinHeight == MovePositions[i].WinHeight );
        }
    }
    return false;
}

//tcohen: notification when resolution changes

function RegisterNotifyResolutionChanged()
{
    Controller.RegisterNotifyResolutionChanged(self);
}

function OnResolutionChanged(int OldResolutionX, int OldResolutionY, int ResolutionX, int ResolutionY);

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous
////////////////////////////////////////////////////////////////////////////////
// This control is no longer needed 
event Free( optional bool bForce ) 			
{
    local int i;
    
    if( bPersistent && !bForce )
        return;
    
    bActiveInput = false;
    bVisible = false;
    
    if( Controller != None )
        Controller.RemovePersistentComponent( self );

	MenuOwner 		= None;
    Controller	 	= None;
    FocusInstead 	= None;
    Style			= None;
    
    for( i = 0; i < UndoHistory.Length; i++ )
    {
        UndoHistory[i].Free(bForce);
        UndoHistory[i] = None;
    }
    
    UndoHistory.Remove( 0, UndoHistory.Length );
    
    RadioGroup = None;
}

//utility function to get the player's owner
function PlayerController PlayerOwner()
{
	return Controller.ViewportOwner.Actor;
}

// Force control to use same area as its MenuOwner.
function FillOwner()
{
	WinLeft = 0.0;
	WinTop = 0.0;
	WinWidth = 1.0;
	WinHeight = 1.0;
	bScaleToParent = true;
	bBoundToParent = true;
	SetDirty();
}

//set a new hint for this component
function SetHint(string NewHint)
{
	Hint = NewHint;
}

function SetLinks(GUIComponent cUp,GUIComponent cDown,GUIComponent cLeft,GUIComponent cRight)
{
	Links[0] = cUp;
    Links[1] = cDown;
    Links[2] = cLeft;
    Links[3] = cRight;
}

function SetLinkOverrides(GUIComponent cUp,GUIComponent cDown,GUIComponent cLeft,GUIComponent cRight)
{
	LinkOverrides[0] = cUp;
    LinkOverrides[1] = cDown;
    LinkOverrides[2] = cLeft;
    LinkOverrides[3] = cRight;
}


// The ActualXXXX functions are not viable until after the first render so don't
// use them in inits
native function float ActualWidth();
native function float ActualHeight();
native function float ActualLeft();
native function Float ActualTop();


////////////////////////////////////////////////////////////////////////////////
// Radio Groups
////////////////////////////////////////////////////////////////////////////////
function SetRadioGroup( GUIRadioButton group )
{
    if( RadioGroup != None )
        SetEnabled( RadioGroup == group );
}


////////////////////////////////////////////////////////////////////////////////
// GUI Editor Functions on this component
////////////////////////////////////////////////////////////////////////////////
//save layout to config file
function SaveLayout(bool FlushToDisk)
{
    SaveConfig(
		"", "", // these are needed when IG_GUI_LAYOUT || IG_ACTOR_CONFIG is defined
		FlushToDisk
		, true // dont save config that's the same as the class' default
		);

    bSaved=true;
}

//update the history for this component
function SaveLayoutToHistory()
{
    local int i;
	if( UndoLevel+1 < UndoHistory.length )
	    UndoHistory.Remove(UndoLevel+1,UndoHistory.length-(UndoLevel+1));
    i = UndoHistory.length;
    UndoHistory[i]=new(None) self.class;
    self.CopyConfig( UndoHistory[i] ); //save current config variables to this history component
}

//Update the component from the current undo level in history
function LoadLayoutFromHistory()
{
    UndoHistory[UndoLevel].CopyConfig( self );
    
	Style = Controller.GetStyle(StyleName);
}

//Goes back to the previous history level
function UndoLayout()
{
    assertWithDescription( UndoLevel > 0, "Cannot perform Undo on this component!");
    //log("[dkaplan]: Undoing, UndoLevel="@UndoLevel@"UndoHistory.length="@UndoHistory.length);
    if( UndoLevel > 0 )
    {
        UndoLevel-=1;
        LoadLayoutFromHistory();
    }
}

//Goes foraward to the next history level
function RedoLayout()
{
    assertWithDescription( UndoLevel < UndoHistory.length-1, "Cannot perform Redo on this component!");
    //log("[dkaplan]: Redoing, UndoLevel="@UndoLevel@"UndoHistory.length="@UndoHistory.length);
    if( UndoLevel < UndoHistory.length-1 )
    {
        UndoLevel+=1;
        LoadLayoutFromHistory();
    }
}

//change the style of this component (based of the key name of the style)
event ChangeStyle(String newStyle)
{
    StyleName=newStyle;
	Style = Controller.GetStyle(StyleName);
    OnChangeLayout();
}

//handle layout changes on this component
event OnChangeLayout()
{
    //log("[dkaplan]: in OnChangeLayout-> WinTop="@WinTop@"WinLeft="@WinLeft@"WinWidth="@WinWidth@"WinHeight="@WinHeight);
    //update history
    SetDirty();
#if IG_TRIBES3 // dbeswick: don't undo during player edit
	if( !Controller.bPlayerDesignMode )
	{
    	SaveLayoutToHistory();
    	UndoLevel=UndoHistory.length-1;
	}
#else
    SaveLayoutToHistory();
    UndoLevel=UndoHistory.length-1;
#endif
    bSaved=false;
}

#if IG_TRIBES3	// michaelj:  Added some color-related code from UT2004
// Take a string and strip out colour codes
static function string StripColorCodes(string InString)
{
    local int CodePos;

    CodePos = InStr(InString, Chr(27));
//    while(CodePos != -1 && CodePos < Len(InString)-3) // ignore colour codes at the end of the string
	while ( CodePos != -1 ) // do not ignore color codes at the end of the word, or they aren't stripped
    {
	    InString = Left(InString, CodePos)$Mid(InString, CodePos+4);
        CodePos = InStr(InString, Chr(27));
    }

    return InString;
}
#endif



////////////////////////////////////////////////////////////////////////////////
// Defaults for all GUIComponents
////////////////////////////////////////////////////////////////////////////////

cpptext
{
        virtual void UpdateComponent(UCanvas* Canvas); //Performs an update, refreshing the component's dims, etc.; should be overridden in a subclass
		virtual void PreDraw(UCanvas *Canvas);	// Should be overridden in a subclass
		virtual void Draw(UCanvas* Canvas);		// Should be overridden in a subclass
		void ClientDraw(UCanvas* Canvas);		// Prepare the Canvas for a client to draw on the component, and then call delegateOnClientDraw

        virtual void Modify(); //callback from the object browser

		virtual UBOOL PerformHitTest(INT MouseX, INT MouseY);					// Check to see if a mouse press affects the control
		virtual void  UpdateBounds();											// Updates the Bounds for hit tests and such
		virtual FLOAT ActualWidth();											// Returns the actual width (including scaling) of a component
		virtual FLOAT ActualHeight();											// Returns the actual height (including scaling) of a component
		virtual FLOAT ActualLeft();												// Returns the actual left (including scaling) of a component
		virtual FLOAT ActualTop();												// Returns the actual top (including scaling) of a component
		virtual void  SaveCanvasState(UCanvas* Canvas);							// Save the current state of the canvas
		virtual void  RestoreCanvasState(UCanvas* Canvas);						// Restores the state of the canvas

		virtual UGUIComponent* UnderCursor(FLOAT MouseX, FLOAT MouseY);

		virtual UBOOL MouseMove(INT XDelta, INT YDelta);			// The Mouse has moved
		virtual UBOOL MousePressed(UBOOL IsRepeat);					// The Mouse was pressed
		virtual UBOOL MouseReleased();								// The Mouse was released
		virtual UBOOL MouseHover();									// The Mouse is over a non-pressed thing

		virtual UBOOL NativeKeyType(BYTE& iKey, TCHAR Unicode );				// Handle key presses
		virtual UBOOL NativeKeyEvent(BYTE& iKey, BYTE& State, FLOAT Delta);	// Handle key events

		virtual void SetDims(FLOAT Width, FLOAT Height, FLOAT Left, FLOAT Top);	// Set the dims quickly
		virtual void  CloneDims(UGUIComponent* From);	// Clones the Width,Height, Top, Left settings

		virtual UBOOL SpecialHit();
        virtual UBOOL XControllerEvent(int Id, eXControllerCodes iCode);
        virtual UBOOL RawXController(int Id, BYTE& iKey, BYTE& State, FLOAT Axis);

}


defaultproperties
{
     CyclePosition=-1
     MoveGroup=-1
     bSaved=True
     WinTop=0.400000
     WinLeft=0.400000
     WinWidth=0.200000
     WinHeight=0.200000
     bScaled=True
     bBoundToParent=True
     bScaleToParent=True
     bCanBeShown=True
     bAcceptsInput=True
     RenderWeight=0.500000
     TimerIndex=-1
     bAllowPressedEffect=True
}
