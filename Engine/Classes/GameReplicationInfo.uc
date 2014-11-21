//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native nativereplication;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
var bool bTeamGame;							// Assigned by GameInfo.
var bool bStopCountDown;
var bool bMatchHasBegun;
var bool bTeamSymbolsUpdated;
#if IG_TRIBES3	// michaelj:  Tourney mode
var bool bTournamentMode;
var float playerTeamDamagePercentage;
#endif
var int  RemainingTime, ElapsedTime, RemainingMinute;
var float SecondCount;
var int GoalScore;
var int TimeLimit;
var int MaxLives;

//var TeamInfo Teams[2];

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;		// Email address of the server admin.
#if IG_TRIBES3	// michaelj:  Store additional data
var() globalconfig string AdminPass;		// Session password of the server admin
var() globalconfig bool bAdvertise;			// Whether or not to advertise on GameSpy
var() globalconfig bool bCollectStats;		// Whether or not to track stats via GameSpy
#endif
var() globalconfig int	  ServerRegion;		// Region of the game server.

var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var Actor Winner;			// set by gameinfo when game ends

var() array<PlayerReplicationInfo> PRIArray;

var vector FlagPos;	// replicated 2D position of one object

enum ECarriedObjectState
{
    COS_Home,
    COS_HeldFriendly,
    COS_HeldEnemy,
    COS_Down,
};
var ECarriedObjectState CarriedObjectState[2];

// stats
var int MatchID;

replication
{
	reliable if ( bNetDirty && (Role == ROLE_Authority) )
		RemainingMinute, bStopCountDown, Winner, FlagPos, CarriedObjectState, bMatchHasBegun, MatchID; 

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		GameName, GameClass, bTeamGame, 
		RemainingTime, ElapsedTime,MOTDLine1, MOTDLine2, 
		MOTDLine3, MOTDLine4, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, GoalScore, MaxLives, TimeLimit; 

#if IG_TRIBES3	// michaelj:  Tourney mode
	reliable if (Role == ROLE_Authority)
		bTournamentMode, playerTeamDamagePercentage;
#endif
}

simulated function SetCarriedObjectState(int Team, name NewState)
{
	switch( NewState )
	{
		case 'Down':
			CarriedObjectState[Team] = COS_Down;
			break;
		case 'HeldEnemy ':
			CarriedObjectState[Team] = COS_HeldEnemy;
			break;
		case 'Home ':
			CarriedObjectState[Team] = COS_Home;
			break;
		case 'HeldFriendly ':
			CarriedObjectState[Team] = COS_HeldFriendly;
			break;
	}
}

simulated function name GetCarriedObjectState(int Team)
{
	switch( CarriedObjectState[Team] )
	{
		case COS_Down:
			return 'Down';
		case COS_HeldEnemy:
			return 'HeldEnemy';
		case COS_Home:
			return 'Home';
		case COS_HeldFriendly:
			return 'HeldFriendly';
	}
	return '';
}			

simulated function PostNetBeginPlay()
{
	local PlayerReplicationInfo PRI;

#if IG_TRIBES3	// michaelj:  Integrated from UT2004
	Level.GRI = self;
#endif
	
	ForEach DynamicActors(class'PlayerReplicationInfo',PRI)
		AddPRI(PRI);
	if ( Level.NetMode == NM_Client )
		TeamSymbolNotify();
}

simulated function TeamSymbolNotify()
{
#if !IG_TRIBES3 // david: not using Unreal team object
	local Actor A;

	if ( (Teams[0] == None) || (Teams[1] == None)
		|| (Teams[0].TeamIcon == None) || (Teams[1].TeamIcon == None) )
		return;
	bTeamSymbolsUpdated = true;
	ForEach AllActors(class'Actor', A)
		A.SetGRI(self);
#endif
}

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(1, true);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Winner = None;
}

simulated function Timer()
{
	if ( Level.NetMode == NM_Client )
	{
		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( (RemainingTime > 0) && !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
		if ( !bTeamSymbolsUpdated )
			TeamSymbolNotify();
	}
}

simulated function AddPRI(PlayerReplicationInfo PRI)
{
    PRIArray[PRIArray.Length] = PRI;
}

simulated function RemovePRI(PlayerReplicationInfo PRI)
{
    local int i;

    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] == PRI)
            break;
    }

    if (i == PRIArray.Length)
    {
        Log("GameReplicationInfo::RemovePRI() pri="$PRI$" not found.", 'Error');
        return;
    }

    PRIArray.Remove(i,1);
	}

simulated function GetPRIArray(out array<PlayerReplicationInfo> pris)
{
    local int i;
    local int num;

    pris.Remove(0, pris.Length);
    for (i=0; i<PRIArray.Length; i++)
    {
        if (PRIArray[i] != None)
            pris[num++] = PRIArray[i];
    }
}

defaultproperties
{
     bStopCountDown=True
     ServerName="Another TV Server"
     ShortName="TV Server"
     bAdvertise=True
     bNetNotify=True
}
