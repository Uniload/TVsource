class TribesPatchCheck extends TribesGUIPage
	native;

var(TribesGui) protected EditInline Config GUIButton YesButton;
var(TribesGui) protected EditInline Config GUIButton NoButton;
var(TribesGui) protected EditInline Config GUIButton OKButton;
var(TribesGui) protected EditInline Config GUILabel StatusLabel;
var(TribesGui) protected EditInline Config GUILabel URLLabel;

var(TribesGui) protected EditInline GlobalConfig localized string PatchCheckingText;
var(TribesGui) protected EditInline GlobalConfig localized string NewVersionText;
var(TribesGui) protected EditInline GlobalConfig localized string UpToDateText;
var(TribesGui) protected EditInline GlobalConfig localized string URLFailedText;

var(TribesGui) protected EditInline GlobalConfig int CheckTimeout		"Gamespy timeout";

var TribesGameSpyManager	gm;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OnShow=InternalOnShow;
}

function InternalOnShow()
{
	gm = TribesGameSpyManager(PlayerOwner().Level.GetGameSpyManager());

	if (gm == None)
	{
		log("Failed patch check: no gamespy manager");
		Controller.CloseMenu();
		return;
	}

	YesButton.OnClick = OnYes;
	NoButton.OnClick = OnNo;
	OKButton.OnClick = OnNo;
	YesButton.bCanBeShown = false;
	YesButton.Hide();
	NoButton.bCanBeShown = false;
	NoButton.Hide();
	OKButton.bCanBeShown = false;
	OKButton.Hide();
	URLLabel.Caption = "";
	StatusLabel.Caption = PatchCheckingText;

	gm.OnQueryPatchResult = OnQueryPatchResult;
	gm.QueryPatch();
	SetTimer(CheckTimeout, false);
}

function Timer()
{
	log("Failed patch check: gamespy timeout");
	Controller.CloseMenu();
}

function OnQueryPatchResult(bool bNeeded, bool bMandatory, string versionName, string URL)
{
	SetTimer(0);

	if (!bNeeded)
	{
		StatusLabel.Caption = UpToDateText;
		OKButton.bCanBeShown = true;
		OKButton.Show();
	}
	else
	{
		YesButton.bCanBeShown = true;
		YesButton.Show();
		NoButton.bCanBeShown = true;
		NoButton.Show();
		StatusLabel.Caption = NewVersionText;
		URLLabel.Caption = URL;
	}
}

native function OnYes(GUIComponent Sender);

event OnURLFailed(string Error)
{
	OpenDlg(replaceStr(URLFailedText, Error), QBTN_Ok, "1");
}

function OnNo(GUIComponent Sender)
{
	Controller.CloseMenu();
}


defaultproperties
{
	PatchCheckingText="Checking for an updated version of Tribes: Vengeance..."
	UpToDateText="You already have the latest version of Tribes: Vengeance."
	NewVersionText="An updated version of Tribes: Vengeance has been released. You must install an update in order to play online. Would you like to download the update now at the location below?"
	URLFailedText="An error occurred while browsing to the URL: %1"
	CheckTimeout=10
}