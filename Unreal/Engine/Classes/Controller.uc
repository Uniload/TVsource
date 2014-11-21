//=============================================================================
// Controller, the base class of players or AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  PlayerControllers are used by human players to control pawns, while 
// AIControFllers implement the artificial intelligence for the pawns they control.  
// Controllers take control of a pawn using their Possess() method, and relinquish 
// control of the pawn by calling UnPossess().
//
// Controllers receive notifications for many of the events occuring for the Pawn they 
// are controlling.  This gives the controller the opportunity to implement the behavior 
// in response to this event, intercepting the event and superceding the Pawn's default 
// behavior.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Controller extends Actor
	native
	nativereplication
	abstract;

// IGA >>> AI properties used by pathfinding system
struct native FindPathAIProperties
{
	// flags
	var bool jetpack;
	var bool Airborne;
	var bool roadBased;

	var name teamName;

	var float upCostFactor; // 0 to 1, 0 implies no increased cost
	var float downCostFactor; // 0 to 1, 0 implies no increased cost
};

var Pawn Pawn;

var const int		PlayerNum;			// The player number - per-match player number.
var		float		FovAngle;			// X field of view angle in degrees, usually 90.
var globalconfig float	Handedness; 
var		bool        bIsPlayer;			// Pawn is a player or a player-bot.
var		bool		bGodMode;			// cheat - when true, can't be killed or hurt
var		bool		bUsePlayerHearing;

// Input buttons.
var input byte
	bRun, bDuck, bFire, bAltFire, bJetpack, bSki, bJump;

#if IG_TRIBES3
var transient const Controller nextController;
#else
var const Controller	nextController; // chained Controller list
#endif // IG

#if IG_TRIBES3 // Alex: ideally this stuff would be in a controll class in Gameplay that both AI controllers
		// and player controllers derive from however such a class does no exist
struct native RouteCacheElement
{
	// ouput from pathfinding system
	var vector location;
	var bool jetpack;
	var float energy;
	var Actor obstacle; // guaranteed to be a PathfindingObstacle
	var float height; // amount of open air above path node

	// work data
	var float angle;
};

enum FindPathResult
{
	FPR_NoError,
	FPR_SearchSpaceExhausted
};

// initialised when getFindPathResult is called
var array<RouteCacheElement> RouteCache;
var bool RouteComplete;
var FindPathResult lastFindPathResult;
#endif

#if IG_TRIBES3 // Alex:
struct native TraversalLineCheck
{
	var vector start;
	var vector end;
	var color colour;
};
var array<TraversalLineCheck> debugTraversalLineChecks;
#endif

// Replication Info
var() class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var PlayerReplicationInfo PlayerReplicationInfo;

var class<Pawn> PawnClass;			// class of pawn to spawn (for players)
var class<Pawn> PreviousPawnClass;	// Holds the player's previous class

var float GroundPitchTime;
var vector ViewX, ViewY, ViewZ;	// Viewrotation encoding for PHYS_Spider

var Actor StartSpot;  // where player started the match

// for monitoring the position of a pawn
var		vector		MonitorStartLoc;	// used by latent function MonitorPawn()
var		Pawn		MonitoredPawn;		// used by latent function MonitorPawn()
var		float		MonitorMaxDistSq;

#if !IG_TRIBES3	// rowan: we don't use these
var		AvoidMarker	FearSpots[2];	// avoid these spots when moving
#endif

var const Actor LastFailedReach;	// cache to avoid trying failed actorreachable more than once per frame
var const float FailedReachTime;
var const vector FailedReachLocation;

#if !IG_TRIBES3	// rowan: we don't use these
var class<Weapon> LastPawnWeapon;				// used by game stats
#endif

const LATENT_MOVETOWARD = 503; // LatentAction number for Movetoward() latent function

replication
{
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		PlayerReplicationInfo, Pawn;
	reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		PawnClass;

	// Functions the server calls on the client side.
	reliable if( RemoteRole==ROLE_AutonomousProxy ) 
		ClientGameEnded, ClientDying, ClientSetRotation, ClientSetLocation;
//		ClientSwitchToBestWeapon, ClientSetWeapon; 
/*	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) && Role == ROLE_Authority )
		ClientVoiceMessage;*/

	// Functions the client calls on the server.
	unreliable if( Role<ROLE_Authority )
		/*SendVoiceMessage, */SetPawnClass; 
	reliable if ( Role < ROLE_Authority )
		ServerReStartPlayer;
}

/* LineOfSightTo() returns true if any of several points of Other is visible 
  (origin, top, bottom)
*/
native(514) final function bool LineOfSightTo(actor Other); 

// IGA >>> Alex: draw controller world space debug information, called by DefaultHUD in Gameplay,
// it would be better if this function was in Gameplay however it comes back to the problem of not
// having a common controller base in Gameplay
function displayWorldSpaceDebug(HUD displayHUD);

#if IG_TRIBES3 // Alex: pathfinding stuff

native final function GetFindPathResult();

native final function DiscardFindPath();

// returns true if there is a find path in progress and it is yet to complete, otherwise returns false
native final function bool IsFindPathComplete();

native final function FindPath(vector start, vector end, FindPathAIProperties AIProperties, array<Actor> ignore, bool printLogs,
		optional bool manualContinue);

native final function ContinueFindPath(bool untilComplete);

native final function DrawPathDebug(Viewport viewport, bool showQuadtree, bool showNodes, bool stepEnabled,
		bool showReach);

native final function PathDiagnostics();

native final function DebugTraversalCheck(vector start, vector end);

#endif

native(529) final function AddController();
native(530) final function RemoveController();

native final function bool InLatentExecution(int LatentActionNumber); //returns true if controller currently performing latent action specified by LatentActionNumber
event MayFall(); //return true if allowed to fall - called by engine when pawn is about to fall

function PendingStasis()
{
	bStasis = true;
	Pawn = None;
}

/* AIHearSound()
Called when AI controlled pawn would hear a sound.  Default AI implementation uses MakeNoise() 
interface for hearing appropriate sounds instead
*/
event AIHearSound ( 
	actor Actor, 
	sound S, 
	vector SoundLocation, 
	vector Parameters,
	bool Attenuate 
);

event HearNoise( float Loudness, Actor NoiseMaker);

/* DisplayDebug()
list important controller attributes on canvas
*/
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( Pawn == None )
	{
		Super.DisplayDebug(Canvas,YL,YPos);
		return;
	}
	
	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText("CONTROLLER "$GetItemName(string(self))$" Pawn "$GetItemName(string(Pawn)));
	YPos += YL;
	Canvas.SetPos(4,YPos);

	/*if ( Enemy != None )
		Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" Enemy "$Enemy.GetHumanReadableName(), false);
	else
		Canvas.DrawText("     STATE: "$GetStateName()$" Timer: "$TimerCounter$" NO Enemy ", false);*
	YPos += YL;
	Canvas.SetPos(4,YPos);*/

	if ( PlayerReplicationInfo == None )
		Canvas.DrawText("     NO PLAYERREPLICATIONINFO", false);
	else
		PlayerReplicationInfo.DisplayDebug(Canvas,YL,YPos);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

simulated function String GetHumanReadableName()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return GetItemName(String(self));
}

function rotator GetViewRotation()
{
	return Rotation;
}

/* Reset() 
reset actor to initial state
*/
function Reset()
{
	Super.Reset();
	// DLB Controller clean pass: removed AI logic Enemy = None;
	// DLB Controller clean pass: removed AI logic LastSeenTime = 0;
	StartSpot = None;
}

/* ClientSetLocation()
replicated function to set location and rotation.  Allows server to force new location for
teleports, etc.
*/
function ClientSetLocation( vector NewLocation, rotator NewRotation )
{
	SetRotation(NewRotation);
	If ( (Rotation.Pitch > RotationRate.Pitch) 
		&& (Rotation.Pitch < 65536 - RotationRate.Pitch) )
	{
		If (Rotation.Pitch < 32768) 
			NewRotation.Pitch = RotationRate.Pitch;
		else
			NewRotation.Pitch = 65536 - RotationRate.Pitch;
	}
	if ( Pawn != None )
	{
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
		Pawn.SetLocation( NewLocation );
	}
}

/* ClientSetRotation()
replicated function to set rotation.  Allows server to force new rotation.
*/
function ClientSetRotation( rotator NewRotation )
{
	SetRotation(NewRotation);
	if ( Pawn != None )
	{
		NewRotation.Pitch = 0;
		NewRotation.Roll  = 0;
		Pawn.SetRotation( NewRotation );
	}
}

function ClientDying(class<DamageType> DamageType, vector HitLocation)
{
	if ( Pawn != None )
	{
		Pawn.PlayDying(DamageType, HitLocation);
		Pawn.GotoState('Dying');
	}
}

event SoakStop(string problem);

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
	// preserve Pawn's rotation initially for placed Pawns
	// DLB Controller clean pass: removed AI logic FocalPoint = Pawn.Location + 512*vector(Pawn.Rotation);
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
    if ( Pawn != None )
        Pawn.UnPossessed();
    Pawn = None;
}

function WasKilledBy(Controller Other);

#if !IG_TRIBES3	// rowan: we don't use this
function class<Weapon> GetLastWeapon()
{
	if ( (Pawn == None) || (Pawn.Weapon == None) )
		return LastPawnWeapon;
	return Pawn.Weapon.Class;
}
#endif

/* PawnDied()
 unpossess a pawn (because pawn was killed)
 */
function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;

	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.UnPossessed();
	}
Pawn = None;

	// DLB Controller clean pass: removed AI logic PendingMover = None;
	if ( bIsPlayer )
    {
        if ( !IsInState('GameEnded') ) 
		GotoState('Dead'); // can respawn
    }
	else
		Destroy();
}

function Restart()
{
	// DLB Controller clean pass: removed AI logic Enemy = None;
}

event LongFall(); // called when latent function WaitForLanding() doesn't return after 4 seconds

// notifications of pawn events (from C++)
// if return true, then pawn won't get notified 
event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);
event bool NotifyHeadVolumeChange(PhysicsVolume NewVolume);
event bool NotifyLanded(vector HitNormal);
event bool NotifyHitWall(vector HitNormal, actor Wall);
event bool NotifyBump(Actor Other);
event NotifyHitMover(vector HitNormal, mover Wall);
event NotifyJumpApex();
event NotifyMissedJump();

// notifications called by pawn in script
//function NotifyAddInventory(inventory NewItem);
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
} 

function SetFall();	//about to fall
function PawnIsInPain(PhysicsVolume PainVolume);	// called when pawn is taking pain volume damage

event PreBeginPlay()
{
	AddController();
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;

	// DLB Controller clean pass: removed AI logic 	SightCounter = 0.2 * FRand();  //offset randomly 
}

#if IG_TRIBES3
event PostLoadGame()
{
	AddController();
}
#endif // IG

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( !bDeleteMe && bIsPlayer && (Role == ROLE_Authority) )
	{
		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
		InitPlayerReplicationInfo();
	}
}

function InitPlayerReplicationInfo()
{
	if (PlayerReplicationInfo.PlayerName == "")
		PlayerReplicationInfo.SetPlayerName(class'GameInfo'.Default.DefaultPlayerName);
}

function bool SameTeamAs(Controller C)
{
#if !IG_TRIBES3 // david: not using Unreal team object
	if ( (PlayerReplicationInfo == None) || (C == None) || (C.PlayerReplicationInfo == None)
		|| (PlayerReplicationInfo.Team == None) )
		return false;
	Log("KARL: New logic required");
#endif
	return false;
//	return Level.Game.IsOnTeam(C,PlayerReplicationInfo.Team.TeamIndex);
}

simulated event Destroyed()
{
	if ( Role < ROLE_Authority )
    {
    	Super.Destroyed();
		return;
    }

	RemoveController();

	if ( bIsPlayer && (Level.Game != None) )
		Level.Game.Logout(self);
	if ( PlayerReplicationInfo != None )
	{
#if !IG_TRIBES3 // david: not using Unreal team object
		if ( !PlayerReplicationInfo.bOnlySpectator && (PlayerReplicationInfo.Team != None) )
			PlayerReplicationInfo.Team.RemoveFromTeam(self);
#endif
		PlayerReplicationInfo.Destroy();
	}
	Super.Destroyed();
}

/* AdjustView() 
by default, check and see if pawn still needs to update eye height
(only if some playercontroller still has pawn as its viewtarget)
Overridden in playercontroller
*/
function AdjustView( float DeltaTime )
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) )
			return;

	Pawn.bUpdateEyeHeight =false;
	Pawn.EyeHeight = Pawn.BaseEyeHeight;
}
			
function bool WantsSmoothedView()
{
	return ( (Pawn != None) && ((Pawn.Physics==PHYS_Walking) || (Pawn.Physics==PHYS_Spider)) && !Pawn.bJustLanded );
}

function GameHasEnded()
{
	if ( Pawn != None )
		Pawn.bNoWeaponFiring = true;
	GotoState('GameEnded');
}

function ClientGameEnded()
{
	GotoState('GameEnded');
}

simulated event RenderOverlays( canvas Canvas );

/* GetFacingDirection()
returns direction faced relative to movement dir

0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	return 0;
}

//------------------------------------------------------------------------------
// Speech related
// DLB Voice messages - perhaps reinstate this later

/*function byte GetMessageIndex(name PhraseName)
{
	return 0;
}*/

/*function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}*/

// DLB Controller clean pass: removed AI logic
/*function bool AllowVoiceMessage(name MessageType)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return false;
	else
		OldMessageTime = Level.TimeSeconds;

	return true;
}*/
 
/*function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	local Controller P;

	if ( !AllowVoiceMessage(MessageType) )
		return;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		if ( PlayerController(P) != None )
		{  
				if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
				else if ( Sender.Team == P.PlayerReplicationInfo.Team )
					P.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
			}
		else if ( (messagetype == 'ORDER') && ((Recipient == None) || (Recipient == P.PlayerReplicationInfo)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}*/

//function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);

function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime);

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
}

/*
// server calls this to force client to switch
function ClientSwitchToBestWeapon()
{
    SwitchToBestWeapon();
}
*/

/*
function ClientSetWeapon( class<Weapon> WeaponClass )
{
    local Inventory Inv;
	local int Count;
	
    for( Inv = Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
    {
		Count++;
		if ( Count > 1000 )
			return;
        if( !ClassIsChildOf( Inv.Class, WeaponClass ) )
            continue;

	    if( Pawn.Weapon == None )
        {
            Pawn.PendingWeapon = Weapon(Inv);
    		Pawn.ChangedWeapon();
        }
	    else if ( Pawn.Weapon != Weapon(Inv) )
        {
    		Pawn.PendingWeapon = Weapon(Inv);
		Pawn.Weapon.PutDown();
}

        return;
    }
}
*/

function SetPawnClass(string inClass, string inCharacter)
{
    local class<Pawn> pClass;
    pClass = class<Pawn>(DynamicLoadObject(inClass, class'Class'));
    if ( pClass != None )
        PawnClass = pClass;
}

function bool CheckFutureSight(float DeltaTime)
{
	return true;
}

function ChangedWeapon()
{
#if !IG_TRIBES3	// rowan: we don't use this
	if ( Pawn.Weapon != None )
		LastPawnWeapon = Pawn.Weapon.Class;
#endif
}

function ServerReStartPlayer()
{
	if ( Level.NetMode == NM_Client )
		return;
	if ( Pawn != None )
		ServerGivePawn();
}

function ServerGivePawn();

function bool AutoTaunt()
{
	return false;
}

function bool DontReuseTaunt(int T)
{
	return false;
}
// **********************************************
// Controller States

State Dead
{
ignores SeePlayer, HearNoise, KilledBy;

	function PawnDied(Pawn P) 
	{
#if !IG_TRIBES3		// marc: Controller is in DEAD state when waiting for player to respawn
		if ( Level.NetMode != NM_Client )
			Warn(self$" Pawndied while dead");
#endif
	}

	function ServerReStartPlayer()
	{
		if ( Level.NetMode == NM_Client )
			return;
		Level.Game.RestartPlayer(self);
	}
}

state GameEnded
{
#if IG_SHARED  //tcohen: hooked TakeDamage(), used by effects system and reactive world objects
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, PostTakeDamage;
#else
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage;
#endif

	function BeginState()
	{
		if ( Pawn != None )
		{
#if !IG_TRIBES3	// rowan: we don't use this
			if ( Pawn.Weapon != None )
				Pawn.Weapon.HolderDied();
#endif
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
			Pawn.SimAnim.AnimRate = 0;
			Pawn.SetCollision(true,false,false);
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
			Pawn.UnPossessed();
			Pawn.bIgnoreForces = true;
		}
		if ( !bIsPlayer )
			Destroy();
	}
}

defaultproperties
{
	RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
     FovAngle=+00090.000000
	 bHidden=true
	 bHiddenEd=true
	 PlayerReplicationInfoClass=Class'Engine.PlayerReplicationInfo'
}