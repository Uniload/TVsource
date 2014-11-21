// ====================================================================
//  Class:  GUI.GUIDlg
//
//	GUIDlg s are quick popup menus with simple yes/no type questions and
//   a text string
//
//  Written by Dan Kaplan
//  (c) 2003, Irrational Games, Inc.  All Rights Reserved
// ====================================================================

class GUIDlg extends GUIPanel
	Native;


cpptext
{
	void PreDraw(UCanvas* Canvas);
	void UpdateComponent(UCanvas* Canvas);
}


var   GUILabel                MyLabel;    // Caption for the popup
var array<GUIButton>        MyButtons;
var         string                  Passback;   // passback to parent page
var         int                     Selection;  // what button was pressed on the dialogue
var(GUIDlg) config float ButtonPercentX "X percentage of space to be used by the buttons";
var(GUIDlg) config float ButtonPercentY "Y percentage of space to be used by the buttons";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
}

//note that this MUST be called before the first PreDraw of this component
function SetupDlg(string theCaption, string thePassback, int Options, optional float TimeOut)
{
    //since this Dialog is dynamically created, the label should be also
	MyLabel=GUILabel(AddComponent( "GUI.GUILabel" , self.Name$"_CaptionLabel", true));
    Assert( MyLabel != None );

    MyLabel.SetCaption( theCaption );
	MyLabel.TextAlign=TXTA_Center;
#if IG_TRIBES3 // dbeswick:
	MyLabel.bMultiline = true;
	MyLabel.WinWidth = WinWidth * 0.95f;
	MyLabel.WinHeight = WinHeight * 0.33f;
#endif

    Passback = thePassback;
    if( (Options & QBTN_Ok) != 0 || Options == 0 )
        AddButton( QBTN_Ok, "OK" );
    if( (Options & QBTN_Yes) != 0 )
        AddButton( QBTN_Yes, "Yes" );
    if( (Options & QBTN_Continue) != 0 )
        AddButton( QBTN_Continue, "Continue" );
    if( (Options & QBTN_Retry) != 0 )
        AddButton( QBTN_Retry, "Retry" );
    if( (Options & QBTN_Ignore) != 0 )
        AddButton( QBTN_Ignore, "Ignore" );
    if( (Options & QBTN_No) != 0 )
        AddButton( QBTN_No, "No" );
    if( (Options & QBTN_Abort) != 0 )
        AddButton( QBTN_Abort, "Abort" );
    if( (Options & QBTN_Cancel) != 0 )
        AddButton( QBTN_Cancel, "Cancel" );
        
    //focus the last button by default
    //MyButtons[MyButtons.Length-1].Focus();
    
    if( TimeOut > 0 )
        SetTimer( TimeOut );
    SetDirty();
}

function AddButton( int inValue, string inCaption )
{
    local GUIButton theButton;
    theButton = GUIButton(AddComponent("GUI.GUIButton",self.Name$"_"$inCaption, true));
    MyButtons[MyButtons.Length]=theButton;
    theButton.SetCaption( inCaption );
    theButton.Value = inValue;
    theButton.OnClick = InternalOnClick;
    theButton.EnableComponent();
}

function InternalOnClick(GUIComponent Sender)
{
    Selection = GUIButton(Sender).Value;
    GUIPage(MenuOwner).DlgReturned( self );
}

event Timer()
{
    Selection = QBTN_TimeOut;
    GUIPage(MenuOwner).DlgReturned( self );
}

event DeActivate()
{
    local int i;
    KillTimer();
    MyLabel=None;
    MyButtons.Remove( 0, MyButtons.Length );
    for( i = Controls.length-1; i >= 0 ; i-- )
    {
        RemoveComponent(Controls[i]);
    }
    //ensure controls array is emptied
    Controls.Remove( 0, Controls.Length );
    Super.DeActivate();
}

defaultproperties
{
	WinWidth=0.8
	WinHeight=0.4
	WinLeft=0.1
	WinTop=0.3

    RenderWeight=0.999
    ButtonPercentX=0.4
    ButtonPercentY=0.2
	bAcceptsInput=true
	bPersistent=false
    StyleName="STY_DialogPanel"
    bDrawStyle=True
}