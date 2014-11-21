//=============================================================================
// MessagingSpectator - spectator base class for game helper spectators which receive messages
//=============================================================================

#if IG_TRIBES3_ADMIN

class MessagingSpectator extends PlayerController
	abstract;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	bIsPlayer = False;
}

auto state NotPlaying
{
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName="WebAdmin";	// Temporary for debug purpose. Easier to identify if the webadmin is the source of problems.
	PlayerReplicationInfo.bIsSpectator = true;
	PlayerReplicationInfo.bOnlySpectator = true;
	PlayerReplicationInfo.bOutOfLives = true;
	PlayerReplicationInfo.bWaitingPlayer = false;
}

#else

class MessagingSpectator extends PlayerController
	abstract;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bIsPlayer = False;
}

#endif

defaultproperties
{
}
