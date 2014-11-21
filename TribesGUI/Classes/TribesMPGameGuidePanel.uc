// ====================================================================
//  Class:  TribesGui.TribesMPGameGuidePanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPGameGuidePanel extends TribesMPPanel
     ;

var(TribesGui) private EditInline Config GUIButton		    JoinServerButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RefreshButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    FiltersButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    MarkFavoriteButton "A component of this page which has its behavior defined in the code for this page's class.";
//var(TribesGui) private EditInline Config GUIButton		    JoinIPButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    BuddyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    PropertiesButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    PatchButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIComboBox		FilterBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			ServerCountLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			PlayerCountLabel "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIMultiColumnListBox ServerListBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUICheckBoxButton        BuddiesOnlyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton        LANOnlyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckBoxButton        FavsOnlyButton "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) protected EditInline GlobalConfig localized string ServerPasswordText;

var(TribesGui) protected EditInline GlobalConfig localized string GamespyTimeoutText;
var(TribesGui) protected EditInline Config int GamespyTimeout;

var(TribesGui) protected EditInline GlobalConfig localized string GamespyLoginSuccessText;
var(TribesGui) protected EditInline GlobalConfig localized string BadAuthPasswordText;
var(TribesGui) protected EditInline GlobalConfig localized string BadParamText;
var(TribesGui) protected EditInline GlobalConfig localized string NoResponse;
var(TribesGui) protected EditInline GlobalConfig localized string BadServerIdText;

var(TribesGUI) protected EditInline Config float PatchCheckPeriod		"The length of time in seconds between game update checks (default 15 mins)";
var(TribesGUI) protected EditInline Config Texture		LockedIcon;
var(TribesGUI) protected EditInline Config GUIImage		LockedIconImage;
var(TribesGUI) protected EditInline Config Texture		StatsIcon;
var(TribesGUI) protected EditInline Config GUIImage		StatsIconImage;
var(TribesGUI) protected EditInline Config Texture		FavIcon;
var(TribesGUI) protected EditInline Config GUIImage		FavIconImage;
var(TribesGUI) protected EditInline Config bool			bShowUnsupportedVersions;

var TribesGameSpyManager gm;
var ServerFilterInfo filterInfo;
var private string joinURL; // set in AttemptUrl
var string joinPassword;
var float LastPatchCheckTime;
var int numServers;
var int numPlayers;
var localized string noneString;
var localized string playerCountText;
var bool bRefreshingFilters;
var bool bShowingMPHelp;
var int maxQueryLength;
var bool bSuppressMPHelp;

function InitComponent(GUIComponent Owner)
{
	local int i;

	Super.InitComponent(Owner);

	OnShow=InternalOnShow;

    JoinServerButton.OnClick=InternalOnClick;
    RefreshButton.OnClick=InternalOnClick;
    FiltersButton.OnClick=InternalOnClick;
    //JoinIPButton.OnClick=InternalOnClick;
	BuddyButton.OnClick=InternalOnClick;
	LANOnlyButton.OnClick=InternalOnClick;
	FavsOnlyButton.OnClick=InternalOnClick;
	BuddiesOnlyButton.OnClick=InternalOnClick;
	PropertiesButton.OnClick=InternalOnClick;
	FilterBox.OnChange=OnFilterChange;
	MarkFavoriteButton.OnClick=InternalOnClick;
	PatchButton.OnClick=OnPatch;

	for( i = 0; i < ServerListBox.MultiColumnList.Length; i++ )
    {
        ServerListBox.MultiColumnList[i].MCList.OnDblClick=InternalOnClick;
    }

    LockedIconImage=GUIImage(Controller.CreateComponent("GUI.GUIImage","Canvas_LockedIcon"));
	LockedIconImage.Image=LockedIcon;
    StatsIconImage=GUIImage(Controller.CreateComponent("GUI.GUIImage","Canvas_StatsIcon"));
	StatsIconImage.Image=StatsIcon;
    FavIconImage=GUIImage(Controller.CreateComponent("GUI.GUIImage","Canvas_FavIcon"));
	FavIconImage.Image=FavIcon;
	ServerListBox.SetActiveColumn("Ping");
}

function InternalOnActivate()
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();
	if (!p.bShownMPHelp && !bShowingMPHelp && !bSuppressMPHelp)
	{
		Controller.OpenMenu("TribesGUI.TribesMPHelpMenu", "TribesMPHelpMenu");
		bShowingMPHelp = true;

		// Suppress it so it doesn't show again until you switch to a new menu
		bSuppressMPHelp = true;
		p.Store();
	}

	RefreshFilters();
	JoinServerButton.EnableComponent();
}

function InternalOnDeActivate()
{
     GC.SaveConfig();
	 bShowingMPHelp = false;
}

function InternalOnShow()
{
	local float LastCheckElapsed;

	if (gm == None)
	{
		gm = TribesGameSpyManager(PlayerOwner().Level.GetGameSpyManager());

		if (gm == None)
		{
			Log("Error:  no GameSpy manager found");
			return;
		}
	}

	gm.OnGameSpyInitialised = StartListUpdate;
	gm.InitGameSpyClient();

	LastCheckElapsed = PlayerOwner().Level.TimeSeconds - LastPatchCheckTime;
	
	log("Time since last patch check: "$LastCheckElapsed);
	
	if (LastPatchCheckTime == 0 || LastCheckElapsed > PatchCheckPeriod)
	{
		gm.OnQueryPatchResult = OnQueryPatchResult;
		gm.QueryPatch();
		LastPatchCheckTime = PlayerOwner().Level.TimeSeconds;
	}
}

function InternalOnHide()
{
	bSuppressMPHelp = false;
}

function AttemptURL( string URL )
{
	local PlayerProfile p;
	local GUIList list;

	JoinServerButton.DisableComponent();

	joinURL = URL;
	list = ServerListBox.FindColumn("StatsIcon").MCList;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (!p.bUseStatTracking ||
		list.Elements[list.Index].ExtraData == None) // Don't do stat tracking login if server doesn't support it
// TEAMTAG: Removed
	//if ((!p.bUseStatTracking && !p.bUseTeamAffiliation) ||
	//	// Don't do stat tracking login if server doesn't support it
	//	((p.bUseStatTracking && !p.bUseTeamAffiliation) && list.Elements[list.Index].ExtraData == None))
	{
		joinURL $= "?HasStats=0";
		FinaliseAttemptURL(joinURL);
	}
	else
	{
		joinURL $= "?HasStats=1";

		// try to login to gamespy
		if (p.needStatTrackingUserInput())
		{
			ShowGamespyLogin();
		}
		else
		{
			gm.OnProfileCheckResult = OnGamespyLoginResult;
			gm.CheckUserAccount(p.statTrackingNick, p.statTrackingEmail, p.statTrackingPassword);
			SetTimer(GamespyTimeout, false);
		}
	}
}

// gamespy timeout
event Timer()
{
	JoinServerButton.EnableComponent();
	GUIPage(MenuOwner.MenuOwner).OpenDlg(GamespyTimeoutText, QBTN_Ok);
}

private function OnGamespyLoginScreenLogin()
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();
// TEAMTAG: Removed
	//if (!p.bUseTeamAffiliation)
		FinaliseAttemptURL();
	//else
	//	DoGamespyTeamLogin();
}

private function OnGamespyLoginScreenCancel()
{
	joinURL = "";
}

private function OnGamespyLoginResult(GameSpyManager.EGameSpyResult result, int profileId)
{
	local PlayerProfile p;

	SetTimer(0, false);

	switch (result)
	{
	case GSR_VALID_PROFILE:
		p = TribesGUIController(Controller).profileManager.GetActiveProfile();
// TEAMTAG: Removed
		//if (!p.bUseTeamAffiliation)
			FinaliseAttemptURL();
		//else
		//	DoGamespyTeamLogin();

		break;
	default:
		ShowGamespyLogin();
		break;
	}
}

private function ShowGamespyLogin()
{
	Controller.OpenMenu("TribesGUI.TribesGamespyLogin");
	TribesGamespyLogin(Controller.ActivePage).OnSuccess = OnGamespyLoginScreenLogin;
	TribesGamespyLogin(Controller.ActivePage).OnCancel = OnGamespyLoginScreenCancel;
}

private function OnGamespyTeamLoginScreenLogin()
{
	FinaliseAttemptURL();
}

private function OnGamespyTeamLoginScreenCancel()
{
	joinURL = "";
}

private function ShowGamespyTeamLogin()
{
	Controller.OpenMenu("TribesGUI.TribesGamespyTeamLogin");
	TribesGamespyTeamLogin(Controller.ActivePage).OnSuccess = OnGamespyTeamLoginScreenLogin;
	TribesGamespyTeamLogin(Controller.ActivePage).OnCancel = OnGamespyTeamLoginScreenCancel;
}

private function DoGamespyTeamLogin()
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	assert(p.statTrackingID != 0);

	if (p.needTeamAffiliationUserInput())
	{
		ShowGamespyTeamLogin();
	}
	else
	{
		gm.OnLoginTeamResult = OnGamespyTeamLoginResult;
		gm.LoginTeam(p.statTrackingID, p.affiliatedTeamId, p.affiliatedTeamPassword, false);
		SetTimer(GamespyTimeout, false);
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
			GUIPage(MenuOwner.MenuOwner).OpenDlg(BadAuthPasswordText, QBTN_Ok);
		}
		else if (ResponseData == "INVALID PARAMETER")
		{
			GUIPage(MenuOwner.MenuOwner).OpenDlg(BadParamText, QBTN_Ok);
		}
		else
		{
			Div(ResponseData, "|", teamTag, teamName);

			UpdateProfile(teamTag, teamName);

			Log("Successfully logged in to team: " $ teamName);

			FinaliseAttemptURL();
		}
	}
	else
	{
		GUIPage(MenuOwner.MenuOwner).OpenDlg(NoResponse, QBTN_Ok);
	}
}

protected function UpdateProfile(string teamTag, string teamName)
{
	local PlayerProfile p;
	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	p.affiliatedTeamTag = teamTag;
	p.affiliatedTeamName = teamName;
}

private function FinaliseAttemptURL(optional string URL)
{
	local GUIList list;
	JoinServerButton.EnableComponent();

	if (joinURL == "")
		return;

	list = ServerListBox.FindColumn("StatusIcon").MCList;
	// Check for password protection
	if (list.Elements[list.Index].ExtraData != None && joinPassword == "")
	{
		Controller.OpenMenu( "TribesGui.TribesDefaultTextEntryPopup", "TribesDefaultTextEntryPopup", ServerPasswordText, "Password" );
		return;
	}

	if (joinPassword != "")
	{
		joinURL = joinURL $ "?JoinPassword="$joinPassword;
		joinPassword = "";
	}

    joinURL = joinURL$"?"$TribesGUIController(Controller).profileManager.GetURLOptions(URL);
    log( "Trying to join to: " $ joinURL );
	GC.bTravelMission = false;
	GC.CurrentMission = joinURL;
	TribesGUIController(Controller).GameStart();
    //TribesGUIController(Controller).LoadLevel(URL); 

	joinURL = "";
}

function StartListUpdate()
{
	local PlayerProfile activeProfile;
	local int i;
	local string ip, port;

	activeProfile = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (!gm.bInitialised)
		return;

	numServers = 0;
	numPlayers = 0;

	gm.CancelUpdate();

	gm.OnServerDataUpdate = ReceiveServerData;

	ServerListBox.Clear();

	gm.OnUpdateComplete = OnServerListUpdateComplete;

	gm.ClearServerList();

	UpdateCountLabels();

	// If updating favorites, do it manually
	if (FavsOnlyButton.bChecked)
	{
		for (i=0; i<activeProfile.serverFavorites.Length; i++)
		{
			ip = activeProfile.serverFavorites[i].IP;
			port = activeProfile.serverFavorites[i].Port;
			Log("Manually querying "$IP@Port);
			// Manually update by IP address and port.  GameSpy port is server port + 1
			gm.UpdateServerByIP(IP, int(Port));
			ServerCountLabel.Caption = string(i)@"/"@activeProfile.serverFavorites.Length;
			PlayerCountLabel.Caption = "";
		}
	}
	// Otherwise, do a full update
	else
	{
		gm.LANUpdateServerList();
	}
}

function String BuildBuddyFilter()
{
	local int i;
	local string filter;
	local string temp;
	local PlayerProfile activeProfile;

	activeProfile = TribesGUIController(Controller).profileManager.GetActiveProfile();

	if (activeProfile.buddyList.Length > 0)
		filter = "p like '%" $ activeProfile.buddyList[i] $ "%'";

	if (Len(filter) >= 255)
	{
		Log("First buddy name was to long for the filter string");
		return "";
	}

	for (i = 1; i < activeProfile.buddyList.Length; ++i)
	{
		temp = filter $ " or p like '%" $ activeProfile.buddyList[i] $ "%'";

		if (Len(temp) >= 255)
		{
			Log("To many buddies to fit in the filter string");
			break;
		}

		filter = temp;
	}

	return filter;
}

function OnServerListUpdateComplete(bool bLAN)
{
	local string filter;

	if (bLAN && !LANOnlyButton.bChecked)
	{
		if (BuddiesOnlyButton.bChecked)
			filter = BuildBuddyFilter();
		else
			filter = filterInfo.getQueryForName(FilterBox.GetText());

		if (filter == "None")
			filter = "";

		if (Len(filter) > maxQueryLength)
			filter = Left(filter, maxQueryLength);

		gm.UpdateServerList(filter);
	}
	else
	{
		UpdateCountLabels();
	}
}

private function OnServerPropertiesConnect(String ipAddress, String Port)
{
	AttemptURL(ipAddress $ ":" $ Port);
}

function InternalOnClick(GUIComponent Sender)
{
	local GUIList list;
	switch (Sender)
	{
		case RefreshButton:
			StartListUpdate();
            break;
		case FiltersButton:
            Controller.OpenMenu( "TribesGui.TribesMPServerFilterMenu", "TribesMPServerFilterMenu" );
            break;
		case BuddyButton:
            Controller.OpenMenu( "TribesGui.TribesMPBuddyMenu", "TribesMPBuddyMenu" );
            break;
		case LANOnlyButton:
			StartListUpdate();
			break;
		case BuddiesOnlyButton:
			StartListUpdate();
			break;
		case FavsOnlyButton:
			StartListUpdate();
			break;
		//case JoinIPButton:
        //    Controller.OpenMenu( "TribesGui.TribesDefaultTextEntryPopup", "TribesDefaultTextEntryPopup", "Please enter the IP of the server that you wish to join...", "JoinIP" );
        //    break;
		case PropertiesButton:

			if (!gm.bInitialised)
				return;

			list = ServerListBox.FindColumn("ServerName").MCList;

			if (list.Index < 0)
				return;

			// You can pass strings here as parameters so you know which server's properties you should be fetching
			// This should only open if you have a server currently selected
			Controller.OpenMenu( "TribesGui.TribesMPServerPropertiesMenu", "TribesMPServerPropertiesMenu",,, list.Elements[list.Index].ExtraIntData );
			TribesMPServerPropertiesMenu(Controller.ActivePage).OnConnect = OnServerPropertiesConnect;
		   break;
		case MarkFavoriteButton:
			toggleFavorite();
			break;
		case JoinServerButton:
		default:
    		//OpenDlg( "Do you wish to join server "$ServerListBox.FindColumn( "ServerName" ).MCList.GetExtra()$"?", QBTN_YesNo, "JoinServer" );

			list = ServerListBox.FindColumn("StatusIcon").MCList;

			if (list.index < 0)
				return;

			ConnectToSelectedServer();
            break;

    }
}

function string getSelectedIPAddress()
{
	local PlayerProfile p;
	local GUIList list;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	list = ServerListBox.FindColumn("ServerName").MCList;
	return gm.GetServerIpAddress(list.Elements[list.Index].ExtraIntData);
}

function string getSelectedPort()
{
	local PlayerProfile p;
	local GUIList list;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	list = ServerListBox.FindColumn("ServerName").MCList;
	return gm.GetServerPort(list.Elements[list.Index].ExtraIntData);
}

function toggleFavorite()
{
	local PlayerProfile P;
	local GUIList list;

	P = TribesGUIController(Controller).profileManager.GetActiveProfile();
	p.toggleServerFavorite(getSelectedIPAddress(), getSelectedPort());

	// Toggle icon
	list = ServerListBox.FindColumn("FavsIcon").MCList;
	if (list.Elements[list.Index].ExtraData != FavIconImage)
		list.Elements[list.Index].ExtraData = FavIconImage;
	else
	{
		Log("Setting ExtraData to None");
		list.Elements[list.Index].ExtraData = None;
	}
}

function ConnectToSelectedServer()
{
	local GUIList list;
	local String ipAddress;
	local String portNumber;

	list = ServerListBox.FindColumn("ServerName").MCList;

	ipAddress = gm.GetServerIpAddress(list.Elements[list.Index].ExtraIntData);
	portNumber = gm.GetServerPort(list.Elements[list.Index].ExtraIntData);

	if (ipAddress == "" || portNumber == "")
	{
		GUIPage(MenuOwner.MenuOwner).OpenDlg(BadServerIdText, QBTN_Ok);
		return;
	}

	AttemptURL(ipAddress $ ":" $ portNumber);
}

function UpdateCountLabels()
{
	ServerCountLabel.Caption = string(numServers)@"/"@gm.GetNumPotentialServers();
	PlayerCountLabel.Caption = replaceStr(playerCountText, string(numPlayers));
}

function ReceiveServerData(GameSpyServerData gssd)
{
	local int tempPasswordCheck;
	local string PreviouslySelectedServer;
	local int ping;
	local int serverMinVer;
	local int serverVer;
	local int clientMinVer;
	local int clientVer;

	numServers++;
	numPlayers += int(gssd.gsNumPlayers);

	UpdateCountLabels();

	// Don't display the server if its version doesn't match
	if (!bShowUnsupportedVersions)
	{
		serverMinVer = int(gssd.gsMinVersion);
		serverVer = int(gssd.gsGameVer);
		clientMinVer = int(class'Object'.static.GetMinCompatibleBuildNumber());
		clientVer = int(class'Object'.static.GetBuildNumber());

		if (clientVer < serverMinVer || serverVer < clientMinVer)
			return;
	}

	tempPasswordCheck = int(bool(gssd.gsRequiresPassword));

    PreviouslySelectedServer = ServerListBox.GetColumn( "ServerName" ).GetExtra();

	if (tempPasswordCheck > 0)
		ServerListBox.AddNewRowElement( "StatusIcon",LockedIconImage,,,true );

	if (gssd.gsTrackingStats ~= "true")
		ServerListBox.AddNewRowElement( "StatsIcon",StatsIconImage,,,true );

	if (TribesGUIController(Controller).profileManager.GetActiveProfile().hasServerFavorite(gm.GetServerIPAddress(gssd.gsServerId), gm.GetServerPort(gssd.GsServerId)) )
		ServerListBox.AddNewRowElement( "FavsIcon",FavIconImage,,,true );

	ServerListBox.AddNewRowElement( "ServerName",,	gssd.gsHostName, gssd.gsServerId );
	ServerListBox.AddNewRowElement( "Info",,		gssd.gsMapName $ " - " $ gssd.gsGameType );
	ServerListBox.AddNewRowElement( "Players",,		gssd.gsNumPlayers $ "/" $ gssd.gsMaxPlayers, int(gssd.gsNumPlayers) );

	// A zero ping means the ping failed
	if (gssd.gsPing == 0)
		ping = 9999;
	else
		ping = gssd.gsPing;
	ServerListBox.AddNewRowElement( "Ping",,		String(ping), ping );

	ServerListBox.PopulateRow();
	ServerListBox.Sort();

    // Reselect the previously selected server
    //ServerListBox.GetColumn( "ServerName" ).FindExtra(PreviouslySelectedServer);
}

// Filtering
function RefreshFilters()
{
	local int i;
	local int currentIndex;

	bRefreshingFilters = true;
	currentIndex = FilterBox.GetIndex();
	FilterBox.Clear();

	// Load filters; look for custom first, use default if missing
	// Just use new and don't worry about the small leak since it'll be cleaned up once a level loads
	filterInfo = new(Outer, "Custom") class'ServerFilterInfo';

	if (filterInfo.filterList.Length == 0)
	{
		filterInfo = new(Outer, "Default") class'ServerFilterInfo';
	}

	// Always have a None filter
	FilterBox.AddItem(noneString);

	for (i=0; i<filterInfo.filterList.Length; i++)
		FilterBox.AddItem(filterInfo.filterList[i].filterName);

	FilterBox.SetIndex(currentIndex);

	bRefreshingFilters = false;
}

function OnFilterChange(GUIComponent Sender)
{
	// There seems to be some kind of bug that causes this function to be called multiple times when the page in activated
	if (bRefreshingFilters)
		return;

	StartListUpdate();
}

function OnPatch(GUIComponent Sender)
{
	LastPatchCheckTime = PlayerOwner().Level.Timeseconds;
	Controller.OpenMenu("TribesGUI.TribesPatchCheck");
}

function OnQueryPatchResult(bool bNeeded, bool bMandatory, string versionName, string URL)
{
	if (bNeeded)
		OnPatch(PatchButton);
	else
		log("Program is up-to-date.");
}

defaultproperties
{
	OnActivate=InternalOnActivate
	OnDeActivate=InternalOnDeActivate
	OnHide=InternalOnHide
	GamespyTimeoutText="Error: a request to the Gamespy service timed out."
	GamespyTimeout = 30
	PatchCheckPeriod=900
	LockedIcon=Texture'GUITribes.Lock'
	StatsIcon=Texture'GUITribes.Stats'
	FavIcon=Texture'GUITribes.Icon_Favourite'

	ServerPasswordText="This server is password protected. Please enter the password."
	GamespyLoginSuccessText="You successfully logged in to your team."
	BadAuthPasswordText="Team login failed: The password is not correct for that team."
	BadParamText="Team login failed: A bad parameter was sent to the server."
	NoResponse="Team login failed: Unable to get a response from the team login server"
	BadServerIdText="Server connection: A bad server id was detected"
	PlayerCountText="%1 players online"
	NoneString="NONE"
	maxQueryLength=256
}
