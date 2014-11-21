class GameInfo extends Engine.GameInfo;


//-----------------------------------------------------------------------------
// Variables.

var class<CheatManager>		CheatClass;					// class of CheatManager for player controllers

var transient private int	secondsPassed;				// TEMP fix for player start happening way before the first frame
var transient private bool	msgSent;					// TEMP fix for player start happening way before the first frame

// Variables that can be configured by the game operator
var() globalconfig float playerTeamDamagePercentage					"Members of the same team can damage each other's health down to this percentage (0 to disable).  Server configurable.";
var() globalconfig float baseDeviceTeamDamagePercentage				"Members of the same team can damage their base objects' health down to this percentage (0 to disable).  Server configurable.";

var() class<InventoryStationAccess> inventoryStationAccessClass "Optional inventory station used by this game type for non-physical inventory selection.  Can be overriden in roundDatas.";

var() float equipmentLifeTime;

var	LatticeInfo	lattice;

function PostBeginPlay()
{
	local Actor a;
	local LatticeInfo l;
	local TeamInfo t;
	local BaseInfo b;
	local BoundaryVolume bv;

	Label = 'GameInfo';

	Super.PostBeginPlay();

	// filter objects that were loaded
	ForEach DynamicActors(class'Actor', a)
	{
		// Don't delete BoundaryVolumes
		if (!allowObjectAtLoad(a) && !a.isA('BoundaryVolume'))
		{
			//Log("Filtering "$a);
			a.Destroy();
		}
	}

	// instruct reamining TeamInfos to evaluate remaining playerStarts
	ForEach AllActors(class'TeamInfo', t)
	{
		t.evaluatePlayerStarts();
	}

	// initialize baseInfos
	ForEach AllActors(class'BaseInfo', b)
	{
		b.Initialize();
	}

	// load skin packages if required
	if (allowSkinChanges())
	{
		class'SkinInfo'.static.loadAllSkins(Level);
	}

	// See if there's a lattice
	ForEach AllActors(class'LatticeInfo', l)
	{
		// Assume there's only one
		lattice = l;
		break;
	}

	// send a message that the level has started
	dispatchMessage(new class'MessageLevelStart');

	// initialise the game boundary volume
	ForEach AllActors(class'BoundaryVolume', bv)
	{
		// assume there's only one
		if (bv.Active)
		{
			BoundaryVolume = bv;
			break;
		}
	}
}

function PostLoadGame()
{
	super.PostLoadGame();
	dispatchMessage(new class'MessageGameLoaded');
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local Actor						StartSpot;
	local PlayerController			NewPlayer;
    local string					InName, InAdminName, InPassword, InChecksum, InClass, InCharacter; 
	local string					controllerName;
    local bool						bSpectator, bAdmin;
	local class<PlayerController>	PlayerControllerClass;	// type of player controller to spawn for players logging in
	local class<Security>			MySecurityClass;
	local Vector					controllerStartLoc;
	local Rotator					controllerStartRot;

	InName     = Left(DecodeFromURL(ParseOption ( Options, "Name")), 20);

    bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "true" );

    bAdmin = AccessControl.CheckOptionsAdmin(Options);

    // Make sure there is capacity except for admins. (This might have changed since the PreLogin call).
    if ( !bAdmin && AtCapacity(bSpectator) )
	{
		Error=GameMessageClass.Default.MaxedOutMessage;
		return None;
	}

	// If admin, force spectate mode if the server already full of reg. players
	if ( bAdmin && AtCapacity(false))
		bSpectator = true;
	
	BaseMutator.ModifyLogin(Portal, Options);

	// Get URL options.
    InAdminName= ParseOption ( Options, "AdminName");
	InPassword = ParseOption ( Options, "Password" );
	InChecksum = ParseOption ( Options, "Checksum" );

	log( "Login:" @ InName );
	if( InPassword != "" )
		log( "Password"@InPassword );
	
	// Find a start spot.
	StartSpot = tribesFindPlayerStart( None, initialTeam());

	if( StartSpot != None )
	{
		if ( SinglePlayerStart(StartSpot)!=None)
			controllerName = SinglePlayerStart(StartSpot).PlayerControllerClassName;

		controllerStartLoc = StartSpot.Location;
		controllerStartRot = StartSpot.Rotation;
	}
	else
	{
		LOG("GameInfo::Login: Warning, no start spot could be found");
	}

	if ( controllerName == "" )
		controllerName = PlayerControllerClassName;

	if ( PlayerControllerClass == None )
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject(controllerName, class'Class'));

	NewPlayer = spawn(PlayerControllerClass,,,controllerStartLoc,controllerStartRot);

	// Handle controller spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player controller of class "$PlayerControllerClass);
		Error = GameMessageClass.Default.FailedSpawnMessage;
		return None;
	}

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// Apply security to this controller
	
	MySecurityClass=class<Security>(DynamicLoadObject(SecurityClass,class'class'));
	NewPlayer.PlayerSecurity = spawn(MySecurityClass, self);
	if (NewPlayer.PlayerSecurity==None)
	{
		log("Could not spawn security for player "$NewPlayer,'Security');
	}
	
	//NewPlayer.GotoState('AttractMode');

	// Init player's name
	if( InName=="" )
		InName=DefaultPlayerName;
	if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
		ChangeName( NewPlayer, InName, false );

	// Init the players gender
	NewPlayer.PlayerReplicationInfo.bIsFemale = (ParseOption(Options, "IsFemale") ~= "true");

	// Init players voice set
	if(TribesReplicationInfo(NewPlayer.PlayerReplicationInfo) != None)
	{
		TribesReplicationInfo(NewPlayer.PlayerReplicationInfo).VoiceSetPackageName = (ParseOption(Options, "VoiceSet"));
		if(TribesReplicationInfo(NewPlayer.PlayerReplicationInfo).VoiceSetPackageName == "")
			TribesReplicationInfo(NewPlayer.PlayerReplicationInfo).VoiceSetPackageName = "QuickChatAlbrecht";
	}

    if ( bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator )
	{
        NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		NumSpectators++;
		return NewPlayer;
	}

    // Init player's administrative privileges and log it
    if (AccessControl.AdminLogin(NewPlayer, InAdminName, InPassword))
    {
		AccessControl.AdminEntered(NewPlayer, InAdminName);
    }

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Get default pawn class from start point, if available
	if ( PlayerStart(StartSpot)!=None)
		InClass = PlayerStart(StartSpot).defaultPawnClassName();

	// Else get default pawn class from command line
	// Commented out, not needed for our game
/*	if ( InClass == "" )
	InClass = ParseOption( Options, "Class" );*/

	// Else use DefaultPlayerClassName field
    if (InClass == "")
        InClass = DefaultPlayerClassName;
    InCharacter = ParseOption(Options, "Character");
    NewPlayer.SetPawnClass(InClass, InCharacter);

	NumPlayers++;
    bWelcomePending = true;

	// if delayed start, don't give a pawn to the player yet
	// Normal for multiplayer games
	if ( bDelayedStart )
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;	
	}
	
	return NewPlayer;
}	

// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( PlayerController NewPlayer )
{
	Super.PostLogin(NewPlayer);

	PlayerCharacterController(NewPlayer).clientSetCheats(cheatClass);

	// tell client to load skin classes if it is allowed
	if(allowSkinChanges())
		PlayerCharacterController(NewPlayer).clientLoadSkinClasses();

	// Dispatch a connect event
	NewPlayer.dispatchMessage(new class'MessageClientConnected'(PlayerCharacterController(NewPlayer)) );
}

function Logout( Controller Exiting )
{
	local PlayerCharacterController pcc;

	pcc = PlayerCharacterController(Exiting);

	if (pcc != None)
	{
		// Dispatch a disconnect event
		Exiting.dispatchMessage(new class'MessageClientDisconnected'(pcc));

		pcc.playerDisconnected();
	}

	Super.Logout(Exiting);
}

// Moved functionality from RestartPlayer to here, to allow parameterised modification of respawn behaviour
private function respawn( Controller aPlayer, bool bCreateNewPawn )
{
	local PlayerStart startSpot;
	local int spawnTries;
	local Character playerChar;
	local TribesReplicationInfo TRI;
	local Vector teleportLoc;
	
	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer || aPlayer==None)
		return;

	if (aPlayer.Pawn!=None && bCreateNewPawn)
	{
	    //log("destroy pawn: "$aPlayer.Pawn);
	
	    // destroy pawn
		aPlayer.Pawn.Destroy();
		aPlayer.Pawn = None;
    }
    
    if (aPlayer.PawnClass!=None)
    {
		if (aPlayer.PlayerReplicationInfo != None)
			TRI = TribesReplicationInfo(aPlayer.PlayerReplicationInfo);

	    while (spawnTries<5)
	    {
			// If the player has a team already, start him on that team
			if (TRI != None)
			    startSpot = tribesFindPlayerStart(aPlayer, TRI.team);
			else
			// Otherwise try to start him without a team (needed for single player)
				startSpot = tribesFindPlayerStart(aPlayer, None);

		    aPlayer.StartSpot = StartSpot;

		    if (startSpot != None)
		    {
			    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
				    BaseMutator.PlayerChangedClass(aPlayer);			

				// bCreateNewPawn support
				if (aPlayer.Pawn == None)
				{
					aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

					if (aPlayer.Pawn != None)
						break;
				}
				else
				{
					teleportLoc = StartSpot.Location;
					teleportLoc.Z += aPlayer.Pawn.CollisionHeight;
					if (Character(aPlayer.Pawn) == None)
					{
						aPlayer.Pawn.unifiedSetPosition(teleportLoc);
						aPlayer.Pawn.SetRotation(StartSpot.Rotation);
					}
					else
						Character(aPlayer.Pawn).teleportTo(teleportLoc, StartSpot.Rotation);

					if (aPlayer.Pawn.Location != teleportLoc)
						LOG("Couldn't move player to start spot"@teleportLoc);
					else
						break;
				}
		    }

		    spawnTries++;
	    }

	    if (startSpot == None || aPlayer.Pawn == None)
	    {
		    log("Tried 5 times, couldn't spawn player of type "$aPlayer.PawnClass);
		    //log("why you ask? because... startSpot="$startSpot$", aPlayer.Pawn="$aPlayer.Pawn);
		    return;
	    }
	}
	else
		Log("Warning:  respawn() called on a player that has no pawnClass");

    if (aPlayer.Pawn!=None)
    {
	    aPlayer.Pawn.label = 'Player';
	    
	    if (Level.NetMode != NM_Standalone)
		    aPlayer.Pawn.label = aPlayer.Pawn.Name;

	    aPlayer.Pawn.LastStartSpot = startSpot;
	    aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
	    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

	    aPlayer.Possess(aPlayer.Pawn);
	    aPlayer.PawnClass = aPlayer.Pawn.Class;

		// Need to assign the player's team based on TRI
		playerChar = Character(aPlayer.Pawn);
		if (TRI.team != None)
		{
		    playerChar.setTeam(TRI.team);
		}

        aPlayer.Pawn.PlayTeleportEffect(true, true);
	    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	    AddDefaultInventory(aPlayer.Pawn);
	    TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);

	    if (startSpot != None && startSpot.invincibleDelay > 0.0 && Character(aPlayer.Pawn) != None)
	    {
			aPlayer.Pawn.TriggerEffectEvent('Invincible');
		    Character(aPlayer.Pawn).bTempInvincible = true;
		    aPlayer.Pawn.SetTimer(startSpot.invincibleDelay, false);
	    }

	    // send a message that the player has started
	    dispatchMessage(new class'MessagePlayerStart');
	}
}

// Restarts the player while keeping his pawn
function respawnKeepPawn( Controller aPlayer )
{
	respawn(aPlayer, false);
}

//
// Restart a player, call this when you want the player to respawn or start the game
//
function RestartPlayer( Controller aPlayer )	
{
	respawn(aPlayer, true);
}

event Timer()  // TEMP fix for player start happening way before the first frame
{
	Super.Timer();

	if (secondsPassed < 10)
	{
		++secondsPassed;
	}
	else
	{
		if (!msgSent)
		{
			dispatchMessage(new class'MessagePlayerStartDelayed');
			msgSent = true;
		}
	}
}

// initialTeam
function TeamInfo initialTeam()
{
	local TeamInfo t;

	ForEach DynamicActors(class'TeamInfo', t)
		return t;

	return None;
}

function int numTeams()
{
	local int teamCount;
	local TeamInfo ti;

	teamCount = 0;
	foreach DynamicActors(class'TeamInfo', ti)
		teamCount += 1;

	return teamCount;
}

function TeamInfo GetTeamFromIndex(int index)
{
	local int i;
	local TeamInfo ti;

	i = 0;
	foreach DynamicActors(class'TeamInfo', ti)
	{
		if (i == index)
			return ti;

		++i;
	}

	return None;

}

function String GetPlayerNamesList()
{
	local String playerNamesList;
	local TribesReplicationInfo tri;

	foreach DynamicActors(class'TribesReplicationInfo', tri)
		playerNamesList $= tri.getTeamAffiliatedName();

	return playerNamesList;

}

function String GetGameSpyGameMode()
{
	return "exiting";
}

// tryRespawn
// called when a player requests to be respawned
function bool tryRespawn(PlayerCharacterController c)
{
	RestartPlayer(c);
	return true;
}

// onDeath
// called when character that a controller is viewing dies
function onDeath(PlayerCharacterController c)
{
}

// allowObjectAtLoad
function bool allowObjectAtLoad(Actor a)
{
	local int i;

	// Check for inclusion list first, which overrides any exclusions
	for (i=0; i<a.gameInfoInclusions.Length; i++)
	{
		if (IsA(a.gameInfoInclusions[i].name))
			return true;
	}

	// Check for strict exclusivity
	if (a.exclusiveToGameInfo != None)
		return IsA(a.exclusiveToGameInfo.name);

	// Check for exclusion list
	for (i=0; i<a.gameInfoExclusions.Length; i++)
	{
		if (a.gameInfoExclusions[i] == None)
			continue;

		if (IsA(a.gameInfoExclusions[i].name))
			return false;
	}

	return true;
}

function bool allowSkinChanges()
{
	return true;
}

// return false to disable manual respawn with the 'b' key, base implementation returns true
function bool allowManualRespawn()
{
	return Mutator(BaseMutator).MutateManualRespawn();
}

// tribesRatePlayerStart
function float tribesRatePlayerStart(PlayerStart P, TeamInfo Team, Controller Player)
{
	return 1;
}

// tribesFindPlayerStart
function PlayerStart tribesFindPlayerStart( Controller Player, TeamInfo InTeam )
{
	local PlayerStart N, BestStart;
	local float NewRating, BestRating;

	BestRating = 0;

	foreach AllActors( class 'PlayerStart', N )
	{
		NewRating = tribesRatePlayerStart(N, InTeam, Player);

		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;	
		}
	}

	// Log("Best start found to be "$BestStart$" for team "$InTeam);
	return BestStart;
}

// playerPawnDestroyedState
function Name playerPawnDestroyedState()
{
	return 'Dead';
}

function Name playerPawnNoRespawnState()
{
	return 'Dead';
}

// onSpectate
function onSpectate(PlayerCharacterController c)
{
}

function onUnspectate(PlayerCharacterController c)
{
}

function class<InventoryStationAccess> getInventoryStationAccessClass()
{
	return inventoryStationAccessClass;
}

function addDroppedEquipment(Equipment e);

function removeDroppedEquipment(Equipment e);

function preLevelChange()
{
	// Perform any necessary cleanup here
}

function float modifyRepairRate(Rook who, float rate)
{
	return rate;
}

static function bool showChatWindow()
{
	return true;
}

function modifyAI(BaseAICharacter c);
function modifyPlayer(SingleplayerCharacter c);
function float modifyHealthKitRate(Rook who, float rate)
{
	return rate;
}

defaultproperties
{
     CheatClass=Class'ConsoleCommandManager'
     baseDeviceTeamDamagePercentage=0.500000
     inventoryStationAccessClass=Class'InventoryStationStandaloneAccess'
     bRestartLevel=False
     bDelayedStart=False
     DefaultPlayerClassName="Gameplay.Character"
     MutatorClass="Gameplay.Mutator"
     GameReplicationInfoClass=Class'TribesGameReplicationInfo'
}
