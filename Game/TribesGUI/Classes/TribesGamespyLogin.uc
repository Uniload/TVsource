class TribesGamespyLogin extends TribesGUIPage;

var(TribesGui) protected EditInline Config GUIButton ActionButton;
var(TribesGui) protected EditInline Config GUIButton CancelButton;
var(TribesGui) protected EditInline Config GUIEditBox EditNick;
var(TribesGui) protected EditInline Config GUIEditBox EditEmail;
var(TribesGui) protected EditInline Config GUIEditBox EditPassword;

var(TribesGui) protected EditInline GlobalConfig localized string GamespyConnectingText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyCreateSuccessText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyLoginSuccessText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyEmailTakenText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyTimeoutText;
var(TribesGui) protected EditInline GlobalConfig localized string NoGamespyText;
var(TribesGui) protected EditInline GlobalConfig localized string BadNickText;
var(TribesGui) protected EditInline GlobalConfig localized string BadEmailText;
var(TribesGui) protected EditInline GlobalConfig localized string BadPasswordText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthNickText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthEmailText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthPasswordText;
var(TribesGui) protected EditInline GlobalConfig localized string PasswordMismatchText;
var(TribesGui) protected EditInline GlobalConfig localized string GeneralFailureText;
var(TribesGui) protected EditInline GlobalConfig localized string InvalidCharacterText;
var(TribesGui) protected EditInline GlobalConfig string AcceptedGamespyChars;

var(TribesGui) protected EditInline GlobalConfig int InitTimeout;
var(TribesGui) protected EditInline GlobalConfig int ActionTimeout;

var TribesGameSpyManager	gm;

delegate OnSuccess();
delegate OnCancel();

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OnShow=InternalOnShow;
	OnDlgReturned=InternalPopupOk;

	ActionButton.OnClick = OnAction;
	CancelButton.OnClick = OnCancelButton;
}

function InternalOnShow()
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	ActionButton.SetEnabled(true);
	EditEmail.SetText(p.statTrackingEmail);
	EditPassword.SetText(p.statTrackingPassword);
	EditNick.SetText(p.statTrackingNick);

	SetupGamespyVars();
}

function SetupGamespyVars()
{
	gm = TribesGameSpyManager(PlayerOwner().Level.GetGameSpyManager());

	if (gm == None)
	{
		OpenDlg(NoGamespyText, QBTN_Ok, "fail");
		return;
	}
}

private function InternalPopupOk( int Selection, optional string Passback )
{
	if (Passback == "fail")
	{
		Controller.CloseMenu();
		OnCancel();
	}
	else if (Passback == "success")
	{
		Controller.CloseMenu();
		OnSuccess();
	}
}

private function bool VerifyGamespyInput(string s)
{
	local int i;

	for (i = 0; i < Len(s); i++)
	{
		if (InStr(AcceptedGamespyChars, Mid(s, i, 1)) == -1)
			return false;
	}

	return true;
}

protected function bool Validate()
{
	local string firstCharCheck;

	//if (!VerifyGamespyInput(EditNick.GetText()) || EditNick.GetText() == "")
	//{
	//	OpenDlg(BadNickText, QBTN_Ok);
	//	return false;
	//}

	if (HasUnicode(EditEmail) || EditEmail.GetText() == "" || InStr(EditEmail.GetText(), "@") == -1 || InStr(EditEmail.GetText(), ".") == -1)
	{
		OpenDlg(BadEmailText, QBTN_Ok);
		return false;
	}

	firstCharCheck = Left(EditEmail.GetText(), 1);
	if (firstCharCheck == "@" || firstCharCheck == "+" || firstCharCheck == ":" || firstCharCheck == "#")
	{
		OpenDlg(InvalidCharacterText, QBTN_Ok);
		return false;
	}
	
	if (!VerifyGamespyInput(EditPassword.GetText()) || EditPassword.GetText() == "")
	{
		OpenDlg(BadPasswordText, QBTN_Ok);
		return false;
	}

	return true;
}

private function OnAction(GUIComponent Sender)
{
	ActionButton.SetEnabled(false);

	if (Validate())
	{
		// send login test to gamespy, initializing service if necessary
		if (gm.bInitAsClient && gm.bPresenceInitalised)
		{
			OnPerformGamespyAction();
		}
		else
		{
			gm.OnGameSpyPresenceInitialised = OnPerformGamespyAction;
			gm.InitGameSpyClient();
			SetTimer(InitTimeout, False);
		}
	}
}

private function OnCancelButton(GUIComponent Sender)
{
	OnCancel();
	Controller.CloseMenu();
}

event Timer()
{
	OnGamespyTimeout();
}

private function OnGamespyTimeout()
{
	OpenDlg(GamespyTimeoutText, QBTN_Ok);
}

private function GamespyLogin()
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	Log("Checking user account:");

	//Log("Nick:     " $ EditNick.GetText());
	Log("Email:    " $ EditEmail.GetText());

	gm.OnProfileCheckResult = OnGamespyLoginResult;
	gm.CheckUserAccount(p.playerName, EditEmail.GetText(), EditPassword.GetText());
	SetTimer(ActionTimeout, false);
}

private function OnGamespyLoginResult(GameSpyManager.EGameSpyResult result, int profileId)
{
	SetTimer(0, false);

	switch (result)
	{
	case GSR_VALID_PROFILE:
		FillProfile(profileId);
		OpenDlg(GamespyLoginSuccessText, QBTN_Ok, "success");
		break;
	case GSR_BAD_PASSWORD:
		OpenDlg(BadAuthPasswordText, QBTN_Ok);
		break;
	case GSR_BAD_NICK:
		OpenDlg(BadAuthNickText, QBTN_Ok);
		break;
	case GSR_BAD_EMAIL:
		OpenDlg(BadAuthEmailText, QBTN_Ok);
		break;
	}
}

protected function FillProfile(int id)
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	p.statTrackingID = id;
	p.statTrackingNick = p.playerName;
	p.statTrackingEmail = EditEmail.GetText();
	p.statTrackingPassword = EditPassword.GetText();
}

protected function OnPerformGamespyAction()
{
	GamespyLogin();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bVisible && bActiveInput &&
        Key == EInputKey.IK_Tab && State == EInputAction.IST_Press )
    {
		// Manually toggle between edit boxes
		if (EditEmail.MenuState==MSAT_Focused)
			EditPassword.Focus();
		else
			EditEmail.Focus();
		return true;
	}

	return super.InternalOnKeyEvent(Key, State, delta);
}

defaultproperties
{
	BadNickText="The nickname you entered is invalid or contains invalid characters."
	BadEmailText="The email address you entered is invalid."
	BadPasswordText="The password you entered is invalid."
	PasswordMismatchText="The 'Password' and 'Confirm Password' fields must match."
	AcceptedGamespyChars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789[]\\`_^{|}-"
	NoGamespyText="Error: could not initialize the Gamespy service."
	GamespyTimeoutText="Error: a request to the Gamespy service timed out."
	GamespyEmailTakenText="Error: the email you entered has already been registered to another user. Please enter a different email or log-in with your existing account."
	GamespyCreateSuccessText="Your stat-tracking account has been created."
	GamespyLoginSuccessText="You successfully logged in to the stat-tracking service."
	BadAuthNickText="An account with that nickname was not found. Please enter a valid nickname or create a new account."
	BadAuthEmailText="An account with that email address was not found. Please enter a valid email address or create a new account."
	BadAuthPasswordText="The password is not correct for that account. Please enter the correct password or create a new account."
	GeneralFailureText="There was an error while performing the requested operation."
	GamespyConnectingText="Connecting to Gamespy..."
	InvalidCharacterText="The first letter of your email login is invalid.  Please change it."

    OnKeyEvent=InternalOnKeyEvent
	
	InitTimeout=20
	ActionTimeout=30
}