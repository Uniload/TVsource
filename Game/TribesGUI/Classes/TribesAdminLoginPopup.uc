// ====================================================================
//  Class:  TribesGui.TribesAdminLoginPopup
//  Parent: TribesGUIPage
//
// ====================================================================

class TribesAdminLoginPopup extends TribesGuiPage;

var(TribesGui) private EditInline Config GUIButton	LoginButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			UsernameBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			PasswordBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton	AutologinButton "A component of this page which has its behavior defined in the code for this page's class.";

var PlayerProfile p;

var() editconst noexport string CurrentIP, CurrentPort;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
    CancelButton.OnClick=InternalOnClick;
	LoginButton.OnClick=InternalOnClick;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();
}

function InternalOnShow()
{
	local string str, S, port;
	local int i;

	// Find port
	S = PlayerOwner().Level.GetAddressURL();
	i = InStr( S, ":" );
	port = Mid(S,i+1);

	str = PlayerOwner().GetServerNetworkAddress();

	if ( str != "" )
	{
		if ( !Div(str, ":", CurrentIP, CurrentPort) )
		{
			CurrentIP = str;
			CurrentPort = port;
		}
	}

	i = p.FindCredentials(CurrentIP, CurrentPort);
	if ( i != -1 && p.LoginHistory[i].bAutoLogin )
	{
		UsernameBox.SetText(p.LoginHistory[i].Username);
		PasswordBox.SetText(p.LoginHistory[i].Password);
	}
}

function InternalOnClick(GUIComponent Sender)
{
	switch (Sender)
	{
		case CancelButton:
            Controller.CloseMenu();
            break;

		case LoginButton:
			DoLogin();
			Controller.CloseMenu();
			break;
	}
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bVisible && bActiveInput &&
        Key == EInputKey.IK_Tab && State == EInputAction.IST_Press )
    {
		// Manually toggle between edit boxes
		if (UsernameBox.MenuState==MSAT_Focused)
			PasswordBox.Focus();
		else
			Usernamebox.Focus();
		return true;
	}

	return super.InternalOnKeyEvent(Key, State, delta);
}

function DoLogin()
{
	PlayerOwner().ConsoleCommand("adminlogin "$UsernameBox.GetText()@PasswordBox.GetText());
	if (AutologinButton.bChecked)
	{
		p.bStoreLogins = true;
		p.SaveCredentials(UsernameBox.GetText(), PasswordBox.GetText(), CurrentIP, CurrentPort, true);
	}
}


defaultproperties
{
	OnShow=InternalOnShow
    OnKeyEvent=InternalOnKeyEvent
}