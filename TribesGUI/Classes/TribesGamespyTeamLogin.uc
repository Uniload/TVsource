class TribesGamespyTeamLogin extends TribesGUIPage;

var(TribesGui) protected EditInline Config GUIButton ActionButton;
var(TribesGui) protected EditInline Config GUIButton CancelButton;

var(TribesGui) protected EditInline Config GUIEditBox EditTeamTag;
var(TribesGui) protected EditInline Config GUIEditBox EditPassword;

var(TribesGui) protected EditInline GlobalConfig localized string GamespyConnectingText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyCreateSuccessText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyLoginSuccessText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyTeamTagTakenText;
var(TribesGui) protected EditInline GlobalConfig localized string GamespyTimeoutText;
var(TribesGui) protected EditInline GlobalConfig localized string NoGamespyText;
var(TribesGui) protected EditInline GlobalConfig localized string BadTeamNameText;
var(TribesGui) protected EditInline GlobalConfig localized string BadTeamTagLength;
var(TribesGui) protected EditInline GlobalConfig localized string BadTeamTagText;
var(TribesGui) protected EditInline GlobalConfig localized string BadPasswordText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthTeamTagText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthPasswordText;
var(TribesGui) protected EditInline GlobalConfig localized string BadParamText;
var(TribesGui) protected EditInline GlobalConfig localized string PasswordMismatchText;
var(TribesGui) protected EditInline GlobalConfig localized string NoResponse;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthText;
var(TribesGui) protected EditInline GlobalConfig localized string RegistrationError;

var(TribesGui) protected EditInline GlobalConfig string AcceptedGamespyChars;

var(TribesGui) protected EditInline GlobalConfig int InitTimeout;
var(TribesGui) protected EditInline GlobalConfig int ActionTimeout;

var TribesGameSpyManager	gm;

var int teamId;

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

	EditTeamTag.SetText(p.affiliatedTeamTag);
	EditPassword.SetText(p.affiliatedTeamPassword);

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
	if (Len(EditTeamTag.GetText()) > 8)
	{
		OpenDlg(BadTeamTagLength, QBTN_Ok);
		return false;
	}

	if (EditTeamTag.GetText() == "" || !VerifyGamespyInput(EditTeamTag.GetText()))
	{
		OpenDlg(BadTeamTagText, QBTN_Ok);
		return false;
	}
	
	if (EditPassword.GetText() == "" || !VerifyGamespyInput(EditPassword.GetText()))
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

private function OnGamespyFindTeamResult(int foundTeamId)
{
	if (foundTeamId != 0)
	{
		teamId = foundTeamId;
		StartLogin();
	}
	else
	{
		OpenDlg(BadAuthTeamTagText, QBTN_Ok);
	}
}

private function StartLogin()
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	Log("Logging in team:");
	Log("ProfileId: " $ p.statTrackingID);
	Log("TeamId:    " $ teamId);
	Log("TeamTag:   " $ EditTeamTag.GetText());

	gm.OnLoginTeamResult = OnGamespyTeamLoginResult;
	gm.LoginTeam(p.statTrackingID, teamId, EditPassword.GetText(), false);

	SetTimer(ActionTimeout, false);
}

private function GamespyLogin()
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (p.affiliatedTeamId == 0 || EditTeamTag.GetText() != p.affiliatedTeamTag)
	{
		Log("Searching for team:");
		Log("TeamTag: " $ EditTeamTag.GetText());

		gm.OnFindTeamResult = OnGamespyFindTeamResult;
		gm.FindTeam(EditTeamTag.GetText());

		SetTimer(ActionTimeout, false);
	}
	else
	{
		teamId = p.affiliatedTeamId;
		StartLogin();
	}
}

private function OnGamespyTeamLoginResult(bool succeeded, String ResponseData)
{
	local string teamTag;
	local string teamName;

	SetTimer(0, false);

	if (succeeded)
	{
		if (ResponseData == "INVALID PASSWORD")
		{
			OpenDlg(BadAuthPasswordText, QBTN_Ok);
		}
		else if (ResponseData == "INVALID PARAMETER")
		{
			OpenDlg(BadParamText, QBTN_Ok);
		}
		else
		{
			Div(ResponseData, "|", teamTag, teamName);

			FillProfile(teamTag, teamName);

			OpenDlg(GamespyLoginSuccessText, QBTN_Ok, "success");
		}
	}
	else
	{
		OpenDlg(NoResponse, QBTN_Ok);
	}
}

protected function FillProfile(string teamTag, string teamName)
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	p.affiliatedTeamId = teamId;
	p.affiliatedTeamTag = teamTag;
	p.affiliatedTeamName = teamName;
	p.affiliatedTeamPassword = EditPassword.GetText();
}

protected function OnPerformGamespyAction()
{
	GamespyLogin();
}

defaultproperties
{
	BadTeamNameText="The team name you entered is invalid."
	BadTeamTagLength="The team tag can not be longer than eight characters."
	BadTeamTagText="The team tag you entered is invalid."
	BadPasswordText="The password you entered is invalid."
	PasswordMismatchText="The 'Password' and 'Confirm Password' fields must match."
	AcceptedGamespyChars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789[]\\`_^{|}-"
	NoGamespyText="Error: could not initialize the Gamespy service."
	GamespyTimeoutText="Error: a request to the Gamespy service timed out."
	GamespyTeamTagTakenText="Error: the tag you entered has already been registered to another user."
	GamespyCreateSuccessText="Your team has been created."
	GamespyLoginSuccessText="You successfully logged in to your team."
	BadAuthTeamTagText="Team login failed: A team with that tag was not found. Please enter a valid team tag or create a new team."
	BadAuthPasswordText="Team login failed: The password is not correct for that team."
	BadParamText="Team login failed: A bad parameter was sent to the server."
	NoResponse="Team login failed: Unable to get a response from the team login server"
	GamespyConnectingText="Connecting to Gamespy..."
	BadAuthText="Unable to authenticate profile."
	RegistrationError="Error: unable to register team details."
	
	InitTimeout=20
	ActionTimeout=30
}