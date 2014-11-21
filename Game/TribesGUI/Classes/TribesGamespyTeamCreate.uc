class TribesGamespyTeamCreate extends TribesGamespyTeamLogin;

var(TribesGui) private EditInline Config GUIEditBox EditTeamName;
var(TribesGui) private EditInline Config GUIEditBox EditConfirm;

function InternalOnShow()
{
	ActionButton.SetEnabled(true);

	EditTeamTag.SetText("");
	EditPassword.SetText("");
	EditConfirm.SetText("");

	SetupGamespyVars();
}

protected function bool Validate()
{
	if (!Super.Validate())
		return false;

	if (EditPassword.GetText() != EditConfirm.GetText())
	{
		OpenDlg(PasswordMismatchText, QBTN_Ok);
		return false;
	}

	return true;
}

protected function OnPerformGamespyAction()
{
	GamespyCreateAccount();
}

private function GamespyCreateAccount()
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	gm.OnProfileAuthError = OnGamespyProfileAuthError;
	gm.OnTeamTagTaken = OnGamespyTeamTagTaken;
	gm.OnTeamRegistrationError = OnGamespyTeamRegistrationError;
	gm.OnTeamCreated = OnGamespyTeamCreated;

	// TODO: if p.statTrackingPassword is "" need to prompt user for password

	Log("Nick:     " $ p.statTrackingNick);
	Log("Email:    " $ p.statTrackingEmail);
	Log("TeamTag:  " $ EditTeamTag.GetText());
	Log("TeamName: " $ EditTeamName.GetText());

	gm.CreateTeam(p.statTrackingNick, p.statTrackingEmail, p.statTrackingPassword,
			   EditTeamTag.GetText(), EditTeamName.GetText(), EditPassword.GetText());

	SetTimer(ActionTimeout, false);
}

private function OnGamespyProfileAuthError()
{
	SetTimer(0, false);
	OpenDlg(BadParamText, QBTN_Ok);
}

private function OnGamespyTeamTagTaken()
{
	SetTimer(0, false);
	OpenDlg(GamespyTeamTagTakenText, QBTN_Ok);
}

private function OnGamespyTeamRegistrationError()
{
	SetTimer(0, false);
	OpenDlg(RegistrationError, QBTN_Ok);
}

private function OnGamespyTeamCreated()
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	SetTimer(0, false);

	p.ownedTeamTag = EditTeamTag.GetText();
	p.ownedTeamName = EditTeamName.GetText();

	OpenDlg(GamespyCreateSuccessText, QBTN_Ok, "success");
}

defaultproperties
{
}