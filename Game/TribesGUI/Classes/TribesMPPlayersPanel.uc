// ====================================================================
//  Class:  TribesGui.TribesMPPlayersPanel
// ====================================================================

class TribesMPPlayersPanel extends TribesMPEscapePanel
     ;

var(TribesGui) private EditInline Config GUIMultiColumnListBox TeamOneListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox TeamTwoListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox SpectatorListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ChangeTeamButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    SpectateButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    AddBuddyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    VoteToKickButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    MuteButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    KickButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    BanButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    GrantAdminButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    SpectifyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    TeamChangeButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    VoteAdminButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    JoinTeamOneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    JoinTeamTwoButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ForceTeamOneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ForceTeamTwoButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RecordButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGUI) protected EditInline Config Texture		StatusIcon;
var(TribesGUI) protected EditInline Config GUIImage		StatusIconImage;
var(TribesGUI) protected EditInline Config Texture		DeathIcon;
var(TribesGUI) protected EditInline Config GUIImage		DeathIconImage;

var localized string unSpectate;
var localized string Spectate;
var localized string addedBuddyString;
var localized string failedToAddBuddyString;
var localized string joinTeamString;
var localized string forceTeamString;
var localized string startRecordingString;
var localized string stopRecordingString;
var localized string muteString;
var localized string unmuteString;

var(TribesGui) private Config color ownNameColor;

var bool bDebugAdmin;
var bool bRecordingDemo;
var bool bRefreshingLists;
var float pollingDelay;
var GUIMultiColumnListBox currentlySelectedList;
var TeamInfo TeamOne, TeamTwo;

function InitComponent(GUIComponent Owner)
{
	local int i;

	Super.InitComponent(Owner);

    ChangeTeamButton.OnClick=ChangeTeamClick;
    SpectateButton.OnClick=SpectateClick;
	AddBuddyButton.OnClick=AddBuddyClick;
	VoteToKickButton.OnClick=VoteToKickClick;
	VoteAdminButton.OnClick=VoteAdminClick;
	MuteButton.OnClick=MuteClick;
	KickButton.OnClick=KickClick;
    BanButton.OnClick=BanClick;
	GrantAdminButton.OnClick=GrantAdminClick;
	SpectifyButton.OnClick=SpectifyClick;
	TeamChangeButton.OnClick=TeamChangeClick;
	JoinTeamOneButton.OnClick=JoinTeamOneClick;
	JoinTeamTwoButton.OnClick=JoinTeamTwoClick;
	ForceTeamOneButton.OnClick=ForceTeamOneClick;
	ForceTeamTwoButton.OnClick=ForceTeamTwoClick;
	RecordButton.OnClick=RecordClick;
	TeamOneListBox.OnChange=OnListChange;
	TeamTwoListBox.OnChange=OnListChange;
	SpectatorListBox.OnChange=OnListChange;

	StatusIconImage=GUIImage(Controller.CreateComponent("GUI.GUIImage","Canvas_StatusIcon"));
	StatusIconImage.Image=StatusIcon;
	DeathIconImage=GUIImage(Controller.CreateComponent("GUI.GUIImage","Canvas_DeathIcon"));
	DeathIconImage.Image=DeathIcon;

	// Needed for list activation/deactivation
	TeamOneListBox.OnClick=TeamOneListClick;
	TeamTwoListBox.OnClick=TeamTwoListClick;
	SpectatorListBox.OnClick=SpectatorListClick;
	currentlySelectedList = TeamOneListBox;
	for( i = 0; i < TeamOneListBox.MultiColumnList.Length; i++ )
    {
        TeamOneListBox.MultiColumnList[i].MCList.OnClick=TeamOneListClick;
    }

	for( i = 0; i < TeamTwoListBox.MultiColumnList.Length; i++ )
    {
        TeamTwoListBox.MultiColumnList[i].MCList.OnClick=TeamTwoListClick;
    }

	for( i = 0; i < SpectatorListBox.MultiColumnList.Length; i++ )
    {
        SpectatorListBox.MultiColumnList[i].MCList.OnClick=SpectatorListClick;
    }

	TeamOneListBox.GetColumn( "Score" ).bSortForward = false;
	TeamTwoListBox.GetColumn( "Score" ).bSortForward = false;

	OnActivate = InternalOnActivate;
	OnShow = InternalOnShow;
	OnHide = InternalOnHide;
}

function UpdateTeamLists()
{
	local TribesReplicationInfo P;
	local int j;
	local GUIMultiColumnListBox List;
	local TeamInfo team;
	local string currentlySelectedName;
	local int ping;

	// The first team is always the owner's team, if applicable
	//TeamOne = TribesReplicationInfo(PlayerOwner().PlayerReplicationInfo).team;

	// Find teams
	if (TeamOne == None || TeamTwo == None)
	{
		TeamOne = None;
		TeamTwo = None;

		ForEach PlayerOwner().Level.AllActors(class'TeamInfo', team)
		{
			if (team.TeamIndex == 0)
				TeamOne = team;
			else
				TeamTwo = team;
		}
	}

	// Hard-coded update for two teams for now
	// This should detect if there are two teams; if there is only one, it should
	// delete that column and stretch the teamOne column
	TeamOneListBox.FindColumn("Name").MCButton.Caption = TeamOne.localizedName;

	if (TeamTwo != None)
		TeamTwoListBox.FindColumn("Name").MCButton.Caption = TeamTwo.localizedName;

	// Update join and force buttons
	JoinTeamOneButton.Caption = replaceStr(joinTeamString, TeamOne.localizedName);
	JoinTeamTwoButton.Caption = replaceStr(joinTeamString, TeamTwo.localizedName);
	ForceTeamOneButton.Caption = replaceStr(forceTeamString, TeamOne.localizedName);
	ForceTeamTwoButton.Caption = replaceStr(forceTeamString, TeamTwo.localizedName);

	currentlySelectedName = getSelectedPlayerName(true);

	// Update the table
	bRefreshingLists = true;
	TeamOneListBox.clear();
	TeamTwoListBox.clear();
	SpectatorListBox.clear();
	for (j = 0; j < PlayerOwner().GameReplicationInfo.PRIArray.Length; j++)
	{
		P = tribesReplicationInfo(PlayerOwner().GameReplicationInfo.PRIArray[j]);
		if (P == None || P.PlayerName == "" || DemoController(P.Owner) != None)
		{
			//Log("PlayerPanel warning:  Invalid TRI");
			continue;
		}

		if (P.team == None || P.bIsSpectator)
		{
			// Don't display webadmin
			if (P.PlayerName ~= "WebAdmin")
				continue;
			List = SpectatorListBox;
		}
		else if (P.team == TeamOne)
			List = TeamOneListBox;
		else
			List = TeamTwoListBox;

		//Log("PLAYERPANEL adding "$P.PlayerName$" with health "$string(P.health)$", "$string(int(P.Score))$", "$string(P.ping));
		if (P.health <= 0)
			List.AddNewRowElement( "Icon", DeathIconImage,,,true );
		else
			List.AddNewRowElement( "Icon", StatusIconImage,,,true );
	    List.AddNewRowElement( "Name",,  TribesGUIController(Controller).EncodePlayerName(self, P) );
		List.AddNewRowElement( "Score",, string(int(P.Score)), int(P.Score));
		ping = P.ping;
		if (ping > 999)
			ping = 999;
		List.AddNewRowElement( "Ping",, string(ping),ping );
		List.PopulateRow( "Name" );
	}

	TeamOneListBox.Sort("Score");
	TeamTwoListBox.Sort("Score");

	TeamOneListBox.SetIndex(-1);
	TeamTwoListBox.SetIndex(-1);
	SpectatorListBox.SetIndex(-1);

	// Re-select old selection
	if (currentlySelectedList != None)
		currentlySelectedList.FindColumn("Name").MCList.FindExtra(currentlySelectedName);

	bRefreshingLists = false;
}

function ChangeTeamClick(GUIComponent Sender)
{
	ExecuteCommand("SwitchTeam");
	Controller.CloseMenu();
}

function SpectateClick(GUIComponent Sender)
{
	ExecuteCommand("Spectate");
	UpdateButtons();
	Controller.CloseMenu();
}

function AddBuddyClick(GUIComponent Sender)
{
	local string buddyName;

	buddyname = getSelectedPlayerName();
	
	// Don't allow empty strings or own name
	if (buddyName == "" || buddyName == PlayerOwner().PlayerReplicationinfo.PlayerName)
		return;

	if (AddBuddy(buddyName))
		GUIPage(MenuOwner.MenuOwner).OpenDlg(replaceStr(addedBuddyString, buddyName), QBTN_Ok);
	else
		GUIPage(MenuOwner.MenuOwner).OpenDlg(replaceStr(failedToAddBuddyString, buddyName), QBTN_Ok);
}

function VoteToKickClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand( "kickvote " $ getSelectedPlayerName());
	Controller.CloseMenu();
}

function VoteAdminClick(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand( "adminvote " $ getSelectedPlayerName());
	Controller.CloseMenu();
}

function MuteClick(GUIComponent Sender)
{
	// Don't allow self-muting
	if (getSelectedPlayerName() == PlayerOwner().PlayerReplicationInfo.PlayerName)
		return;

	ExecuteCommand("Mute", getSelectedPlayerName());
}

function KickClick(GUIComponent Sender)
{
	ExecuteCommand("admin kick", getSelectedPlayerName());
}

function BanClick(GUIComponent Sender)
{
	ExecuteCommand("admin kick ban", getSelectedPlayerName());
}

function GrantAdminClick(GUIComponent Sender)
{
	ExecuteCommand("adminpromote", getSelectedPlayerName());
}

function SpectifyClick(GUIComponent Sender)
{
	ExecuteCommand("admin spectify", getSelectedPlayerName());
}

function TeamChangeClick(GUIComponent Sender)
{
	ExecuteCommand("admin teamchange", getSelectedPlayerName());
}

function MessageClick(GUIComponent Sender)
{
	ExecuteCommand("SendAdminMessage", getSelectedPlayerName());
}

function string getSelectedPlayerName(optional bool bDontStripCodes)
{
	local string name;

	bRefreshingLists = true;
	if (currentlySelectedList != None)
	{
		if (bDontStripCodes)
			name = currentlySelectedList.FindColumn("Name").MCList.GetExtra();
		else
			name = stripCodes(currentlySelectedList.FindColumn("Name").MCList.GetExtra());
	}
	bRefreshingLists = false;

	return name;
}

function executeCommand(string command, optional string playerName)
{
	if (playerName == "")
		PlayerOwner().ConsoleCommand( command );
	else
		PlayerOwner().ConsoleCommand( command $ " " $ "\"" $ playerName $ "\"");

	UpdateTeamLists();
}

function UpdateButtons()
{
	if (hasAdminPrivileges())
	{
		KickButton.Show();
		BanButton.Show();
//		GrantAdminButton.Show();
		GrantAdminButton.Hide();   // hide since it's not yet implemented
		SpectifyButton.Show();
		TeamChangeButton.Show();
		ForceTeamOneButton.Show();
		ForceTeamTwoButton.Show();
//		MessageButton.Show();
	}
	else
	{
		KickButton.Hide();
		BanButton.Hide();
		GrantAdminButton.Hide();
		SpectifyButton.Hide();
		TeamChangeButton.Hide();
		ForceTeamOneButton.Hide();
		ForceTeamTwoButton.Hide();
//		MessageButton.Hide();
	}

	if (PlayerOwner().PlayerReplicationInfo.bIsSpectator)
		SpectateButton.Caption = unSpectate;
	else
		SpectateButton.Caption = Spectate;

	//if (PlayerOwner().bClientDemoRecording)
	if (bRecordingDemo)
		RecordButton.Caption = stopRecordingString;
	else
		RecordButton.Caption = startRecordingString;

	// Enable/disable team joining buttons depending on own status
	if (PlayerOwner().PlayerReplicationInfo.bIsSpectator)
	{
		JoinTeamOneButton.SetEnabled(true);
		JoinTeamTwoButton.SetEnabled(true);
	}
	else if (TribesReplicationInfo(PlayerOwner().PlayerReplicationInfo).team.teamIndex == 0)
	{
		JoinTeamOneButton.SetEnabled(false);
		JoinTeamTwoButton.SetEnabled(true);
	}
	else
	{
		JoinTeamOneButton.SetEnabled(true);
		JoinTeamTwoButton.SetEnabled(false);
	}

	// Don't allow changing to teams if they don't exist
	if (TeamOne == None)
		JoinTeamOneButton.SetEnabled(false);
	if (TeamTwo == None)
		JoinTeamTwoButton.SetEnabled(false);
}

function bool hasAdminPrivileges()
{
	// Determine if local player has admin privileges here
	return PlayerOwner().PlayerReplicationInfo.bAdmin;
}

function InternalOnActivate()
{
	UpdateButtons();
	UpdateTeamLists();
}

function InternalOnShow()
{
	SetTimer( pollingDelay, true );
}

function InternalOnHide()
{
    KillTimer();
	TeamOne = None;
	TeamTwo = None;
}

function Timer()
{
	UpdateTeamLists();
	UpdateButtons();
}

function bool AddBuddy(string buddy)
{
	local int i;
	local ProfileManager playerProfileManager;
	local PlayerProfile activeProfile;

	playerProfileManager = TribesGUIController(Controller).profileManager;
	activeProfile = playerProfileManager.GetActiveProfile();

	// Add buddy to current profile and refresh
	if (activeProfile == None || buddy == "")
		return false;

	// Don't allow duplicates
	for (i=0; i<activeProfile.buddyList.Length; i++)
	{
		if (activeProfile.buddyList[i] == buddy)
			return false;
	}
	
	activeProfile.buddyList[activeProfile.buddyList.Length] = buddy;

	playerProfileManager.Store();
	return true;
}

function TeamOneListClick(GUIComponent Sender)
{
	// Disable other lists so there's only one selection among them
	TeamTwoListBox.SetIndex(-1);
	SpectatorListBox.SetIndex(-1);
	currentlySelectedList = TeamOneListBox;
}

function TeamTwoListClick(GUIComponent Sender)
{
	// Disable other lists so there's only one selection among them
	TeamOneListBox.SetIndex(-1);
	SpectatorListBox.SetIndex(-1);
	currentlySelectedList = TeamTwoListBox;
}

function SpectatorListClick(GUIComponent Sender)
{
	// Disable other lists so there's only one selection among them
	TeamOneListBox.SetIndex(-1);
	TeamTwoListBox.SetIndex(-1);
	currentlySelectedList = SpectatorListBox;
}

function JoinTeamOneClick(GUIComponent Sender)
{
	ExecuteCommand("ChangeTeam"@string(TeamOne.teamIndex));
	Controller.CloseMenu();
}

function JoinTeamTwoClick(GUIComponent Sender)
{
	ExecuteCommand("ChangeTeam"@string(TeamTwo.teamIndex));
	Controller.CloseMenu();
}

function ForceTeamOneClick(GUIComponent Sender)
{
	if (getSelectedPlayerName() == "")
		return;

	PlayerOwner().ConsoleCommand("admin teamchange \""$getSelectedPlayerName()$"\""@string(TeamOne.teamIndex));
	UpdateTeamLists();
}

function ForceTeamTwoClick(GUIComponent Sender)
{
	if (getSelectedPlayerName() == "")
		return;

	PlayerOwner().ConsoleCommand("admin teamchange \""$getSelectedPlayerName()$"\""@string(TeamTwo.teamIndex));
	UpdateTeamLists();
}

function String FullTimeDate()		// Date/Time in MYSQL format
{
	local LevelInfo Level;

	Level = PlayerOwner().Level;
	return ""$Level.Year$"-"$Level.Month$"-"$Level.Day$"_"$Level.Hour$"."$Level.Minute$"."$Level.Second;
} 

function String constructRecordingName()
{
	return "";
	// TODO:  Replace spaces in the level's title
	//return PlayerOwner().PlayerReplicationInfo.PlayerName$"-"$FullTimeDate()$"_"$PlayerOwner().Level.Title;
}

function RecordClick(GUIComponent Sender)
{
	//if (PlayerOwner().bClientDemoRecording)
	if (bRecordingDemo)
		ExecuteCommand("stopdemo");
	else
		ExecuteCommand("demorec "$constructRecordingName());

	bRecordingDemo = !bRecordingDemo;
	UpdateButtons();
	Controller.CloseMenu();
}

function OnListChange(GUIComponent Sender)
{
	if (bRefreshingLists)
		return;

	// Update mute button
	if (PlayerCharacterController(PlayerOwner()).IsMuted(getSelectedPlayerName()))
		MuteButton.Caption = UnMuteString;
	else
		MuteButton.Caption = MuteString;

	// If currently spectating, switch view to new player
	if (PlayerOwner().PlayerReplicationInfo.bIsSpectator)
	{
		//Log("EXECUTING spectateplayer "$getSelectedPlayerName());
		//ExecuteCommand("spectate", getSelectedPlayerName());
	}
}

function string getColoredPlayerName(TribesReplicationInfo TRI)
{
	local string PlayerName, TeamTag;

	// Team tag
	if (TRI.teamTag != "")
	{
		TeamTag = MakeColorCode(TRI.team.TeamHighlightColor) $ TRI.teamTag;
	}

	PlayerName = stripCodes(TRI.PlayerName);
	if (TRI.team != None)
	{
		// Highlight own name
		if (PlayerOwner().PlayerReplicationInfo == TRI)
			PlayerName = MakeColorCode(TRI.team.TeamHighlightColor) $ PlayerName;
		else
			PlayerName = MakeColorCode(TRI.team.TeamColor) $ PlayerName;
	}

	// Simply add it to front of name for now
	// TODO:  Use delimeter to control how tag looks
	return TeamTag $ PlayerName;
}


defaultproperties
{
	pollingDelay=0.5
	bDebugAdmin=false
	unSpectate = "UNSPECTATE"
	Spectate = "SPECTATE"
	addedBuddyString = "You added %1 to your buddy list."
	failedToAddBuddyString = "%1 is already in your buddy list."
	joinTeamString = "JOIN %1"
	forceTeamString = "FORCE %1"
	startRecordingString = "START RECORDING"
	stopRecordingString = "STOP RECORDING"
	muteString = "MUTE"
	unMuteString = "UNMUTE"
	StatusIcon=Texture'guitribes.icon_medium'
	DeathIcon=Texture'guitribes.icon_skull'
}