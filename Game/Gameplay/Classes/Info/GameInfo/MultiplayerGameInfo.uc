class MultiplayerGameInfo extends GameInfo
	config;

var() editinline class<RoundInfo> roundInfoClass		"The rounds to use";
var() string gameSummaryPage							"The name of the game summary page to use";
var() string roundSummaryPage							"The name of the round summary page to use";
var() string guiPackage									"The name of the package where the specified summary pages can be found";
var() config int scoreLimit								"The match will end after this number of points are scored";
var() config int minimumNumberOfPlayers					"The minimum number of players needed on the server in order to play";
var() globalconfig float postGameDelay					"Wait for this number of seconds after the map ends before loading the next map";
var() globalconfig bool bTournamentMode					"Tournament mode requires admins to change each player's team";
var() globalconfig float tournamentCountdown			"The countdown duration for starting a match in tournament mode";
var() config bool bUseMapScoreLimits					"If true, if a map specifies a score limit for this game type, it will be used";
var() int numTeams										"Number of teams.  Only 1 and 2 are supported.";
var() bool bDontAllowEnemySpectating					"If true, you can spectate members of the other team";
var() class<Loadout> defaultLoadoutOverride				"If provided, all multiplayer starts in this mode will use this loadout by default";
var() localized array<string> gameHints					"Hints that are displayed when each map loads";
var() bool bRepairBaseDevicesBetweenRounds					"If true, all base devices in the game will be fully repaired in-between rounds";
var(LocalMessage) class<TribesLocalMessage> GameAnnouncerMessageClass "The class to use for game announcement messages";

var RoundInfo	roundInfo;
var bool		bRoundStarted;
var Name		playerRestartState;		// if not '', the state that restarting players are set to
var int			numPlayersLoggedIn;
var bool		bPendingMatchEnd;
var bool		bForceStart;
var float		lastTournamentUpdateTime;
var bool		bOnGameEndCalled;
var bool		bServerTravelOverride;
var float		lastTimeLeft;
var float		clientTravelAtTime;
var string		serverTravelURL;
var bool		bWaitingForPlayers;

var String		GameSpyGameMode;

// PreBeginPlay
function PreBeginPlay()
{
	local int i;
	Super.PreBeginPlay();

	// Search for a map-specific RoundInfo override
	ForEach DynamicActors(class'RoundInfo', roundInfo)
	{
		// This sets roundInfo to first found instance
		break;
	}

	// If that doesn't exist, spawn a roundInfo according to this gameinfo's roundInfoClass
	if (roundInfo == None && roundInfoClass != None)
	{
		roundInfo = spawn(roundInfoClass);
	}

	// Failing that, default to a standard roundInfo
	if (roundInfo == None)
	{
		LOG("No RoundInfo found, spawning one");
		roundInfo = spawn(class'RoundInfo');

		roundInfo.rounds[0] = new(roundInfo) class'RoundData';
		roundInfo.rounds[0].duration = 15;
		roundInfo.rounds[0].countdownDuration = 5;
	}
	else if (TimeLimit > 0)
	{
		// TimeLimit is an override for the duration of all rounds
		for (i=0; i<roundInfo.rounds.Length; i++)
		{
			roundInfo.rounds[i].duration = TimeLimit;
		}
	}

	// Make sure there's at least one PlayerStart placed for observers
	checkForObserverPlayerStart();

	// mp debugging
	if (class'GameEngine'.default.EnableDevTools)
		CheatClass = class'TribesCheatManager';

	//LOG("Using RoundInfo "$roundInfo.Label);
}

function PostBeginPlay()
{
	local TeamInfo t;
	local int i;
	local MultiplayerStart mpstart;

	Super.PostBeginPlay();

	// Assign team indices
	ForEach AllActors(class'Teaminfo', t)
	{
		t.TeamIndex = i++;
	}

	// Loadout override
	if (defaultLoadoutOverride != None)
	{
		ForEach AllActors(class'MultiplayerStart', mpstart)
		{
			mpstart.loadoutOverride = defaultLoadoutOverride;
		}
	}

	// Allow map to override score limit for this game type
	if (bUseMapScoreLimits)
	{
		for (i=0; i<Level.SupportedModes.Length; i++)
		{
			if (Level.SupportedModes[i] == Class && i < Level.SupportedModesScoreLimits.Length && Level.SupportedModesScoreLimits[i] > 0)
			{
				scoreLimit = Level.SupportedModesScoreLimits[i];
			}
		}
	}
}

event bool SaveAllowed()
{
	return false;
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();

	GameReplicationInfo.playerTeamDamagePercentage = playerTeamDamagePercentage;
	GameReplicationInfo.bTournamentMode = bTournamentMode;
	TribesGameReplicationinfo(GameReplicationInfo).numTeams = numTeams;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PlayerStart   ///////////////////////////////////////////////////////////////////////////////////////////////

function checkForObserverPlayerStart()
{
	local PlayerStart observerStart;

	if (!observerStartExists())
	{
		observerStart = spawn(class'PlayerStart');
		observerStart.bObserverStart = true;
	}
}

function bool observerStartExists()
{
	local PlayerStart N;

	foreach AllActors( class 'PlayerStart', N )
	{
		if (N.bObserverStart)
			return true;
	}

	return false;
}

function float tribesRatePlayerStart(PlayerStart P, TeamInfo Team, Controller Player)
{
	local PlayerCharacterController c;

	if (Player != None)
		c = PlayerCharacterController(Player);

	// Handle observer start point
	if (P.bObserverStart)
	{
		if (Player == None || c == None)
		{
			//Log("MJOBS:  Positive observer start rating for "$P$", player = "$Player$", c = "$c);
			return Rand(65535);
		}

		// If Player is valid and not observing, don't spawn here
		return 0;
	}

	if (Player == None || c == None)
		return 0;

	if (MultiplayerStart(P) == None || P.team != Team)
		return 0;

	// spawn only within the desired base, if specified
	if (c.spawnBase != None)
	{
		if (P.baseInfo != None && P.baseInfo == c.spawnBase)
			return Rand(65535);
		else
			return 0;
	}

	return Rand(65535);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Login, logout and player initialization  ////////////////////////////////////////////////////////////////////////////

function TeamInfo initialTeam()
{
	local TeamInfo t;
	local TeamInfo smallestTeam;
	local TribesReplicationInfo r;
	local int teamNum;
	local int smallestTeamNum;

	smallestTeamNum = 99999;

	// assign the player to the team with the least players/score, but only if the
	// team has playerStarts associated with it
	ForEach AllActors(class'TeamInfo', t)
	{
		//Log("Found team "$t$" in initialTeam() with numPlayerStarts = "$t.numPlayerStarts);
		if (t.numPlayerStarts == 0)
			continue;

		teamNum = 0;

		ForEach DynamicActors(class'TribesReplicationInfo', r)
		{
			if (r.team == t)
				teamNum++;
		}

		if (teamNum < smallestTeamNum 
				|| (teamNum == smallestTeamNum && smallestTeam != None && t.score < smallestTeam.score))
		{
			smallestTeamNum = teamNum;
			smallestTeam = t;
		}
	}

	return smallestTeam;
}

function bool enoughPlayersToStart()
{
	return numPlayersLoggedIn >= minimumNumberOfPlayers;
}


function PostLogin(PlayerController NewPlayer)
{
	local TeamInfo t;
	local PlayerCharacterController PC;
	local TribesReplicationInfo TRI;

	Super.PostLogin(NewPlayer);

	PC = PlayerCharacterController(NewPlayer);
	if (PC == None)
	{
		Log("Login error:  joining controller was None");
		return;
	}
	numPlayersLoggedIn++;

	NewPlayer.PlayerReplicationInfo.bWaitingPlayer = true;

	// Set the player's round info
	PC.roundInfo = roundinfo;

	TRI = TribesReplicationInfo(PC.PlayerReplicationInfo);

	// If game is in tournament mode, all connecting players are forced to be spectators and must
	// be team'd by an admin
	if (bTournamentMode)
	{
		if (TribesGameReplicationInfo(GameReplicationInfo).bAwaitingTournamentStart)
		{
			//Log("Forcing "$NewPlayer$" into awaitingGameStart due to tourney", 'postlogin');
			NewPlayer.GotoState('AwaitingGameStart');
			NewPlayer.ClientGotoState('AwaitingGameStart');
		}
		else
		{
			//Log("Forcing "$NewPlayer$" into spectator mode due to tourney", 'postlogin');
			NewPlayer.GotoState('TribesSpectating');
			NewPlayer.ClientGotoState('TribesSpectating');
		}
		return;
	}

	// Assign a team
	if(TRI.team == None)
	{
		t = initialTeam();
		TRI.setTeam(t);
		TRI.bTeamChanged = true;
	}
	//Log("Team of "$NewPlayer$" set to "$TRI.team, 'postlogin');

	if (bWaitingForPlayers)
	{
		//Log("Forcing "$NewPlayer$" into awaitingGameStart mode due to not enough players", 'postlogin');
		NewPlayer.GotoState('AwaitingGameStart');
		NewPlayer.ClientGotoState('AwaitingGameStart');
		return;
	}

	// If a round with maxLives is in progress the player must wait until the next round
	if (GetStateName() == 'GamePhase' && roundInfo.currentRound().maxLives > 0)
	{
		//Log("Forcing "$NewPlayer$" to wait for next round", 'postlogin');
		PC.bWaitingForRoundEnd = true;
		
		// New player has a team but make sure he's not allowed to spawn yet
		PC.livesLeft = 0;

		NewPlayer.GotoState('AwaitingNextRound');
		NewPlayer.ClientGotoState('AwaitingNextRound');
		return;
	}

	// Reset livesLeft.  This is done between each round, but it needs to be done here as well to handle
	// players who join during a round countdown
	if (roundInfo.currentRound() != None && roundInfo.currentRound().maxLives > 0)
	{
		PC.livesLeft = roundInfo.currentRound().maxLives;
	}
	else
		// Otherwise ensure respawns are disabled for this player
		PC.livesLeft = -1;

	//Log("Sending "$NewPlayer$" to PlayerRespawn on PostLogin");

	// In all other cases, allow the player to spawn
	NewPlayer.GotoState('PlayerRespawn');
	NewPlayer.ClientGotoState('PlayerRespawn');
}

function Logout( Controller Exiting )
{
	numPlayersLoggedIn--;
	BaseMutator.NotifyLogout(Exiting);
	Super.Logout(Exiting);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Restarting and respawning  //////////////////////////////////////////////////////////////////////////////////

function RestartPlayer( Controller aPlayer )	
{
	local Mutator mutator;
	local class<Loadout> mutatedLoadoutClass;
	local class<CombatRole> mutatedCombatRoleClass;
	local PlayerCharacterController pcc;
	local Character c;
	local bool spectator;
	local MultiplayerStart mpstart;
	local Vehicle vehicle;
	local VehicleMountedTurret vehicleTurret;
	local Turret turret;

	//log("Restarting player "$aPlayer);

    // spectator controllers have a none pawn class (utserveradminspectator etc.)
    if (aPlayer.PawnClass==None)
        spectator = true;

	// Properly kill the pawn before the superclass has a chance to destroy it - need to handle vehicle and turret case
	// This forces the player to drop all equipment
	if ( (aPlayer.Pawn != None) && (Level.TimeSeconds - aPlayer.Pawn.LastStartTime > 1) )
	{
		vehicle = Vehicle(aPlayer.Pawn);
		vehicleTurret = VehicleMountedTurret(aPlayer.Pawn);
		turret = Turret(aPlayer.Pawn);
		if (vehicle != None)
		{
			// vehicle case
			vehicle.positions[vehicle.driverIndex].occupant.KilledBy(aPlayer.Pawn);

			// ... kick out dead body immediately
			vehicle.driverLeave(true, vehicle.driverIndex);
		}
		else if (vehicleTurret != None)
		{
			// vehicle mounted turret case
			vehicleTurret.ownerVehicle.positions[vehicleTurret.positionIndex].occupant.KilledBy(aPlayer.Pawn);

			// ... kick out dead body immediately
			vehicleTurret.ownerVehicle.driverLeave(true, vehicleTurret.positionIndex);
		}
		else if (turret != None)
		{
			// turret case
			turret.driver.KilledBy(aPlayer.Pawn);

			// ... kick out dead body immediately
			turret.driverLeave(true);
		}
		else
			aPlayer.Pawn.KilledBy(aPlayer.Pawn);
	}

	Super.RestartPlayer(aPlayer);

    // early exit for spectators (originally dont have a pawn)
    if (spectator)
    {
        log("restarted spectator controller");
        return;
    }

    // post respawn initialization for pawns
	mutator = Mutator(BaseMutator);
	pcc = PlayerCharacterController(aPlayer);
	c = Character(aPlayer.Pawn);

	// force MP gamers' character to get the PRI bIsFemale flag
	c.bIsFemale = pcc.PlayerReplicationInfo.bIsFemale;

	if (aPlayer.StartSpot == None)
	{
		log("Can't spawn multiplayer character: character has no start point. Did you set your start points' team fields?"); 
		return;
	}

	if (aPlayer.Pawn == None)
	{
		log("Can't spawn multiplayer character: character was not created"); 
		return;
	}
	
	if (TribesReplicationInfo(aPlayer.PlayerReplicationInfo).team == None)
	{
		log("Can't spawn multiplayer character: character has no team"); 
		return;
	}

	mpstart = MultiplayerStart(aPlayer.StartSpot);

	if (mpstart != None && !mpstart.canRespawn())
	{
		log("Can't spawn multiplayer character:  disallowed by "$mpstart);
		return;
	}

	if (mpstart.combatRole == None)
	{
		log("NOTE: MultiplayerStart "$aPlayer.StartSpot.name$" has no combat role defined");
	}
	else
	{
		if (mutator != None)
		{
			mutatedLoadoutClass = class<Loadout>
				(DynamicLoadObject(mutator.MutateSpawnLoadoutClass(c), class'Class', true));
			mutatedCombatRoleClass = class<CombatRole>
				(DynamicLoadObject(mutator.MutateSpawnCombatRoleClass(c), class'Class', true));
		}

		if (mutatedLoadoutClass == None)
		{
			// equip player with override loadout from spawn point, if defined
			if (mpstart.loadoutOverride != None)
			{
				pcc.newLoadout(new mpstart.loadoutOverride);
			}
			else if(!pcc.HasCurrentLoadout())
			{
				// else equip player with default loadout from combat role
				pcc.newLoadout(new mpstart.combatRole.default.defaultLoadout);
			}
		}
		else
		{
			// equip with mutated loadout class
			pcc.newLoadout(new mutatedLoadoutClass);
		}

		if (mutatedCombatRoleClass == None)
		{
			// take initial combat role from start spot
			c.combatRole = mpstart.combatRole;
		}
		else
		{
			// equip with mutated combat role class
			c.combatRole = mutatedCombatRoleClass;
		}

		// equip player with armor from combat role
		mpstart.combatRole.default.armorClass.static.equip(Character(aPlayer.Pawn));

		// Set the mesh of the player
		SetPlayerMesh(pcc);

		// update the new character's skin from the client's preference
		if (allowSkinChanges())
			pcc.clientGetSkinPreference(Character(aPlayer.Pawn).Mesh);
	}

	pcc.playerReplicationInfo.bIsSpectator = false;

	pcc.equipCharacter();
	pcc.NextWeapon();

	// If the game is in countdown or waiting to start, the player must wait
	if (IsInState('CountdownPhase') || IsInState('StartGame'))
	{
		// Don't send client to this state since it's not needed
		pcc.GotoState('TribesCountdown');
	}
	// Otherwise, start the player
	else
		startPlayer(pcc);

	// Notify the playerStart so it can notify its baseInfo and spawnArray.
	// Doing this in the parent RestartPlayer() didn't work because carryable containers
	// depend on this callback for giving the player a carryable when he spawns. But the above
	// code messes with your equipment in such a way that prevented you from accessing
	// your carryables.  So this callback has to come after your equipment is given to you.
	mpstart.onPlayerSpawned(aPlayer);

	// invoke mutator
	BaseMutator.ModifyPlayer(aPlayer.Pawn);
}

function SetPlayerMesh( Controller aPlayer )
{
	local Mesh mesh;
	local Jetpack jetpack;
	local class<Jetpack> mutatedJetpack;
	local Mesh armsMesh;
	local Character c;
	local MultiplayerStart mpstart;

	if (Mutator(BaseMutator) != None)
		Mutator(BaseMutator).MutatePlayerMeshes(mesh, mutatedJetpack, armsMesh);

	c = Character(aPlayer.Pawn);
	mpstart = MultiplayerStart(aPlayer.StartSpot);

	// set mesh from TeamInfo
	if (mesh == None)
		mesh = c.team().getMeshForRole(mpstart.combatRole, aPlayer.PlayerReplicationInfo.bIsFemale);
	if (mesh != None)
	{
		aPlayer.Pawn.LinkMesh(mesh);
	}
	else
	{
		log("MultiplayerGameInfo: No mesh defined for combat role "$mpstart.combatRole$
			", team "$c.team()$", bIsFemale "$aPlayer.PlayerReplicationInfo.bIsFemale);
	}

	// set jetpack mesh for TeamInfo
	if (mutatedJetpack == None)
		jetpack = c.team().getJetpackForRole(aPlayer.Pawn, mpstart.combatRole, aPlayer.PlayerReplicationInfo.bIsFemale);
	else
        jetpack = new mutatedJetpack;
	if (jetpack != None)
	{
		c.setJetpack(jetpack);
	}

	if (armsMesh == None)
		armsMesh = c.team().getArmsMeshForRole(mpstart.combatRole);
	if (armsMesh != None)
	{
		c.setArmsMesh(armsMesh);
	}
}

// Set the state of all players who aren't spectating
function setAllActivePlayerStates(Name newState, optional Name stateTag, optional bool bForceSpectators)
{
	local PlayerCharacterController C;

	//Log("Setting state for all players to "$newState);

	ForEach Level.AllControllers(class'PlayerCharacterController', C)
	{
		// Don't set spectator states
		if (!bForceSpectators && C.PlayerReplicationInfo.bIsSpectator)
			continue;

		if (C.IsInState(newState))
		{
			//Log("Player "$C$" is already in state "$newState);
			continue;
		}

		C.GotoState(newState, stateTag);
		C.ClientGotoState(newState, stateTag);
	}
		
}

// Set all players who aren't spectating to their movement state
// Players who haven't yet spawned in the world will not be started by calling this function
function startAllActivePlayers()
{
	local PlayerCharacterController C;

	//Log("Starting all active players");

	ForEach Level.AllControllers(class'PlayerCharacterController', C)
	{
		startPlayer(C);
	}
}

// Set this player to his movement state.
// If the player has not yet spawned in the world, this function will try to spawn
// the player (and then be called again from RestartPlayer())
function startPlayer(PlayerCharacterController C)
{
	// Don't start spectators
	if (C.PlayerReplicationInfo.bIsSpectator)
		return;

	// If the player doesn't have a pawn, try to spawn one
	// MJ TODO:  If the player gets forced out of inventory selection by this restart, they should
	// get whatever equipment they had selected at the time of being forced out
	if (C.Pawn == None)
	{
		RestartPlayer(C);

		// Return because this function will get called again from RestartPlayer()
		return;
	}

	if (C.Pawn != None)
	{
		// Put player in their expected movement state, i.e. let them start playing
		C.GotoState(Rook(C.Pawn).playerControllerState);
		C.ClientGotoState(Rook(C.Pawn).playerControllerState);
		C.Restart();
	}
	else
	{
		// This should never happen
		Log("Not starting active player "$C$" due to no Pawn");
	}
}

function killAllPlayers()
{
	local PlayerCharacterController C;

	//Log("Killing all active players");

	ForEach Level.AllControllers(class'PlayerCharacterController', C)
	{
		if (C.Pawn != None)
			C.Pawn.KilledBy(C.Pawn);
	}
}

// playerPawnDestroyedState
// The state that the playercontroller is put into when the pawn dies
function Name playerPawnDestroyedState()
{
	return 'PlayerRespawn';
}

// The state that the player is put into if he has no lives left
function Name playerPawnNoRespawnState()
{
	return 'AwaitingNextRound';
}

// This function is called BEFORE the player actually respawns; if it returns
// before calling super.tryRespawn() then the player will NOT spawn
function bool tryRespawn(PlayerCharacterController c)
{
	//local TeamInfo t;
	//local TribesReplicationInfo TRI;

	//Log("Global tryRespawn() called on "$c);

	// Don't allow respawn if respawnDelay has not yet elapsed
	if (c.respawnDelay > 0 && ! c.bForcedRespawn)
	{
		//Log(c$" can't respawn due to respawnDelay = "$c.respawnDelay);
		return false;	// can't respawn, waiting for delay
	}

	// Don't allow respawn if the player has run out of lives
	if (c.livesLeft == 0 && roundInfo.currentRound().maxLives != -1)
	{
		//Log(c$" can't respawn due to respawnsLeft");
		return false; // can't respawn, none left
	}

	c.bWaitingForRoundEnd = false;

	// set the team if there is none
	//TRI = TribesReplicationInfo(c.PlayerReplicationInfo);
	//if(TRI.team == None)
	//{
	//	t = initialTeam();
	//	c.dispatchMessage(new class'MessageClientChangedTeam'(c, t, TRI.team)); 
	//	TRI.team = t;
	//}

	// Show an inventory screen if applicable
	if(roundInfo.currentRound().bAllowEquipOnRespawn)
	{
		// Log("Allowing equipment for controller "$c);
		c.GotoState('PlayerEquippingPreRestart');
		c.ClientGotoState('PlayerEquippingPreRestart');

		// Return now so the player doesn't respawn just yet
		return false;
	}

	// Superclass calls RestartPlayer()
	return Super.tryRespawn(c);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State StartGame
// Gives a chance for players to connect, then starts the game if there are
// enough players.  If there aren't enough players, wait for them.
auto state StartGame
{
	function bool allowMapVote()
	{
		return false;
	}

	function bool playersReady()
	{
		local PlayerController PC;
		local PlayerReplicationInfo PRINotReady[3];
		local int numControllersNotReady;
		local bool bOneActivePlayer;

		// Find out which players aren't ready
		ForEach DynamicActors(class'PlayerController', PC)
		{
			if (PC.IsInState('TribesCountdown'))
			{
				bOneActivePlayer = true;
				if (!TribesReplicationInfo(PC.PlayerReplicationInfo).bReady)
				{
					if (numControllersNotReady < 3)
						PRINotReady[numControllersNotReady] = PC.PlayerReplicationInfo;
					numControllersNotReady++;
				}
			}
		}

		// If only a few players are holding things up, broadcast a message with those player names
		if (numControllersNotReady > 0 && numControllersNotReady <= 3 && Level.TimeSeconds - 10 > lastTournamentUpdateTime)
		{
			lastTournamentUpdateTime = Level.TimeSeconds;
			BroadcastLocalized(self, GameMessageClass, 22, PRINotReady[0], PRINotReady[1], PRINotReady[2]);
		}
		return bOneActivePlayer && numControllersNotReady == 0;
	}

	// Always allow team changes
	function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
	{
		return true;
	}

	function EndState()
	{
		// Log("Ending state StartGame");
	}
Begin:
	// Log("Entered state StartGame...");

	// If in tourney mode, wait for all players to be ready or an admin forced start, whichever comes first
	if (bTournamentMode)
	{
		GameSpyStateChange("openwaiting");

		// Wait until all players are ready or an admin forces the match to start
		TribesGameReplicationInfo(GameReplicationInfo).bAwaitingTournamentStart = true;
		while (!playersReady() && !bForceStart)
		{
			Sleep(1);
		}
		TribesGameReplicationInfo(GameReplicationInfo).bAwaitingTournamentStart = false;
		bForceStart = false;

		// If still in tourney mode, set countdown duration of first round to a special tourney value
		if (bTournamentMode)
			roundInfo.rounds[0].countdownDuration = tournamentCountdown;
	}

	GameSpyStateChange("openplaying");

	// Goto the state that decides how to proceed to the next round
	GotoState('InBetweenRounds');
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State InBetweenRound
// This state handles transitions between rounds, including the transition from start of game to the first round
state InBetweenRounds
{

	function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
	{
		// Don't allow switching to spectator mode in this state
		return false;
	}


	function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
	{
		// Don't allow changing teams in this state
		return false;
	}

	function showRoundSummary()
	{
		local PlayerCharacterController c;

		// Cause everyone to see a round summary
		ForEach Level.AllControllers(class'PlayerCharacterController', c)
		{
			// Inform of winning team
			c.clientOpenMenu(guiPackage $ "." $ roundSummaryPage, roundSummaryPage);
		}
	}

	function closeRoundSummary()
	{
		local PlayerCharacterController c;

		// Close everyone's round summaries
		ForEach Level.AllControllers(class'PlayerCharacterController', c)
		{
			c.clientCloseMenu();
		}
	}

Begin:
	//Log("Server entered state InBetweenRounds");

	// Check for a pending match end.  It's possible that this state was entered in the same tick that the
	// match should've ended, thus overriding the GameEnd state.  This works but a better solution would
	// be preferable.
	if (bPendingMatchEnd)
	{
		//Log("Pending match end detected...forcing to GameEnd");
		GotoState('GameEnd');
	}

	// If this isn't the first or last round, show a round summary
	if (roundInfo.currentRoundIdx >= 0 && roundInfo.currentRoundIdx < roundInfo.rounds.Length - 1)
	{
		//setAllActivePlayerStates('AwaitingNextRound');
		// Wait a second before showing the summary
		// This is a hacky way to help ensure the team scoring information gets replicated before
		// the summary page is shown...consider a better solution
		Sleep(1);
		showRoundSummary();
		Sleep(3);
		closeRoundSummary();
	}

	// Go to the next round if applicable; otherwise, end the game
	if (roundInfo.moreRoundsToPlay())
	{
		// Check that the minimum number of players is satisfied; if not, wait until it is
		if (!enoughPlayersToStart())
		{
			bWaitingForPlayers = true;
			// Make sure everyone is waiting
			setAllActivePlayerStates('AwaitingGameStart');

			// Check the first round for minimumNumberOfPlayers and wait until there are enough
			// players to satisfy this restriction
			while (!enoughPlayersToStart())
			{
				//Log("Not enough players.  Waiting...");
				Sleep(5);
			}
			bWaitingForPlayers = false;
			setAllActivePlayerStates('PlayerRespawn', 'Forced', true);
		}


		// If the upcoming round isn't the first round, force all active players to spawn (make sure everyone's dead first)
		if (roundInfo.currentRoundIdx + 1 > 0)
		{
			killAllPlayers();
			setAllActivePlayerStates('PlayerRespawn', 'Forced');
		}

		// Repair everything if applicable
		if (bRepairBaseDevicesBetweenRounds)
			repairAllBaseDevices();

		// Start the next round
		roundInfo.startNextRound();

		// Goto countdown phase if required; otherwise start the game immediately
		if (roundInfo.needsCountdown())
		{
			GotoState('CountdownPhase');
		}
		else
		{
			GotoState('GamePhase');
		}
	}
	else
	{
		GotoState('GameEnd');
	}
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State CountdownPhase
// Players already spawned, but are locked.  Newly connected players will be able to spawn, but will also be locked
state CountdownPhase
{
	function bool allowMapVote()
	{
		return false;
	}
Begin:
	//Log("Entering CountdownPhase");
	dispatchMessage(new class'MessageRoundWarmup');

	// Loop until the countdown is finished
	while (roundInfo.isCountdown())
		Sleep(0.5);

	// Set the countdown to an invalid number to indicate that it's over, then start the game
	roundInfo.replicatedRemainingCountdown = -1;
	GotoState('GamePhase');
}

// State GamePhase
// Actual gameplay
state GamePhase
{
	function onDeath(PlayerCharacterController c)
	{
		if (roundInfo.currentRound() != None)
		{
			// Decrement the dead controller's number of lives, if applicable
			if (roundInfo.currentRound().maxLives > 0)
			{
				c.livesLeft--;
				//Log("maxLives decremented, "$c$" now has "$c.livesLeft$" lives left");
			}

			// For each character death, check to see if the round should end as a result
			// of that death
			if (roundInfo.currentRound().shouldEndAfterDeathOf(Level, c))
			{
				//Log("Forcing selection of next round as a result of "$c$"'s death");
				Level.Game.Broadcast(self, "Round ended due to one team being defeated!");
				GotoState('InBetweenRounds');
			}

			// Assign the dying character a respawnDelay
			c.respawnDelay = roundInfo.currentRound().getRespawnDelay();
		}

		//Log(c$" died, livesLeft = "$c.livesLeft);
	}

	// Called by MPActors whenever team points are scored
	// This is used to prematurely end matches based on total number of points scored
	function postTeamScored(TeamInfo t, int numPoints, optional Actor EndGameFocus)
	{
		local PlayerController player;
		local Controller P;

		if (scoreLimit > 0 && t.score >= scoreLimit)
		{
			//Log("Ending match due to scoreLimit reached");
			//Level.Game.Broadcast(self, "Score limit for this match was reached!");

			// Set a flag to mark match end since game state might change before next tick
			bPendingMatchEnd = true;

			// If FocusRookOnWin provided, force everyone to view it
			if (EndGameFocus != None)
			{
				for ( P=Level.ControllerList; P!=None; P=P.nextController )
				{
					player = PlayerController(P);
					if ( Player != None )
					{
						Player.ClientSetBehindView(true);
						Player.CameraDist = 11;
						Player.ClientSetViewTarget(EndGameFocus);
						Player.SetViewTarget(EndGameFocus);
					}
				}
				GotoState('GameEnd', 'Delayed');
				return;
			}

			GotoState('GameEnd');
			return;
		}

		// Check the current round's scoreLimit
		if (roundInfo.currentRound() != None && roundInfo.currentRound().shouldEndAfterTeamScored(Level, t))
		{
			//Log("Ending round due to scoreLimit reached");
			//Level.Game.Broadcast(self, "Score limit for this round was reached!");
			GotoState('InBetweenRounds');
		}
	}

	function evaluateTimeLeft()
	{
		local float timeLeft;

		// Play 1-minute and 10-second warnings
		timeLeft = roundInfo.currentRound().timeLeft(Level);

		if (lastTimeLeft >= 61 && timeLeft < 61)		
		{
			BroadcastLocalized(self, GameAnnouncerMessageClass, 3);
		}
		else if (lastTimeLeft >= 11 && timeLeft < 11)
		{
			BroadcastLocalized(self, GameAnnouncerMessageClass, 4);
		}
		lastTimeLeft = timeLeft;
	}

Begin:
	//Log("Entering GamePhase");
	if (!roundInfo.isFinished())
	{
		// Start all players who were waiting for this round
		startAllActivePlayers();
		dispatchMessage(new class'MessageRoundStart');
		BroadcastLocalized(self, GameAnnouncerMessageClass, 5);

		// Loop until the round is finished
		while (!roundInfo.isFinished())
		{
			Sleep(0.5);
			roundInfo.currentRound().advanceWaveTime(0.5);
			evaluateTimeLeft();
		}
	}
	//Log("Round "$roundInfo.currentRound()$" ended");

	// If more than 1 round exists, announce round winner here
	// Assume no round ends in a tie
	if (roundInfo.rounds.Length > 1)
	{
		if (roundInfo.currentRound().winningTeam != None)
			Level.Game.BroadcastLocalized(self, GameAnnouncerMessageClass, 1, roundInfo.currentRound().winningTeam);
	}

	// Go to the next round
	dispatchMessage(new class'MessageRoundEnd');
	GotoState('InBetweenRounds');
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State GameEnd
// The game has ended, time to load a new map
state GameEnd
{
	function SendMPActorsToGameOver()
	{
		local MPActor a;

		// Put all MPActors in GameOver state
		ForEach Level.AllActors(class'MPActor', a)
		{
			a.GotoState('GameOver');
		}
	}

	function bool tryRespawn(PlayerCharacterController c)
	{
		// MJ:  Should figure out why this function gets spammed at the end of a map
		return false;
	}

	function showGameSummary()
	{
		local PlayerCharacterController c;

		// Force everyone to see a GUIPage
		ForEach Level.AllControllers(class'PlayerCharacterController', c)
		{
			c.clientOpenMenu(guiPackage $ "." $ gameSummaryPage, gameSummaryPage);
		}
	}

	function closeGameSummary()
	{
		local PlayerCharacterController c;

		// Force everyone to close it
		ForEach Level.AllControllers(class'PlayerCharacterController', c)
		{
			c.clientCloseMenu();
		}
	}

	// Don't allow team changes
	function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
	{
		return false;
	}
Delayed:
	Sleep(6);

Begin:
	GameSpyGameMode = "closedwaiting";

	//Log("Entering GameEnd");
	OnGameEnd();

	SendMPActorsToGameOver();

	// Notify that the game has ended
	EndGame(None, "");

	// Play announcement here
	if (numTeams > 1)
	{
		if (getWinningTeam() != getLosingTeam())
			Level.Game.BroadcastLocalized(self, GameAnnouncerMessageClass, 0, getWinningTeam());
		else
			Level.Game.BroadcastLocalized(self, GameAnnouncerMessageClass, 2);
	}

	Sleep(2);
	showGameSummary();
	Sleep(postGameDelay);
	//closeGameSummary();

	if (!bServerTravelOverride)
	{
		RestartGame();	// base class, loads next map
	}
	else
	{
		Level.ServerTravel(serverTravelURL, false);
	}
}

function OnGameEnd()
{
	bOnGameEndCalled = true;

	// Cleanup winningTeam in roundInfos to satisfy garbage collection
	roundInfo.cleanup();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous

function PostTeamScored(TeamInfo t, int numPoints, optional Actor EndGameFocus)
{
}

function onSpectate(PlayerCharacterController c)
{
	//Log("Sending "$c$" to TribesSpectating");
	if (c.Pawn != None)
		c.Pawn.KilledBy(c.Pawn);
	c.unpossess();
	c.GotoState('TribesSpectating');
	c.ClientGotoState('TribesSpectating');
}

function onUnspectate(PlayerCharacterController c)
{
	local tribesReplicationInfo TRI;
	local TeamInfo t;

	TRI = TribesReplicationInfo(c.playerReplicationInfo);
	// Only allow unSpectating if you would normally be allowed to change teams
	if (ChangeTeam(c, 0, false))
	{
		if(TRI.team == None)
		{
			t = initialTeam();
			TRI.setTeam(t);
			TRI.bTeamChanged = true;
		}
		c.GotoState('PlayerRespawn');
		c.ClientGotoState('PlayerRespawn');
	}

	// MJ temp message
	c.ClientMessage("Can't unspectate now");
}


// Returns team with highest score
function TeamInfo getWinningTeam()
{
	local TeamInfo team, winningTeam;

	ForEach Level.AllActors(class'TeamInfo', team)
	{
		if (winningTeam == None)
			winningTeam = team;
		else if (team.Score > winningTeam.Score)
			winningTeam = team;
	}

	return winningTeam;
}

// Returns team with lowest score
function TeamInfo getLosingTeam()
{
	local TeamInfo team, losingTeam;

	ForEach Level.AllActors(class'TeamInfo', team)
	{
		if (losingTeam == None)
			losingTeam = team;
		else if (team.Score < losingTeam.Score)
			losingTeam = team;
	}

	return losingTeam;
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	local PlayerCharacterController pcc;
	local bool allowChangeTeam;
	local TeamInfo t;
	local bool bTournamentActive;

	pcc = PlayerCharacterController(Other);
	t = pcc.getTeamInfo(N);

	// Don't allow team changes while the player is respawning, if the round has limited lives, if
	// a team has run out of carryables, or if the server has started a tournament
	bTournamentActive = bTournamentMode && !TribesGameReplicationInfo(GameReplicationInfo).bAwaitingTournamentStart;

	allowChangeTeam = (pcc.respawnDelay <= 0 || pcc.respawnDelay == roundInfo.currentRound().respawnDelay) &&
					  !t.bNoMoreCarryables &&
					  !bTournamentActive;

	// Don't allow changing teams if maxLives is set and the game is in progress, but do allow changing
	// teams if the game is in between rounds
	//if (roundInfo.currentRound().maxLives >= 0)
	//	allowChangeTeam = !IsInState('GamePhase');
	
	//Log("Change team returning "$allowChangeTeam$" trying to change "$Other$" to "$t);
	//Log("respawnDelay = "$pcc.respawnDelay$", maxLives = "$roundInfo.currentRound().maxLives$", noCarry = "$t.bNoMoreCarryables$", tourney = "$bTournamentActive);
	return allowChangeTeam;
}

function enableTournamentMode()
{
	bTournamentMode = true;
	default.bTournamentMode = true;
	GameReplicationInfo.bTournamentMode = true;
	bChangeLevels = false;
	Class.static.StaticSaveConfig();
	RestartGame();
}

function disableTournamentMode()
{
	bTournamentMode = false;
	default.bTournamentMode = false;
	GameReplicationInfo.bTournamentMode = false;
	bForceStart = true;
	bChangeLevels = true;
	Class.static.StaticSaveConfig();
}

function setPlayerTeamDamagePercentage(float percentage)
{
	if (percentage < 0)
		percentage = 0;
	else if (percentage > 1)
		percentage = 1;

	default.playerTeamDamagePercentage = percentage;
	playerTeamDamagePercentage = percentage;
	GameReplicationInfo.playerTeamDamagePercentage = percentage;
	Class.static.StaticSaveConfig();
}

// returns the number of player controllers that have active pawns
function int numActivePlayers()
{
	local PlayerCharacterController pc;
	local int i;

	ForEach Level.AllControllers(class'PlayerCharacterController', pc)
	{
		if (pc.Pawn != None)
			i++;
	}

	return i;
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	local Controller C;
	local bool bAllow;

	if (MPActor(ViewTarget) != None)
		return true;

	C = Controller(ViewTarget);

	// can only spectate characters, occupied vehicles, occupied vehicle turrets
	bAllow = Viewer == ViewTarget || 
			(C != None && (Character(C.Pawn) != None || Vehicle(C.Pawn) != None || VehicleMountedTurret(C.Pawn) != None) && !C.IsInState('TribesSpectating'));

	if (bAllow && Rook(ViewTarget) != None && Viewer.Pawn != None && bDontAllowEnemySpectating)
	{
		bAllow = (Rook(ViewTarget).team() == Rook(Viewer.Pawn).team());
	}
	return bAllow;
}

function bool allowMapVote()
{
	return true;
}

function repairAllBaseDevices()
{
	local BaseDevice bd;

	ForEach AllActors(class'BaseDevice', bd)
	{
		if (bd.bCanBeDamaged)
			bd.Health = bd.default.Health;
	}

}


/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
	if (!bOnGameEndCalled)
	{
		bServerTravelOverride = true;
		serverTravelURL = URL;

		Level.bLevelChange = false;
		Level.NextURL = "";
		Log("ProcessServerTravel called, sending to GameEnd");
		GotoState('GameEnd');
	}
	else
	{
		Log("Calling super.ProcessServerTravel");
		super.ProcessServerTravel(URL, bItems);
	}
}


// Hints
static function string GetLoadingHint( PlayerController Ref, color HintColor, color BindColor )
{
	local string Hint;
	local int Attempt;

	if ( Ref == None )
		return "";

	while ( Hint == "" && ++Attempt < 10 )
		Hint = ParseLoadingHint(GetNextLoadHint(), Ref, HintColor, BindColor);

	return Hint;
}

static function string ParseLoadingHint(string Hint, PlayerController Ref, color HintColor, color BindColor)
{
	local string CurrentHint, Cmd, Result;
	local int pos;

	pos = InStr(Hint, "%");
	if ( pos == -1 )
		return Hint;

	do
	{
		Cmd = "";
		Result = "";

		CurrentHint $= Left(Hint,pos);
		Hint = Mid(Hint, pos+1);

		pos = InStr(Hint, "%");
		if ( pos == -1 )
			break;

		Cmd = Left(Hint,pos);
		Hint = Mid(Hint,pos+1);

		Result = Ref.Player.InteractionMaster.GetKeyFromBinding(Cmd, true);
		if ( Result == Cmd || Result == "" )
			break;

		CurrentHint $= MakeColorCode(BindColor) $ Result $ MakeColorCode(HintColor);
		pos = InStr(Hint, "%");
	} until ( Hint == "" || pos == -1 );

	if ( Result != "" && Result != Cmd )
		return CurrentHint $ Hint;

	return "";
}

static function string GetNextLoadHint()
{
	local array<string> Hints;

	// Higher chance that we'll pull a loading hint from our own gametype
	if ( Rand(100) < 75 )
		Hints = GetAllLoadHints(true);
	else Hints = GetAllLoadHints();

	if ( Hints.Length > 0 )
		return Hints[Rand(Hints.Length)];

	return "";
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	return default.gameHints;
}

static function string MakeColorCode(color NewColor)
{
    // Text colours use 1 as 0.
    if(NewColor.R == 0)
        NewColor.R = 1;

    if(NewColor.G == 0)
        NewColor.G = 1;

    if(NewColor.B == 0)
        NewColor.B = 1;

    return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

function String GetGameSpyGameMode()
{
	return GameSpyGameMode;
}

function GameSpyStateChange(String newGameMode)
{
	GameSpyGameMode = newGameMode;
	Level.GetGameSpyManager().SendGameSpyGameModeChange();
}


defaultproperties
{
	Label						= "GAMEINFO"
	PlayerControllerClassName	= "Gameplay.PlayerCharacterController"
	DefaultPlayerClassName		= "Gameplay.MultiplayerCharacter"
    bDelayedStart				= true
	MapListType					= "Gameplay.MapList"
	CheatClass					= class'ConsoleCommandManager'
	gameSummaryPage				= "TribesMPGameSummaryMenu"
	roundSummaryPage			= "TribesMPRoundSummaryMenu"
	guiPackage					= "TribesGui"
	equipmentLifeTime			= 15.0
	DeathMessageClass			= class'Gameplay.MPDeathMessages'
	GameMessageClass			= class'Gameplay.TribesGameMessage'
	postGameDelay				= 8.0
	GameAnnouncerMessageClass	= class'Gameplay.MPGameAnnouncerMessages'
	tournamentCountdown			= 30.0
	minimumNumberOfPlayers		= 0
	numTeams					= 2
	bPauseable					= false
	GameSpyGameMode				= "closedwaiting"
}
