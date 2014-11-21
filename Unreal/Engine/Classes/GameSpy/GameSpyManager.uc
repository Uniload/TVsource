class GameSpyManager extends Core.Object
	native;

enum EGameSpyResult
{
	GSR_VALID_PROFILE,
	GSR_USER_CONNECTED,
	GSR_REGISTERED_UNIQUE_NICK,
	GSR_UNIQUE_NICK_TAKEN,
	GSR_BAD_EMAIL,
	GSR_BAD_PASSWORD,
	GSR_BAD_NICK,
	GSR_TIMED_OUT,
	GSR_GENERAL_FAILURE
};

enum ETeamAffiliationResult
{
	TAR_PLAYER_AFFILIATED,
	TAR_TEAM_ID_MISMATCH,
	TAR_OLD_JOIN_TIME
};

var GameEngine	Engine;

var const bool	bAvailable;
var const bool	bFailedAvailabilityCheck;

var const bool	bInitAsServer;
var const bool	bInitAsClient;

var const bool	bInitialised;
var const bool	bFailedInitialisation;

var const bool	bTrackingStats;				// If true try to initialise the stat tracker
var const bool	bStatsInitalised;

var const bool	bUsingPresence;				// If true try to initialise the presence sdk
var const bool	bPresenceInitalised;

var const bool	bServerUpdateFinished;		// Used during GetNextServer
var const int	currentServerIndex;			// Used during GetNextServer

var Array<byte> ServerKeyIds;
var Array<String> ServerKeyNames;

var Array<byte> PlayerKeyIds;
var Array<String> PlayerKeyNames;

var Array<byte> TeamKeyIds;
var Array<String> TeamKeyNames;

var Array<byte> CustomServerKeyIds;
var Array<String> CustomServerKeyNames;

var Array<byte> CustomPlayerKeyIds;
var Array<String> CustomPlayerKeyNames;

var Array<byte> CustomTeamKeyIds;
var Array<String> CustomTeamKeyNames;

// The key ids for the values that will be initially retrieved during a server update
var Array<byte> InitialKeyIds;

var private globalconfig string ProductVersionID;			// for auto-patching, build number is used if this is empty
var private globalconfig localized string ProductRegionID;	// for auto-patching
var globalconfig string BaseFilePlanetPatchURL;

// This function initialises GameSpy as a client
// Note: This function only tells GameSpy to initialise it may take longer and wont be initialised after returning from this function
// The GameSpyInitialised event will be called once GameSpy has finished initalising.
// There is no need for a script side function to init as a server as this is done automatically in native code when a server starts
final native function InitGameSpyClient();

// This event is called once GameSpy as initialised
event GameSpyInitialised();

event OnLevelChange()
{
	SendGameSpyGameModeChange();
}

event InitGameSpyData();
final native function LevelInfo GetLevelInfo();

final native function Player GetPlayerObject();

final native function SendGameSpyGameModeChange();

// This function starts an update of the server list
final native function UpdateServerList(optional String filter);

// This function starts an update of the server list for the LAN
final native function LANUpdateServerList();

// This function clears the internal server list
final native function ClearServerList();

// This function updates a server based on ip and port
final native function UpdateServerByIP(String ipAddress, int serverGamePort);

// This function starts an update for a specific server in the list to update server specific data (player/team data)
// serverId is the server id received in UpdatedServerData during a server list update
// if refresh is true then the update will be done even if the server data is already available
final native function UpdateServer(int serverId, bool Refresh);

// This function will cancel a previously started update of the server list
final native function CancelUpdate();

// This function returns the ip address for the given serverId
final native function String GetServerIpAddress(int serverId);

// This function returns the port for the given serverId
final native function String GetServerPort(int serverId);

// This function returns the number of servers, including servers that haven't been updated yet
final native function int GetNumPotentialServers();

// This function can be used to iterate over all the servers currently in the list
// Returns true if there is still more data, but the data may not have arrived yet
// If the data has not arrived yet serverId will be zero
final native function bool GetNextServer(out int serverId, out String ipAddress, out Array<String> serverData);

// Call this function when a new game starts to tell the stat tracking server
final native function StatsNewGameStarted();

// Call this function to verify that a connected player has a profile id and stat response string
final native function bool StatsHasPIDAndResponse(PlayerController pc);

// Call this function to get the profile id for the given player controller
final native function String StatsGetPID(PlayerController pc);

// Call this function to get the stat response string for the given player controller
final native function String StatsGetStatResponse(PlayerController pc);

// Call this function to add a new player to the stat tracking server
final native function StatsNewPlayer(int playerId, string playerName);

// Call this function to add a new team to the stat tracking server
final native function StatsNewTeam(int TeamID, string TeamName);

// Call this function to remove a player from the stat tracking server
final native function StatsRemovePlayer(int playerId);

// Call this function to remove a team from the stat tracking server
final native function StatsRemoveTeam(int TeamID);

// Set the value of a server related stat
final native function SetServerStat(coerce string statName, coerce string statValue);

// Set the value of a player specific stat
final native function SetPlayerStat(coerce string statName, coerce string statValue, int playerId);

// Set the value of a team specific stat
final native function SetTeamStat(coerce string statName, coerce string statValue, int TeamID);

// Call this function to send a snapshot of the game stats to the stat server. Set finalSnapshot to true if the game has ended (default false)
final native function SendStatSnapshot(optional bool finalSnapshot);

// Call this function to create a new user account
final native function CreateUserAccount(string Nick, string Email, string Password);

// Call this function to check with GameSpy that the given account details are valid
final native function CheckUserAccount(string Nick, string Email, string Password);

// Call this function to connect to the GameSpy server with the given account details
final native function ConnectUserAccount(string Nick, string Email, string Password);

event UserConnectionResult(EGameSpyResult result, int profileId, string UniqueNick);

// Call this function to disconnect the currently connected user account
final native function DisconnectUserAccount();

// Call this function to register a unique nick for the currently connected profile
final native function RegisterUniqueNick(string UniqueNick);

event UniqueNickRegistrationResult(EGameSpyResult result);

// Call this function to authenticate a profile before trying to write private data
final native function AuthenticateProfile(int profileId, string Password);

event AuthenticatedProfileResult(int profileId, int authenticated, string error);

// Call this function to get the teamId for a teamTag
final native function FindTeam(string teamTag);

event FindTeamResult(int teamId);

// Call this function to set private read/write data for a profile
final native function SetDataPrivateRW(int profileId, string PrivateData);

event SetDataPrivateRWResult(int success);

// Call this function to send a get request to the given URL
final native function HTTPGetRequest(String URL, bool bBlock);

event HTTPGetRequestResult(bool succeeded, String ResponseData);

final native function SetTeamAffiliation(int profileId, int teamId, PlayerReplicationInfo pri);

event SetTeamAffiliationResult(ETeamAffiliationResult result, String TeamTag, PlayerReplicationInfo pri);

// This function is called each time a servers data is updated
event UpdatedServerData(int serverId, String ipAddress, int Ping, bool bLAN, Array<String> serverData, Array<String> playerData, Array<String> teamData);

// This function is called after an update of the server list completes
event UpdateComplete(bool bLAN);

// This function is called on the server to get the data for a particular server key
event string GetValueForKey(int key);

// This function is called on the server to get the data for a particular player key
event string GetValueForPlayerKey(int key, int index);

// This function is called on the server to get the data for a particular team key
event string GetValueForTeamKey(int key, int index);

event int GetNumTeams()
{
	return 0;
}

// Client side function to get the user's GameSpy profile id
event String GetGameSpyProfileId();

event String GetGameSpyPassword();

event EmailAlreadyTaken();
event ProfileCreateResult(EGameSpyResult result, int profileId);
event ProfileCheckResult(EGameSpyResult result, int profileId);

private event string GetProductVersionID()
{
	if (ProductVersionID == "")
		return GetBuildNumber();
	else
		return ProductVersionID;
}

private event string GetProductRegionID()
{
	return ProductRegionID;
}

private event string GetPatchDownloadURL(int FilePlanetID)
{
	return BaseFilePlanetPatchURL $ string(FilePlanetID);
}

// Check if a patch is required. Calls OnQueryPatchResult with the result of the query.
native function QueryPatch();

private event QueryPatchCompleted(bool bNeeded, bool bMandatory, string versionName, int fileplanetID, string URL)
{
	if (fileplanetID > 0)
	{
		OnQueryPatchResult(bNeeded, bMandatory, versionName, GetPatchDownloadURL(fileplanetID));
	}
	else
	{
		OnQueryPatchResult(bNeeded, bMandatory, versionName, URL);
	}
}

delegate OnQueryPatchResult(bool bNeeded, bool bMandatory, string versionName, string URL);


defaultproperties
{
	BaseFilePlanetPatchURL="http://www.fileplanet.com/index.asp?file="
}