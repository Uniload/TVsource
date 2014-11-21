class VotingReplicationInfo extends Engine.VotingReplicationInfoBase;

enum RepDataType
{
	REPDATATYPE_GameConfig,
	REPDATATYPE_MapList,
	REPDATATYPE_MapVoteCount,
	REPDATATYPE_KickVoteCount,
	REPDATATYPE_AdminVoteCount,
	REPDATATYPE_TeamDamageVoteCount,
	REPDATATYPE_TournamentVoteCount,
	REPDATATYPE_MatchConfig,
	REPDATATYPE_Maps,
	REPDATATYPE_Mutators
};

struct TickedReplicationQueueItem
{
	var RepDataType DataType;
	var int Index;
	var int Last;
};

struct MutatorData
{
    var string ClassName;
    var string FriendlyName;
};

var array<TickedReplicationQueueItem> TickedReplicationQueue;
var array<VotingHandler.MapVoteMapList> MapList;
var int MapCount;             // total count of maps

var array<VotingHandler.MapVoteGameConfigLite> GameConfig;  // game types
var int GameConfigCount;      // total count of game types
var int CurrentGameConfig;
var bool bWaitingForReply;     // used in replication

var array<VotingHandler.MapVoteScore> MapVoteCount;
var array<VotingHandler.KickVoteScore> KickVoteCount;
var array<VotingHandler.AdminVoteScore> AdminVoteCount;
var VotingHandler.TeamDamageVoteScore TeamDamageVoteCount;
var VotingHandler.TournamentVoteScore TournamentVoteCount;

var int MapVote;      // Index of the map that the owner has voted for
var int VoteCount;
var int GameVote;       // Index of the Game type that the owner has voted for
var int KickVote;       // PlayerID of the that the owner has voted against to kick
var int AdminVote;      // PlayerID of the that the owner has voted for admin
var int TeamDamageVote; // Team damage vote (-1 = not voted, 0 = no , 1 = yes)
var int TournamentVote; // Tournament vote (-1 = not voted, 0 = no , 1 = yes)
var PlayerController PlayerOwner;    // player this RI belongs too
var int PlayerID;     // PlayerID of the owner. Needed to match up when player disconnects and owner == none
var byte Mode;        // voting mode enum

var bool bMapVote;             // Map voting enabled
var bool bKickVote;            // Kick voting enabled
var bool bAdminVote;           // Admin voting enabled
var bool bTeamDamageVote;      // Team Damage voting enabled
var bool bTournamentVote;      // Tournament voting enabled
var bool bMatchSetup;          // MatchSetup enabled
var bool bMatchSetupPermitted; // owner is logged in as a MatchSetup user.
var bool bMatchSetupAccepted;  // owner has accept the current match settings

var bool bSendingMatchSetup;   // currently sending match setup stuff to client
var int SecurityLevel;         // matchsetup users security level
var config bool bDebugLog;
var() name CountDownSounds[60];
var int CountDown;

var TribesVotingHandler VH;

// localization
var localized string lmsgSavedAsDefaultSuccess, lmsgNotAllAccepted;

// Client Response Identifiers
var string MapID, MutatorID, OptionID, GeneralID;
var string URLID, StatusID, MatchSetupID, LoginID, CompleteID;
var string AddID, RemoveID, UpdateID, FailedID, TournamentID, DemoRecID, GameTypeID;

//------------------------------------------------------------------------------------------------
replication
{
	// Variables the server should send to the client only initially
	reliable if( Role==ROLE_Authority && bNetInitial)
		PlayerOwner,
		MapCount,
		GameConfigCount,
		bKickVote,
		bAdminVote,
		bTournamentVote,
		bTeamDamageVote,
		bMapVote,
		bMatchSetup,
		CurrentGameConfig;
		//bIsSpectator;

	// Variables or Functions the server should send to the client and keep updated if MapVoting enabled
	reliable if (Role==ROLE_Authority)
		ReceiveGameConfig,
		ReceiveMapInfo,
		CloseWindow,
		OpenWindow,
		ReceiveMapVoteCount,
		ReceiveKickVoteCount,
		ReceiveAdminVoteCount,
		ReceiveTeamDamageVoteCount,
		ReceiveTournamentVoteCount,
		Mode,
		PlayCountDown;

    // note: send playerid is not really used anymore...

	// Functions the server should send to the client if KickVoting or AdminVoting enabled
	reliable if( Role==ROLE_Authority && (bKickVote || bAdminVote))
		SendPlayerID;

	// Variables or Functions the server should send to the client
	// and keep updated if MatchSetup is enabled
	reliable if( Role==ROLE_Authority && bMatchSetup )
		bMatchSetupPermitted,
		bMatchSetupAccepted,
		SecurityLevel;

	// functions the client calls on the server
	reliable if( Role < ROLE_Authority )
		ReplicationReply,
		SendMapVote,
		SendKickVote,
		SendAdminVote,
		MatchSetupLogin,
		RequestMatchSettings,
		MatchSettingsSubmit,
		SaveAsDefault,
		RestoreDefaultProfile,
		MatchSetupLogout,
		RequestPlayerIP;
}
//------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = PlayerController(Owner);
	VH = TribesVotingHandler(Level.Game.VotingHandler);
}

simulated event PostNetBeginPlay()
{
	DebugLog("____VotingReplicationInfo.PostNetBeginPlay");
    Super.PostNetBeginPlay();
    GetServerData();
	
	DebugLog("****** VotingReplicationInfo.PostNetBeginPlay ******");
}
simulated event PostNetReceive()
{
	bNetNotify = NeedNetNotify();
	if ( !bNetNotify && Owner == None )
		SetOwner(PlayerOwner);
}

simulated function bool NeedNetNotify()
{
	return PlayerOwner == None;
}
simulated function GUIController GetController()
{
	if ( Level.NetMode == NM_ListenServer || Level.NetMode == NM_Client )
	{
		if ( PlayerOwner != None && PlayerOwner.Player != None )
			return GUIController(PlayerOwner.Player.GUIController);
	}

	return None;
}

//------------------------------------------------------------------------------------------------
simulated function GetServerData()
{
	// grab data from VotingHandler on server side
	if (Level.NetMode != NM_Client)
	{
	    DebugLog("*** get server data ***");
	
		bKickVote = VH.bKickVote;
		bAdminVote = VH.bAdminVote;
		bTeamDamageVote = VH.bTeamDamageVote;
		bTournamentVote = VH.bTournamentVote;
		bMapVote = VH.bMapVote;
		bMatchSetup = VH.bMatchSetup;
		MapCount = VH.MapCount;
		GameConfigCount = VH.GameConfig.Length;

		if (bMapVote)
		{
		    DebugLog("get server map and gametype data");
		
			Mode = byte(VH.bEliminationMode);
			Mode += byte(VH.bScoreMode) * 2;
			Mode += byte(VH.bAccumulationMode) * 4;

			CurrentGameConfig = VH.CurrentGameConfig;

            DebugLog("map count: "$MapCount);
            DebugLog("game count: "$GameConfigCount);

			AddToTickedReplicationQueue(REPDATATYPE_GameConfig, GameConfigCount-1);
			AddToTickedReplicationQueue(REPDATATYPE_MapList, MapCount-1);
			
			if (VH.MapVoteCount.Length>0)
				AddToTickedReplicationQueue(REPDATATYPE_MapVoteCount, VH.MapVoteCount.Length-1);
		}

		if (bKickVote && VH.KickVoteCount.Length>0)
			AddToTickedReplicationQueue(REPDATATYPE_KickVoteCount, VH.KickVoteCount.Length-1);

		if (bAdminVote && VH.AdminVoteCount.Length>0)
			AddToTickedReplicationQueue(REPDATATYPE_AdminVoteCount, VH.AdminVoteCount.Length-1);

		if (bTeamDamageVote && (VH.TeamDamageVoteCount.YesVotes>0 || VH.TeamDamageVoteCount.NoVotes>0))
			AddToTickedReplicationQueue(REPDATATYPE_TeamDamageVoteCount, 0);

		if (bTournamentVote && (VH.TournamentVoteCount.YesVotes>0 || VH.TournamentVoteCount.NoVotes>0))
			AddToTickedReplicationQueue(REPDATATYPE_TournamentVoteCount, 0);
	}
}
//------------------------------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	local int i;
	local bool bDedicated, bListening;

	if( TickedReplicationQueue.Length == 0 || bWaitingForReply)
		return;

	bDedicated = Level.NetMode == NM_DedicatedServer ||
	            (Level.NetMode == NM_ListenServer && PlayerOwner != none &&
				 PlayerOwner.Player.Console == none );

  	bListening = Level.NetMode == NM_ListenServer && PlayerOwner != none &&
	             PlayerOwner.Player.Console != none;

	if( !bDedicated && !bListening )
		return;

	i = TickedReplicationQueue.Length - 1;

	switch( TickedReplicationQueue[i].DataType )
	{
		case REPDATATYPE_GameConfig:
			TickedReplication_GameConfig(TickedReplicationQueue[i].Index, bDedicated);
 			break;
		case REPDATATYPE_MapList:
			TickedReplication_MapList(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_MapVoteCount:
			TickedReplication_MapVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_KickVoteCount:
			TickedReplication_KickVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_AdminVoteCount:
			TickedReplication_AdminVoteCount(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_TeamDamageVoteCount:
		    TickedReplication_TeamDamageVoteCount(TickedReplicationQueue[i].Index, bDedicated);
		case REPDATATYPE_TournamentVoteCount:
		    TickedReplication_TeamDamageVoteCount(TickedReplicationQueue[i].Index, bDedicated);
		case REPDATATYPE_MatchConfig:
			TickedReplication_MatchConfig(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Maps:
			TickedReplication_Maps(TickedReplicationQueue[i].Index, bDedicated);
			break;
		case REPDATATYPE_Mutators:
			TickedReplication_Mutators(TickedReplicationQueue[i].Index, bDedicated);
			break;
	}
	TickedReplicationQueue[i].Index++;
	if( TickedReplicationQueue[i].Index > TickedReplicationQueue[i].Last )
		TickedReplicationQueue.Remove(i,1);
}
//------------------------------------------------------------------------------------------------
function AddToTickedReplicationQueue(RepDataType Type, int Last)
{
	if( Last > -1 )
	{
		TickedReplicationQueue.Insert(0,1);
		TickedReplicationQueue[0].DataType = Type;
		TickedReplicationQueue[0].Index = 0;
		TickedReplicationQueue[0].Last = Last;
	}
}
//------------------------------------------------------------------------------------------------
function TickedReplication_GameConfig(int Index, bool bDedicated)
{
	local VotingHandler.MapVoteGameConfigLite GameConfigItem;

	GameConfigItem = VH.GetGameConfig(Index);
	DebugLog("___Sending " $ Index $ " - " $ GameConfigItem.GameName);
	if( bDedicated )
	{
		ReceiveGameConfig(GameConfigItem); // replicate one GameConfig each tick
		bWaitingForReply = True;
	}
	else
		GameConfig[GameConfig.Length] = GameConfigItem;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MapList(int Index, bool bDedicated)
{
 	local VotingHandler.MapVoteMapList MapInfo;

	MapInfo = VH.GetMapList(Index);
	DebugLog("___Sending " $ Index $ " - " $ MapInfo.MapName);

	if( bDedicated )
	{
		ReceiveMapInfo(MapInfo);  // replicate one map each tick until all maps are replicated.
		bWaitingForReply = True;
	}
	else
		MapList[MapList.Length] = MapInfo;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MatchConfig(int Index, bool bDedicated)
{
    // TribesVoting TODO - match config

    // i think this is the stuff where dudes vote at the end of the match for the next match...

    /*
	local MatchConfig MatchProfile;
	local PlayInfo.PlayInfoData PIData;

	if( Index < 6 )
	{
		MatchProfile = VH.MatchProfile;
		switch( Index )
		{
			case 0:
				SendClientResponse( GeneralID, UpdateID $ Chr(27) $ GameTypeID, MatchProfile.GameClassString);
				break;
			case 1:
				SendClientResponse( MapID, UpdateID, MatchProfile.MapIndexList );
				break;
			case 2:
				SendClientResponse( MutatorID, UpdateID, MatchProfile.MutatorIndexList );
				break;
			case 3:
				SendClientResponse( GeneralID, UpdateId $ Chr(27) $ URLID, MatchProfile.Parameters );
				break;
			case 4:
				SendClientResponse( GeneralID, UpdateId $ Chr(27) $ TournamentID, string(MatchProfile.bTournamentMode) );
				break;
			case 5:
				SendClientResponse( GeneralID, UpdateID $ Chr(27) $ DemoRecID, MatchProfile.DemoRecFileName );
				break;
		}
		bWaitingForReply = bDedicated;
	}
	else
	{
		DebugLog("___Sending " $ VH.MatchProfile.PInfo.Settings[Index-6].SettingName);
		PIData = VH.MatchProfile.PInfo.Settings[Index-6];
		if( PIData.ArrayDim == -1) // no array properties (cant handle them)
		{
			SendClientResponse( OptionID, AddID, PIData.SettingName $ Chr(27) $ PIData.ClassFrom $ Chr(27) $ PIData.Value );
			bWaitingForReply = bDedicated;
		}
	}
	*/
}
//------------------------------------------------------------------------------------------------
function TickedReplication_MapVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending MapVoteCountIndex " $ Index);
	if( bDedicated )
	{
		ReceiveMapVoteCount(VH.MapVoteCount[Index], True);
		bWaitingForReply = True;
	}
	else
		MapVoteCount[MapVoteCount.Length] = VH.MapVoteCount[Index];
}
//------------------------------------------------------------------------------------------------
function TickedReplication_KickVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending KickVoteCountIndex " $ Index);
	if( bDedicated )
	{
		ReceiveKickVoteCount(VH.KickVoteCount[Index], True);
		bWaitingForReply = True;
	}
	else
		KickVoteCount[KickVoteCount.Length] = VH.KickVoteCount[Index];
}
//------------------------------------------------------------------------------------------------
function TickedReplication_AdminVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending AdminVoteCountIndex " $ Index);
	if( bDedicated )
	{
		ReceiveAdminVoteCount(VH.AdminVoteCount[Index], True);
		bWaitingForReply = True;
	}
	else
		AdminVoteCount[AdminVoteCount.Length] = VH.AdminVoteCount[Index];
}
//------------------------------------------------------------------------------------------------
function TickedReplication_TeamDamageVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending TeamDamageVoteCountIndex");
	if (bDedicated)
	{
		ReceiveTeamDamageVoteCount(VH.TeamDamageVoteCount, True);
		bWaitingForReply = True;
	}
	else
		TeamDamageVoteCount = VH.TeamDamageVoteCount;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_TournamentVoteCount(int Index, bool bDedicated)
{
	DebugLog("___Sending TournamentVoteCountIndex " $ Index);
	if (bDedicated)
	{
		ReceiveTournamentVoteCount(VH.TournamentVoteCount, True);
		bWaitingForReply = True;
	}
	else
		TournamentVoteCount = VH.TournamentVoteCount;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_Maps(int Index, bool bDedicated)
{
    // TribesVoting TODO - ticked replication maps? what does this actually do?!

	DebugLog("TickedReplication_Maps " $ Index $ ", " $ VH.MapList[index].MapName);

	SendClientResponse(MapID, AddID, Index $ "," $ VH.MapList[index].MapName);
	bWaitingForReply = bDedicated;
}
//------------------------------------------------------------------------------------------------
function TickedReplication_Mutators(int Index, bool bDedicated)
{
    // TribesVoting TODO - mutators

    /*
	local MatchConfig MatchProfile;
	local MutatorData M;

	MatchProfile = VH.MatchProfile;
	DebugLog("TickedReplication_Mutators " $ Index $ ", " $ MatchProfile.Mutators[Index].ClassName);

	M.ClassName = MatchProfile.Mutators[Index].ClassName;
	M.FriendlyName = MatchProfile.Mutators[Index].FriendlyName;

	SendClientResponse( MutatorID, AddID, Index $ "," $ M.ClassName $ Chr(27) $ M.FriendlyName );
	bWaitingForReply = bDedicated;
	*/
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveGameConfig(VotingHandler.MapVoteGameConfigLite p_GameConfig)
{
	GameConfig[GameConfig.Length] = p_GameConfig;
	DebugLog("___Receiving - " $ p_GameConfig.GameName);
	ReplicationReply();
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveMapInfo(VotingHandler.MapVoteMapList MapInfo)
{
	MapList[MapList.Length] = MapInfo;
	DebugLog("___Receiving - " $ MapInfo.MapName);
	ReplicationReply();
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveMapVoteCount(VotingHandler.MapVoteScore MVCData, bool bReply)
{
	local int i;
	local bool bFound;

    DebugLog("voting replication info: recieve map vote count");

	for( i=0; i<MapVoteCount.Length; i++ )
	{
		if( MVCData.MapIndex == MapVoteCount[i].MapIndex &&
			MVCData.GameConfigIndex == MapVoteCount[i].GameConfigIndex)
		{
			if( MVCData.VoteCount <= 0 )
				MapVoteCount.Remove( i, 1);  // canceled vote
			else
				MapVoteCount[i].VoteCount = MVCData.VoteCount; // updated vote
			bFound = True;
			break;
		}
	}

	if( !bFound ) // new vote
	{
	    // TribesVoting michaelj - a new map vote has been started
	
		DebugLog("new map vote started");

		i = MapVoteCount.Length;
		MapVoteCount.Insert(i,1);
		MapVoteCount[i] = MVCData;
	}

	if( bReply )
		ReplicationReply();
	else if ( PlayerOwner != None && PlayerOwner.Player != None )
	{
	    // TribesVoting TODO - update map vote count

        // TribesVoting michaelj - this is where you should hook up your UI to track map votes and stuffs...
	
        DebugLog("map vote count changed");
	
	    /*
		if ( MapVotingPage(GetController().ActivePage) != None )
			MapVotingPage(GetController().ActivePage).UpdateMapVoteCount(i,MVCData.VoteCount==0);
		if( MapInfoPage(GetController().ActivePage) != none )
			MapVotingPage(GetController().ActivePage.ParentPage).UpdateMapVoteCount(i,MVCData.VoteCount== 0);
			*/
	}
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveKickVoteCount(VotingHandler.KickVoteScore KVCData, bool bReply)
{
	local int i;
	local bool bFound;

	for( i=0; i<KickVoteCount.Length; i++ )
	{
		if( KVCData.PlayerID == KickVoteCount[i].PlayerID )
		{
			KickVoteCount[i].KickVoteCount = KVCData.KickVoteCount;
			bFound = True;
			break;
		}
	}

	if( !bFound )
	{
		i = KickVoteCount.Length;
		KickVoteCount.Insert(i,1);
		KickVoteCount[i] = KVCData;
		
		// TribesVoting michaelj
		
		DebugLog("new kick vote started");
	}

	if( bReply )
		ReplicationReply();
	else
	{
	    // TribesVoting TODO - update kick vote count

        // TribesVoting michaelj - this is where you should hookup to your ui to display kick votes for each player

        DebugLog("kick vote count changed");
	
	    /*
		if( KickVotingPage(GetController().ActivePage) != None )
			KickVotingPage(GetController().ActivePage).UpdateKickVoteCount(KickVoteCount[i]);
			*/
	}
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveAdminVoteCount(VotingHandler.AdminVoteScore data, bool bReply)
{
	local int i;
	local bool bFound;

	for( i=0; i<AdminVoteCount.Length; i++ )
	{
		if( data.PlayerID == AdminVoteCount[i].PlayerID )
		{
			AdminVoteCount[i].AdminVoteCount = data.AdminVoteCount;
			bFound = True;
			break;
		}
	}

	if( !bFound )
	{
		i = AdminVoteCount.Length;
		AdminVoteCount.Insert(i,1);
		AdminVoteCount[i] = data;
		
		// TribesVoting michaelj
		
		DebugLog("new admin vote started");
	}

	if( bReply )
		ReplicationReply();
	else
	{
	    // TribesVoting TODO - update admin vote count

        // TribesVoting michaelj - this is where you should hookup to your ui to display admin votes for each player

        DebugLog("admin vote count changed");
	
	    /*
		if( AdminVotingPage(GetController().ActivePage) != None )
			AdminVotingPage(GetController().ActivePage).UpdateAdminVoteCount(AdminVoteCount[i]);
			*/
	}
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveTeamDamageVoteCount(VotingHandler.TeamDamageVoteScore data, bool bReply)
{
    TeamDamageVoteCount = data;

	if (bReply)
		ReplicationReply();         // what does this do?
	else
	{
        // TribesVoting michaelj - this is where you should hookup to your ui to update team damage votes

        DebugLog("team damage vote count changed");

        // ...
	}
}
//------------------------------------------------------------------------------------------------
simulated function ReceiveTournamentVoteCount(VotingHandler.TournamentVoteScore data, bool bReply)
{
    TournamentVoteCount = data;

	if (bReply)
		ReplicationReply();         // what does this do?
	else
	{
        // TribesVoting michaelj - this is where you should hookup to your ui to update team damage votes

        DebugLog("tournament vote count changed");

        // ...
	}
}
//------------------------------------------------------------------------------------------------
function ReplicationReply()
{
    // what does this method do?

	bWaitingForReply = False;

	if (bSendingMatchSetup && TickedReplicationQueue.Length==0)
	{
		SendClientResponse(StatusID, CompleteID);
		bSendingMatchSetup = false;
	}
}

// glenn's stuff:

function SubmitKickVote(string name)
{
    local int i;
    local int id;
    local PlayerController player;

    DebugLog("submit kick vote: "$name);

    // translate from player name to player id
    
    id = -1;

    DebugLog("MVRI length: "$VH.MVRI.length);
        
    for (i=0; i<VH.MVRI.length; i++)
    {
        player = VH.MVRI[i].PlayerOwner;

        //log("searching: "$player.playerReplicationInfo.playerName, 'voting');
        
        if (player.playerReplicationInfo.playerName~=name)
        {
            id = VH.MVRI[i].PlayerID;
            //log("found player "$name$" with id "$id, 'voting');
            break;
        }
    }
    
    if (id>=0)
        SendKickVote(id);
    else
        log("invalid player name in kick vote: "$name, 'voting');
}

function SubmitAdminVote(string name)
{
    local int i;
    local int id;
    local PlayerController player;

    DebugLog("submit admin vote: "$name);

    // translate from player name to player id
    
    id = -1;

    DebugLog("MVRI length: "$VH.MVRI.length);
        
    for (i=0; i<VH.MVRI.length; i++)
    {
        player = VH.MVRI[i].PlayerOwner;

        //log("searching: "$player.playerReplicationInfo.playerName, 'voting');
        
        if (player.playerReplicationInfo.playerName~=name)
        {
            id = VH.MVRI[i].PlayerID;
            //log("found player "$name$" with id "$id, 'voting');
            break;
        }
    }
    
    if (id>=0)
        SendAdminVote(id);
    else
        log("invalid player name in admin vote: "$name, 'voting');
}

function SubmitMapVote(string map, string gametype)
{
    local int i;
    local int mapIndex;
    local int gameTypeIndex;

    DebugLog("submit map vote: "$map$" ["$gametype$"]");

    if (VH.MapList.length==0)
    {
        log("*** no multiplayer maps found ***", 'voting');
        return;
    }
        
    if (VH.GameConfig.length==0)
    {
        log("*** no game types found ***", 'voting');
        return;
    }

    // look up map index from map name
    
    mapIndex = -1;
    
    for (i=0; i<VH.MapList.length; i++)
    {
        if (VH.MapList[i].mapName~=map)
        {
            //log("found map "$map$" with index "$i, 'voting');
            mapIndex = i;
            break; 
        }
    }
    
    if (mapIndex<0)
    {
        log("invalid map name in map vote: "$map, 'voting');
        return;
    }
    
    // look up game type index from gametype name    
    
    gameTypeIndex = -1;
    
    DebugLog("game type count: "$VH.GameConfig.length);
    
    for (i=0; i<VH.GameConfig.length; i++)
    {
        //log("game type check: "$gametype$" vs. "$VH.GameConfig[i].prefix);
    
        if (VH.GameConfig[i].Prefix~=gametype)
        {
            //log("found gametype "$gametype$" with index "$i, 'voting');
            gameTypeIndex = i;
            break; 
        }
    }

    if (gameTypeIndex<0)
    {
        log("invalid gametype name in map vote: "$gametype, 'voting');
        log("defaulting to gametype 0: "$VH.GameConfig[0].gameName, 'voting');
        gameTypeIndex = 0;
    }

    // todo: verify game type is supported for map?
    
    SendMapVote(mapIndex, gameTypeIndex);
}

function SubmitTeamDamageVote(bool vote)
{
    DebugLog("submit team damage vote: "$vote);
    
	VH.SubmitTeamDamageVote(vote, Owner);
}

function SubmitTournamentVote(bool vote)
{
    DebugLog("submit tourament damage vote: "$vote);
    
	VH.SubmitTournamentVote(vote, Owner);
}

//------------------------------------------------------------------------------------------------
function SendMapVote(int MapIndex, int p_GameIndex)
{
	DebugLog("MVRI.SendMapVote(" $ MapIndex $ ", " $ p_GameIndex $ ")");
	VH.SubmitMapVote(MapIndex,p_GameIndex,Owner);
}
//------------------------------------------------------------------------------------------------
function SendKickVote(int PlayerID)
{
	VH.SubmitKickVote(PlayerID, Owner);
}

function SendAdminVote(int PlayerID)
{
	VH.SubmitAdminVote(PlayerID, Owner);
}
//------------------------------------------------------------------------------------------------
simulated function CloseWindow()
{
    // TribesVoting TODO - close voting window

    // TribesVoting michaelj - unreal thinks that voting windows should be closed, whee! - cant find where/if this is called
    
    DebugLog("close voting windows");

	settimer(0,false);

    /*
	GetController().CloseAll(true);
	*/
}
//------------------------------------------------------------------------------------------------
simulated function OpenWindow()
{
    // TribesVoting TODO - open map voting menu

    // TribesVoting michaelj - unreal thinks that now would be a good time to open the map voting ui, not sure if this gets called, cant find anywhere that calls it in this file

    DebugLog("open voting windows");

	//GetController().OpenMenu(GetController().MapVotingMenu);
}
//------------------------------------------------------------------------------------------------
simulated function string GetMapNameString(int Index)
{
	if(Index >= MapList.Length)
		return "";
	else
		return MapList[Index].MapName;
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogin(string UserID, string Password)
{
	local int SecLevel;

	if( VH.MatchSetupLogin(UserID,Password,PlayerOwner,SecLevel) )
	{
		bMatchSetupPermitted=True;
		SecurityLevel = SecLevel;

		SendClientResponse(LoginID,"1");
	}
	else
	{
		bMatchSetupPermitted=False;
		SendClientResponse(LoginID);
	}
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogout()
{
	bMatchSetupPermitted = false;
	bMatchSetupAccepted = false;
	bSendingMatchSetup = false;
	VH.MatchSetupLogout( PlayerOwner );

	SendClientResponse("logout");
}
//------------------------------------------------------------------------------------------------
function RequestMatchSettings(bool bRefreshMaps, bool bRefreshMutators)
{
    // TribesVoting TODO - request match settings

    /*
	DebugLog("____RequestConfigSettings");

	if(bMatchSetupPermitted)
	{
		bMatchSetupAccepted = false;
		bSendingMatchSetup = true;

		// Send the full list of maps
		if ( bRefreshMaps )
			AddToTickedReplicationQueue(REPDATATYPE_Maps, VH.MatchProfile.Maps.Length-1);

		// Send the full list of mutators
		if ( bRefreshMutators )
			AddToTickedReplicationQueue(REPDATATYPE_Mutators, VH.MatchProfile.Mutators.Length-1);

		// Send the game configuration, including the active maps & mutators, command line params, and misc. settings
		AddToTickedReplicationQueue(REPDATATYPE_MatchConfig, VH.MatchProfile.PInfo.Settings.Length + 5);
	}
	else SendClientResponse(MatchSetupID, FailedID);
	*/
}
function SendClientResponse( string Identifier, optional string Response, optional string Data )
{
	if ( Identifier == "" )
		return;

	if ( Response != "" )
		Identifier $= ":" $ Response;

	if ( Data != "" )
		Identifier $= ";" $ Data;

	SendResponse(Identifier);
}

function ReceiveCommand( string Command )
{
	local string Type, Info, Data;

	DecodeCommand( Command, Type, Info, Data );
	HandleCommand( Type, Info, Data );
}

static function DecodeCommand( string Response, out string Type, out string Info, out string Data )
{
    // TribesVoting TODO - what is this used for?

    //log("decode command: "$type$", "$info$", "$data);

    /*
	local string str;


	Type = "";
	Info = "";
	Data = "";

	if ( Response == "" )
		return;

	if ( Divide(Response, ":", Type, str) )
	{
		if ( !Divide(str, ";", Info, Data) )
			Info = str;
	}
	else Type = Response;
	*/
}

function HandleCommand( string Type, string Info, string Data )
{
    // TribesVoting TODO - what is this used for?

    DebugLog("handle command: "$type$", "$info$", "$data);

    /*
	local bool bPropagate;

	if ( Type == "" )
		return;

	log("HandleCommand Type: '"$Type$"'   Info: '"$Info$"'   Data: '"$Data$"'",'MapVoteDebug');
	switch ( Type )
	{
	case MapID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			bPropagate = VH.MatchProfile.ChangeSetting(Type, Info);
		}

		break;

	case MutatorID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			bPropagate = VH.MatchProfile.ChangeSetting( Type, Info );
		}
		break;

	case GeneralID:
		if ( bMatchSetupPermitted )
		{
			bMatchSetupAccepted = false;
			switch ( Info )
			{
			case OptionID:
			case TournamentID:
			case DemoRecID:
				bPropagate = VH.MatchProfile.ChangeSetting( Info, Data );
			}
		}

		break;
	}

	if ( bPropagate )
		VH.PropagateValue(Self, Type, Info, Data);
		*/
}

simulated function SendResponse(string Response)
{
	Super.SendResponse(Response);
	ReplicationReply();
}

//------------------------------------------------------------------------------------------------
function MatchSettingsSubmit()
{
	local int i;
	local bool bAllAccepted;

	DebugLog("____MatchSettingsSubmit()");

	if(bMatchSetupPermitted)
	{
		bAllAccepted = true;
		bMatchSetupAccepted = true;
		// check if any match setup users did not accept the settings
		for( i=0; i<VH.MVRI.Length; i++)
		{
			if(VH.MVRI[i].bMatchSetupPermitted && !VH.MVRI[i].bMatchSetupAccepted)
			{
				bAllAccepted = false;
				break;
			}
		}

		// TribesVoting TODO - match profile start match
			
        /*
		if( bAllAccepted ) // if all match setup users accepted then implement changes
			VH.MatchProfile.StartMatch();
		else SendClientResponse(StatusID, lmsgNotAllAccepted);
			*/
	}
}
//------------------------------------------------------------------------------------------------
function SaveAsDefault()
{
	DebugLog("____SaveAsDefault()");

	// double chech permissions just incase
	if( bMatchSetupPermitted && PlayerOwner.PlayerReplicationInfo.bAdmin )
	{
	    // TribesVoting TODO - match profile save default
	
		//VH.MatchProfile.SaveDefault();
		SendClientResponse(StatusID, lmsgSavedAsDefaultSuccess);
	}
}
//------------------------------------------------------------------------------------------------
function RestoreDefaultProfile()
{
    // TribesVoting TODO - match profile

    /*
	local MatchConfig MatchProfile;

	DebugLog("____RestoreDefaultProfile()");

	// double chech permissions just incase
	if( bMatchSetupPermitted )
	{
		MatchProfile = VH.MatchProfile;
		MatchProfile.RestoreDefault(PlayerOwner);
	}
	*/
}
//------------------------------------------------------------------------------------------------
simulated function PlayCountDown(int Count)
{
    // TribesVoting michaelj - unreal is starting a voting count down - i suspect this is for match setup only

    DebugLog("starting count down from "$count);

    setTimer(1,false);

    /*
	local float t;

    if(Count > 10 && Count <= 60 && CountDownSounds[Count-1] != '')
        PlayerOwner.PlayStatusAnnouncement( CountDownSounds[Count-1], 1);

	if( Count == 10 )
	{
	    t = GetSoundDuration(PlayerOwner.StatusAnnouncer.PreCacheSound(CountDownSounds[9]));
	    if(t + 0.15 < 1)
			t = 1;
    	SetTimer(t + 0.15,false);
    	PlayerOwner.PlayStatusAnnouncement( CountDownSounds[9], 1);
    	CountDown = 9;
    }
    */
}
//------------------------------------------------------------------------------------------------
simulated function Timer()
{
    // TribesVoting michaelj - unreal is using the time to count down until voting is done (this may be only for the match setup stuff...)

	CountDown--;

    //log("voting count down: "$CountDown);

	if (CountDown>0)
	   	SetTimer(1,false);

    /*
 	local float t;

    t = GetSoundDuration(PlayerOwner.StatusAnnouncer.PreCacheSound(CountDownSounds[CountDown-1]));
    if(t + 0.15 < 1)
		t = 1;
	PlayerOwner.PlayStatusAnnouncement( CountDownSounds[CountDown-1], 1);
	CountDown--;
	if( CountDown > 0 )
	   	SetTimer(t + 0.15,false);
	*/
}
//------------------------------------------------------------------------------------------------
function RequestPlayerIP( string PlayerName )
{
	local PlayerController P;

	if( PlayerOwner.PlayerReplicationInfo.bAdmin )
	{
	    foreach DynamicActors( class'PlayerController', P )
	    {
	    	if( P.PlayerReplicationInfo.PlayerName ~= PlayerName )
	    	{
	    	    // TribesVoting TODO - player controller GetPlayerIDHash
	    	
	    		//SendPlayerID(P.GetPlayerNetworkAddress(), P.GetPlayerIDHash());
	    		break;
	    	}
	    }
	}
}
//------------------------------------------------------------------------------------------------
simulated function SendPlayerID(string IPAddress, string PlayerID)
{
    // TribesVoting TODO - player id

    /*
	local KickInfoPage Page;

	Page = KickInfoPage(GetController().ActivePage);
	if(Page != None)
	{
		Page.lb_PlayerInfoBox.Add(class'KickInfoPage'.default.IPText,IPAddress);
		Page.lb_PlayerInfoBox.Add(class'KickInfoPage'.default.IDText,PlayerID);
	}
	*/
}
//------------------------------------------------------------------------------------------------
simulated function DebugLog(string Text)
{
	if(bDebugLog)
		log(Text,'votingdebug');
}
//------------------------------------------------------------------------------------------------

simulated function bool MatchSetupLocked() { return !bMatchSetupPermitted; }
simulated function bool MapVoteEnabled() { return bMapVote; }
simulated function bool KickVoteEnabled() { return bKickVote; }
simulated function bool AdminVoteEnabled() { return bAdminVote; }
simulated function bool TeamDamageVoteEnabled() { return bTeamDamageVote; }
simulated function bool TournamentVoteEnabled() { return bTournamentVote; }
simulated function bool MatchSetupEnabled() { return bMatchSetup; }

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=1
	bOnlyRelevantToOwner=True
	MapVote=-1
	GameVote=-1
	KickVote=-1
	AdminVote=-1
    TeamDamageVote=-1
    TournamentVote=-1
	bDebugLog=false
	NetUpdateFrequency=1
	bMatchSetupPermitted=False
	bNetNotify=True

	ProcessCommand=ReceiveCommand

    // TribesVoting TODO - we dont have count down sounds

	CountDownSounds(0)=one
	CountDownSounds(1)=two
	CountDownSounds(2)=three
	CountDownSounds(3)=four
	CountDownSounds(4)=five
	CountDownSounds(5)=six
	CountDownSounds(6)=seven
	CountDownSounds(7)=eight
	CountDownSounds(8)=nine
	CountDownSounds(9)=ten
	CountDownSounds(19)=20_seconds
	CountDownSounds(29)=30_seconds_remain
	CountDownSounds(59)=1_minute_remains

	lmsgSavedAsDefaultSuccess="Profile was saved as default successfully"
	lmsgNotAllAccepted="You have Accepted the current settings, Waiting for other users to accept."

	MapID="map"
	MutatorID="mutator"
	OptionID="option"
	GeneralID="general"

	URLID="url"
	StatusID="status"
	MatchSetupID="matchsetup"
	LoginID="login"
	FailedID="failed"
	CompleteID="done"

	AddID="add"
	RemoveID="remove"
	UpdateID="update"

	TournamentID="tournament"
	DemoRecID="demorec"
	GameTypeID="game"
}

