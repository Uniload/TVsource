// ====================================================================
//  Class:  TribesGui.TribesMissionLoadingMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMissionLoadingMenu extends TribesGUIPage
     native;

var(TribesGui) private EditInline Config GUILabel	descriptionLabel	"Used for map description in SP, game type description in MP.";
var(TribesGui) private EditInline Config GUILabel	titleLabel			"Used to display the map title in SP, map title and game type in MP.";
var(TribesGui) private EditInline Config GUIImage	screenshotImage		"Used to display a screenshot of the map, stored in LevelSummary.";
var(TribesGUI) private EditInline Config Material	defaultImage;
var(TribesGUI) private EditInline Config Material	defaultFrameImage;
var(TribesGUI) private EditInline Config GUIImage	frameImage;
var(TribesGui) private EditInline Config GUILabel	hintLabel			"Used to display hints in MP.";
var(TribesGui) private EditInline Config GUIProgressBar MissionLoadingProgressBar;

var() color HintColor;
var() color BindColor;

var localized string connectingText;
var string defaultLabel;
var string defaultTitle;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OnKeyEvent = InternalOnKey;

	defaultLabel = "";
	defaultTitle = "";
	defaultImage = screenshotImage.Image;
}

function bool InternalOnKey(out byte Key, out byte State, float delta)
{
	if (key==EInputKey.IK_Escape)
	{
		Controller.ConsoleCommand("ABORTCONNECT");
	}

	return true;
}

function InternalOnShow()
{
	local LevelSummary L;
	local String URL;
	local class<GameInfo> G;
	local String gameClassStr;
	local int gStart;
	local int gEnd;

	L = GC.CurrentLevelSummary;
	hintLabel.Caption = "";

	if (L == None)
	{
		Log("The map doesn't have a LevelSummary");
		
		descriptionLabel.Caption = defaultLabel;
		titleLabel.Caption = defaultTitle;
		screenshotImage.Image = defaultImage;
	}
	else
	{
		descriptionLabel.Caption = L.Description;
		titleLabel.Caption = L.Title;

		if (L.Screenshot != None)
			screenshotImage.Image = L.Screenshot;
	}

	URL = Caps(GC.CurrentURL);

	// check if description must be obtained from gametype (in mp game)
	gStart = InStr(URL, "GAME=");
	frameImage.Image = None;
	if (gStart != -1)
	{
		gameClassStr = Mid(URL, gStart + 5);
		gEnd = InStr(gameClassStr, "?");
		if (gEnd != -1)
			gameClassStr = Left(gameClassStr, gEnd);

		LOG("Retrieving info for game type"@gameClassStr);
		G = class<GameInfo>(DynamicLoadObject(gameClassStr, class'Class'));
		if (G != None && class<MultiplayerGameInfo>(G) != None)
		{
			titleLabel.Caption @= "-"@G.default.GameName;
			descriptionLabel.Caption = G.default.GameDescription;
			hintLabel.Caption = class<MultiplayerGameInfo>(G).static.GetLoadingHint(PlayerOwner(), HintColor, BindColor);
			frameImage.Image = defaultFrameImage;
		}
	}
}

event HandleParameters( string Param1, string Param2, optional int param3)
{
	// multiplayer connection
	if (Param1 != "")
	{
		titleLabel.Caption = "";
		descriptionLabel.Caption = replaceStr(connectingText, Param1);
		screenshotImage.Image = defaultImage;
		hintLabel.Caption = "";

		MissionLoadingProgressBar.bCanBeShown = false;
		MissionLoadingProgressBar.Hide();
	}
	else
	{
		MissionLoadingProgressBar.bCanBeShown = true;
		MissionLoadingProgressBar.Show();
	}
}

function OnProgress(string Str1, string Str2)
{
	MissionLoadingProgressBar.Value = float(Str1);
	if (Controller != None)
		Controller.PaintProgress();
}

defaultproperties
{
	OnShow=InternalOnShow
	connectingText="Connecting to %1... (Press ESC to cancel)";
	bHideMouseCursor=true
	HintColor	= (R=255,G=255,B=255)
	BindColor	= (R=255,G=255,B=255)
}
