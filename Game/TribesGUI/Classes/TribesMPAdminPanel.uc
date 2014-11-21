// ====================================================================
//  Class:  TribesGui.TribesMPAdminPanel
// ====================================================================

class TribesMPAdminPanel extends TribesMPEscapePanel;

var(TribesGui) private EditInline Config GUIListBox		    MapListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox		    GameTypeListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    SwitchButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RestartButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox         TimeLimitBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TimeLimitLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    UpdateButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    LoginButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    TournamentButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    VoteMapChangeButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton			VoteTournamentButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    StatusLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton			ForceStartButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton			TeamDamageButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton			VoteTeamDamageButton "A component of this page which has its behavior defined in the code for this page's class.";

var localized string loginString;
var localized string logoutString;
var localized string tourneyString;
var localized string publicString;
var localized string enableTeamDamageString;
var localized string disableTeamDamageString;
var localized string voteTeamDamageOnString;
var localized string voteTeamDamageOffString;
var localized string voteTourneyString;
var localized string votePublicString;

var bool bInitialized;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	LoginButton.OnClick=OnLoginClick;
	SwitchButton.OnClick=OnSwitchClick;
	RestartButton.OnClick=OnRestartClick;
	UpdateButton.OnClick=OnUpdateClick;
	VoteMapChangeButton.OnClick=OnVoteMapChangeClick;
	VoteTournamentButton.OnClick=OnVoteTournamentClick;
	ForceStartButton.OnClick=OnForceStartClick;
	TournamentButton.OnClick=OnTournamentClick;
	TeamDamageButton.OnClick=OnTeamDamageClick;
	VoteTeamDamageButton.OnClick=OnVoteTeamDamageClick;
	GameTypeListBox.List.OnChange=GameTypeListOnChange;

	OnActivate=InternalOnActivate;
	OnShow=InternalOnShow;
	OnHide=InternalOnHide;
}

function InternalOnActivate()
{
	if (!bInitialized)
	{
		Refresh();
		bInitialized = true;
	}

	RefreshComponents();
}

function InternalOnShow()
{
	SetTimer(0.5, true);
	RefreshComponents();
}

function InternalOnHide()
{
	KillTimer();
}

function Timer()
{
	RefreshComponents();
}


function Refresh()
{
	class'Utility'.static.refresh();
	RefreshGameTypes();
	RefreshGameInfoData();
	RefreshComponents();
}

function RefreshGameTypes()
{
	local array<Utility.GameData> gdList;
	local int i;

	class'Utility'.static.getGameTypeList(gdList);

	// Populate game type list
	GameTypeListBox.List.clear();

	for (i=0; i<gdList.Length; i++)
	{
		GameTypeListBox.List.Add(gdList[i].name,,gdList[i].className);
	}

	GameTypeListBox.List.Sort();
	GameTypeListBox.List.SetIndex(0);
}

function RefreshMaps()
{
	local array<string> mapList;
	local int i;

	MapListBox.clear();
	class'Utility'.static.getLevelListForGameType(GameTypeListBox.List.Get(), mapList);

	for (i=0; i<mapList.Length; i++)
	{
		//Log("Adding "$mapList[i]);
		if (MapListBox.List.Find(mapList[i]) == "")
			MapListBox.List.Add(mapList[i]);
	}

	MapListBox.List.Sort();
	MapListBox.List.SetIndex(0);
}

function RefreshGameInfoData()
{
	local class<MultiplayerGameInfo> G;

	G = class<MultiplayerGameInfo>(PlayerCharacterController(PlayerOwner()).clientSideChar.gameClass);

	if (G == None)
	{
		Log("Warning:  RefreshGameInfoData couldn't find gameClass in csc");
		return;
	}

	//Log("Found gameInfo "$G);
	//Log("Found roundInfoClass "$G.default.roundInfoClass);
	//Log("Found round "$G.default.roundInfoClass.default.rounds[0]);
	TimeLimitBox.SetText(string(int(G.default.roundInfoClass.default.rounds[0].duration)));
}

function RefreshComponents()
{
	// Only show some components when the player has admin access
	if (PlayerOwner().PlayerReplicationInfo.bAdmin)
	{
		SwitchButton.SetEnabled(true);
		RestartButton.SetEnabled(true);
		TimeLimitBox.SetEnabled(true);
		TimeLimitLabel.SetEnabled(true);
		TournamentButton.SetEnabled(true);
		TeamDamageButton.SetEnabled(true);
		UpdateButton.SetEnabled(true);
		ForceStartButton.SetEnabled(true);
		SwitchButton.Show();
		RestartButton.Show();
		TimeLimitBox.Show();
		TimeLimitLabel.Show();
		TournamentButton.Show();
		TeamDamageButton.Show();
		UpdateButton.Show();
		ForceStartButton.Show();
		LoginButton.Caption = logoutString;
	}
	else
	{
		SwitchButton.SetEnabled(false);
		RestartButton.SetEnabled(false);
		TimeLimitBox.SetEnabled(false);
		TimeLimitLabel.SetEnabled(false);
		TournamentButton.SetEnabled(false);
		TeamDamageButton.SetEnabled(false);
		UpdateButton.SetEnabled(false);
		ForceStartButton.SetEnabled(false);
		SwitchButton.Hide();
		RestartButton.Hide();
		TimeLimitBox.Hide();
		TimeLimitLabel.Hide();
		TournamentButton.Hide();
		TeamDamageButton.Hide();
		UpdateButton.Hide();
		ForceStartButton.Hide();
		LoginButton.Caption = loginString;
	}

	// Tourney mode toggle
	if (PlayerOwner().Level.GRI.bTournamentMode)
	{
		TournamentButton.Caption = publicString;
		VoteTournamentButton.Caption = votePublicString;
		if (PlayerOwner().PlayerReplicationInfo.bAdmin)
		{
			ForceStartButton.SetEnabled(true);
			ForceStartButton.Show();
		}
	}
	else
	{
		TournamentButton.Caption = tourneyString;
		VoteTournamentButton.Caption = voteTourneyString;
		ForceStartButton.SetEnabled(false);
		ForceStartButton.Hide();
	}

	// Team damage toggle
	if (PlayerOwner().Level.GRI.playerTeamDamagePercentage == 0)
	{
		TeamDamageButton.Caption = disableTeamDamageString;
		VoteTeamDamageButton.Caption = voteTeamDamageOffString;
	}
	else
	{
		TeamDamageButton.Caption = enableTeamDamageString;
		VoteTeamDamageButton.Caption = voteTeamDamageOnString;
	}

}

function OnSwitchClick(GUIComponent Sender)
{
	local string gameTypeClassName;
	local string mapFilename;

	// Switch to selected map and game type
	// MJ TODO:  End map properly instead of forcing an abrupt change

	mapFilename = MapListBox.List.Get();
	gameTypeClassName = GameTypeListBox.List.GetExtra();

	// Try doing it with a "switch" and hope the other settings don't get reset
	PlayerOwner().ConsoleCommand("admin switch "$mapFilename$"?game="$gameTypeClassName);

	// If that doesn't work, could try this instead:
	// PlayerOwner().ConsoleCommand("admin game changeto "$gameTypeClassName);
	// PlayerOwner().ConsoleCommand("admin game map "$mapFilename);
	Controller.CloseMenu();
}

function OnRestartClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("admin restartmap");
	Controller.CloseMenu();
}

function GameTypeListOnChange(GUIComponent Sender)
{
	// Display set of maps supported by selected game type
	RefreshMaps();
}

function OnUpdateClick(GUIComponent Sender)
{
	local float limit;
	// Game edit doesn't work due to problems with loading game types in AdminIni.uc
	//PlayerOwner().ConsoleCommand("admin game edit");
	//PlayerOwner().ConsoleCommand("admin game set rounddata duration "$TimeLimitBox.GetText());
	//PlayerOwner().ConsoleCommand("admin game endedit");

	limit = float(TimeLimitBox.GetText());

	if (limit < 1)
	{
		TimeLimitBox.SetText("1");
	}

	PlayerOwner().ConsoleCommand("admin settimelimit "$TimeLimitBox.GetText());
}

function OnLoginClick(GUIComponent Sender)
{
	if (PlayerOwner().PlayerReplicationInfo.bAdmin)
		PlayerOwner().ConsoleCommand("adminlogout");
	else
		Controller.OpenMenu("TribesGui.TribesAdminLoginPopup", "TribesAdminLoginPopup");

	RefreshComponents();
}

function OnVoteMapChangeClick(GUIComponent Sender)
{
	local string gameTypeName;
	local string mapFilename;

	mapFilename = MapListBox.List.Get();
	gameTypeName = GameTypeListBox.List.Get();

	PlayerOwner().ConsoleCommand("mapvote "$mapFileName@gameTypeName);
	Controller.CloseMenu();
}

function OnVoteTournamentClick(GUIComponent Sender)
{
	if (PlayerOwner().GameReplicationInfo.bTournamentMode)
	{
		PlayerOwner().ConsoleCommand("tournamentvote false");
	}
	else
	{
		PlayerOwner().ConsoleCommand("tournamentvote true");
	}

	Controller.CloseMenu();
}

function OnTournamentClick(GUIComponent Sender)
{
	if (PlayerOwner().GameReplicationInfo.bTournamentMode)
	{
		PlayerOwner().ConsoleCommand("admin disabletournamentmode");
	}
	else
	{
		PlayerOwner().ConsoleCommand("admin enabletournamentmode");
	}

	Controller.CloseMenu();
	RefreshComponents();
}

function OnForceStartClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("admin forcestart");
	Controller.CloseMenu();
}

function OnTeamDamageClick(GUIComponent Sender)
{
	//Log("TD clicked with TD = "$PlayerOwner().GameReplicationInfo.playerTeamDamagePercentage);
	if (PlayerOwner().GameReplicationInfo.playerTeamDamagePercentage == 0)
	{
		// Disable team damage
		PlayerOwner().ConsoleCommand("admin SetTeamDamage 1.0");
	}
	else
	{
		// Enable team damage
		PlayerOwner().ConsoleCommand("admin SetTeamDamage 0.0");
	}

	Controller.CloseMenu();
	RefreshComponents();
}

function OnVoteTeamDamageClick(GUIComponent Sender)
{
	if (PlayerOwner().GameReplicationInfo.playerTeamDamagePercentage == 0)
	{
		PlayerOwner().ConsoleCommand("teamdamagevote false");
	}
	else
	{
		PlayerOwner().ConsoleCommand("teamdamagevote true");
	}

	Controller.CloseMenu();
	RefreshComponents();
}

defaultproperties
{
	loginString = "ADMIN LOGIN"
	logoutString = "ADMIN LOGOUT"
	tourneyString = "TOURNEY MODE"
	publicString = "PUBLIC MODE"
	enableTeamDamageString		= "ENABLE TEAM DAMAGE"
	disableTeamDamageString		= "DISABLE TEAM DAMAGE"
	voteTeamDamageOnString		= "VOTE TEAM DAMAGE ON"
	voteTeamDamageOffString		= "VOTE TEAM DAMAGE OFF"
	voteTourneyString			= "VOTE TOURNAMENT"
	votePublicString			= "VOTE PUBLIC"
}