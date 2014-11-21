class TribesGameSpyManager extends Engine.GameSpyManager;

const MAX_REGISTERED_KEYS	= 254;
const NUM_RESERVED_KEYS		= 50;		// GameSpy reserve key ids upto 50

// Current GameSpy key ids that can be used
// Server specific
const HOSTNAME_KEY			= 1;
const GAMENAME_KEY			= 2;
const GAMEVER_KEY			= 3;
const HOSTPORT_KEY			= 4;
const MAPNAME_KEY			= 5;
const GAMETYPE_KEY			= 6;
const GAMEVARIANT_KEY		= 7;
const NUMPLAYERS_KEY		= 8;
const NUMTEAMS_KEY			= 9;
const MAXPLAYERS_KEY		= 10;
const GAMEMODE_KEY			= 11;
const TEAMPLAY_KEY			= 12;
const FRAGLIMIT_KEY			= 13;
const TEAMFRAGLIMIT_KEY		= 14;
const TIMEELAPSED_KEY		= 15;
const TIMELIMIT_KEY			= 16;
const ROUNDTIME_KEY			= 17;
const ROUNDELAPSED_KEY		= 18;
const PASSWORD_KEY			= 19;
const GROUPID_KEY			= 20;

// Player specific
const PLAYER__KEY			= 21;
const SCORE__KEY			= 22;
const SKILL__KEY			= 23;
const PING__KEY				= 24;
const TEAM__KEY				= 25;
const DEATHS__KEY			= 26;
const PID__KEY				= 27;

// Team specific
const TEAM_T_KEY			= 28;
const SCORE_T_KEY			= 29;

// Add custom server/player/team key ids here. Must be > 50 and <= 254
//const SAMPLESERVER_KEY		= 51; // sample server key
//const SAMPLEPLAYER__KEY		= 52; // sample player key note extra _
//const SAMPLETEAM_T_KEY		= 53; // sample team key note extra _T
const TEAMONE_KEY			= 51;
const TEAMTWO_KEY			= 52;
const TEAMONESCORE_KEY		= 53;
const TEAMTWOSCORE_KEY		= 54;
const ADMINNAME_KEY			= 55;
const ADMINEMAIL_KEY		= 56;
const PLAYERNAMES_KEY		= 57;
const TRACKINGSTATS_KEY		= 58;
const DEDICATED_KEY			= 59;
const MINVER_KEY			= 60;

struct SCreateTeamData
{
	var String ProfilePassword;
	var String TeamTag;
	var String TeamName;
	var String TeamPassword;
	var int TeamId;
};

var SCreateTeamData CreateTeamData;

var bool bMapChange;

event OnLevelChange()
{
	bMapChange = true;
	super.OnLevelChange();
}

function InitGameSpyData()
{
	// Init server keys
	ServerKeyIds[ServerKeyIds.Length] = MAPNAME_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "MapName";

	ServerKeyIds[ServerKeyIds.Length] = NUMPLAYERS_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "numplayers";

	ServerKeyIds[ServerKeyIds.Length] = MAXPLAYERS_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "maxplayers";

	ServerKeyIds[ServerKeyIds.Length] = HOSTNAME_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "hostname";

	ServerKeyIds[ServerKeyIds.Length] = HOSTPORT_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "hostport";

	ServerKeyIds[ServerKeyIds.Length] = GAMETYPE_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "gametype";

	ServerKeyIds[ServerKeyIds.Length] = GAMEVER_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "gamever";

	ServerKeyIds[ServerKeyIds.Length] = PASSWORD_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "password";

	ServerKeyIds[ServerKeyIds.Length] = GAMENAME_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "gamename";

	ServerKeyIds[ServerKeyIds.Length] = GAMEMODE_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "gamemode";

	ServerKeyIds[ServerKeyIds.Length] = GAMEVARIANT_KEY;
	ServerKeyNames[ServerKeyNames.Length] = "gamevariant";

	// Init player keys
	PlayerKeyIds[PlayerKeyIds.Length] = PLAYER__KEY;
	PlayerKeyNames[PlayerKeyNames.Length] = "player";

	PlayerKeyIds[PlayerKeyIds.Length] = PING__KEY;
	PlayerKeyNames[PlayerKeyNames.Length] = "ping";

	PlayerKeyIds[PlayerKeyIds.Length] = SCORE__KEY;
	PlayerKeyNames[PlayerKeyNames.Length] = "score";

	PlayerKeyIds[PlayerKeyIds.Length] = TEAM__KEY;
	PlayerKeyNames[PlayerKeyNames.Length] = "team";

	// Init team keys
	//TeamKeyIds[TeamKeyIds.Length] = TEAM_T_KEY;
	//TeamKeyNames[TeamKeyNames.Length] = "team_t";

	// Init custom server keys
	CustomServerKeyIds[CustomServerKeyIds.Length] = TEAMONE_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "teamone";

	CustomServerKeyIds[CustomServerKeyIds.Length] = TEAMTWO_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "teamtwo";

	CustomServerKeyIds[CustomServerKeyIds.Length] = TEAMONESCORE_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "teamonescore";

	CustomServerKeyIds[CustomServerKeyIds.Length] = TEAMTWOSCORE_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "teamtwoscore";

	CustomServerKeyIds[CustomServerKeyIds.Length] = ADMINNAME_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "adminname";

	CustomServerKeyIds[CustomServerKeyIds.Length] = ADMINEMAIL_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "adminemail";

	CustomServerKeyIds[CustomServerKeyIds.Length] = PLAYERNAMES_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "p";

	CustomServerKeyIds[CustomServerKeyIds.Length] = TRACKINGSTATS_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "trackingstats";

	CustomServerKeyIds[CustomServerKeyIds.Length] = DEDICATED_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "dedicated";

	CustomServerKeyIds[CustomServerKeyIds.Length] = MINVER_KEY;
	CustomServerKeyNames[CustomServerKeyNames.Length] = "minver";

	// Init custom player keys

	// Init custom team keys

	checkKeyIds();

	InitialKeyIds[InitialKeyIds.Length] = MAPNAME_KEY;
	InitialKeyIds[InitialKeyIds.Length] = NUMPLAYERS_KEY;
	InitialKeyIds[InitialKeyIds.Length] = MAXPLAYERS_KEY;
	InitialKeyIds[InitialKeyIds.Length] = HOSTNAME_KEY;
	InitialKeyIds[InitialKeyIds.Length] = HOSTPORT_KEY;
	InitialKeyIds[InitialKeyIds.Length] = GAMETYPE_KEY;
	InitialKeyIds[InitialKeyIds.Length] = GAMEVER_KEY;
	InitialKeyIds[InitialKeyIds.Length] = PASSWORD_KEY;
	InitialKeyIds[InitialKeyIds.Length] = GAMENAME_KEY;
	InitialKeyIds[InitialKeyIds.Length] = GAMEMODE_KEY;
	InitialKeyIds[InitialKeyIds.Length] = GAMEVARIANT_KEY;
	InitialKeyIds[InitialKeyIds.Length] = TRACKINGSTATS_KEY;
	InitialKeyIds[InitialKeyIds.Length] = DEDICATED_KEY;
	InitialKeyIds[InitialKeyIds.Length] = MINVER_KEY;
}

function checkKeyIds()
{
	local int i;

	assert(ServerKeyIds.Length +
		   PlayerKeyIds.Length +
		   TeamKeyIds.Length +
		   CustomServerKeyIds.Length +
		   CustomPlayerKeyIds.Length +
		   CustomTeamKeyIds.Length <= MAX_REGISTERED_KEYS);

	for (i = 0; i < ServerKeyIds.Length; ++i)
		assert(ServerKeyIds[i] > 0 && ServerKeyIds[i] <= 50);

	for (i = 0; i < PlayerKeyIds.Length; ++i)
		assert(PlayerKeyIds[i] > 0 && PlayerKeyIds[i] <= 50);

	for (i = 0; i < TeamKeyIds.Length; ++i)
		assert(TeamKeyIds[i] > 0 && TeamKeyIds[i] <= 50);

	for (i = 0; i < CustomServerKeyIds.Length; ++i)
		assert(CustomServerKeyIds[i] > 50 && CustomServerKeyIds[i] <= 254);

	for (i = 0; i < CustomPlayerKeyIds.Length; ++i)
		assert(CustomPlayerKeyIds[i] > 50 && CustomPlayerKeyIds[i] <= 254);

	for (i = 0; i < CustomTeamKeyIds.Length; ++i)
		assert(CustomTeamKeyIds[i] > 50 && CustomTeamKeyIds[i] <= 254);
}

function GameSpyInitialised()
{
	if (bInitAsClient)
	{
		OnGameSpyInitialised();
		OnGameSpyPresenceInitialised();
	}
}

delegate OnGameSpyInitialised();
delegate OnGameSpyPresenceInitialised();

function UpdatedServerData(int ServerId, String ipAddress, int Ping, bool bLAN, Array<String> serverData, Array<String> playerData, Array<String> teamData)
{
	local GameSpyServerData gssd;
	local int i;

	gssd.gsServerId = ServerId;
	gssd.gsIpAddress = ipAddress;
	gssd.gsPing = Ping;
	gssd.gsLAN = bLAN;

	// Server data
	gssd.gsMapName = serverData[0];
	gssd.gsNumPlayers = serverData[1];
	gssd.gsMaxPlayers = serverData[2];
	gssd.gsHostName = serverData[3];
	gssd.gsHostPort = serverData[4];
	gssd.gsGameType = serverData[5];
	gssd.gsGameVer = serverData[6];
	gssd.gsRequiresPassword = serverData[7];

	// Custom server data
	gssd.gsTeamOneName = serverData[11];
	gssd.gsTeamTwoName = serverData[12];
	gssd.gsTeamOneScore = serverData[13];
	gssd.gsTeamTwoScore = serverData[14];
	gssd.gsAdminName = serverData[15];
	gssd.gsAdminEmail = serverData[16];
	gssd.gsTrackingStats = serverData[18];
	gssd.gsMinVersion = serverData[20];

	for (i = 0; i < playerData.Length; i += PlayerKeyIds.Length)
	{
		gssd.gsPlayerNames[gssd.gsPlayerNames.Length] = playerData[i];
		gssd.gsPlayerPings[gssd.gsPlayerPings.Length] = playerData[i + 1];
		gssd.gsPlayerScores[gssd.gsPlayerScores.Length] = playerData[i + 2];
		gssd.gsPlayerTeams[gssd.gsPlayerTeams.Length] = playerData[i + 3];
	}

	OnServerDataUpdate(gssd);
}

delegate OnServerDataUpdate(GameSpyServerData gssd)
{
	Log("Received a server but the OnServerDataUpdate delegate wasn't set");
}

function UpdateComplete(bool bLAN)
{
	OnUpdateComplete(bLAN);
}

delegate OnUpdateComplete(bool bLAN);

function string GetValueForKey(int key)
{
	local int ServerPort;

	switch(key)
	{
	case MAPNAME_KEY:
		if (GetLevelInfo() != None)
			return GetLevelInfo().Title;
		break;

	case NUMPLAYERS_KEY:
		return String(GetLevelInfo().Game.NumPlayers);

	case MAXPLAYERS_KEY:
		return String(GetLevelInfo().Game.MaxPlayers);

	case HOSTNAME_KEY:
		return GetLevelInfo().Game.GameReplicationInfo.ServerName;

	case HOSTPORT_KEY:
		ServerPort = GetLevelInfo().Game.GetServerPort();
//		log("Gamespy server key setting port to "$ServerPort);
		return String(ServerPort);

	case GAMETYPE_KEY:
		return GetLevelInfo().Game.acronym;

	case GAMEVER_KEY:
		return class'Object'.static.GetBuildNumber();

	case PASSWORD_KEY:
		if (GetLevelInfo().Game.AccessControl.RequiresPassword())
			return "1";
		else
			return "0";

	case GAMENAME_KEY:
		return "tribesv";

	case GAMEMODE_KEY:
		if (bMapChange || GetLevelInfo().Game == None)
		{
			bMapChange = false;
			return "closedwaiting";
		}

		return GameInfo(GetLevelInfo().Game).GetGameSpyGameMode();

	case GAMEVARIANT_KEY:
		if (GetLevelInfo().GetUrlOption("GameStats") ~= "true")
			return "1";
		else
			return "0";

	case TEAMONE_KEY:
		return GameInfo(GetLevelInfo().Game).GetTeamFromIndex(0).localizedName;

	case TEAMTWO_KEY:
		return GameInfo(GetLevelInfo().Game).GetTeamFromIndex(1).localizedName;

	case TEAMONESCORE_KEY:
		return String(GameInfo(GetLevelInfo().Game).GetTeamFromIndex(0).score);

	case TEAMTWOSCORE_KEY:
		return String(GameInfo(GetLevelInfo().Game).GetTeamFromIndex(1).score);

	case ADMINNAME_KEY:
		return GetLevelInfo().Game.GameReplicationInfo.AdminName;

	case ADMINEMAIL_KEY:
		return GetLevelInfo().Game.GameReplicationInfo.AdminEmail;

	case PLAYERNAMES_KEY:
		return GameInfo(GetLevelInfo().Game).GetPlayerNamesList();

	case TRACKINGSTATS_KEY:
		return String(GetLevelInfo().GetUrlOption("GameStats") ~= "true");

	case DEDICATED_KEY:
		if (GetLevelInfo().NetMode == NM_DedicatedServer)
			return "true";
		else
			return "false";

	case MINVER_KEY:
		return class'Object'.static.GetMinCompatibleBuildNumber();
	}

	return "";
}

function string GetValueForPlayerKey(int key, int index)
{
	local PlayerController pc;
	local TribesReplicationInfo tri;

	local int playerScore;

	pc = GetPlayerControllerFromIndex(index);
	tri = TribesReplicationInfo(pc.PlayerReplicationInfo);

	if (pc == None)
	{
		Log("Controller for index " $ index $ " was None");
		return "";
	}

	switch (key)
	{
	case PLAYER__KEY:
		return tri.PlayerName;
		break;

	case PING__KEY:
		// This comment in PlayerReplicationInfo may mean that this value is wrong: "packet loss packed into this property as well"
		return String(tri.Ping);
		break;

	case SCORE__KEY:
		playerScore = tri.Score; // PlayerReplicationInfo's score field is a float but we want it as an int
		return String(playerScore);
		break;

	case TEAM__KEY:
		if (tri.team != None)
			return tri.team.localizedName;
		else
			return "";

		break;
	}

	return "";
}

function PlayerController GetPlayerControllerFromIndex(int index)
{
	local int i;
	local LevelInfo li;
	local Controller c;
	local PlayerController pc;

	li = GetLevelInfo();

	if (li == None)
		return None;

	i = 0;
	For (c = li.ControllerList; c != None; c = c.NextController)
	{
		pc = PlayerController(c);

		if (pc != None)
		{
			if (i == index)
				return pc;

			++i;
		}
	}

	return None;
}

function string GetValueForTeamKey(int key, int index)
{
	local TeamInfo ti;
	local LevelInfo li;
	local GameInfo gi;

	li = GetLevelInfo();

	if (li == None)
		return "";

	gi = GameInfo(li.Game);

	if (gi == None)
		return "";

	ti = gi.GetTeamFromIndex(index);

	if (ti == None)
		return "";

	switch (key)
	{

	}

	return "";
}

event int GetNumTeams()
{
	local LevelInfo li;
	local GameInfo gi;

	li = GetLevelInfo();

	if (li != None)
	{
		gi = GameInfo(li.Game);

		if (gi != None)
			return gi.numTeams();
	}

	return 0;
}

function EmailAlreadyTaken()
{
	OnEmailAlreadyTaken();
}

delegate OnEmailAlreadyTaken()
{
	Log("Received an email already taken event but the OnEmailAlreadyTaken delegate wasn't set");
}

function ProfileCreateResult(EGameSpyResult result, int profileId)
{
	OnProfileCreateResult(result, profileId);
}

delegate OnProfileCreateResult(EGameSpyResult result, int profileId)
{
	Log("Received a profile create result event but the OnProfileCreateResult delegate wasn't set");
}

function ProfileCheckResult(EGameSpyResult result, int profileId)
{
	OnProfileCheckResult(result, profileId);
}

delegate OnProfileCheckResult(EGameSpyResult result, int profileId)
{
	Log("Received a profile check result event but the OnProfileCheckResult delegate wasn't set");
}

function String GetGameSpyProfileId()
{
	local Player p;
	local TribesGUIControllerBase gc;

	p = GetPlayerObject();

	if (p != None)
	{
		gc = TribesGUIControllerBase(p.GUIController);

		if (gc != None)
			return String(gc.GetGameSpyProfileId());
		else
			Log("Tried to get GameSpy profile id, but the GUIController was not derived from TribesGUIControllerBase");
	}
	else
		Log("Tried to get GameSpy profile id, but there was no player object");

	return "";
}

function String GetGameSpyPassword()
{
	local Player p;
	local TribesGUIControllerBase gc;

	p = GetPlayerObject();

	if (p != None)
	{
		gc = TribesGUIControllerBase(p.GUIController);

		if (gc != None)
			return gc.GetGameSpyPassword();
		else
			Log("Tried to get the GameSpy password, but the GUIController was not derived from TribesGUIControllerBase");
	}
	else
		Log("Tried to get the GameSpy password, but there was no player object");

	return "";
}

function CreateTeam(string Nick, string Email, string Password, string TeamTag, string TeamName, string TeamPassword)
{
	CreateTeamData.ProfilePassword = Password;
	CreateTeamData.TeamTag = TeamTag;
	CreateTeamData.TeamName = TeamName;
	CreateTeamData.TeamPassword = TeamPassword;

	ConnectUserAccount(Nick, Email, Password);
}

delegate OnProfileAuthError()
{
	Log("Authentication failed during team creation but the OnProfileAuthError delegate wasn't set");
}

function UserConnectionResult(EGameSpyResult result, int profileId, string UniqueNick)
{
	if (result == GSR_USER_CONNECTED)
	{
		CreateTeamData.TeamId = profileId;
		AuthenticateProfile(profileId, CreateTeamData.ProfilePassword);
	}
	else
		OnProfileAuthError();
}

function AuthenticatedProfileResult(int profileId, int authenticated, string error)
{
	if (authenticated == 1)
	{
		RegisterUniqueNick(CreateTeamData.TeamTag);
	}
	else
	{
		DisconnectUserAccount();
		OnProfileAuthError();
	}
}

delegate OnTeamTagTaken()
{
	Log("The given team tag was already taken but the OnTeamTagTaken delegate was not set");
}

delegate OnTeamRegistrationError()
{
	Log("There was a team tag registration error but the OnTeamTagRegistrationError delegate was not set");
}

function UniqueNickRegistrationResult(EGameSpyResult result)
{
	if (result == GSR_REGISTERED_UNIQUE_NICK)
	{
		SetDataPrivateRW(CreateTeamData.TeamId, "\\TeamPassword\\" $ CreateTeamData.TeamPassword $ "\\TeamName\\" $ CreateTeamData.TeamName);
		return;
	}
	else if (result == GSR_UNIQUE_NICK_TAKEN)
		OnTeamTagTaken();
	else
		OnTeamRegistrationError();

	DisconnectUserAccount();
}

delegate OnTeamCreated()
{
	Log("Team was created but the OnTeamCreated delegate was not set");
}

function SetDataPrivateRWResult(int success)
{
	if (success == 1)
		OnTeamCreated();
	else
		OnTeamRegistrationError();

	DisconnectUserAccount();
}

delegate OnFindTeamResult(int teamId)
{
	Log("Received a find team result but the OnFindTeamResult delegate was not set");
}

function FindTeamResult(int teamId)
{
	OnFindTeamResult(teamId);
}

function LoginTeam(int profileId, int teamId, string TeamPassword, bool bBlock)
{
	HTTPGetRequest("http://gamestats.gamespy.com/tribesv/TribesTeamLogin.asp?playerID=" $ profileId $ "&teamID=" $ teamId $ "&password=" $ TeamPassword, bBlock);
}

delegate OnLoginTeamResult(bool succeeded, String ResponseData)
{
	Log("Received a team login result but the OnLoginTeamResult delegate was not set");
}

function HTTPGetRequestResult(bool succeeded, String ResponseData)
{
	OnLoginTeamResult(succeeded, ResponseData);
}

function SetTeamAffiliationResult(ETeamAffiliationResult result, String TeamTag, PlayerReplicationInfo pri)
{
	local TribesReplicationInfo TRI;

	if (result == TAR_PLAYER_AFFILIATED)
	{
		TRI = TribesReplicationInfo(pri);

		TRI.teamTag = TeamTag;
	}
}

defaultproperties
{
	bUsingPresence = true
	bTrackingStats = true
}