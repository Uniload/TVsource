// ====================================================================
//  Class:  TribesGui.TribesKeyMappingPopup
//  Parent: TribesGUIPage
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesKeyMappingPopup extends TribesGuiPage
     ;

var(TribesGui) private EditInline Config GUILabel   MyTitleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	MyCancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var String      Passback;       //passback string
var int         SortingOrder;
var GUIListElem theElem;
var bool		bAllowKeys;
var string		key;

var() private EditInline Config array<string> RestrictedKeys; //keys which are restricted and cannot be remapped

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	OnShow=InternalOnShow;
}

function InternalOnShow()
{
	bAllowKeys = false;
	SetTimer(0.25, false);
	key = "";
    
    MyCancelButton.OnClick=InternalOnClick;
}

function Timer()
{
	bAllowKeys = true;
}

private function bool IsRestricted( string key )
{
    local int i;
    for( i = 0; i < RestrictedKeys.Length; i++ )
    {
        if( RestrictedKeys[i] ~= key )
            return true;
    }
    return false;
}

function InternalOnActivate()
{
//log("[dkaplan]: in internalOnActivate()");
    Controller.OnNeedRawKeyPress=InternalOnRawKeyPress;
}

function InternalOnDeActivate()
{
//log("[dkaplan]: in internalOnDeActivate(), ParentPage = "$ParentPage);
    Controller.OnNeedRawKeyPress=None; //dkaplan: doesn't seem to unset the delegate, why?
}

event HandleParameters(string Param1, string Param2, optional int param3)
{
    MyTitleLabel.Caption = Param1;
    Passback = Param2;
    SortingOrder = Param3;
}

function InternalOnClick(GUIComponent Sender)
{
    Controller.CloseMenu();
}

//function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
//function bool InternalOnKeyType(out byte Key, optional string Unicode)
function bool InternalOnRawKeyPress(byte NewKey)
{
    local string iKey;
    if( !bActiveInput )
        return false;

	if (!bAllowKeys)
		return false;

	iKey = PlayerOwner().ConsoleCommand("KEYNAME"@NewKey);
	if (IsRestricted(iKey))
		return false;
//log( "[dkaplan] key pressed (and returned via InternalOnRawKeyPress): NewKey="$NewKey$", iKey="$iKey);
	if (NewKey == EInputKey.IK_LeftMouse)
	{
		if (MyCancelButton.MenuState == MSAT_Pressed)
		{
			InternalOnClick(MyCancelButton);
			return false;
		}
	}

	theElem = CreateElement(Passback,,iKey,SortingOrder);
	Controller.ParentPage().OnPopupReturned( theElem, Passback );
	Controller.CloseMenu();

	return true;
}


defaultproperties
{
    OnActivate=InternalOnActivate
    OnDeActivate=InternalOnDeActivate
	RestrictedKeys=("Unknown5B","Unknown5D","PrintScrn","Pause","ScrollLock")
}