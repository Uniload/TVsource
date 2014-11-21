// ====================================================================
//  Class:  TribesGui.TribesCreditsMenu
//  Parent: TribesGUIPage
//
//  Menu to display Tribes Credits.
// ====================================================================

class TribesCreditsMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		MyEscapeButton;

var(TribesGui) private EditInline Editconst array<GUILabel>  Credits;

var(CREDITS) private config float ScrollDelay;
var(CREDITS) private config float InitialDelay;
var(CREDITS) private config float RepeatDelay;
var(CREDITS) private config sDynamicPositionSpec InitialPlacement;
var(CREDITS) private config sDynamicPositionSpec FinalPlacement;

var(CREDITS) private int NextToStartScrolling;

function InitComponent(GUIComponent MyOwner)
{
    local int i;
    local TribesCredits CreditObj;
        
    Super.InitComponent(MyOwner);

    MyEscapeButton.OnClick=InternalOnClick;
    
    CreditObj = new() class'TribesCredits';
	//Log("Successfully created CreditObj "$CreditObj);

    assertWithDescription( CreditObj.CreditLines.Length == CreditObj.CreditLineStyles.Length, "The number of lines of credits specified in TribesCredits.ini does not match the number of styles!" );

    for( i = 0; i < CreditObj.CreditLines.Length; i++ )
    {
        Credits[i] = GUILabel(AddComponent("GUI.GUILabel",self.Name$"_"$i$"_Label",true));
        Assert( Credits[i] != None );
        Credits[i].SetCaption( CreditObj.CreditLines[i] );
        Credits[i].StyleName = CreditObj.CreditLineStyles[i];
        Credits[i].Style = Controller.GetStyle( CreditObj.CreditLineStyles[i] );

        Credits[i].MovePositions[0] = FinalPlacement;
        Credits[i].MovePositions[1] = InitialPlacement;
        Credits[i].RePosition( InitialPlacement.KeyName, true );
        Credits[i].OnRePositionCompleted = InternalOnRePositionCompleted;
		Credits[i].Hide();

        Credits[i].TextAlign = TXTA_Center;
        Credits[i].bAllowHTMLTextFormatting=true;
    }
}


private function InternalOnShow()
{
    if( Credits.Length < 1 )
        return;
    NextToStartScrolling = 0;
    SetTimer( InitialDelay );
}

private function InternalOnHide()
{
    local int i;
    
    for( i = 0; i < Credits.Length; i++ )
    {
        Credits[i].RePosition( InitialPlacement.KeyName, true );
    }
}

event Timer()
{
    ScrollNext();
}

private function ScrollNext()
{
//log("ScrollingNext: " $ NextToStartScrolling);
    if( NextToStartScrolling >= Credits.Length )
    {
        ScrollingCompleted();
        return;
    }
	Credits[NextToStartScrolling].Show();
    Credits[NextToStartScrolling].RePosition( FinalPlacement.KeyName );
    NextToStartScrolling++;
    SetTimer( ScrollDelay );
}

private function InternalOnRePositionCompleted( GUIComponent Sender, name NewPosLabel )
{
    if( NewPosLabel == FinalPlacement.KeyName )
        Sender.RePosition( InitialPlacement.KeyName, true );
}

private function ScrollingCompleted()
{
//log("ScrollingCompleted");
    NextToStartScrolling = 0;
    SetTimer( RepeatDelay );
}

////////////////////////////////////////////////////////////////////////////////////
// Component Management
////////////////////////////////////////////////////////////////////////////////////
private function InternalOnClick(GUIComponent Sender)
{
    Close();
}

private function Close()
{
	SetTimer(0);
    Controller.CloseMenu();

	// MJ:  This call to Free prevents the Timer() function from working if the menu
	// is opened a second time
    //Free( true );
}

////////////////////////////////////////////////////////////////////////////////////
// Component Cleanup
////////////////////////////////////////////////////////////////////////////////////
event Free( optional bool bForce) 			
{
	local int i;
	
    for (i=0;i<Credits.Length;i++)
        Credits[i] = None;
    Credits.Remove(0,Credits.Length);

    MyEscapeButton=None;

    Super.Free( bForce );
}


defaultproperties
{
	OnShow=InternalOnShow
	OnHide=InternalOnHide
	
	ScrollDelay=1
	InitialDelay=1
	RepeatDelay=1
}