//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native nativereplication;

var float				Score;			// Player's current score.
var float				Deaths;			// Number of player's deaths.
//var CarriedObject		HasFlag;
var int					Ping;				// packet loss packed into this property as well
var Volume				PlayerVolume;
var ZoneInfo            PlayerZone;
var int					NumLives;

var string				PlayerName;		// Player name, or blank if none.
var string				CharacterName, OldCharacterName;
var string				OldName, PreviousName;		// Temporary value.
var int					PlayerID;		// Unique id number.
#if !IG_TRIBES3 // david: not using Unreal team object
var TeamInfo			Team;			// Player Team
var int					TeamID;			// Player position in team.
#endif
var class<VoicePack>	VoiceType;
var bool				bAdmin;				// Player logged in as Administrator
var bool				bIsFemale;
var bool				bIsSpectator;
var bool				bOnlySpectator;
var bool				bWaitingPlayer;
var bool				bReadyToPlay;
var bool				bOutOfLives;
var bool				bBot;
var bool				bWelcomed;			// set after welcome message broadcast (not replicated)
var bool				bReceivedPing;			
var bool				bHasFlag;			

// Time elapsed.
var int					StartTime;

var localized String	StringDead;
var localized String    StringSpectating;
var localized String	StringUnknown;

var int					GoalsScored;		// not replicated - used on server side only
var int					Kills;				// not replicated
 				
replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		Score, Deaths, bHasFlag, PlayerVolume, PlayerZone,
#if IG_TRIBES3 // david: not using Unreal team object
		PlayerName, VoiceType, bIsFemale, bAdmin, 
#else
		PlayerName, Team, TeamID, VoiceType, bIsFemale, bAdmin, 
#endif
		bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
		bOutOfLives, CharacterName;
	reliable if ( bNetDirty && (!bNetOwner || bDemoRecording) && (Role == Role_Authority) )
		Ping; 
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		StartTime, bBot;
}

function PostBeginPlay()
{
	if ( Role < ROLE_Authority )
		return;
//    if (AIController(Owner) != None)
  //      bBot = true;
	StartTime = Level.Game.GameReplicationInfo.ElapsedTime;
	Timer();
	SetTimer(1.5 + FRand(), true);
}

simulated function PostNetBeginPlay()
{
	local GameReplicationInfo GRI;
	
	ForEach DynamicActors(class'GameReplicationInfo',GRI)
	{
		GRI.AddPRI(self);
		break;
	}
}

simulated function Destroyed()
{
	local GameReplicationInfo GRI;
	
	ForEach DynamicActors(class'GameReplicationInfo',GRI)
        GRI.RemovePRI(self);
        
    Super.Destroyed();
}
	
function SetCharacterName(string S)
{
	CharacterName = S;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
	Deaths = 0;
//	SetFlag(None);
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
}

/*
function SetFlag(CarriedObject NewFlag)
{
	HasFlag = NewFlag;
	bHasFlag = (HasFlag != None);
}
*/

simulated function string GetHumanReadableName()
{
	return PlayerName;
}

simulated function string GetLocationName()
{
    if( ( PlayerVolume == None ) && ( PlayerZone == None ) )
    {
    	if ( (Owner != None) && Controller(Owner).IsInState('Dead') )
        	return StringDead;
        else
        return StringSpectating;
    }
    
	if( ( PlayerVolume != None ) && ( PlayerVolume.LocationName != class'Volume'.Default.LocationName ) )
		return PlayerVolume.LocationName;
	else if( PlayerZone != None && ( PlayerZone.LocationName != "" )  )
		return PlayerZone.LocationName;
    else if ( Level.Title != Level.Default.Title )
		return Level.Title;
	else
        return StringUnknown;
}

simulated function material GetPortrait();
event UpdateCharacter();

function UpdatePlayerLocation()
{
    local Volume V, Best;
    local Pawn P;
    local Controller C;

    C = Controller(Owner);

    if( C != None )
        P = C.Pawn;
    
    if( P == None )
		{
        PlayerVolume = None;
        PlayerZone = None;
        return;
    }
    
    if ( PlayerZone != P.Region.Zone )
		PlayerZone = P.Region.Zone;

    foreach P.TouchingActors( class'Volume', V )
    {
        if( V.LocationName == "") 
            continue;
        
        if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
            continue;
            
        if( V.Encompasses(P) )
            Best = V;
		}
    if ( PlayerVolume != Best )
		PlayerVolume = Best;
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
//	if ( Team != None )
//		Canvas.DrawText("     PlayerName "$PlayerName$" Team "$Team.GetHumanReadableName()$" has flag "$HasFlag);
//	else
		Canvas.DrawText("     PlayerName "$PlayerName$" NO Team");
}
 					
event ClientNameChange()
{
    local PlayerController PC;

	ForEach DynamicActors(class'PlayerController', PC)
		PC.ReceiveLocalizedMessage( class'GameMessage', 2, self );          
}

function Timer()
{
    local Controller C;

	UpdatePlayerLocation();
	SetTimer(1.5 + FRand(), true);
	if( FRand() < 0.65 )
		return;

	if( !bBot )
	{
	    C = Controller(Owner);
		if ( !bReceivedPing )
			Ping = int(C.ConsoleCommand("GETPING"));
	}
}

function SetPlayerName(string S)
{
	OldName = PlayerName;
	PlayerName = S;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;	
	bWaitingPlayer = B;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    StringSpectating="Spectating"
    StringUnknown="Unknown"
    StringDead="Dead"
    NetUpdateFrequency=5
}
