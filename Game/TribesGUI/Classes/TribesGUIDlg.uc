// ====================================================================
//  Class:  TribesGUIDlg
//
//	GUIDlg s are quick popup menus with simple yes/no type questions and
//   a text string
//
//  Written by Dan Kaplan
//  (c) 2003, Irrational Games, Inc.  All Rights Reserved
// ====================================================================

class TribesGUIDlg extends GUI.GUIDlg;

var(TribesGui)	Material borderMaterial;
var GUIImage borderImage;

var localized string OKText;
var localized string YesText;
var localized string ContinueText;
var localized string RetryText;
var localized string IgnoreText;
var localized string NoText;
var localized string AbortText;
var localized string CancelText;

#exec LOAD FILE=GUITribes.pkg

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
	MyLabel.bMultiLine=true;

	borderImage=GUIImage(AddComponent( "GUI.GUIImage", self.Name$"_borderImage", true));
	Assert( borderImage != None);
	borderImage.bScaleToParent=false;
	borderImage.Image=borderMaterial;
	borderImage.ImageStyle=ISTY_Stretched;
	borderImage.WinWidth=WinWidth;
	borderImage.WinHeight=WinHeight;
	borderImage.WinLeft=0;
	borderImage.WinTop=0;
	borderImage.bSwallowAllKeyEvents=true;
	borderImage.bAcceptsInput=true;
	borderImage.bCaptureMouse=true;

    Passback = thePassback;
    if( (Options & QBTN_Ok) != 0 || Options == 0 )
        AddButton( QBTN_Ok, OKText );
    if( (Options & QBTN_Yes) != 0 )
        AddButton( QBTN_Yes, YesText );
    if( (Options & QBTN_Continue) != 0 )
        AddButton( QBTN_Continue, ContinueText );
    if( (Options & QBTN_Retry) != 0 )
        AddButton( QBTN_Retry, RetryText );
    if( (Options & QBTN_Ignore) != 0 )
        AddButton( QBTN_Ignore, IgnoreText );
    if( (Options & QBTN_No) != 0 )
        AddButton( QBTN_No, NoText );
    if( (Options & QBTN_Abort) != 0 )
        AddButton( QBTN_Abort, AbortText );
    if( (Options & QBTN_Cancel) != 0 )
        AddButton( QBTN_Cancel, CancelText );
        
    //focus the last button by default
    //MyButtons[MyButtons.Length-1].Focus();
    
    if( TimeOut > 0 )
        SetTimer( TimeOut );

//	Background=Texture'GUITribes.BackgroundBlack';
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
	theButton.StyleName = "STY_RoundButton";
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
	SetFocusInstead(None);
    MyLabel=None;
    MyButtons.Remove( 0, MyButtons.Length );
    for( i = Controls.length-1; i >= 0 ; i-- )
    {
        RemoveComponent(Controls[i]);
    }
    //ensure controls array is emptied
    Controls.Remove( 0, Controls.Length );
    Super.DeActivate();

    //remove the dialog after it has been closed and processed
    GUIMultiComponent(MenuOwner).RemoveComponent( self );
}

defaultproperties
{
	WinWidth=0.7
	WinHeight=0.35
	WinLeft=0.15
	WinTop=0.35

    RenderWeight=0.999
    ButtonPercentX=0.4
    ButtonPercentY=0.3
	bAcceptsInput=true
	bPersistent=false
	bScaleToParent=false
	bBoundToParent=false
	bSwallowAllKeyEvents=true
	borderMaterial=Material'GUITribes.DialogueBox'

    OKText="OK"
    YesText="Yes"
    ContinueText="Continue"
    RetryText="Retry"
    IgnoreText="Ignore"
    NoText="No"
    AbortText="Abort"
    CancelText="Cancel"
}