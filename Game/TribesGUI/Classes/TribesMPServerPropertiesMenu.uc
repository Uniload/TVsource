// ====================================================================
//  Class:  TribesGui.TribesMPServerPropertiesMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPServerPropertiesMenu extends TribesGUIPage
     ;
var(TribesGui) private EditInline Config GUILabel			ServerNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			ServerIPAddressLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			ServerEmailLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			MapNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			GameTypeLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TimeLeftLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TeamOneNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TeamTwoNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TeamOneScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TeamTwoScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			VersionLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			PingLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    ConnectButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RefreshButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    TeamOneBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    TeamTwoBox "A component of this page which has its behavior defined in the code for this page's class.";

var TribesGameSpyManager gm;
var int currServerId;

var String currIpAddress;
var String currPort;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    CancelButton.OnClick=OnCancelClicked;
    ConnectButton.OnClick=OnConnectClicked;
    RefreshButton.OnClick=OnRefreshClicked;

	TeamOneBox.GetColumn( "Score" ).bSortForward = false;
	TeamTwoBox.GetColumn( "Score" ).bSortForward = false;
}

function HandleParameters(string Param1, string Param2, optional int param3)
{
	currServerId = param3;
	gm.UpdateServer(currServerId, false);
	RefreshData();
}

function InternalOnActivate()
{
	gm = TribesGameSpyManager(PlayerOwner().Level.GetGameSpyManager());

	assert(gm != None);

	gm.CancelUpdate();

	gm.OnServerDataUpdate = ReceiveServerData;
}

function ReceiveServerData(GameSpyServerData gssd)
{
	local int i;
	local int ping;

	assert(gssd.gsServerId == currServerId);

	currIpAddress = gssd.gsIpAddress;
	currPort = gssd.gsHostPort;

	ServerNameLabel.SetCaption(gssd.gsHostName);
	ServerIPAddressLabel.SetCaption(gssd.gsIpAddress$":"$gssd.gsHostPort);
	VersionLabel.SetCaption(gssd.gsGameVer);
	ping = gssd.gsPing;
	if (ping > 999)
		ping = 999;
	PingLabel.SetCaption(String(ping));
	ServerEmailLabel.SetCaption(gssd.gsAdminEmail);
	MapNameLabel.SetCaption(gssd.gsMapName);
	GameTypeLabel.SetCaption(gssd.gsGameType);
	//TimeLeftLabel.SetCaption();
	TeamOneNameLabel.SetCaption(gssd.gsTeamOneName);
	TeamTwoNameLabel.SetCaption(gssd.gsTeamTwoName);
	TeamOneScoreLabel.SetCaption(gssd.gsTeamOneScore);
	TeamTwoScoreLabel.SetCaption(gssd.gsTeamTwoScore);
	PingLabel.SetCaption(string(gssd.gsPing));

	TeamOneBox.Clear();
	TeamTwoBox.Clear();

	for (i = 0; i < gssd.gsPlayerNames.Length; ++i)
	{
		if (gssd.gsPlayerTeams[i] == gssd.gsTeamOneName)
			AddNewRowToList(TeamOneBox, gssd.gsPlayerNames[i], gssd.gsPlayerPings[i], gssd.gsPlayerScores[i]);
		else if (gssd.gsPlayerTeams[i] == gssd.gsTeamTwoName)
			AddNewRowToList(TeamTwoBox, gssd.gsPlayerNames[i], gssd.gsPlayerPings[i], gssd.gsPlayerScores[i]);
		else
			Log("Received player data with an invalid team name");
	}

	TeamOneBox.Sort("Score");
	TeamTwoBox.Sort("Score");
}

function AddNewRowToList(GUIMultiColumnListBox list, String name, String ping, String score)
{
	list.AddNewRowElement("Name",, name);
	list.AddNewRowElement("Ping",, ping, int(ping));
	list.AddNewRowElement("Score",, score, int(score));

	list.PopulateRow();
}

function RefreshData()
{
	gm.UpdateServer(currServerId, true);
}

function OnCancelClicked(GUIComponent Sender)
{
	Controller.CloseMenu();
}

function OnConnectClicked(GUIComponent Sender)
{
	Controller.CloseMenu();
	OnConnect(currIpAddress, currPort);
}

delegate OnConnect(String ipAddress, String Port);

function OnRefreshClicked(GUIComponent Sender)
{
	RefreshData();
}

defaultproperties
{
	OnActivate=InternalOnActivate
	bPersistent=false
}