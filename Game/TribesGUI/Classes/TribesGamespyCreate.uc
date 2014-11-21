class TribesGamespyCreate extends TribesGamespyLogin;

var(TribesGui) private EditInline Config GUIEditBox EditConfirm;


function InternalOnShow()
{
	ActionButton.SetEnabled(true);

	//EditNick.SetText("");
	EditEmail.SetText("");
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

	SetTimer(0, False);

	Log("Creating new user account:");

	Log("Nick:  " $ p.playerName);
	Log("Email: " $ EditEmail.GetText());

	gm.OnEmailAlreadyTaken = OnGamespyEmailTaken;
	gm.OnProfileCreateResult = OnGamespyCreateResult;
	gm.CreateUserAccount(p.playerName, EditEmail.GetText(), EditPassword.GetText());

	SetTimer(ActionTimeout, false);
}

private function OnGamespyCreateResult(GameSpyManager.EGameSpyResult result, int profileId)
{
	SetTimer(0, false);

	switch (result)
	{
	case GSR_VALID_PROFILE:
		FillProfile(profileId);
		OpenDlg(GamespyCreateSuccessText, QBTN_Ok, "success");
		break;
	case GSR_BAD_PASSWORD:
		OpenDlg(BadPasswordText, QBTN_Ok);
		break;
	case GSR_BAD_NICK:
		OpenDlg(BadNickText, QBTN_Ok);
		break;
	case GSR_GENERAL_FAILURE:
		OpenDlg(GeneralFailureText, QBTN_Ok);
		break;
	}
}

private function OnGamespyEmailTaken()
{
	OpenDlg(GamespyEmailTakenText, QBTN_Ok);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bVisible && bActiveInput &&
        Key == EInputKey.IK_Tab && State == EInputAction.IST_Press )
    {
		// Manually toggle between edit boxes
		if (EditEmail.MenuState==MSAT_Focused)
			EditPassword.Focus();
		else if (EditPassword.MenuState==MSAT_Focused)
			EditConfirm.Focus();
		else
			EditEmail.Focus();
		return true;
	}

	return super.InternalOnKeyEvent(Key, State, delta);
}

defaultproperties
{
    OnKeyEvent=InternalOnKeyEvent	
}