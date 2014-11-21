// TribesReplicationInfo
// Players go in and out of relevancy as the game plays out. All the information that must be
// available to clients at all times should be held in this class.
class TribesReplicationInfo extends Engine.PlayerReplicationInfo;

var TeamInfo team;
var String teamTag;
var int health;
var String VoiceSetPackageName;
var string userSkinName;
var string oldUserSkinName;
var class<SkinInfo> userSkinClass;
var bool bReady;
var int numReadies;			// Used to prevent spamming while waiting for tourney mode to start
var bool bTeamChanged;

// Tribes scoring has more than one category
var int offenseScore;
var int defenseScore;
var int styleScore;

// Stats are replicated on demand, not whenever they change
var Array<StatData> statDataList;

var int statID;

var int lastStatRequestTime;
var int maxStatRequestInterval;

var int playerStatIndex; // Used by GameSpy stat tracking

var bool bAttemptedTeamAffiliation;

replication
{
	reliable if (Role == ROLE_Authority)
		team, health, offenseScore, defenseScore, styleScore, statID, bReady,
		clientReceiveStatData, clientInitStatData, VoiceSetPackageName, userSkinName, teamTag;

	reliable if (Role < ROLE_Authority)
		requestStatUpdates, requestStatInit, requestTeamAffiliation;
}

function PostBeginPlay()
{
	local ModeInfo mode;

	super.PostBeginPlay();

	mode = ModeInfo(Level.Game);

	if (mode != None)
		statID = mode.Tracker.createStatID();
}
// TEAMTAG: Removed
//simulated function PostNetBeginPlay()
//{
//	Super.PostNetBeginPlay();
//
//	if (!bAttemptedTeamAffiliation && bNetOwner && Owner != None)
//		AttemptTeamAffiliation();
//}

simulated function PostNetReceive()
{
	if (!bAttemptedTeamAffiliation && bNetOwner && Owner != None)
		AttemptTeamAffiliation();
}

simulated function AttemptTeamAffiliation()
{
	local TribesGUIControllerBase gc;
	local int profileId;
	local int teamId;

	if (Level.NetMode ==  NM_Client && teamTag == "")
	{
		gc = TribesGUIControllerBase(PlayerController(Owner).Player.GUIController);

		if (gc != None && gc.UseGameSpyTeamAffiliation())
		{
			profileId = gc.GetGameSpyProfileId();
			teamId = gc.GetGameSpyTeamId();

			if (profileId != 0 && teamId != 0)
				requestTeamAffiliation(profileId, teamId);
		}
	}

	bAttemptedTeamAffiliation = true;
}

// Performed by server on client request
function requestStatInit()
{
	// Instruct client to initialize statDataList
	clientInitStatData(statDataList.Length);
}

function requestStatUpdates()
{
	local TribesReplicationInfo TRI;
	local GameReplicationInfo GRI;
	local int i, j;

	// Don't allow clients to hammer for stats
	if (Level.Timeseconds - lastStatRequestTime < maxStatRequestInterval)
		return;

	lastStatRequestTime = Level.Timeseconds;

	// Send every statData for every TRI back to the client
	GRI = Level.Game.GameReplicationInfo;
	for (i=0; i<GRI.PRIArray.Length; i++)
	{
		TRI = TribesReplicationInfo(GRI.PRIArray[i]);
		if (TRI == None)
			continue;

		for (j=0; j<TRI.statDataList.Length; j++)
		{
			clientReceiveStatData(TRI.statID, TRI.statDataList[j].statClass, TRI.statDataList[j].amount, j);
		}
	}
}

function requestTeamAffiliation(int profileId, int teamId)
{
	local TribesGameSpyManager gm;

	gm = TribesGameSpyManager(Level.GetGameSpyManager());

	if (gm != None)
		gm.SetTeamAffiliation(profileId, teamId, self);
}

simulated function String getTeamAffiliatedName()
{
	if (teamTag != "")
		return "[" $ teamTag $ "]" $ PlayerName;
	else
		return PlayerName;
}

simulated function clientInitStatData(int numStats)
{
	local TribesReplicationInfo TRI;
	local GameReplicationInfo GRI;
	local int i, j;

	if (Level.NetMode != NM_Client)
		return;

    GRI = PlayerController(Owner).GameReplicationInfo;
    for (i=0; i<GRI.PRIArray.Length; i++)
	{
		TRI = TribesReplicationInfo(GRI.PRIArray[i]);
		if (TRI == None)
			continue;

		TRI.statDataList.Remove(0, TRI.statDataList.Length);
		for (j=0; j<numStats; j++)
		{
			TRI.statDataList[TRI.statDataList.Length] = new class'statData';
		}
	}
}

simulated function clientReceiveStatData(int playerStatID, class<Stat> statClass, int amount, int statIndex)
{
	local TribesReplicationInfo TRI;
	local GameReplicationInfo GRI;
	local int i;

	if (Level.NetMode != NM_Client)
		return;

    GRI = PlayerController(Owner).GameReplicationInfo;

	for (i=0; i<GRI.PRIArray.Length; i++)
	{
		// Find the corresponding TRI based on playerStatID
		TRI = TribesReplicationInfo(GRI.PRIArray[i]);
		if (TRI == None)
			continue;

		if (TRI.statID == playerStatID)
		{
			TRI.statDataList[statIndex].statClass = statClass;
			TRI.statDataList[statIndex].amount = amount;
		}
	}

	//Log("STATS:  client received "$statClass$", num = "$amount$", id = "$playerStatID$", index = "$statIndex);
}

function updateStatData()
{
	local ModeInfo mode;
	local int i;

	mode = ModeInfo(Level.Game);
	if (mode == None)
		return;

	// Make sure the registered stats and this TRI's statData match up
	// Assume that if the lengths are the same, everything's ok, i.e. assume the stats that are
	// tracked don't change while a map is in progress.
	if (statDataList.Length != mode.Tracker.stats.Length)
	{
		// Otherwise, initialize everything
		statDataList.Length = 0;
		for (i=0; i<mode.Tracker.stats.Length; i++)
		{
			addStatData(mode.Tracker.stats[i]);
		}
	}
}

function addStatData(Stat s)
{
	//Log("STATS:  Adding statData for "$s);
	statDataList[statDataList.Length] = new class'StatData';
	statDataList[statDataList.Length - 1].statClass = s.Class;
	statDataList[statDataList.Length - 1].amount = 0;
}

function StatData getStatData(Class<Stat> s)
{
	local int i;

	// Find the stat.  Should ideally use a hash map instead.
	for (i=0; i<statDataList.Length; i++)
	{
		if (statDataList[i].statClass == s)
			return statDataList[i];
	}

	return None;
}

function setTeam(TeamInfo t)
{
	team = t;
}

function SetPlayerName(string S)
{
	local int i;
	local PlayerController PC;
	local int nameID;

	Super.SetPlayerName(S);

	PC = PlayerController(Owner);
	if (PC == None)
		return;

    // glenn: tribestv will correct with name "TribesTV" and GameReplicationInfo is None

    if (PC.GameReplicationInfo==None)
        return;

	// Enforce name uniqueness
	for (i=0; i<PC.GameReplicationInfo.PRIArray.Length; i++)
	{
		// Don't check against own name
		if (PC.GameReplicationInfo.PRIArray[i] == self)
			continue;

		if (PlayerName == PC.GameReplicationInfo.PRIArray[i].PlayerName)
		{
			// Check to see if there's already a non-zero integer on the end
			nameID = int(Right(PlayerName, 1));

			// Check for double digits in the event it was a 0
			if (nameID == 0)
				nameID = int(Right(PlayerName, 2));

			// If there was already an integer on the end of the name
			if (nameID != 0)
			{
				// Increment it and replace it
				PlayerName = Left(PlayerName, Len(PlayerName) -	Len(string(nameID))) $ nameID + 1;
			}
			else
			{
				// Otherwise, add a '1'
				PlayerName = PlayerName $ ".1";
			}
		}
	}

	// Strip color codes
	PlayerName = stripCodes(PlayerName);
}

// Script version of GUI's stripCodes (which unfortunately isn't static)
function string stripCodes(string str)
{
    local int StartPos;
	local int EndPos;
	local string rightStr;
	
	StartPos = InStr(str, "[C=");
	rightStr = Right(str, StartPos);
    EndPos = InStr(rightStr, "]") + StartPos + 3 - 1;		// 3 is length of "[C="
    while( StartPos != -1 && StartPos < EndPos )
    {
        str = Left( str, StartPos ) $ Mid( str, EndPos + 1);
		StartPos = InStr(str, "[C=");
		rightStr = Right(str, StartPos);
        EndPos = InStr(rightStr, "]") + StartPos + 3 - 1;
    }

	StartPos = InStr(str, "[\C]");
	while( StartPos != -1 )
	{
		str = Left( str, StartPos ) $ Mid( str, StartPos + 4 );
		StartPos = InStr(str, "[\C]");
	}

    return str;
}

simulated function Tick(float Delta)
{
	// check for skin change and load skin class
	if (oldUserSkinName != userSkinName)
	{
		if (userSkinName == "")
		{
			// clear skin
			userSkinClass = class'SkinInfo';
		}
		else
		{
			userSkinClass = class<SkinInfo>(DynamicLoadObject(userSkinName, class'Class'));
		}

		if (userSkinClass == None)
		{
			userSkinClass = class'SkinInfo';
		}

		oldUserSkinName = userSkinName;
	}
}

defaultproperties
{
     userSkinClass=Class'SkinInfo'
     playerStatIndex=-1
     bNetNotify=True
}
