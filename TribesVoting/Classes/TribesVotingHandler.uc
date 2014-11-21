class TribesVotingHandler extends Engine.VotingHandler config;

// work variables
var array<VotingReplicationInfo> MVRI; // used to communicated between players and server
var int           MapCount;      // number of maps
var bool          bLevelSwitchPending;
var bool          bMidGameVote;
var int           TimeLeft,ScoreBoardTime,ServerTravelTime;
var array<MapVoteScore> MapVoteCount;
var array<KickVoteScore> KickVoteCount;
var array<AdminVoteScore> AdminVoteCount;
var TeamDamageVoteScore TeamDamageVoteCount;
var TournamentVoteScore TournamentVoteCount;

// VOTING TODO - map vote history

//var class<MapVoteHistory> MapVoteHistoryClass;
var array<MapVoteMapList> MapList;
//var MapVoteHistory History;
var string        TextMessage;
var string        ServerTravelString;

// ---- INI Configuration setting variables ----
var() config array<MapVoteGameConfig> GameConfig;
var() config int    VoteTimeLimit;
var() config int    ScoreBoardDelay;
var() config bool   bAutoOpen;
var() config int    MidGameVotePercent;
var() config bool   bScoreMode;
var() config bool   bAccumulationMode;
var() config bool   bEliminationMode;
var() config int    MinMapCount;
var() config string MapVoteHistoryType;
var() config int    RepeatLimit;
var() config int    DefaultGameConfig;
var() config bool   bDefaultToCurrentGameType;
var() config bool   bMapVote;
var() config bool   bKickVote;
var() config bool   bAdminVote;
var() config bool   bTeamDamageVote;
var() config bool   bTournamentVote;
var() config bool   bMatchSetup;
var() config int    KickPercent;
var() config int    AdminPercent;
var() config int    TeamDamagePercent;
var() config int    TournamentPercent;
var() config bool   bAnonymousKicking;
var() config bool   bAnonymousAdmining;
var() config array<AccumulationData> AccInfo; // used to save player's unused votes between maps when in Accumulation mode
var() config int    ServerNumber;
var() config int    CurrentGameConfig;

// MatchSetup

// VOTING TODO - match profile

//var MatchConfig MatchProfile;
var string GameConfigPage;
var string MapListConfigPage;

// Localization variables
var localized string lmsgInvalidPassword;
var localized string lmsgMatchSetupPermission;
var localized string lmsgKickVote;
var localized string lmsgAnonymousKickVote;
var localized string lmsgKickVoteAdmin;
var localized string lmsgAdminVote;
var localized string lmsgAnonymousAdminVote;
var localized string lmsgAdminVoteAdmin;
var localized string lmsgTeamDamageVote;
var localized string lmsgTournamentVote;
var localized string lmsgMapWon;
var localized string lmsgMidGameVote;
var localized string lmsgSpectatorsCantVote;
var localized string lmsgMapVotedFor;
var localized string lmsgMapVotedForWithCount;
var localized string lmsgTournamentModeEnabled;
var localized string lmsgTournamentModeDisabled;
var localized string lmsgTeamDamageEnabled;
var localized string lmsgTeamDamageDisabled;
var localized string PropsDisplayText[24];
var localized string PropDescription[24];
var localized string lmsgAdminMapChange;
var localized string lmsgGameConfigColumnTitle[6];

//================================================================================================
//                                    Startup/Event Code
//================================================================================================
function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
    {
        log("disable voting: netmode standalone");
		return;
	}

    LoadMapList();

	bMatchSetup = bMatchSetup;

	if (bKickVote)
		log("Kick Voting Enabled",'voting');
	else
		log("Kick Voting Disabled",'voting');

	if (bAdminVote)
		log("Admin Voting Enabled",'voting');
	else
		log("Admin Voting Disabled",'voting');

	if (bTeamDamageVote)
		log("Team Damage Voting Enabled",'voting');
	else
		log("Team Damage Voting Disabled",'voting');

	if (bTournamentVote)
		log("Tournament Voting Enabled",'voting');
	else
		log("Tournament Voting Disabled",'voting');

	if(bMapVote)
		log("Map Voting Enabled",'voting');
	else
		log("Map Voting Disabled",'voting');

	// check current game settings
	
	if( !(string(Level.Game.Class) ~= GameConfig[CurrentGameConfig].GameClass) )
	{
		CurrentGameConfig = 0;
		// find matching game type in game config
		for( i=0; i<GameConfig.Length; i++)
		{
			if(GameConfig[i].GameClass ~= string(Level.Game.Class))
			{
				log("current game config: "$GameConfig[i].GameClass$" ["$i$"]", 'voting');
			
				CurrentGameConfig = i;
				break;
			}
		}
	}

    // VOTING TODO - match profile

    /*
	if(bMatchSetup)
	{
		log("MatchSetup Enabled",'voting');

		MatchProfile = CreateMatchProfile();
		MatchProfile.Init(Level);
		MatchProfile.LoadCurrentSettings();
	}
	else
		log("MatchSetup Disabled",'voting');
		*/
}
//------------------------------------------------------------------------------------------------
function PlayerJoin(PlayerController Player)
{
	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return;

    if (bMapVote || bKickVote || bAdminVote || bTeamDamageVote || bTournamentVote || bMatchSetup)
	{
		//Log("___New Player Joined - " $ Player.PlayerReplicationInfo.PlayerName $ ", " $ Player.GetPlayerNetworkAddress(),'voting');
		AddVoteReplicationInfo(Player);
	}
}
//------------------------------------------------------------------------------------------------
function PlayerExit(Controller Exiting)
{
	local int i,x,ExitingPlayerIndex;

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return;

    ExitingPlayerIndex = -1;

	//log("____PlayerExit", 'votedebug');

    if (bMapVote || bKickVote || bAdminVote || bTeamDamageVote || bTournamentVote || bMatchSetup)
	{
		for (i=0; i<MVRI.Length; i++)
		{
		    // remove players vote from vote count
		    
			if (MVRI[i]!=none && (MVRI[i].PlayerOwner== none || MVRI[i].PlayerOwner==Exiting))
			{
				//log("exiting player MVRI found " $ i,'votedebug');
				
				ExitingPlayerIndex = i;
				
				if (bMapVote && MVRI[ExitingPlayerIndex].MapVote>-1 && MVRI[ExitingPlayerIndex].GameVote>-1)
				{
					for (x=0; x<MapVoteCount.Length; x++)
					{
						if (MVRI[ExitingPlayerIndex].MapVote==MapVoteCount[x].MapIndex &&
							MVRI[ExitingPlayerIndex].GameVote==MapVoteCount[x].GameConfigIndex)
						{
							MapVoteCount[x].VoteCount -= MVRI[ExitingPlayerIndex].VoteCount;
							UpdateVoteCount(MapVoteCount[x].MapIndex, MapVoteCount[x].GameConfigIndex, MapVoteCount[x].VoteCount);
							break;
						}
					}
				}

				if (bKickVote)
				{
					// clear votes for exiting player
					UpdateKickVoteCount(MVRI[ExitingPlayerIndex].PlayerID, 0);

					// decrease votecount for player that the exiting player voted against
					if (MVRI[ExitingPlayerIndex].KickVote>-1 && MVRI[MVRI[ExitingPlayerIndex].KickVote]!=none)
						UpdateKickVoteCount(MVRI[MVRI[ExitingPlayerIndex].KickVote].PlayerID, -1);
				}

				if (bAdminVote)
				{
					// clear votes for exiting player
					UpdateAdminVoteCount(MVRI[ExitingPlayerIndex].PlayerID, 0);

					// decrease votecount for player that the exiting player voted against
					if (MVRI[ExitingPlayerIndex].AdminVote>-1 && MVRI[MVRI[ExitingPlayerIndex].AdminVote]!=none)
						UpdateAdminVoteCount(MVRI[MVRI[ExitingPlayerIndex].AdminVote].PlayerID, -1);
				}

                if (bTeamDamageVote)
                {
					// clear votes of exiting player

                    if (MVRI[ExitingPlayerIndex].TeamDamageVote==0)
                        UpdateTeamDamageVoteCount(0, -1);       // undo no vote
                    else if (MVRI[ExitingPlayerIndex].TeamDamageVote==1)
                        UpdateTeamDamageVoteCount(-1, 0);       // undo yes vote
                }
                
                if (bTournamentVote)
                {
					// clear votes of exiting player

                    if (MVRI[ExitingPlayerIndex].TournamentVote==0)
                        UpdateTournamentVoteCount(0, -1);       // undo no vote
                    else if (MVRI[ExitingPlayerIndex].TournamentVote==1)
                        UpdateTournamentVoteCount(-1, 0);       // undo yes vote
                }				
			}

            // clear other players votes for the exiting player

			if (bKickVote && ExitingPlayerIndex>-1 && MVRI[i]!=none && MVRI[i].KickVote==ExitingPlayerIndex)
				MVRI[i].KickVote = -1;

			if (bAdminVote && ExitingPlayerIndex>-1 && MVRI[i]!=none && MVRI[i].AdminVote==ExitingPlayerIndex)
				MVRI[i].AdminVote = -1;

            // destroy voting replication info for exiting player

			if (MVRI[i]!=none && (MVRI[i].PlayerOwner==none || MVRI[i].PlayerOwner==Exiting))
			{
				//log("___Destroying VRI...",'votedebug');
				MVRI[i].Destroy();
				MVRI[i] = none;
				
				if (bKickVote)
					TallyKickVotes();
				
				if (bAdminVote)
					TallyAdminVotes();

                if (bTeamDamageVote)
                    TallyTeamDamageVotes();
				
                if (bTournamentVote)
                    TallyTournamentVotes();
				
				if (bMapVote)
					TallyMapVotes(false);
			}
		}
	}
}
//------------------------------------------------------------------------------------------------
function AddVoteReplicationInfo(PlayerController Player)
{
	local VotingReplicationInfo M;

    // glenn: test
    
    if (Level.NetMode == NM_Client)
    {
        log("**** tried to add vote replication info on client ****");
		return;
    }                                                                 

	//log("___Spawning VotingReplicationInfo",'votedebug');
	M = Spawn(class'VotingReplicationInfo',Player,,Player.Location);
	if(M == None)
	{
		Log("___Failed to spawn VotingReplicationInfo",'voting');
		return;
	}
//	else
//	    log("*** successful add vote replication info ***");

	M.PlayerID = Player.PlayerReplicationInfo.PlayerID;
	MVRI[MVRI.Length] = M;
}
//================================================================================================
//                                    Map Voting
//================================================================================================

private function LoadMapListInternal()
{
    local int i, index;
    local array<string> levelList;
    
    class'Gameplay.Utility'.static.smartRefresh();
    class'Gameplay.Utility'.static.getLevelList(levelList);

    MapList.length = 0;
    
    for (i=0; i<levelList.length; i++)
    {
        index = MapList.length;
        MapList.length = MapList.length + 1;
        
        MapList[index].MapName = levelList[i];
        MapList[index].PlayCount = 0;
        MapList[index].Sequence = 0;        // ?
        MapList[index].bEnabled = true;     // i guess this is how they enable/disable maps per gametype
        
        //log(MapList[index].MapName, 'voting');
    }

    /*
    struct MapVoteMapList
    {
	    var string MapName;
	    var int PlayCount;
	    var int Sequence;
	    var bool bEnabled;
    };
    */
}

private function LoadGameTypesInternal()
{
    // GameConfig

    local int i, index;
    local array<Gameplay.Utility.GameData> gameTypes;
    
    class'Gameplay.Utility'.static.smartRefresh();
    class'Gameplay.Utility'.static.getGameTypeList(gameTypes);

    GameConfig.length = 0;
    
    for (i=0; i<gameTypes.length; i++)
    {
        index = GameConfig.length;
        GameConfig.length = GameConfig.length + 1;
        
        GameConfig[index].GameClass = gameTypes[i].className;
        GameConfig[index].Prefix = gameTypes[i].name;
        GameConfig[index].Acronym = gameTypes[i].name;              // in our system always the same as prefix
        GameConfig[index].GameName = gameTypes[i].name;             // todo: descriptive name "Capture the Fag" etc.
        GameConfig[index].Mutators = "";                            // mutators?
        GameConfig[index].Options = "";                             // options?
        
        //log(GameConfig[index].GameClass, 'voting');
    }

    /*
    struct MapVoteGameConfig
    {
	    var string GameClass; // code class of game type. XGame.xDeathMatch
	    var string Prefix;    // MapName Prefix. DM, CTF, BR etc.
	    var string Acronym;   // Game Acronym (appended to map names in messages to help identify game type for map)
	    var string GameName;  // Name or Title of the game type. "DeathMatch", "Capture The Flag"
	    var string Mutators;  // Mutators to load with this gametype. "XGame.MutInstaGib,UnrealGame.MutBigHead,UnrealGame.MutLowGrav"
	    var string Options;   // Game Options
    };
    */
}

function LoadMapList()
{
	local int i,EnabledMapCount;
	
    // VOTING TODO - map vote history

    /*
	MapVoteHistoryClass = class<MapVoteHistory>(DynamicLoadObject(MapVoteHistoryType, class'Class'));
	History = new(None,"MapVoteHistory"$string(ServerNumber)) MapVoteHistoryClass;
	if(History == None) // Failed to spawn MapVoteHistory
		History = new(None,"MapVoteHistory"$string(ServerNumber)) class'MapVoteHistory_INI';
	*/

    // load game type list

	//log("GameTypes:", 'voting');

    LoadGameTypesInternal();

    // load map list

    //log("Maps:", 'voting');

	LoadMapListInternal();

    MapCount = MapList.length;

	//log(MapCount $ " maps loaded.",'voting');

    // VOTING TODO - map history

	//History.Save();

    // VOTING TODO - what is elimination mode?

	if(bEliminationMode)
	{
		// Count the Remaining Enabled maps
		EnabledMapCount = 0;
		for(i=0;i<MapCount;i++)
		{
			if(MapList[i].bEnabled)
				EnabledMapCount++;
		}
		if(EnabledMapCount < MinMapCount || EnabledMapCount == 0)
		{
			log("Elimination Mode Reset/Reload.",'voting');
			RepeatLimit = 0;
			MapList.Length = 0;
			MapCount = 0;
			SaveConfig();
			
			LoadMapListInternal();
		}
	}
}
//------------------------------------------------------------------------------------------------

// not required: our Gameplay.Utility class does this for us already

/*
function AddMap(string MapName, string Mutators, string GameOptions) // called from the MapListLoader
{
    // VOTING TODO - map history info

	//local MapHistoryInfo MapInfo;
	//local bool bUpdate;
	local int i;

	for(i=0; i < MapList.Length; i++)  // dont add duplicate map names
		if(MapName ~= MapList[i].MapName)
			return;

	//MapInfo = History.GetMapHistory(MapName);

	MapList.Length = MapCount + 1;
	MapList[MapCount].MapName = MapName;
	MapList[MapCount].PlayCount = MapInfo.P;
	MapList[MapCount].Sequence = MapInfo.S;
	if(MapInfo.S <= RepeatLimit && MapInfo.S != 0)
		MapList[MapCount].bEnabled = false; // dont allow players to vote for this one
	else
		MapList[MapCount].bEnabled = true;
	MapCount++;

    // VOTING TODO - mutators from map info

	if(Mutators != "" && Mutators != MapInfo.U)
	{
		MapInfo.U = Mutators;
		bUpdate = True;
	}
	
	// VOTING TODO - game options from map info

	if(GameOptions != "" && GameOptions != MapInfo.G)
	{
		MapInfo.G = GameOptions;
		bUpdate = True;
	}

	if(MapInfo.M == "") // if map not found in MapVoteHistory then add it
	{
		MapInfo.M = MapName;
		bUpdate = True;
	}

	if(bUpdate)
		History.AddMap(MapInfo);
}
*/

//------------------------------------------------------------------------------------------------
function int GetMVRIIndex(PlayerController Player)
{
	local int i;

	for(i=0;i < MVRI.Length;i++)
		if(MVRI[i] != None && MVRI[i].PlayerOwner == Player)
			return i;
	return -1;
}
//------------------------------------------------------------------------------------------------
function SubmitMapVote(int MapIndex, int GameIndex, Actor Voter)
{
	local int Index, VoteCount, PrevMapVote, PrevGameVote;
	//local MapHistoryInfo MapInfo;

    log("TribesVotingHandler.SubmitMapVote: mapIndex="$Mapindex$", gameIndex="$GameIndex$", voter="$voter, 'voting');

	if(bLevelSwitchPending)
	{
	    log("level switch pending", 'voting');
		return;
    }

	Index = GetMVRIIndex(PlayerController(Voter));

	if (PlayerController(Voter).PlayerReplicationInfo.bAdmin)
	{
	    log("voter is an admin", 'voting');
	
		TextMessage = lmsgAdminMapChange;
		TextMessage = Repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")");
		Level.Game.Broadcast(self,TextMessage);

		log("Admin has forced map switch to " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'voting');

		CloseAllVoteWindows();

		bLevelSwitchPending = true;

        // VOTING TODO - map info history play map

        /*
		MapInfo = History.PlayMap(MapList[MapIndex].MapName);

		ServerTravelString = SetupGameMap(MapList[MapIndex], GameIndex, MapInfo);
		log("ServerTravelString = " $ ServerTravelString ,'votedebug');
		*/

		ServerTravelString = SetupGameMap(MapList[MapIndex], GameIndex);

		Level.ServerTravel(ServerTravelString, false);    // change the map

		settimer(1,true);
		return;
	}

	if (PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator)
	{
		log("ignoring spectator vote", 'voting');
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}
	
	// reject invalid map votes

	if (MapIndex<0 || MapIndex>=MapCount)
	{
	    log("rejecting vote for invalid map index", 'voting');
	    return;
	}
	
	if (GameIndex<0 || GameIndex>=GameConfig.Length)
	{
	    log("rejecting vote for invalid game type index", 'voting');
	    return;
	}
	
	if (MVRI[Index].GameVote==GameIndex && MVRI[Index].MapVote==MapIndex)
	{
	    log("rejecting duplicate vote for same map and game type", 'voting');
		return;
    }

    /*
	// check for invalid map, invalid gametype, player isnt revoting same as previous vote, and map choosen isnt disabled
	if(MapIndex < 0 ||
		MapIndex >= MapCount ||
		GameIndex >= GameConfig.Length ||
		(MVRI[Index].GameVote == GameIndex && MVRI[Index].MapVote == MapIndex) ||
		!MapList[MapIndex].bEnabled)
		return;
		*/

	log("___" $ Index $ " - " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " voted for " $ MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")",'voting');

	PrevMapVote = MVRI[Index].MapVote;
	PrevGameVote = MVRI[Index].GameVote;
	MVRI[Index].MapVote = MapIndex;
	MVRI[Index].GameVote = GameIndex;

	if(bAccumulationMode)
	{
	    log("bAccumulationMode=true", 'voting');
	
		if(bScoreMode)
		{
		    log("bScoreMode=true", 'voting');
		
			VoteCount = GetAccVote(PlayerController(Voter)) + int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
		    log("bScoreMode=false", 'voting');
		
			VoteCount = GetAccVote(PlayerController(Voter)) + 1;
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	else
	{
	    log("bAccumulationMode=false", 'voting');
	
		if(bScoreMode)
		{
		    log("bScoreMode=true", 'voting');
		
			VoteCount = int(GetPlayerScore(PlayerController(Voter)));
			TextMessage = lmsgMapVotedForWithCount;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%votecount%", string(VoteCount) );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
		else
		{
		    log("bScoreMode=false", 'voting');
		
			VoteCount =  1;
			TextMessage = lmsgMapVotedFor;
			TextMessage = repl(TextMessage, "%playername%", PlayerController(Voter).PlayerReplicationInfo.PlayerName );
			TextMessage = repl(TextMessage, "%mapname%", MapList[MapIndex].MapName $ "(" $ GameConfig[GameIndex].Acronym $ ")" );
			Level.Game.Broadcast(self,TextMessage);
		}
	}
	
	UpdateVoteCount(MapIndex, GameIndex, VoteCount);
	
	if (PrevMapVote>-1 && PrevGameVote>-1)
	{
	    log("undo previous vote for player: "$voter);
		UpdateVoteCount(PrevMapVote, PrevGameVote, -MVRI[Index].VoteCount);
    }
	
	MVRI[Index].VoteCount = VoteCount;
	
	TallyMapVotes(false);
}
//------------------------------------------------------------------------------------------------
function UpdateVoteCount(int MapIndex, int GameIndex, int VoteCount)
{
	local int x,i;
	local bool bFound;
	local MapVoteScore MVCData;

	// search for matching record
	for( x=0; x<MapVoteCount.Length; x++ )
	{
		if( MapVoteCount[x].GameConfigIndex == GameIndex &&
		    MapVoteCount[x].MapIndex == MapIndex)
		{
			MapVoteCount[x].VoteCount += VoteCount;
			MVCData = MapVoteCount[x];
			if(MapVoteCount[x].VoteCount <= 0)
				MapVoteCount.Remove( x, 1);
			bFound = true;
			
			log("found existing vote record: mapIndex="$MapIndex$", GameIndex="$gameIndex$", voteCount="$voteCount, 'voting');
			
			break;
		}
	}

	if( !bFound && VoteCount > 0) // add new if not found
	{
	    log("adding new vote record: mapIndex="$MapIndex$", GameIndex="$gameIndex$", voteCount="$voteCount, 'voting');
	
		x = MapVoteCount.Length;
		MapVoteCount.Insert(x,1);
		MapVoteCount[x].GameConfigIndex = GameIndex;
		MapVoteCount[x].MapIndex = MapIndex;
		MapVoteCount[x].VoteCount = VoteCount;
		MVCData = MapVoteCount[x];
	}

	// send update to all players
	for( i=0; i<MVRI.Length; i++ )
	{
	    log("sending vote update to "$MVRI[i].PlayerOwner, 'voting');
	
		if( MVRI[i] != none && MVRI[i].PlayerOwner != none )
			MVRI[i].ReceiveMapVoteCount(MVCData, False);
	}
}
//------------------------------------------------------------------------------------------------
function TallyMapVotes(bool bForceMapSwitch)
{
	local int        index,x,y,topmap,r,mapidx,gameidx;
	local array<int> VoteCount;
	local array<int> Ranking;
	local int        PlayersThatVoted;
	local int        TieCount;
	local string     CurrentMap;
	local int        Votes;
	//local MapHistoryInfo MapInfo;         // VOTING TODO - map history info

    //log("TallyMapVotes: bForceMapSwitch="$bForceMapSwitch, 'voting');

	if(bLevelSwitchPending)
	{
	    log("level switch pending", 'voting');
		return;
    }

	// MJ:  Only allow map change vote if the game has entered GamePhase; this prevents an exploit when the map changes
	// where someone can vote a map change before everyone else reconnects
	if (MultiplayerGameInfo(Level.Game) != None && !MultiplayerGameInfo(Level.Game).allowMapVote())
		return;

	PlayersThatVoted = 0;
	VoteCount.Length = GameConfig.Length * MapCount;
	// note: VoteCount array is a 2 dimension array VoteCount[GameConfigIndex, MapIndex]
	//       Maps ->
	//       0 1 2 3 4 5 6 7 8
	// G     - - - - - - - - -
	// a  0 |0 0 0 0 0 0 0 2 0
	// m  1 |0 0 0 2 0 0 0 0 0
	// e  2 |0 6 0 0 0 5 0 0 0
	// s  3 |0 0 0 3 0 0 0 0 0

	for (x=0; x<MVRI.Length; x++) // for each player
	{
		if (MVRI[x]!=none && MVRI[x].MapVote>-1 && MVRI[x].GameVote>-1) // if this player has voted
		{
			PlayersThatVoted++;

			if(bScoreMode)
			{
				if(bAccumulationMode)
					Votes = GetAccVote(MVRI[x].PlayerOwner) + int(GetPlayerScore(MVRI[x].PlayerOwner));
				else
					Votes = int(GetPlayerScore(MVRI[x].PlayerOwner));
			}
			else
			{  // Not Score Mode == Majority (one vote per player)
				if(bAccumulationMode)
					Votes = GetAccVote(MVRI[x].PlayerOwner) + 1;
				else
					Votes = 1;
			}
			VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote] = VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote] + Votes;

			if(!bScoreMode)
			{
				// If more then half the players voted for the same map as this player then force a winner
				if(Level.Game.NumPlayers > 2 && float(VoteCount[MVRI[x].GameVote * MapCount + MVRI[x].MapVote]) / float(Level.Game.NumPlayers) > 0.5 && Level.Game.bGameEnded)
					bForceMapSwitch = true;
			}
		}
	}

	//log("___Voted - " $ PlayersThatVoted,'votedebug');

	if (!Level.Game.bGameEnded && !bMidGameVote && (float(PlayersThatVoted) / float(Level.Game.NumPlayers)) * 100 >= MidGameVotePercent)
	{
	    log("*** starting mid game vote ***", 'voting');
	
		Level.Game.Broadcast(self,lmsgMidGameVote);

		bMidGameVote = true;

		// Start voting count-down timer
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = 1;
		settimer(1,true);
	}

	index = 0;

	for(x=0;x < VoteCount.Length;x++) // for each map
	{
		if(VoteCount[x] > 0)
		{
			Ranking.Insert(index,1);
			Ranking[index++] = x; // copy all vote indexes to the ranking list if someone has voted for it.
		}
	}

	if(PlayersThatVoted > 1)
	{
		// bubble sort ranking list by vote count
		for(x=0; x<index-1; x++)
		{
			for(y=x+1; y<index; y++)
			{
				if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
				{
				topmap = Ranking[x];
				Ranking[x] = Ranking[y];
				Ranking[y] = topmap;
				}
			}
		}
	}
	else
	{
		if(PlayersThatVoted == 0)
		{
			GetDefaultMap(mapidx, gameidx);
			topmap = gameidx * MapCount + mapidx;
		}
		else
			topmap = Ranking[0];  // only one player voted
	}

	//Check for a tie
	if(PlayersThatVoted > 1) // need more than one player vote for a tie
	{
		if(index > 1 && VoteCount[Ranking[0]] == VoteCount[Ranking[1]] && VoteCount[Ranking[0]] != 0)
		{
		    log("tie break", 'voting');
		
			TieCount = 1;
			for(x=1; x<index; x++)
			{
				if(VoteCount[Ranking[0]] == VoteCount[Ranking[x]])
				TieCount++;
			}
			//reminder ---> int Rand( int Max ); Returns a random number from 0 to Max-1.
			topmap = Ranking[Rand(TieCount)];

			// Don't allow same map to be choosen
			CurrentMap = GetURLMap();

			r = 0;
			while(MapList[topmap - (topmap/MapCount) * MapCount].MapName ~= CurrentMap)
			{
				topmap = Ranking[Rand(TieCount)];
				if(r++>100)
					break;  // just incase
			}
		}
		else
		{
			topmap = Ranking[0];
		}
	}

	// if everyone has voted go ahead and change map
	if(bForceMapSwitch || (Level.Game.NumPlayers == PlayersThatVoted && Level.Game.NumPlayers > 0) )
	{
	    log("everybody has voted, changing map", 'voting');
	
		if(MapList[topmap - topmap/MapCount * MapCount].MapName == "")
			return;

		TextMessage = lmsgMapWon;
		TextMessage = repl(TextMessage,"%mapname%",MapList[topmap - topmap/MapCount * MapCount].MapName $ "(" $ GameConfig[topmap/MapCount].Acronym $ ")");
		Level.Game.Broadcast(self,TextMessage);

		CloseAllVoteWindows();

        // VOTING TODO - history and map info (PlayMap via history req?)

        /*
		MapInfo = History.PlayMap(MapList[topmap - topmap/MapCount * MapCount].MapName);

		ServerTravelString = SetupGameMap(MapList[topmap - topmap/MapCount * MapCount], topmap/MapCount, MapInfo);
		log("ServerTravelString = " $ ServerTravelString ,'votedebug');

		History.Save();
		*/

		ServerTravelString = SetupGameMap(MapList[topmap - topmap/MapCount * MapCount], topmap/MapCount);

		if(bEliminationMode)
			RepeatLimit++;

		if(bAccumulationMode)
			SaveAccVotes(topmap - topmap/MapCount * MapCount, topmap/MapCount);

		//if(bEliminationMode || bAccumulationMode)
		CurrentGameConfig = topmap/MapCount;
		SaveConfig();

		bLevelSwitchPending = true;
		settimer(Level.TimeDilation,true);  // timer() will monitor the server-travel and detect a failure

        log("server travel: "$ServerTravelString, 'voting');

		Level.ServerTravel(ServerTravelString, false);    // change the map
	}
}
//------------------------------------------------------------------------------------------------
event timer()
{
	//local int mapidx,gameidx;
	local int i;
	//local MapHistoryInfo MapInfo;

	if (bLevelSwitchPending)
	{
		if( Level.NextURL == "" )
		{
			if(Level.NextSwitchCountdown < 0)  // if negative then level switch failed
			{
			    log("change map failed!", 'voting');
			    
			    /*
				Log("___Map change Failed, bad or missing map file.",'voting');
				GetDefaultMap(mapidx, gameidx);
				MapInfo = History.PlayMap(MapList[mapidx].MapName);
				ServerTravelString = SetupGameMap(MapList[mapidx], gameidx, MapInfo);
				log("ServerTravelString = " $ ServerTravelString ,'votedebug');
				History.Save();
				Level.ServerTravel(ServerTravelString, false);    // change the map
				*/
			}
		}
		return;
	}

	if(ScoreBoardTime > -1)
	{
		if (ScoreBoardTime==0)
		{
		    // VOTING TODO - open vote windows
		
            //log("open all voting windows");
		
			OpenAllVoteWindows();
	    }
		ScoreBoardTime--;
		return;
	}
	TimeLeft--;

	if (TimeLeft == 60 || TimeLeft == 30 || TimeLeft == 20 || TimeLeft<10)
	{
	    //Level.Game.Broadcast(self, TimeLeft$" seconds left in map vote", 'voting');
		
		for( i=0; i<MVRI.Length; i++)
			if(MVRI[i] != none && MVRI[i].PlayerOwner != none )
				MVRI[i].PlayCountDown(TimeLeft);
	}

	if (TimeLeft==0)
	{   
	    //Level.Game.Broadcast(self, "map vote has ended", 'voting');
	
		TallyMapVotes(true);   // if no-one has voted a random map will be choosen
		
		// todo: tally other votes too!
	}
}
//------------------------------------------------------------------------------------------------
function CloseAllVoteWindows()
{
	local int i;

    log("close all vote windows", 'voting');

	for(i=0; i < MVRI.Length;i++)
	{
		if(MVRI[i] != none)
		{
			//log("___Closing window " $ i,'votedebug');
			MVRI[i].CloseWindow();
		}
	}
}
//------------------------------------------------------------------------------------------------
function OpenAllVoteWindows()
{
	local int i;

    log("open all vote windows");

	for(i=0; i < MVRI.Length;i++)
	{
		if(MVRI[i] != none)
		{
			//log("Opening window " $ i,'votedebug');
			MVRI[i].OpenWindow();
		}
	}
}
//------------------------------------------------------------------------------------------------
function string SetupGameMap(MapVoteMapList MapInfo, int GameIndex)//, MapHistoryInfo MapHistoryInfo)
{
	local string ReturnString;
	local string MutatorString;
	local string OptionString;

    /*
	// Add Per-GameType Mutators
	if(GameConfig[GameIndex].Mutators != "")
		MutatorString = MutatorString $ GameConfig[GameIndex].Mutators;
		*/

    /*
	// Add Per-Map Mutators
	if(MapHistoryInfo.U != "")
		MutatorString = MutatorString $ "," $ MapHistoryInfo.U;
		*/

	// Add Per-GameType Game Options
	if(GameConfig[GameIndex].Options != "")
		OptionString = OptionString $ Repl(Repl(GameConfig[GameIndex].Options,",","?")," ","");

    /*
	// Add Per-Map Game Options
	if(MapHistoryInfo.G != "")
		OptionString = OptionString $ "?" $ MapHistoryInfo.G;
		*/

	// create URL
	ReturnString = MapInfo.MapName;
	ReturnString = ReturnString $ "?Game=" $ GameConfig[GameIndex].GameClass;

	if(MutatorString != "")
		ReturnString = ReturnString $ "?Mutator=" $ MutatorString;

	if(OptionString != "")
		ReturnString = ReturnString $ "?" $ OptionString;

	return ReturnString;
}
//------------------------------------------------------------------------------------------------
function bool HandleRestartGame()
{
	local int i;
	// Called by GameInfo.RestartGame at End Of Game
	// Return False to prevent traveling to next map
    log("____HandleRestartGame", 'votedebug');

	// disable voting in single player mode
    if( Level.NetMode == NM_StandAlone )
		return true;

	if( bMatchSetup ) // check if any match setup in progress
	{
		for( i=0; i<MVRI.Length; i++)
			if( MVRI[i] != none && MVRI[i].bMatchSetupPermitted )
				return false; // don't contine to next map
	}

	if(bMapVote && bAutoOpen)
	{
	    // VOTING TODO - code below seems redundant in our game
	
	    /*
		//check if the game is an assault mod for UT2k3Assault
		if(string(Level.Game.Class) ~= "RoARAssault.xAssault")
			if(int(Level.Game.GameReplicationInfo.GetPropertyText("Part")) != 2)
				return true;

		// Start voting count-down timer
		TimeLeft = VoteTimeLimit;
		ScoreBoardTime = ScoreBoardDelay;
		settimer(1,true);
  		return false;
		*/
	}
	return true;
}
//------------------------------------------------------------------------------------------------
function MapVoteMapList GetMapList(int p_MapIndex)
{
	return MapList[p_MapIndex];
}
//------------------------------------------------------------------------------------------------
function MapVoteGameConfigLite GetGameConfig(int p_GameConfigIndex)
{
	local MapVoteGameConfigLite GameConfigItem;

	GameConfigItem.GameClass = GameConfig[p_GameConfigIndex].GameClass;
	GameConfigItem.Prefix = GameConfig[p_GameConfigIndex].Prefix;
	GameConfigItem.GameName = GameConfig[p_GameConfigIndex].GameName;

	return GameConfigItem;
}
//------------------------------------------------------------------------------------------------
function float GetPlayerScore(PlayerController Player)
{
	local float PlayerScore;

	if( !Level.Game.bGameEnded )
		PlayerScore = 1;
	else
		PlayerScore = Player.PlayerReplicationInfo.Score;

	if(PlayerScore < 1)
		PlayerScore = 1;

	return PlayerScore;
}
//------------------------------------------------------------------------------------------------
function int GetAccVote(PlayerController Player)
{
	local int x,PlayerAccVotes;
	local string PlayerName;

	PlayerName = Player.PlayerReplicationInfo.PlayerName;

	if(PlayerName == "")
		return(0);

	if(AccInfo.Length > 0)
	{
		// Find the players name in the saved accumulated votes
		for(x=0;x<AccInfo.Length;x++)
		{
			if(AccInfo[x].Name == PlayerName)
			{
				PlayerAccVotes = AccInfo[x].VoteCount;
				break;
			}
		}
	}
	else
		PlayerAccVotes = 0;
	return(PlayerAccVotes);
}
//------------------------------------------------------------------------------------------------
function SaveAccVotes(int WinningMapIndex, int WinningGameIndex)
{
	local Controller C;
	local PlayerController P;
	local int x, Index;
	local bool bFound;

	if(AccInfo.Length > 0)
	{
		for(x=0;x<AccInfo.Length;x++)
		{
			if(AccInfo[x].Name != "")
			{
				bFound = false;
				for(C=Level.ControllerList;C!=None;C=C.NextController)
				{
					P = PlayerController(C);
					if(C.bIsPlayer && P != None && AccInfo[x].Name == P.PlayerReplicationInfo.PlayerName)
					{
						Index = GetMVRIIndex(P);
						if(MVRI[Index] != None && MVRI[Index].MapVote != WinningMapIndex && MVRI[Index].GameVote != WinningGameIndex)
						{
							bFound = true;
							if(bScoreMode)
								AccInfo[x].VoteCount = AccInfo[x].VoteCount + int(GetPlayerScore(P));
							else
								AccInfo[x].VoteCount++;
						}
						break;
					}
				}
				if(!bFound)  // If this player is not here anymore remove or voted for winning map then remove
				{
					AccInfo[x].Name = "";
					AccInfo[x].VoteCount = 0;
				}
			}
		}

		// Remove blank entries
		for(x=AccInfo.Length-1;x>=0;x--)
		{
			if(AccInfo[x].Name == "")
			{
				//log("Removeing " $ AccInfo[x].Name);
				AccInfo.Remove(x,1);
			}
		}
	}

	// Add players who have not voted
	for(C=Level.ControllerList;C!=None;C=C.NextController)
	{
		P = PlayerController(C);
		if(C.bIsPlayer && P != None)
		{
			bFound = false;
			if(AccInfo.Length > 0)
			{
				for(x=0;x<AccInfo.Length;x++)
				{
					if(AccInfo[x].Name == P.PlayerReplicationInfo.PlayerName)
					{
						bFound = true;
						break;
					}
				}
			}
			Index = GetMVRIIndex(P);
			if(!bFound && MVRI[Index].MapVote != WinningMapIndex && MVRI[Index].GameVote != WinningGameIndex)
			{
				// Not found, so add it
				AccInfo.Insert(AccInfo.Length,1);
				AccInfo[AccInfo.Length - 1].Name = P.PlayerReplicationInfo.PlayerName;
				if(bScoreMode)
					AccInfo[AccInfo.Length - 1].VoteCount = int(GetPlayerScore(P));
				else
					AccInfo[AccInfo.Length - 1].VoteCount = 1;
			}
		}
	}
}
//------------------------------------------------------------------------------------------------
function GetDefaultMap(out int mapidx, out int gameidx)
{
    // VOTING TODO - this whole function is probably quite incorrect for our map/gametype setup!

	local int i,x,y,r,p,GCIdx;
	local array<string> PrefixList;
	local bool bLoop;

	if(MapCount <= 0)
		return;

	// set the default gametype
	if(bDefaultToCurrentGameType)
		GCIdx = CurrentGameConfig;
	else
		GCIdx = DefaultGameConfig;

	// Parse Prefix list for default game type
	PrefixList.Length = 0;
	p = Split(GameConfig[GCIdx].Prefix, ",", PrefixList);
	if(PrefixList.Length == 0)
	{
		gameidx = GCIdx;
		mapidx = 0;
		return;
	}

	// choose a map at random, check if it is enabled and the prefix is in the prefix list
	r=0;
	bLoop = True;
	while(bLoop)
	{
		i = Rand(MapCount);
		if( MapList[i].bEnabled )
		{
			for(x=0; x < PrefixList.Length; x++)
			{
				if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
				{
					bLoop = false;
					break;
				}
			}
		}

		if(bLoop && r++ > 100)
		{
			// give up after 100 unsuccessful attempts.
			// find the first map that matches up to default gametype
            for(i=0;i<MapCount;i++)
			{
				if( MapList[i].bEnabled )
				{
					for(x=0; x < PrefixList.Length; x++)
					{
						if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
						{
							// ding ding ding, found one
							bLoop = false;
							break;
						}
					}
				}
			}

			if(bLoop) // still didnt find any, then find the first enabled map and find its gameconfig
			{
				for(i=0;i<MapCount;i++)
				{
					if( MapList[i].bEnabled )
					{
						// find prefix in GameConfigs
						for(y=0;y<GameConfig.Length;y++)
						{
							// Parse Prefix list for game type
							PrefixList.Length = 0;
							p = Split(GameConfig[y].Prefix, ",", PrefixList);
							if(PrefixList.Length > 0)
							{
								for(x=0; x < PrefixList.Length; x++)
								{
									if( left(MapList[i].MapName, len(PrefixList[x])) ~= PrefixList[x] )
									{
										// ding ding ding, found one
										GCIdx = y;
										bLoop = false;
										break;
									}
								}
							}
							if(!bLoop)
								break;
						}
						break;
					}
				}
			}
			break;
		}
	}
	gameidx = GCIdx;
	mapidx = i;
	//log("Default Map Chosen = " $ MapList[mapidx].MapName $ "(" $ GameConfig[gameidx].Acronym $ ")",'votedebug');
}
//================================================================================================
//                                    Kick Voting
//================================================================================================
function SubmitKickVote(int PlayerID, Actor Voter)
{
	local int VoterID, VictimID, i, PreviousVote;
	local bool bFound;
	local string PlayerName;

	log("SubmitKickVote " $ PlayerID, 'votedebug');

	if (bLevelSwitchPending || !bKickVote)
		return;

	VoterID = GetMVRIIndex(PlayerController(Voter));

	// Find Player
	bFound = false;
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != none && MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			bFound = true;
			VictimID = i;
			PlayerName = MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerName;
			break;
		}
	}
	if(!bFound)
		return;

	if( MVRI[VoterID].KickVote == VictimID ) // if vote is for same player stop
		return;

	if( PlayerController(Voter).PlayerReplicationInfo.bAdmin )  // Administrator Vote
	{
		log("___Admin " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " kicked " $ PlayerName,'voting');
		KickPlayer(VictimID);
		return;
	}

	if( PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator )
	{
		// Spectators cant vote

		Level.Game.Broadcast(self,lmsgMidGameVote);

		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	// cant kick admin
	if(MVRI[VictimID].PlayerOwner.PlayerReplicationInfo.bAdmin || NetConnection(MVRI[VictimID].PlayerOwner.Player) == None)
	{
		TextMessage = lmsgKickVoteAdmin;
		TextMessage = repl(TextMessage,"%playername%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		Level.Game.Broadcast(self,TextMessage);
		return;
	}

	log("___" $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " placed a kick vote against " $ PlayerName,'voting');
	if (bAnonymousKicking)
	{
		TextMessage = lmsgAnonymousKickVote;
		TextMessage = repl(TextMessage,"%playername%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	else
	{
		TextMessage = lmsgKickVote;
		TextMessage = repl(TextMessage,"%playername1%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		TextMessage = repl(TextMessage,"%playername2%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	PreviousVote = MVRI[VoterID].KickVote;
	MVRI[VoterID].KickVote = VictimID;

  	UpdateKickVoteCount(MVRI[VictimID].PlayerID, 1);
	if( PreviousVote > -1 )
		UpdateKickVoteCount(MVRI[PreviousVote].PlayerID, -1); // undo previous vote

	TallyKickVotes();
}
//------------------------------------------------------------------------------------------------
function UpdateKickVoteCount(int PlayerID, int VoteCountDelta)
{
	local int x,i;
	local bool bFound;

	if( PlayerID < 0 )
		return;

	// search for matching record
	for( x=0; x<KickVoteCount.Length; x++ )
	{
		if( KickVoteCount[x].PlayerID == PlayerID)
		{
			if( VoteCountDelta == 0 )
				KickVoteCount[x].KickVoteCount = 0;
			else
				KickVoteCount[x].KickVoteCount += VoteCountDelta;

			if( KickVoteCount[x].KickVoteCount < 0 )
			   KickVoteCount[x].KickVoteCount = 0;
			bFound = true;
			break;
		}
	}

	if( !bFound && VoteCountDelta > 0) // add new if not found
	{
		x = KickVoteCount.Length;
		KickVoteCount.Insert(x,1);
		KickVoteCount[x].PlayerID = PlayerID;
		KickVoteCount[x].KickVoteCount = 1;
	}

	// send update to all players
	for( i=0; i<MVRI.Length; i++ )
	{
		if( MVRI[i] != none && MVRI[i].PlayerOwner != none && x < KickVoteCount.Length )
			MVRI[i].ReceiveKickVoteCount(KickVoteCount[x], False);
	}
}
//------------------------------------------------------------------------------------------------
function TallyKickVotes()
{
	local int i,x,y,index,PlayersThatVoted,Lamer;
	local array<int> VoteCount;
	local array<int> Ranking;

	VoteCount.Length = MVRI.Length;

	// tally up the votes
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != None && MVRI[i].KickVote != -1) // if this player has voted
		{
			PlayersThatVoted++;
			VoteCount[MVRI[i].KickVote]++; // increment the votecount for this player
		}
	}

	index = 0;
	for(i=0;i < VoteCount.Length;i++) // for each player
	{
		if(VoteCount[i] > 0)
		{
			Ranking.Insert(index,1);
			Ranking[index++] = i;
		}
	}

	if(PlayersThatVoted > 1)
	{
		// bubble sort ranking list by vote count
		for(x=0; x<index-1; x++)
		{
			for(y=x+1; y<index; y++)
			{
				if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
				{
				Lamer = Ranking[x];
				Ranking[x] = Ranking[y];
				Ranking[y] = Lamer;
				}
			}
		}
		Lamer = Ranking[0];
	}

	// if more than KickPercent of the players voted to kick this player then kick
	// TODO: For TESTING only , remove
	//if(Level.Game.NumPlayers > 2 && ((float(VoteCount[Lamer])/float(Level.Game.NumPlayers))*100 >= KickPercent))
	if(((float(VoteCount[Lamer])/float(Level.Game.NumPlayers))*100 >= KickPercent))
	{
		KickPlayer(Lamer);
		return;
	}
}
//------------------------------------------------------------------------------------------------
function KickPlayer(int PlayerIndex)
{
	local int i;

	if( MVRI[PlayerIndex] == none || MVRI[PlayerIndex].PlayerOwner == none )
		return;

	TextMessage = "%playername% has been kicked.";
	TextMessage = repl(TextMessage,"%playername%",MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName);
	Level.Game.Broadcast(self,TextMessage);

	if(bKickVote)
	{
		// Reset votes
		for(i=0;i < MVRI.Length;i++)
		{
			if(MVRI[i] != None && MVRI[i].KickVote != -1)
				MVRI[i].KickVote = -1;
		}
	}

	//close his/her voting window if open
	if(MVRI[PlayerIndex] != None)
		MVRI[PlayerIndex].CloseWindow();

	log("___" $ MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName $ " has been kicked.",'voting');
	Level.Game.AccessControl.BanPlayer(MVRI[PlayerIndex].PlayerOwner, True); // session type ban
}
//================================================================================================
//                                    Admin Voting
//================================================================================================
function SubmitAdminVote(int PlayerID, Actor Voter)
{
	local int VoterID, VictimID, i, PreviousVote;
	local bool bFound;
	local string PlayerName;

	log("SubmitAdminVote " $ PlayerID, 'voting');

	if(bLevelSwitchPending || !bAdminVote)
		return;

	VoterID = GetMVRIIndex(PlayerController(Voter));

	// Find Player
	bFound = false;
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != none && MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			bFound = true;
			VictimID = i;
			PlayerName = MVRI[i].PlayerOwner.PlayerReplicationInfo.PlayerName;
			break;
		}
	}
	if(!bFound)
		return;

	if( MVRI[VoterID].AdminVote == VictimID ) // if vote is for same player stop
		return;

	if( PlayerController(Voter).PlayerReplicationInfo.bAdmin )  // Administrator Vote
	{
		log("___Admin " $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " admined " $ PlayerName,'voting');
		AdminPlayer(VictimID);
		return;
	}

	if( PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator )
	{
		// Spectators cant vote
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

	// cant admin admin
	if(MVRI[VictimID].PlayerOwner.PlayerReplicationInfo.bAdmin || NetConnection(MVRI[VictimID].PlayerOwner.Player) == None)
	{
		TextMessage = lmsgAdminVoteAdmin;
		TextMessage = repl(TextMessage,"%playername%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		Level.Game.Broadcast(self,TextMessage);
		return;
	}

	log("___" $ PlayerController(Voter).PlayerReplicationInfo.PlayerName $ " placed a admin vote against " $ PlayerName,'voting');
	if(bAnonymousAdmining)
	{
		TextMessage = lmsgAnonymousAdminVote;
		TextMessage = repl(TextMessage,"%playername%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	else
	{
		TextMessage = lmsgAdminVote;
		TextMessage = repl(TextMessage,"%playername1%",PlayerController(Voter).PlayerReplicationInfo.PlayerName);
		TextMessage = repl(TextMessage,"%playername2%",PlayerName);
		Level.Game.Broadcast(self,TextMessage);
	}
	PreviousVote = MVRI[VoterID].AdminVote;
	MVRI[VoterID].AdminVote = VictimID;

  	UpdateAdminVoteCount(MVRI[VictimID].PlayerID, 1);
	if( PreviousVote > -1 )
		UpdateAdminVoteCount(MVRI[PreviousVote].PlayerID, -1); // undo previous vote

	TallyAdminVotes();
}
//------------------------------------------------------------------------------------------------
function UpdateAdminVoteCount(int PlayerID, int VoteCountDelta)
{
	local int x,i;
	local bool bFound;

	if( PlayerID < 0 )
		return;

	// search for matching record
	for( x=0; x<AdminVoteCount.Length; x++ )
	{
		if( AdminVoteCount[x].PlayerID == PlayerID)
		{
			if( VoteCountDelta == 0 )
				AdminVoteCount[x].AdminVoteCount = 0;
			else
				AdminVoteCount[x].AdminVoteCount += VoteCountDelta;

			if( AdminVoteCount[x].AdminVoteCount < 0 )
			   AdminVoteCount[x].AdminVoteCount = 0;
			bFound = true;
			break;
		}
	}

	if( !bFound && VoteCountDelta > 0) // add new if not found
	{
		x = AdminVoteCount.Length;
		AdminVoteCount.Insert(x,1);
		AdminVoteCount[x].PlayerID = PlayerID;
		AdminVoteCount[x].AdminVoteCount = 1;
	}

	// send update to all players
	for( i=0; i<MVRI.Length; i++ )
	{
		if( MVRI[i] != none && MVRI[i].PlayerOwner != none && x < AdminVoteCount.Length )
			MVRI[i].ReceiveAdminVoteCount(AdminVoteCount[x], False);
	}
}
//------------------------------------------------------------------------------------------------
function TallyAdminVotes()
{
	local int i,x,y,index,PlayersThatVoted,Lamer;
	local array<int> VoteCount;
	local array<int> Ranking;

	VoteCount.Length = MVRI.Length;

	// tally up the votes
	for(i=0;i < MVRI.Length;i++)
	{
		if(MVRI[i] != None && MVRI[i].AdminVote != -1) // if this player has voted
		{
			PlayersThatVoted++;
			VoteCount[MVRI[i].AdminVote]++; // increment the votecount for this player
		}
	}

	index = 0;
	for(i=0;i < VoteCount.Length;i++) // for each player
	{
		if(VoteCount[i] > 0)
		{
			Ranking.Insert(index,1);
			Ranking[index++] = i;
		}
	}

	if(PlayersThatVoted > 1)
	{
		// bubble sort ranking list by vote count
		for(x=0; x<index-1; x++)
		{
			for(y=x+1; y<index; y++)
			{
				if(VoteCount[Ranking[x]] < VoteCount[Ranking[y]])
				{
				Lamer = Ranking[x];
				Ranking[x] = Ranking[y];
				Ranking[y] = Lamer;
				}
			}
		}
		Lamer = Ranking[0];
	}

	// if more than AdminPercent of the players voted to admin this player then admin
	if(((float(VoteCount[Lamer])/float(Level.Game.NumPlayers))*100 >= AdminPercent))
	{
		AdminPlayer(Lamer);
		return;
	}
}
//------------------------------------------------------------------------------------------------
function AdminPlayer(int PlayerIndex)
{
	local int i;

	if( MVRI[PlayerIndex] == none || MVRI[PlayerIndex].PlayerOwner == none )
		return;

	TextMessage = "%playername% has been made admin.";
	TextMessage = repl(TextMessage,"%playername%",MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName);
	Level.Game.Broadcast(self,TextMessage);

	if(bAdminVote)
	{
		// Reset votes
		for(i=0;i < MVRI.Length;i++)
		{
			if(MVRI[i] != None && MVRI[i].AdminVote != -1)
				MVRI[i].AdminVote = -1;
		}
	}

	//close his/her voting window if open
	if(MVRI[PlayerIndex] != None)
		MVRI[PlayerIndex].CloseWindow();

	log("___" $ MVRI[PlayerIndex].PlayerOwner.PlayerReplicationInfo.PlayerName $ " has been admined.",'voting');

	MVRI[PlayerIndex].PlayerOwner.ForceAdmin();
    log("****** MAKE PLAYER ADMIN ******", 'voting');
}

//================================================================================================
//                                    Team Damage Voting
//================================================================================================

function SubmitTeamDamageVote(bool vote, Actor Voter)
{
    local int VoterID;

	if(bLevelSwitchPending || !bTeamDamageVote)
		return;

    log("SubmitTeamDamageVote: "$vote$"["$voter$"]", 'voting');

	VoterID = GetMVRIIndex(PlayerController(Voter));

    // check voter id
    
    if (VoterID<0)
        return;

    // spectators cannot vote
    
	if (PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator)
	{
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

    // ignore duplicate vote

	if (MVRI[VoterID].TeamDamageVote==int(vote))
		return;

    // undo previous vote if exists
    
    if (MVRI[VoterID].TeamDamageVote!=-1)
    {
        if (MVRI[VoterID].TeamDamageVote==0)
            UpdateTeamDamageVoteCount(0,-1);     // undo no vote
        else if (MVRI[VoterID].TeamDamageVote==1)
            UpdateTeamDamageVoteCount(-1,0);     // undo yes vote
    }
    
    // update vote count
    
    if (vote==true)
    {
	    //Level.Game.Broadcast(self, PlayerController(Voter).PlayerReplicationInfo.PlayerName$" voted for team damage");
    
        UpdateTeamDamageVoteCount(1,0);     // yes vote
    }
    else
    {
	   // Level.Game.Broadcast(self, PlayerController(Voter).PlayerReplicationInfo.PlayerName$" voted against team damage");

        UpdateTeamDamageVoteCount(0,1);     // no vote
    }

    // set the vote in the replication info
    
    MVRI[VoterID].TeamDamageVote = int(vote);

    // tally the votes!
	
	TallyTeamDamageVotes();
}

function UpdateTeamDamageVoteCount(int yesVoteDelta, int noVoteDelta)
{
    local int i;

    // update vote counts

    TeamDamageVoteCount.yesVotes += yesVoteDelta;
    TeamDamageVoteCount.noVotes += noVoteDelta;

    // todo: validation of vote counts ?
    
	// send update to all players
	
	for (i=0; i<MVRI.Length; i++)
	{
		if (MVRI[i]!=none && MVRI[i].PlayerOwner!=none)
			MVRI[i].ReceiveTeamDamageVoteCount(TeamDamageVoteCount, False);
	}
}

function TallyTeamDamageVotes()
{
	// if more than TeamDamagePercent of the players voted for team damage then enable it
	
	if (((float(TeamDamageVoteCount.yesVotes)/float(Level.Game.NumPlayers))*100 >= TeamDamagePercent))
	{
	    Level.Game.Broadcast(self, lmsgTeamDamageEnabled);

		MultiplayerGameInfo(Level.Game).setPlayerTeamDamagePercentage(0.0);
	}
    else if (((float(TeamDamageVoteCount.noVotes)/float(Level.Game.NumPlayers))*100 >= TeamDamagePercent))
    {
	    Level.Game.Broadcast(self, lmsgTeamDamageDisabled);

		MultiplayerGameInfo(Level.Game).setPlayerTeamDamagePercentage(1.0);
    }
    
    // note: if a vote succeeds, its probably the correct thing to do to clear all counts and
    // all votes stored in player replication infos? -- otherwise the data will stick around
}

//================================================================================================
//                                    Tournament Voting
//================================================================================================

function SubmitTournamentVote(bool vote, Actor Voter)
{
    local int VoterID;

	if(bLevelSwitchPending || !bTournamentVote)
		return;

    log("SubmitTournamentVote: "$vote$"["$voter$"]", 'voting');

	VoterID = GetMVRIIndex(PlayerController(Voter));

    // check voter id
    
    if (VoterID<0)
        return;

    // spectators cannot vote
    
	if (PlayerController(Voter).PlayerReplicationInfo.bOnlySpectator)
	{
		PlayerController(Voter).ClientMessage(lmsgSpectatorsCantVote);
		return;
	}

    // ignore duplicate vote

	if (MVRI[VoterID].TournamentVote==int(vote))
		return;

    // undo previous vote if exists
    
    if (MVRI[VoterID].TournamentVote!=-1)
    {
        if (MVRI[VoterID].TournamentVote==0)
            UpdateTournamentVoteCount(0,-1);     // undo no vote
        else if (MVRI[VoterID].TournamentVote==1)
            UpdateTournamentVoteCount(-1,0);     // undo yes vote
    }
    
    // update vote count
    
    if (vote==true)
    {
	    //Level.Game.Broadcast(self, PlayerController(Voter).PlayerReplicationInfo.PlayerName$" voted for tournament mode");

        UpdateTournamentVoteCount(1,0);     // yes vote
    }
    else
    {
	    //Level.Game.Broadcast(self, PlayerController(Voter).PlayerReplicationInfo.PlayerName$" voted against tournament mode");

        UpdateTournamentVoteCount(0,1);     // no vote
    }

    // set the vote in the replication info
    
    MVRI[VoterID].TournamentVote = int(vote);

    // tally the votes!
	
	TallyTournamentVotes();
}

function UpdateTournamentVoteCount(int yesVoteDelta, int noVoteDelta)
{
    local int i;

    // update vote counts

    TournamentVoteCount.yesVotes += yesVoteDelta;
    TournamentVoteCount.noVotes += noVoteDelta;

    // todo: validation of vote counts ?
    
	// send update to all players
	
	for (i=0; i<MVRI.Length; i++)
	{
		if (MVRI[i]!=none && MVRI[i].PlayerOwner!=none)
			MVRI[i].ReceiveTournamentVoteCount(TournamentVoteCount, False);
	}
}

function TallyTournamentVotes()
{
	// if more than TournamentPercent of the players voted for team damage then enable it
	
	if (((float(TournamentVoteCount.yesVotes)/float(Level.Game.NumPlayers))*100 >= TournamentPercent))
	{
	    Level.Game.Broadcast(self, lmsgTournamentModeEnabled);

		MultiplayerGameInfo(Level.Game).enableTournamentMode();
	}
    else if (((float(TournamentVoteCount.noVotes)/float(Level.Game.NumPlayers))*100 >= TournamentPercent))
    {
	    Level.Game.Broadcast(self, lmsgTournamentModeDisabled);

		MultiplayerGameInfo(Level.Game).disableTournamentMode();
    }
    
    // note: if a vote succeeds, its probably the correct thing to do to clear all counts and
    // all votes stored in player replication infos? -- otherwise the data will stick around
}

//================================================================================================
//                                    MatchSetup
//================================================================================================
function bool MatchSetupLogin(string UserID, string Password, Actor Requestor, out int SecLevel)
{
	local TribesAdminUser AdminUser;

	if( bMatchSetup && PlayerController(Requestor) != none )
	{
		if( UserID ~= "Admin" && PlayerController(Requestor).PlayerReplicationInfo.bAdmin )
		{
			SecLevel = 255;
			return True; // this user is already logged in as an administrator
		}

		if( Level.Game.AccessControl.AdminLogin( PlayerController(Requestor), UserID, Password) )
		{
			// Xm = MatchSetup Priv
			if( Level.Game.AccessControl.CanPerform(PlayerController(Requestor), "Xm") )
			{
				Log(UserID $ " has logged in to MatchSetup.");
				AdminUser = Level.Game.AccessControl.GetUser(UserID);
				if( AdminUser != none )
					SecLevel = AdminUser.MaxSecLevel();
				else
					SecLevel = 0;
				// hack for default AccessControl setup
				if( SecLevel == 0 && PlayerController(Requestor).PlayerReplicationInfo.bAdmin )
					SecLevel = 255;

				Log("SecLevel = " $ SecLevel);
				return True;
			}
			else
			{
				log(UserID $ " doesnt have MatchSetup permissions.");
				PlayerController(Requestor).ClientMessage(lmsgMatchSetupPermission);
				Return False;
			}
		}
		else
		{
			Log(UserID $ " password was invalid.");
			PlayerController(Requestor).ClientMessage(lmsgInvalidPassword);
			return False;
		}
	}
}
//------------------------------------------------------------------------------------------------
function MatchSetupLogout(Actor Requestor)
{
	if( bMatchSetup && PlayerController(Requestor) != none )
		Level.Game.AccessControl.AdminLogout( PlayerController(Requestor) );
}
//================================================================================================
//                                    Configuration
//================================================================================================
static function FillPlayInfo(PlayInfo PlayInfo)
{
	// This sends configuration settings to ether the WebAdmin, Server Rules GUI,
	// or MatchSetup via the PlayInfo class.
	Super.FillPlayInfo(PlayInfo);

    // VOTING TODO - fill play info

    /*
	PlayInfo.AddSetting(default.MapVoteGroup,"bMapVote",default.PropsDisplayText[0],0,1,"Check",,,True,False);
	PlayInfo.AddSetting(default.MapVoteGroup,"bAutoOpen",default.PropsDisplayText[1],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"ScoreBoardDelay",default.PropsDisplayText[2],0,1,"Text","3;0:60",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bScoreMode",default.PropsDisplayText[3],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bAccumulationMode",default.PropsDisplayText[4],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bEliminationMode",default.PropsDisplayText[5],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"MinMapCount",default.PropsDisplayText[6],0,1,"Text","4;1:9999",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"RepeatLimit",default.PropsDisplayText[7],0,1,"Text","4;0:9999",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"VoteTimeLimit",default.PropsDisplayText[8],0,1,"Text","3;10:300",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"MidGameVotePercent",default.PropsDisplayText[9],0,1,"Text","3;1:100",,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"bDefaultToCurrentGameType",default.PropsDisplayText[10],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"GameConfig",default.PropsDisplayText[15],0, 1,"Custom",";;"$default.GameConfigPage,,True,True);
	PlayInfo.AddSetting(default.MapVoteGroup,"MapListLoaderType",default.PropsDisplayText[16],0, 1,"Custom",";;"$default.MapListConfigPage,,True,True);

	PlayInfo.AddSetting(default.KickVoteGroup,"bKickVote",default.PropsDisplayText[11],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.KickVoteGroup,"KickPercent",default.PropsDisplayText[12],0,1,"Text","3;1:100",,True,True);
	PlayInfo.AddSetting(default.KickVoteGroup,"bAnonymousKicking",default.PropsDisplayText[13],0,1,"Check",,,True,True);

	PlayInfo.AddSetting(default.AdminVoteGroup,"bAdminVote",default.PropsDisplayText[14],0,1,"Check",,,True,True);
	PlayInfo.AddSetting(default.AdminVoteGroup,"AdminPercent",default.PropsDisplayText[15],0,1,"Text","3;1:100",,True,True);
	PlayInfo.AddSetting(default.AdminVoteGroup,"bAnonymousAdmining",default.PropsDisplayText[16],0,1,"Check",,,True,True);

	PlayInfo.AddSetting(default.ServerGroup,"bMatchSetup",default.PropsDisplayText[17],0,1,"Check",,,True,True);
	*/
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
    // VOTING TODO - accept play info property (what does this do?)

    /*
	if ( class'LevelInfo'.static.IsDemoBuild() )
		return false;

	switch ( PropertyName )
	{
	case "bMapVote":
	case "bAutoOpen":
	case "ScoreBoardDelay":
	case "bScoreMode":
	case "bAccumulationMode":
	case "bEliminationMode":
	case "MinMapCount":
	case "RepeatLimit":
	case "VoteTimeLimit":
	case "MidGameVotePercent":
	case "bDefaultToCurrentGameType":
	case "GameConfig":
	case "MapListLoaderType":
		 return MAPVOTEALLOWED;

	case "bKickVote":
	case "KickPercent":
	case "bAnonymousKicking":
		return KICKVOTEALLOWED;

	case "bAdminVote":
	case "AdminPercent":
	case "bAnonymousAdmining":
		return AdminVOTEALLOWED;

	case "bMatchSetup":
		return MATCHSETUPALLOWED;
	}
	*/

	return Super.AcceptPlayInfoProperty(PropertyName);
}

//------------------------------------------------------------------------------------------------
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bMapVote":					return default.PropDescription[0];
		case "bAutoOpen":					return default.PropDescription[1];
		case "ScoreBoardDelay":				return default.PropDescription[2];
		case "bScoreMode":					return default.PropDescription[3];
		case "bAccumulationMode":			return default.PropDescription[4];
		case "bEliminationMode":			return default.PropDescription[5];
		case "MinMapCount":					return default.PropDescription[6];
		case "RepeatLimit":					return default.PropDescription[7];
		case "VoteTimeLimit":				return default.PropDescription[8];
		case "MidGameVotePercent":			return default.PropDescription[9];
		case "bDefaultToCurrentGameType":	return default.PropDescription[10];
		case "bKickVote":					return default.PropDescription[11];
		case "KickPercent":					return default.PropDescription[12];
		case "bAnonymousKicking":			return default.PropDescription[13];
		case "bAdminVote":					return default.PropDescription[14];
		case "AdminPercent":				return default.PropDescription[15];
		case "bAnonymousAdmining":			return default.PropDescription[16];
		case "bTeamDamageVote":				return default.PropDescription[17];
		case "TeamDamagePercent":			return default.PropDescription[18];
		case "bTournamentVote":				return default.PropDescription[19];
		case "TournamentPercent":			return default.PropDescription[20];
		case "bMatchSetup":			        return default.PropDescription[21];
		case "GameConfig":                  return default.PropDescription[22];
		case "MapListLoaderType":           return default.PropDescription[23];
	}
	return "";
}
//------------------------------------------------------------------------------------------------
function string GetConfigArrayData(string ConfigArrayName, int RowIndex, int ColumnIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex > GameConfig.Length-1 || ColumnIndex > 5 )
				return "";

			switch( ColumnIndex )
			{
	        	case 0:
					return "GAMETYPE;50;" $ GameConfig[RowIndex].GameClass;
				case 1:
					return "TEXT;50;" $ GameConfig[RowIndex].Prefix;
				case 2:
					return "TEXT;20;" $ GameConfig[RowIndex].Acronym;
				case 3:
					return "TEXT;50;" $ GameConfig[RowIndex].GameName;
				case 4:
					return "MUTATORS;255;" $ GameConfig[RowIndex].Mutators;
				case 5:
					return "TEXT;255;" $ GameConfig[RowIndex].Options;
				default:
					return "";
			}
			break;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function string GetConfigArrayColumnTitle(string ConfigArrayName, int ColumnIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( ColumnIndex > 5 || ColumnIndex < 0 )
				return "";
   			return lmsgGameConfigColumnTitle[ColumnIndex];

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function DeleteConfigArrayItem(string ConfigArrayName, int RowIndex)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex < 0 || RowIndex > GameConfig.Length-1 )
				return;
			GameConfig.Remove(RowIndex,1);
   			return;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function int AddConfigArrayItem(string ConfigArrayName)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			GameConfig.Insert(GameConfig.Length,1);
			GameConfig[GameConfig.Length-1].GameClass = "XGame.xDeathMatch";
			GameConfig[GameConfig.Length-1].Prefix = "";
			GameConfig[GameConfig.Length-1].Acronym = "";
			GameConfig[GameConfig.Length-1].GameName = "new";
			GameConfig[GameConfig.Length-1].Mutators = "";
			GameConfig[GameConfig.Length-1].Options = "";
   			return GameConfig.Length-1;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function UpdateConfigArrayItem(string ConfigArrayName, int RowIndex, int ColumnIndex, string NewValue)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
			if( RowIndex < 0 || RowIndex > GameConfig.Length-1 || ColumnIndex > 5 )
				return;

			switch( ColumnIndex )
			{
	        	case 0:
					GameConfig[RowIndex].GameClass = NewValue;
					break;
				case 1:
					GameConfig[RowIndex].Prefix = NewValue;
					break;
				case 2:
					GameConfig[RowIndex].Acronym = NewValue;
					break;
				case 3:
					GameConfig[RowIndex].GameName = NewValue;
					break;
				case 4:
					GameConfig[RowIndex].Mutators = NewValue;
					break;
				case 5:
					GameConfig[RowIndex].Options = NewValue;
					break;
			}
   			return;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function int GetConfigArrayItemCount(string ConfigArrayName)
{
	switch( Caps(ConfigArrayName) )
	{
		case "GAMECONFIG":
   			return GameConfig.Length;

		case "MAPLIST":
			// TODO: *
			break;
	}
}
//------------------------------------------------------------------------------------------------
function ReloadAll( optional bool bParam )
{
	// TODO: ReloadAll
	ReloadMatchConfig(bParam,bParam);
}
//------------------------------------------------------------------------------------------------
function PropagateValue( VotingReplicationInfo Sender, string Type, string SettingName, string NewValue )
{
	local int i;

	// BroadCast change to all other MatchSetup users.
	for( i=0; i<MVRI.Length; i++)
	{
		if(MVRI[i].bMatchSetupPermitted && MVRI[i] != Sender)
		{
			MVRI[i].SendClientResponse( Type, MVRI[i].UpdateID, SettingName $ Chr(27) $ NewValue );
			MVRI[i].bMatchSetupAccepted = false;
		}
	}
}
//------------------------------------------------------------------------------------------------
function ReloadMatchConfig( bool bRefreshMaps, bool bRefreshMuts, optional PlayerController Caller )
{
	local int i;

	for ( i = 0; i < MVRI.Length; i++ )
	{
		// TODO - optimize to determine which settings need to be sent and only send those
		if ( MVRI[i] != None && MVRI[i].bMatchSetupPermitted )
		{
			// If we want a full refresh, have the client request the full refresh, so
			// that the client's current lists will be cleared first
			if ( bRefreshMaps && bRefreshMuts )
				MVRI[i].SendClientResponse(MVRI[i].LoginID,"1");
			else MVRI[i].RequestMatchSettings(bRefreshMaps, bRefreshMuts);
		}
	}
}
//------------------------------------------------------------------------------------------------
/*
function MatchConfig CreateMatchProfile()
{
    // VOTING TODO - create match profile
    
    return none;

	//return new(None, "MatchConfig" $ Chr(27) $ Level.Game.Class $ Chr(27) $ ServerNumber) class'MatchConfig';
}
*/
//------------------------------------------------------------------------------------------------
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int i;
	i = ServerState.ServerInfo.Length;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "MapVoting";
	ServerState.ServerInfo[i++].Value = Locs(bMapVote);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "KickVoting";
	ServerState.ServerInfo[i++].Value = Locs(bKickVote);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "AdminVoting";
	ServerState.ServerInfo[i++].Value = Locs(bAdminVote);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "TeamDamageVoting";
	ServerState.ServerInfo[i++].Value = Locs(bTeamDamageVote);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "TournamentVoting";
	ServerState.ServerInfo[i++].Value = Locs(bTournamentVote);
}
//------------------------------------------------------------------------------------------------
defaultproperties
{
	VoteTimeLimit=60
	ScoreBoardDelay=5
	bAutoOpen=False
	MinMapCount=2
	MapVoteHistoryType="TribesVoting.MapVoteHistory_INI"
	RepeatLimit=4
	bScoreMode=False
	bAccumulationMode=False
	bEliminationMode=False
	DefaultGameConfig=0
	bDefaultToCurrentGameType=True

	bMapVote=True
	bKickVote=True
	bMatchSetup=True
    bAdminVote=True
    bTeamDamageVote=True
    bTournamentVote=true
	
	bAnonymousKicking=True
	bAnonymousAdmining=True

	MidGameVotePercent=51
	KickPercent=51
	AdminPercent=51
    TeamDamagePercent=51
    TournamentPercent=51

	ServerNumber=1

	PropsDisplayText(0)="Enable Map Voting"
    PropsDisplayText(1)="Auto Open GUI"
    PropsDisplayText(2)="ScoreBoard Delay"
    PropsDisplayText(3)="Score Mode"
    PropsDisplayText(4)="Accumulation Mode"
    PropsDisplayText(5)="Elimination Mode"
    PropsDisplayText(6)="Minimum Maps"
    PropsDisplayText(7)="Repeat Limit"
    PropsDisplayText(8)="Voting Time Limit"
    PropsDisplayText(9)="Mid-Game Vote Percent"
    PropsDisplayText(10)="Default Current GameType"
    PropsDisplayText(11)="Enable Kick Voting"
    PropsDisplayText(12)="Kick Vote Percent"
    PropsDisplayText(13)="Anonymous Kick Voting"
    PropsDisplayText(14)="Enable Admin Voting"
    PropsDisplayText(15)="Admin Vote Percent"
    PropsDisplayText(16)="Anonymous Admin Voting"
    PropsDisplayText(17)="Enable Team Damage Voting"
    PropsDisplayText(18)="Team Damage Vote Percent"
    PropsDisplayText(19)="Enable Tournament Voting"
    PropsDisplayText(20)="Tournament Vote Percent"
    PropsDisplayText(21)="Allow Match Setup"
    PropsDisplayText(22)="Game Configuration"
    PropsDisplayText(23)="Map List Configuration"

	PropDescription(0)="If enabled players can vote for maps."
    PropDescription(1)="If enabled the Map voting interface will automatically open at the end of each game."
    PropDescription(2)="Sets the number of seconds to delay after the end of each game before opening the voting interface."
    PropDescription(3)="If enabled, each player gets his or her score worth of votes."
    PropDescription(4)="If enabled, each player will accumulate votes each game until they win."
    PropDescription(5)="If enabled, available maps are disabled as they are played until there are X maps left."
    PropDescription(6)="The number of enabled maps that remain in the map list (in Elimination mode) before the map list is reset."
    PropDescription(7)="Number of previously played maps that should not be votable."
    PropDescription(8)="Limits how much time (in seconds) to allow for voting."
    PropDescription(9)="Percentage of players that must vote to trigger a Mid-Game vote."
    PropDescription(10)="If enabled, and there are no players on the server then the server will stay on the current game type."
    PropDescription(11)="If enable players can vote to kick other players."
    PropDescription(12)="The percentage of players that must vote against an individual player to have them kicked from the server."
    PropDescription(13)="If enabled players can place Kick votes without anyone knowing who placed the vote."
    PropDescription(14)="If enable players can vote to Admin other players."
    PropDescription(15)="The percentage of players that must vote against an individual player to have them Admined from the server."
    PropDescription(16)="If enabled players can place Admin votes without anyone knowing who placed the vote."
    PropDescription(17)="If enable players can vote for team damage."
    PropDescription(18)="The percentage of players that must vote for/against team damage to have it enabled or disabled."
    PropDescription(19)="If enable players can vote for tournament mode."
    PropDescription(20)="The percentage of players that must vote for/against tournament mode to have it enabled or disabled."
	PropDescription(21)="Enables match setup on the server - valid admin username & password is required in order to use this feature"
    PropDescription(22)="Opens the map voting game configuration screen"
    PropDescription(23)="Opens the map voting list configuration screen"

	lmsgAdminMapChange="Admin has forced map switch to %mapname%"
	lmsgMapVotedForWithCount="%playername% has placed %votecount% votes for %mapname%"
	lmsgMapVotedFor="%playername% has voted for %mapname%"
	lmsgMapWon="%mapname% has won !"
	lmsgMidGameVote="Mid-Game Map Voting has been initiated !!!!"
	lmsgSpectatorsCantVote="Sorry, Spectators can not vote."
	lmsgInvalidPassword="The password entered is invalid !"
	lmsgMatchSetupPermission="Sorry, you do not have permission to use Match Setup !"
	lmsgKickVote="%playername1% placed a kick vote against %playername2%"
	lmsgAnonymousKickVote="A kick vote has been placed against %playername%"
	lmsgKickVoteAdmin="%playername% attempted to submit a kick vote against the server administrator !"
	lmsgAdminVote="%playername1% placed an admin vote for %playername2%"
	lmsgAnonymousAdminVote="An admin vote has been placed for %playername%"
	lmsgAdminVoteAdmin="%playername% submitted an admin vote for an existing administrator"
	lmsgTeamDamageVote="%playername% placed a vote %type% team damage"
	lmsgTournamentVote="%playername% placed a vote %type% tournament mode"
	lmsgTournamentModeEnabled="Tournament mode has been enabled by vote"
	lmsgTournamentModeDisabled="Tournament mode has been disabled by vote"
	lmsgTeamDamageEnabled="Team damage has been enabled by vote"
	lmsgTeamDamageDisabled="Team damage has been disabled by vote"
	lmsgGameConfigColumnTitle[0]="GameType"
	lmsgGameConfigColumnTitle[1]="MapPrefixes"
	lmsgGameConfigColumnTitle[2]="Abbreviation"
	lmsgGameConfigColumnTitle[3]="Name"
	lmsgGameConfigColumnTitle[4]="Mutators"
	lmsgGameConfigColumnTitle[5]="Options"
}
