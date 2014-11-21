//=============================================================================
// PlayerController
//
// PlayerControllers are used by human players to control pawns.
//
// This is a built-in Unreal class and it shouldn't be modified.
// for the change in Possess().
//=============================================================================
class PlayerController extends Controller
	config(user)
	native
    nativereplication;

// Player info.
var const player Player;

// player input control
var globalconfig	bool 	bLookUpStairs;	// look up/down stairs (player)
var globalconfig	bool	bSnapToLevel;	// Snap to level eyeheight when not mouselooking
var globalconfig	bool	bAlwaysMouseLook;
var globalconfig	bool	bKeyboardLook;	// no snapping when true
var bool					bCenterView;

// Player control flags
var bool		bBehindView;    // Outside-the-player view.
var bool		bFrozen;		// set when game ends or player dies to temporarily prevent player from restarting (until cleared by timer)
var bool		bPressedJump;
var	bool		bDoubleJump;
var bool		bUpdatePosition;
var bool		bIsTyping;
var bool		bFixedCamera;	// used to fix camera in position (to view animations)
var bool		bJumpStatus;	// used in net games
var	bool		bUpdating;
var globalconfig bool	bNeverSwitchOnPickup;	// if true, don't automatically switch to picked up weapon

var bool		bZooming;

var globalconfig bool bAlwaysLevel;
var bool		bSetTurnRot;
var bool		bCheatFlying;	// instantly stop in flying mode
var bool		bFreeCamera;	// free camera when in behindview mode (for checking out player models and animations)
var	bool		bZeroRoll;
var	bool		bCameraPositionLocked;
var	bool		bViewBot;
var bool		UseFixedVisibility;
var bool	bBlockCloseCamera;
var bool	bValidBehindCamera;
var bool	bForcePrecache;
var bool	bClientDemo;
var const bool bAllActorsRelevant;	// used by UTTV.  DO NOT SET THIS TRUE - it has a huge impact on network performance
var bool	bShortConnectTimeOut;	// when true, reduces connect timeout to 15 seconds
var bool	bPendingDestroy;		// when true, playercontroller is being destroyed

var globalconfig bool bNoVoiceMessages;
var globalconfig bool bNoVoiceTaunts;
var globalconfig bool bNoAutoTaunts;
var globalconfig bool bAutoTaunt;
var globalconfig bool bNoMatureLanguage;
var globalconfig bool bDynamicNetSpeed;

var globalconfig byte AnnouncerLevel;  // 0=none, 1=no possession announcements, 2=all
var globalconfig byte AnnouncerVolume; // 1 to 4
var globalconfig float AimingHelp;
var globalconfig float MaxResponseTime;		// how long server will wait for client move update before setting position
var float WaitDelay;			// Delay time until can restart

var input float
	aBaseX, aBaseY, aBaseZ,	aMouseX, aMouseY,
	aForward, aTurn, aStrafe, aUp, aLookUp;

var input byte
	bStrafe, bSnapLevel, bLook, bFreeLook, bTurn180, bTurnToNearest, bXAxis, bYAxis;

var EDoubleClickDir DoubleClickDir;		// direction of movement key double click (for special moves)

// Camera info.
var int ShowFlags;
// IGA >>> Extended show flags for new rendering stuff
var int ExShowFlags;
// IGA
var int Misc1,Misc2;
var int RendMap;
var float        OrthoZoom;     // Orthogonal/map view zoom factor.
var const actor ViewTarget;
var const Controller RealViewTarget;
var PlayerController DemoViewer;
var float CameraDist;		// multiplier for behindview camera dist
var vector OldCameraLoc;		// used in behindview calculations
var rotator OldCameraRot;
var transient array<CameraEffect> CameraEffects;	// A stack of camera effects.

var globalconfig float DesiredFOV;
var globalconfig float DefaultFOV;
var float		ZoomLevel;

// Fixed visibility.
var vector	FixedLocation;
var rotator	FixedRotation;
var Matrix	RenderWorldToCamera;

// Screen flashes
var vector FlashScale, FlashFog;
var float ConstantGlowScale;
var vector ConstantGlowFog;
#if IG_SHARED // dbeswick: support for cinematic fade action
var bool bManualFogUpdate;
#endif

// Distance fog fading.
var color	LastDistanceFogColor;
var float	LastDistanceFogStart;
var float	LastDistanceFogEnd;
var float	CurrentDistanceFogEnd;
var float	TimeSinceLastFogChange;
var int		LastZone;

// Remote Pawn ViewTargets
var rotator		TargetViewRotation; 
var rotator     BlendedTargetViewRotation;
var float		TargetEyeHeight;
var vector		TargetWeaponViewOffset;

var HUD	myHUD;	// heads up display info

var float LastPlaySound;
var float LastPlaySpeech;

// Music info.
var string				Song;
var EMusicTransition	Transition;

// Move buffering for network games.  Clients save their un-acknowledged moves in order to replay them
// when they get position updates from the server.
var SavedMove SavedMoves;	// buffered moves pending position updates
var SavedMove FreeMoves;	// freed moves, available for buffering
var SavedMove PendingMove;	
var float CurrentTimeStamp,LastUpdateTime,ServerTimeStamp,TimeMargin, ClientUpdateTime;
var globalconfig float MaxTimeMargin;
//var Weapon OldClientWeapon;
var int WeaponUpdate;

// Progess Indicator - used by the engine to provide status messages (HUD is responsible for displaying these).
var string	ProgressMessage[4];
var color	ProgressColor[4];
var float	ProgressTimeOut;

// Localized strings
#if IG_TRIBES3 // dbeswick:
var localized string QuickSaveName;
#endif
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;
#if IG_TRIBES3_VOTING    // glenn: voting support
var VotingReplicationInfoBase VoteReplicationInfo;
#endif

// Stats Logging
var globalconfig string StatsUsername;
var globalconfig string StatsPassword;

var class<LocalMessage> LocalMessageClass;

// view shaking (affects roll, and offsets camera position)
var float	MaxShakeRoll; // max magnitude to roll camera
var vector	MaxShakeOffset; // max magnitude to offset camera position
var float	ShakeRollRate;	// rate to change roll
var vector	ShakeOffsetRate;
var vector	ShakeOffset; //current magnitude to offset camera from shake
var float	ShakeRollTime; // how long to roll.  if value is < 1.0, then MaxShakeOffset gets damped by this, else if > 1 then its the number of times to repeat undamped
var vector	ShakeOffsetTime;

// IGA >>> Cinematic camera shake for mojo
var vector	CinematicShakeOffset;
var rotator	CinematicShakeRotate;
// IGA

var Pawn		TurnTarget;
var config int	EnemyTurnSpeed;
var int			GroundPitch;
var rotator		TurnRot180;

var vector OldFloor;		// used by PlayerSpider mode - floor for which old rotation was based;

// Components ( inner classes )
#if IG_TRIBES3 // david: enable cheats for debugging
var transient CheatManager    CheatManager;   // Object within playercontroller that manages "cheat" commands
#else
var private transient CheatManager    CheatManager;   // Object within playercontroller that manages "cheat" commands
#endif
var class<CheatManager>		CheatClass;		// class of my CheatManager
var private transient PlayerInput	PlayerInput;	// Object within playercontroller that manages player input.
var config class<PlayerInput>       InputClass;     // class of my PlayerInput
#if IG_TRIBES3 // dbeswick: needed access to other player's adminmanagers from the Admin class
var transient AdminBase	AdminManager;
#else
var private transient AdminBase		AdminManager;
#endif
var const vector FailedPathStart;

var Security PlayerSecurity;	// Used for Cheat Protection
var float ForcePrecacheTime;

#if IG_TRIBES3	// michaelj:  Integrated UT2004 admin login
var float LoginDelay;
var float NextLoginTime;
#endif

var float LastPingUpdate;
var float ExactPing;
var float OldPing;
var float SpectateSpeed;
var globalconfig float DynamicPingThreshold;
var float NextSpeedChange;
var int ClientCap;

var(ForceFeedback) globalconfig bool bEnablePickupForceFeedback;
var(ForceFeedback) globalconfig bool bEnableWeaponForceFeedback;
var(ForceFeedback) globalconfig bool bEnableDamageForceFeedback;
var(ForceFeedback) globalconfig bool bEnableGUIForceFeedback;
var(ForceFeedback) bool bForceFeedbackSupported;  // true if a device is detected

var float FOVBias;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
#if IG_TRIBES3	// michaelj:  Integrated UT2004 admin login
		LoginDelay,
#endif
        GameReplicationInfo;
	unreliable if ( bNetOwner && Role==ROLE_Authority && (ViewTarget != Pawn) && (Pawn(ViewTarget) != None) )
		TargetViewRotation, TargetEyeHeight, TargetWeaponViewOffset;

	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientSetHUD,ClientReliablePlaySound, FOV, StartZoom, 
		ToggleZoom, StopZoom, EndZoom, ClientSetMusic, ClientRestart,
		ClientAdjustGlow, 
		ClientSetBehindView, ClientSetFixedCamera, ClearProgressMessages, 
        ProgressCommand, SetProgressMessage, SetProgressTime,
#if IG_TRIBES3 // david: replication of GivePawn not required
		ClientGotoState,
#else
		GivePawn, ClientGotoState,
#endif
		ClientChangeVoiceChatter,
		ClientLeaveVoiceChat,
		ClientValidate,
        ClientSetViewTarget, ClientCapBandwidth,
		ClientOpenMenu, ClientCloseMenu,
		AdminReply;

	reliable if ( (Role == ROLE_Authority) && (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc)) )
		ClientMessage, TeamMessage, ReceiveLocalizedMessage;
	unreliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientPlaySound,PlayAnnouncement;
	reliable if( Role==ROLE_Authority && !bDemoRecording )
        ClientStopForceFeedback, ClientTravel;
	unreliable if( Role==ROLE_Authority )
        SetFOVAngle, ClientShake, ClientFlash,  
		ClientAdjustPosition, ShortClientAdjustPosition, VeryShortClientAdjustPosition, LongClientAdjustPosition;
	unreliable if( (!bDemoRecording || bClientDemoRecording && bClientDemoNetFunc) && Role==ROLE_Authority )
		ClientHearSound;
    reliable if( bClientDemoRecording && ROLE==ROLE_Authority )
		DemoClientSetHUD;

	// Functions client can call.
	unreliable if( Role<ROLE_Authority )
        ServerUpdatePing, ShortServerMove, ServerMove, 
		RocketServerMove, Say, TeamSay, ServerSetHandedness, 
		ServerViewNextPlayer, ServerViewSelf,ServerUse, ServerDrive, ServerToggleBehindView;
	reliable if( Role<ROLE_Authority )
        Speech, Pause, SetPause,Mutate,
		PrevItem, ActivateItem, ServerReStartGame, AskForPawn,
		ChangeName, ChangeTeam, Suicide,
        ServerThrowWeapon, BehindView, Typing,
		ServerChangeVoiceChatter,
		ServerGetVoiceChatters,
		ServerValidationResponse, ServerVerifyViewTarget, ServerSpectateSpeed, ServerSetClientDemo;
#if IG_UDN_UTRACE_DEBUGGING // ckline: UDN UTrace code
 	reliable if( Role<ROLE_Authority )
		ServerUTrace;
#endif

#if IG_TRIBES3_ADMIN
	// Server Admin replicated functions
	reliable if( Role<ROLE_Authority )
		Admin, AdminCommand, ServerAdminLogin, AdminPromote, AdminLogout;
#endif
}

native final function SetNetSpeed(int NewSpeed);
native final function string GetPlayerNetworkAddress();
native final function string GetServerNetworkAddress();
native function string ConsoleCommand( string Command );
native final function LevelInfo GetEntryLevel();
native(544) final function ResetKeyboard();
native final function SetViewTarget(Actor NewViewTarget);
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
#if !IG_TRIBES3_ADMIN	// glenn: old update url method replaced by xadmin version in actor
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
#endif
native final function string GetDefaultURL(string Option);
#if IG_TRIBES3	// michaelj:  UT2004 integrate for IRC client
native final function string GetURLProtocol();
#endif
// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
native function CopyToClipboard( string Text );
native function string PasteFromClipboard();

// Validation.
private native event ClientValidate(string C);
private native event ServerValidationResponse(string R);

/* FindStairRotation()
returns an integer to use as a pitch to orient player view along current ground (flat, up, or down)
*/
// IGA <<< Remove AI code from controller native(524) final function int FindStairRotation(float DeltaTime);

native event INT ClientHearSound ( 
	actor Actor, 
#if !IG_EFFECTS
	int Id, 
#endif
	sound S, 
	vector SoundLocation, 
	vector Parameters,
#if IG_EFFECTS
    float InnerRadius,
    int Flags,
    FLOAT FadeInTime,
#endif
	bool Attenuate
);

#if IG_SHARED
event PreBeginPlay()
{
    Super.PreBeginPlay();

    //MCJ @ IGB
    // The following line forces LevelInfo to set its LocalPlayer variable
    // now. Native code uses it without calling the accessor, so we have to force
    // it to be set here before the native code uses it.
    Level.GetLocalPlayerController();
	assert( Level.NetMode == NM_DedicatedServer || Level.GetLocalPlayerController() != None );
}
#endif

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SpawnDefaultHUD();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);

	DesiredFOV = DefaultFOV;
	SetViewTarget(self);  // MUST have a view target!
#if !IG_TRIBES3 // david: enable cheats for debugging
	if ( Level.NetMode == NM_Standalone )
#endif
		AddCheats();
    
#if !IG_SHARED	// rowan: this was essentially an epic hack.. we handle this better now by explicitly precaching actors on the client
	//bForcePrecache = (Role < ROLE_Authority);
 //   ForcePrecacheTime = Level.TimeSeconds + 2;
#endif

#if IG_TRIBES3	// michaelj:  Added ability to inform GUI of gameplay messages
	registerMessage(class'MessageLoadProgress', "All");
#endif

#if IG_SHARED // dbeswick: support for cinematic fade action
	bManualFogUpdate = false;
#endif
}

#if IG_TRIBES3 // Ryan: Save game notification
event GameSaved();
#endif

#if IG_TRIBES3	// michaelj:  Added ability to inform GUI of gameplay messages
function onMessage(Message msg)
{
	// forward the message to the GUIController
	Player.GUIController.onGameplayMessage(msg);
}
#endif

#if IG_TRIBES3
//
// Paul:  Added ability for PlayerController to check whether another actor is friendly
// this is implemented properly in PlayerCharacter controller, but needs a base 
// implementation here so it can be called from engine
//
function bool IsFriendly(Actor Other)
{
	return true;
}

//
// Paul:  Added ability for PlayerController to check whether another PRI is friendly
// this is implemented properly in PlayerCharacter controller, but needs a base 
// implementation here so it can be called from engine. The reason we cannot use the
// above IsFriendly implementation is because we absolute team equality. The above function
// considers None teams to be friendly, which is not correct when braodcasting chat (which
// is shy this function is required).
//
function bool IsFriendlyPRI(PlayerReplicationInfo OtherPRI)
{
	return true;
}

//
// Paul: Hook to set cinematic mode, needed in Base PlayerController
//  in order to access it from scripting package.
//
function SetCinematicMode(bool bCinematic);

//
// Paul: Hook to add a subtitle, along with the length of time it should
// display for.
//
event ShowSubtitle(String Subtitle, float lifetime);

native final function bool CheckCullDistance(vector Location, float CullDistance);
#endif

exec function SetSpectateSpeed(Float F)
{
	SpectateSpeed = F;
	ServerSpectateSpeed(F);
}

function ServerSpectateSpeed(Float F)
{
	SpectateSpeed = F;
}

function ServerGivePawn()
{
	GivePawn(Pawn);
}

function ClientCapBandwidth(int Cap)
{
	ClientCap = Cap;
	if ( (Player != None) && (Player.CurrentNetSpeed > Cap) )
		SetNetSpeed(Cap);
}
		
function PendingStasis()
{
	bStasis = true;
	Pawn = None;
	GotoState('Scripting');
}

function AddCheats()
{
	// Assuming that this never gets called for NM_Client
	if ( CheatManager == None && (Level.NetMode == NM_Standalone) )
		CheatManager = new(self) CheatClass();
}

#if !IG_TRIBES3	// rowan: don't need this
function HandlePickup(Pickup pick)
{
	ReceiveLocalizedMessage(pick.MessageClass,,,,pick.class);
}
#endif

event ClientSetViewTarget( Actor a )
{
	if ( A == None )
		ServerVerifyViewTarget();
    SetViewTarget( a );
}

function ServerVerifyViewTarget()
{
	if ( ViewTarget == self )
		return;

	ClientSetViewTarget(ViewTarget);
}

/* SpawnDefaultHUD()
Spawn a HUD (make sure that PlayerController always has valid HUD, even if \
ClientSetHUD() hasn't been called\
*/
function SpawnDefaultHUD()
{
	myHUD = spawn(class'HUD',self);
}
	
/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    PawnDied(Pawn);
	Super.Reset();
	SetViewTarget(self);
#if !IG_TRIBES3 // david: no need, do it in state
	bBehindView = false;
#endif
	WaitDelay = Level.TimeSeconds + 2;
    FixFOV();
    if ( !PlayerReplicationInfo.bOnlySpectator )
		GotoState('PlayerWaiting');
}

function CleanOutSavedMoves()
{
    local SavedMove Next;
	
	// clean out saved moves
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
	if ( PendingMove != None )
	{
		PendingMove.Destroy();
		PendingMove = None;
	}
}

/* InitInputSystem()
Spawn the appropriate class of PlayerInput
Only called for playercontrollers that belong to local players
*/
event InitInputSystem()
{
	PlayerInput = new(self) InputClass();
}

/* ClientGotoState()
server uses this to force client into NewState
*/
#if IG_TRIBES3 // david: NewLabel is optional
function ClientGotoState(name NewState, optional name NewLabel)
{
	if (NewLabel != '')
		GotoState(NewState,NewLabel);
	else
		GotoState(NewState);
}
#else
function ClientGotoState(name NewState, name NewLabel)
{
	GotoState(NewState,NewLabel);
}
#endif

function AskForPawn()
{
	if ( IsInState('GameEnded') )
		ClientGotoState('GameEnded', 'Begin');
	else if ( Pawn != None )
		GivePawn(Pawn);
	else
	{
		bFrozen = false;
		ServerRestartPlayer();
	}		
}	

function GivePawn(Pawn NewPawn)
{
	if ( NewPawn == None )
		return;
	Pawn = NewPawn;
	NewPawn.Controller = self;
#if IG_TRIBES3 // Alex:
	ClientRestart(NewPawn, GetStateName());
#else
	ClientRestart();
#endif
}	

/* GetFacingDirection()
returns direction faced relative to movement dir
0 = forward
16384 = right
32768 = back
49152 = left
*/
function int GetFacingDirection()
{
	local vector X,Y,Z, Dir;

	GetAxes(Pawn.Rotation, X,Y,Z);
	Dir = Normal(Pawn.Acceleration);
	if ( Y Dot Dir > 0 )
		return ( 49152 + 16384 * (X Dot Dir) );
	else
		return ( 16384 - 16384 * (X Dot Dir) );
}

// Possess a pawn
function Possess(Pawn aPawn)
{
    if ( PlayerReplicationInfo.bOnlySpectator )
		return;

	SetRotation(aPawn.Rotation);
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	Pawn.bStasis = false;
    CleanOutSavedMoves();  // don't replay moves previous to possession
#if ! IG_TRIBES3 // Paul: Don't set PRI.bIsFemale in tribes
	PlayerReplicationInfo.bIsFemale = Pawn.bIsFemale;
#endif
	ServerSetHandedness(Handedness);
	Restart();
}

// unpossessed a pawn (not because pawn was killed)
function UnPossess()
{
	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
		CleanOutSavedMoves();  // don't replay moves previous to unpossession
		if ( Viewtarget == Pawn )
			SetViewTarget(self);
	}
	Pawn = None;
	GotoState('Spectating');
}

#if !IG_TRIBES3 // dbeswick:
function ViewNextBot()
{
	if ( CheatManager != None )
		CheatManager.ViewBot();
}
#endif

// unpossessed a pawn (because pawn was killed)
function PawnDied(Pawn P)
{
	if ( P != Pawn )
		return;
	EndZoom();
	if ( Pawn != None )
		Pawn.RemoteRole = ROLE_SimulatedProxy;
	if ( ViewTarget == Pawn )
		bBehindView = true;

    Super.PawnDied(P);
}

#if IG_TRIBES3 // david: dont use scoreboard
function ClientSetHUD(class<HUD> newHUDType, optional class<Scoreboard> newScoringType)
#else
function ClientSetHUD(class<HUD> newHUDType, class<Scoreboard> newScoringType)
#endif
{
	local HUD NewHUD;

	if ( (myHUD == None) || ((newHUDType != None) && (newHUDType != myHUD.Class)) )
	{
		NewHUD = spawn(newHUDType, self); 
		if ( NewHUD != None )
		{
			if ( myHUD != None )
				myHUD.Destroy();
			myHUD = NewHUD;
		}
	}
#if !IG_TRIBES3	// david: dont use scoreboard
	if ( (myHUD != None) && (newScoringType != None) )
		MyHUD.SpawnScoreBoard(newScoringType);
#endif
}

// jdf ---
// Server ignores this call, client plays effect
simulated function ClientPlayForceFeedback( String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
        PlayFeedbackEffect( EffectName );
}

simulated function StopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
    {
		if (EffectName != "")
			StopFeedbackEffect( EffectName );
		else
			StopFeedbackEffect();
	}
}

function ClientStopForceFeedback( optional String EffectName )
{
    if (bForceFeedbackSupported && Viewport(Player) != None)
    {
		if (EffectName != "")
			StopFeedbackEffect( EffectName );
		else
			StopFeedbackEffect();
	}
}
// --- jdf

final function float UpdateFlashComponent(float Current, float Step, float goal)
{
	if ( goal > Current )
		return FMin(Current + Step, goal);
	else
		return FMax(Current - Step, goal);
}

function ViewFlash(float DeltaTime)
{
    local vector goalFog;
    local float goalscale, delta, Step;

#if IG_MOJO
	if (Level.bIsMojoPlaying)
	{
		return;
	}
#endif

#if IG_SHARED // dbeswick: support for cinematic fade action
	if (bManualFogUpdate)
		return;
#endif

    delta = FMin(0.1, DeltaTime);
    goalScale = 1; // + ConstantGlowScale;
    goalFog = vect(0,0,0); // ConstantGlowFog;

    if ( Pawn != None )
    {
        goalScale += Pawn.HeadVolume.ViewFlash.X; 
        goalFog += Pawn.HeadVolume.ViewFog;
    }
	Step = 0.6 * delta;
	FlashScale.X = UpdateFlashComponent(FlashScale.X,step,goalScale);
    FlashScale = FlashScale.X * vect(1,1,1);

	FlashFog.X = UpdateFlashComponent(FlashFog.X,step,goalFog.X);
	FlashFog.Y = UpdateFlashComponent(FlashFog.Y,step,goalFog.Y);
	FlashFog.Z = UpdateFlashComponent(FlashFog.Z,step,goalFog.Z);
}

#if IG_TRIBES3 // david: more flexibility in LocalMessage system, uses Objects instead of PlayerReplicationInfos

simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Object OptionalObject, optional String OptionalString )
{
	Message.Static.ClientReceive( Self, Switch, Related1, Related2, OptionalObject, OptionalString );
	if ( Message.default.bIsConsoleMessage && (Player != None) && (Player.Console != None) )
		Player.Console.Message(Message.Static.GetString(Switch, Related1, Related2, OptionalObject, OptionalString),0 );
}

#else
simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	if ( Message.default.bIsConsoleMessage && (Player != None) && (Player.Console != None) )
		Player.Console.Message(Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),0 );
}
#endif

event ClientMessage( coerce string S, optional Name Type )
{
	if (Type == '')
		Type = 'Event';

	TeamMessage(PlayerReplicationInfo, S, Type);
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
	if ( myHUD != None )
	myHUD.Message( PRI, S, Type );

    if ( ((Type == 'Say') || (Type == 'TeamSay')) && (PRI != None) )
		S = PRI.PlayerName$": "$S;

    Player.Console.Message( S, 6.0 );
}

simulated function PlayBeepSound();

simulated function PlayAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{	
	local float Atten;
	
	if ( AnnouncementLevel > AnnouncerLevel )
		return;
	if ( !bForce && (Level.TimeSeconds - LastPlaySound < 1) )
		return;
	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	LastPlaySpeech = Level.TimeSeconds;	// don't want chatter to overlap announcements
	
	Atten = FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
#if IG_EFFECTS
    ClientPlaySound(ASound,true,Atten);
#else
	ClientPlaySound(ASound,true,Atten,SLOT_Talk);
#endif
}

/*function bool AllowVoiceMessage(name MessageType)
{
	if ( Level.NetMode == NM_Standalone )
		return true;
		
	if ( Level.TimeSeconds - OldMessageTime < 3 )
	{
		if ( (MessageType == 'TAUNT') || (MessageType == 'AUTOTAUNT') )
			return false;
		if ( Level.TimeSeconds - OldMessageTime < 1 )
			return false;
	}
	if ( Level.TimeSeconds - OldMessageTime < 6 )
		OldMessageTime = Level.TimeSeconds + 3;
	else
		OldMessageTime = Level.TimeSeconds;
	return true;
}*/
	
//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional bool bVolumeControl, optional float inAtten
#if !IG_EFFECTS
                                   , optional ESoundSlot slot 
#endif
                                   )
{
    local float atten;

    atten = 0.9;
    if( bVolumeControl )
        atten = FClamp(inAtten,0,1);

	if ( ViewTarget != None )
#if IG_EFFECTS
		ViewTarget.PlaySound(ASound, atten,,,,,,,false);
#else
		ViewTarget.PlaySound(ASound, slot, atten,,,,false);
#endif
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bVolumeControl )
{
	ClientPlaySound(ASound, bVolumeControl);
}


#if IG_SHARED // carlos: move first actor tick until after precaching
simulated event OnFinishedPrecaching()
{
}
#endif

simulated event Destroyed()
{
	local SavedMove Next;
 //   local KVehicle DrivenVehicle;
 //   local SVehicle DrivenSVehicle;
 //   local HavokVehicle DrivenHVehicle;
	//local Pawn Driver;

	// cheatmanager, adminmanager, and playerinput cleaned up in C++ PostScriptDestroyed()

	if (AdminManager != None)
		AdminManager.DoLogout();

    StopFeedbackEffect();
 
	//if ( Pawn != None )
	//{
	//	// If its a vehicle, just destroy the driver, otherwise do the normal.
	//	DrivenVehicle = KVehicle(Pawn);
	//	if(DrivenVehicle != None)
	//	{	
	//		Driver = DrivenVehicle.Driver;
	//		DrivenVehicle.KDriverLeave(true); // Force the driver out of the car
	//		Driver.Destroy();
	//	}
	//	else
	//	{
	//		DrivenHVehicle = HavokVehicle(Pawn);
	//		if(DrivenHVehicle != None)
	//		{	
	//			Driver = DrivenHVehicle.Driver;
	//			DrivenHVehicle.DriverLeave(true); // Force the driver out of the car
	//			Driver.Destroy();
	//		}
	//		else
	//		{
	//			DrivenSVehicle = SVehicle(Pawn);
	//			if(DrivenSVehicle != None)
	//			{	
	//				Driver = DrivenSVehicle.Driver;
	//				DrivenSVehicle.KDriverLeave(true); // Force the driver out of the car
	//				Driver.Destroy();
	//			}
	//			else
	//			{

	//				Pawn.Health = 0;
	//				Pawn.Died( self, class'Suicided', Pawn.Location );
	//			}
	//		}
	//	}
	//}
	myHud.Destroy();

	while ( FreeMoves != None )
	{
		Next = FreeMoves.NextMove;
		FreeMoves.Destroy();
		FreeMoves = Next;
	}
	while ( SavedMoves != None )
	{
		Next = SavedMoves.NextMove;
		SavedMoves.Destroy();
		SavedMoves = Next;
	}
    
    if( PlayerSecurity != None )
    {
        PlayerSecurity.Destroy();
        PlayerSecurity = None;
    }

    Super.Destroyed();
}

function ClientSetMusic( string NewSong, EMusicTransition NewTransition )
{
	StopAllMusic( 0.0 );
	PlayMusic( NewSong, 3.0 );
	Song        = NewSong;
	Transition  = NewTransition;
}
	
// ------------------------------------------------------------------------
// Zooming/FOV change functions

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}
	
function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
}

function FixFOV()
{
	FovAngle = Default.DefaultFOV;
	DesiredFOV = Default.DefaultFOV;
	DefaultFOV = Default.DefaultFOV;
}

function SetFOV(float NewFOV)
{
	DesiredFOV = NewFOV;
	FovAngle = NewFOV;
}

function ResetFOV()
{
	DesiredFOV = DefaultFOV;
	FovAngle = DefaultFOV;
}

exec function FOV(float F)
{
	if( (F >= 80.0) || (Level.NetMode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
		SaveConfig();
	}
}


exec function Mutate(string MutateString)
{
	if( Level.NetMode == NM_Client )
		return;
	Level.Game.BaseMutator.Mutate(MutateString, Self);
}

exec function SetSensitivity(float F)
{
	PlayerInput.UpdateSensitivity(F);
}

exec function SetMouseSmoothing( int Mode )
{
    PlayerInput.UpdateSmoothing( Mode );
}

exec function SetMouseAccel(float F)
{
	PlayerInput.UpdateAccel(F);
}

exec function ForceReload()
{
/*
	if ( (Pawn != None) && (Pawn.Weapon != None) )
	{
		Pawn.Weapon.ForceReload();
	}
*/
}

// ------------------------------------------------------------------------
// Messaging functions


// Send a message to all players.
exec function Say( string Msg )
{
	local controller C;

	// center print admin messages which start with #
	if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
	{
		Msg = right(Msg,len(Msg)-1);
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.IsA('PlayerController') )
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(6);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
			}
		return;
	}
	Level.Game.Broadcast(self, Msg, 'Say');
}

exec function TeamSay( string Msg )
{
#if !IG_TRIBES3	// Paul: Removed this check, as we don't use the bTeamGame flag
	if( !GameReplicationInfo.bTeamGame )
	{
		Say( Msg );
		return;
	}
#endif // IG_TRIBES3

    Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( Level.Game.BaseMutator , self, Msg ) , 'TeamSay');
}

// ------------------------------------------------------------------------

function ServerSetHandedness( float hand)
{
	Handedness = hand;
  //  if ( (Pawn != None) && (Pawn.Weapon != None) )
//		Pawn.Weapon.SetHand(Handedness);
}

function SetHand(int IntValue)
{
    class'PlayerController'.default.Handedness = IntValue;
    class'PlayerController'.static.StaticSaveConfig();
    Handedness = IntValue;
//    if( (Pawn != None) && (Pawn.Weapon != None) )
//	Pawn.Weapon.SetHand(Handedness);
     
//	ServerSetHandedness(Handedness);
}

exec function SetWeaponHand ( string S )
{
	if ( S ~= "Left" )
		Handedness = -1;
	else if ( S~= "Right" )
		Handedness = 1;
	else if ( S ~= "Center" )
		Handedness = 0;
	else if ( S ~= "Hidden" )
		Handedness = 2;
    SetHand(Handedness);
}

function bool IsDead()
{
	return false;
}

exec function ShowGun ()
{
    if( Handedness == 2 )
        Handedness = 1;
    else
        Handedness = 2;

    SetHand(Handedness);
}

event PreClientTravel()
{
    log("PreClientTravel");
    ClientStopForceFeedback();  // jdf
}

function ClientSetFixedCamera(bool B)
{
	bFixedCamera = B;
}

function ClientSetBehindView(bool B, optional bool bInteractive)
{
	bBehindView = B;
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( (Sender == None) || (Sender.voicetype == None) || (Player.Console == None) )
		return;
		
	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

/* ForceDeathUpdate()
Make sure ClientAdjustPosition immediately informs client of pawn's death
*/
function ForceDeathUpdate()
{
	LastUpdateTime = Level.TimeSeconds - 10;
}

/* RocketServerMove()
compressed version of server move for PlayerRocketing state
*/
function RocketServerMove
(
	float TimeStamp, 
	vector InAccel, 
	vector ClientLoc,
	byte ClientRoll, 
	int View
)
{
	ServerMove(TimeStamp,InAccel,ClientLoc,false,false,false,false, DCLICK_NONE,ClientRoll,View,false);
}	

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function ShortServerMove
(
	float TimeStamp, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus, 
	byte ClientRoll, 
	int View,
	bool NewbJetpack
)
{
    ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,false,DCLICK_None,ClientRoll,View,NewbJetpack);
}

/* ServerMove() 
- replicated function sent by client to server - contains client movement and firing info
Passes acceleration in components so it doesn't get rounded.
*/
function ServerMove
(
	float TimeStamp, 
	vector InAccel, 
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus, 
    bool NewbDoubleJump,
	EDoubleClickDir DoubleClickMove, 
	byte ClientRoll, 
	int View,
	bool NewbJetpack,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot, ViewRot;
	local vector Accel, LocDiff, ClientVel, ClientFloor;
	local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump, OldbRun, OldbDoubleJump;
	local EDoubleClickDir OldDoubleClickMove;
	local actor ClientBase;
	local EPhysics ClientPhysics;


	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	bShortConnectTimeOut = true;

	// if OldTimeDelta corresponds to a lost packet, process it first
	if (  OldTimeDelta != 0 )
	{
		OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
		if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
		{
			// split out components of lost move (approx)
			Accel.X = OldAccel >>> 23;
			if ( Accel.X > 127 )
				Accel.X = -1 * (Accel.X - 128);
			Accel.Y = (OldAccel >>> 15) & 255;
			if ( Accel.Y > 127 )
				Accel.Y = -1 * (Accel.Y - 128);
			Accel.Z = (OldAccel >>> 7) & 255;
			if ( Accel.Z > 127 )
				Accel.Z = -1 * (Accel.Z - 128);
			Accel *= 20;
			
			OldbRun = ( (OldAccel & 64) != 0 );
            OldbDoubleJump = ( (OldAccel & 32) != 0 );
			NewbPressedJump = ( (OldAccel & 16) != 0 );
			if ( NewbPressedJump )
				bJumpStatus = NewbJumpStatus;
			switch (OldAccel & 7)
			{
				case 0:
					OldDoubleClickMove = DCLICK_None;
					break;
				case 1:
					OldDoubleClickMove = DCLICK_Left;
					break;
				case 2:
					OldDoubleClickMove = DCLICK_Right;
					break;
				case 3:
					OldDoubleClickMove = DCLICK_Forward;
					break;
				case 4:
					OldDoubleClickMove = DCLICK_Back;
					break;
			}
			//log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
            OldTimeStamp = FMin(OldTimeStamp, CurrentTimeStamp + MaxResponseTime);
            MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, (bDuck == 1), NewbPressedJump, OldbDoubleJump, (bJetpack == 1), OldDoubleClickMove, Accel, rot(0,0,0));
			CurrentTimeStamp = OldTimeStamp;
		}
	}		

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	// Save move parameters.
    DeltaTime = FMin(MaxResponseTime,TimeStamp - CurrentTimeStamp);

	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
        TimeMargin = FMax(0,TimeMargin + DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp));
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	ViewRot.Pitch = ViewPitch;
	ViewRot.Yaw = ViewYaw;
	ViewRot.Roll = 0;
	SetRotation(ViewRot);

	if ( Pawn != None )
	{
		Rot.Roll = 256 * ClientRoll;
		Rot.Yaw = ViewYaw;
		if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
			maxPitch = 2;
		else
            maxPitch = 0;
		If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
		{
			If (ViewPitch < 32768) 
				Rot.Pitch = maxPitch * RotationRate.Pitch;
			else
				Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
		}
		else
			Rot.Pitch = ViewPitch;
		DeltaRot = (Rotation - Rot);
		Pawn.SetRotation(Rot);
	}

    // Perform actual movement
	if ( (Level.Pauser == None) && (DeltaTime > 0) )
        MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, NewbJetpack, DoubleClickMove, Accel, DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		if ( Pawn == None )
			LocDiff = Location - ClientLoc;
		else
			LocDiff = Pawn.Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Pawn == None )
		{
			ClientPhysics = Physics;
			ClientLoc = Location;
			ClientVel = Velocity;
		}
		else
		{
			ClientPhysics = Pawn.Physics;
			ClientVel = Pawn.Velocity;
			ClientBase = Pawn.Base;
			if ( Mover(Pawn.Base) != None )
				ClientLoc = Pawn.Location - Pawn.Base.Location;
			else
				ClientLoc = Pawn.Location;
			ClientFloor = Pawn.Floor;
		}
		//	log(Level.TimeSeconds$" Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
		LastUpdateTime = Level.TimeSeconds;

		if ( (Pawn == None) || (Pawn.Physics != PHYS_Spider) )
		{
			if ( ClientVel == vect(0,0,0) )
			{
					ShortClientAdjustPosition
					(
						TimeStamp, 
						GetStateName(), 
						ClientPhysics, 
						ClientLoc.X, 
						ClientLoc.Y, 
						ClientLoc.Z, 
						ClientBase
					);
			}
			else
				ClientAdjustPosition
				(
					TimeStamp, 
					GetStateName(), 
					ClientPhysics, 
					ClientLoc.X, 
					ClientLoc.Y, 
					ClientLoc.Z, 
					ClientVel.X, 
					ClientVel.Y, 
					ClientVel.Z,
					ClientBase
				);
		}
		else
			LongClientAdjustPosition
			(
				TimeStamp, 
				GetStateName(), 
				ClientPhysics, 
				ClientLoc.X, 
				ClientLoc.Y, 
				ClientLoc.Z, 
				ClientVel.X, 
				ClientVel.Y, 
				ClientVel.Z,
				ClientBase,
				ClientFloor.X,
				ClientFloor.Y,
				ClientFloor.Z
			);
	}
	//log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}	

// Only executed on server
function ServerDrive(float InForward, float InStrafe, float InUp, bool InJump)
{
	ProcessDrive(InForward, InStrafe, InUp, InJump);
}

function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
{
	Log("ProcessDrive Not Valid Outside State PlayerDriving");
}

function ProcessMove ( float DeltaTime, vector newAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)
{
	if ( Pawn != None )
		Pawn.Acceleration = newAccel;
}

final function MoveAutonomous
(	
	float DeltaTime, 	
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump, 
    bool NewbDoubleJump,
	bool NewbJetpack,
	EDoubleClickDir DoubleClickMove, 
	vector newAccel, 
	rotator DeltaRot
)
{
	if ( NewbJetpack )
		bJetpack = 1;
	else
		bJetpack = 0;

	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	bPressedJump = NewbPressedJump;
    bDoubleJump = NewbDoubleJump;
	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DoubleClickMove, DeltaRot);
	if ( Pawn != None )	
		Pawn.AutonomousPhysics(DeltaTime);
	else
		AutonomousPhysics(DeltaTime);
    bDoubleJump = false;
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

/* VeryShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed, and pawn is walking
*/
function VeryShortClientAdjustPosition
(
	float TimeStamp, 
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,'PlayerWalking',PHYS_Walking,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ShortClientAdjustPosition
bandwidth saving version, when velocity is zeroed
*/
function ShortClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,0,0,0,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* ClientAdjustPosition
- pass newloc and newvel in components so they don't get rounded
*/
function ClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase
)
{
	local vector Floor;

	if ( Pawn != None )
		Floor = Pawn.Floor;
	LongClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase,Floor.X,Floor.Y,Floor.Z);
}

/* LongClientAdjustPosition 
long version, when care about pawn's floor normal
*/
function LongClientAdjustPosition
(
	float TimeStamp, 
	name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase,
	float NewFloorX,
	float NewFloorY,
	float NewFloorZ
)
{
    local vector NewLocation, NewVelocity, NewFloor;
	local Actor MoveActor;
    local SavedMove CurrentMove;
 
	// update ping
	if ( (PlayerReplicationInfo != None) && !bDemoOwner )
	{
		if ( ExactPing < 0.006 )
			ExactPing = Level.TimeSeconds - TimeStamp;
		else
			ExactPing = 0.99 * ExactPing + 0.008 * (Level.TimeSeconds - TimeStamp); // placebo effect
		PlayerReplicationInfo.Ping = 1000 * ExactPing;

		if ( Level.TimeSeconds - LastPingUpdate > 4 )
		{
			if ( bDynamicNetSpeed && (OldPing > DynamicPingThreshold * 0.001) && (ExactPing > DynamicPingThreshold * 0.001) )
			{
				if ( Player.CurrentNetSpeed > 5000 )
					SetNetSpeed(5000);
				else if ( Level.MoveRepSize < 80 )
					Level.MoveRepSize += 8;
				else if ( Player.CurrentNetSpeed > 4000 )
					SetNetSpeed(4000);
				OldPing = 0;
			}
			else
				OldPing = ExactPing;
			LastPingUpdate = Level.TimeSeconds;
			ServerUpdatePing(1000 * ExactPing);
		}
	}
	if ( Pawn != None )
	{
		if ( Pawn.bTearOff )
		{
			Pawn = None;
			if ( !IsInState('GameEnded') && !IsInState('Dead') )
			{
			GotoState('Dead');
            }
			return;
		}
		MoveActor = Pawn;
        if ( (ViewTarget != Pawn)
			&& ((ViewTarget == self) || ((Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Health <= 0))) )
		{
			bBehindView = false;
			SetViewTarget(Pawn);
		}
	}
	else 
    {
		MoveActor = self;
 	   	if( GetStateName() != newstate )
		{
		    if ( NewState == 'GameEnded' )
			    GotoState(NewState);
			else if ( IsInState('Dead') )
			{
		    	if ( (NewState != 'PlayerWalking') && (NewState != 'PlayerSwimming') )
		        {
				    GotoState(NewState);
		        }
		        return;
			}
			else if ( NewState == 'Dead' )
				GotoState(NewState);
		}
	}
    if ( CurrentTimeStamp >= TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
    NewVelocity.X = NewVelX;
    NewVelocity.Y = NewVelY;
    NewVelocity.Z = NewVelZ;

	// skip update if no error
    CurrentMove = SavedMoves;
    while ( CurrentMove != None )
    {
        if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
			if ( CurrentMove.TimeStamp == CurrentTimeStamp )
			{ 
				FreeMoves.Clear();
				if ( (VSize(CurrentMove.SavedLocation - NewLocation) < 3)
					&& (VSize(CurrentMove.SavedVelocity - NewVelocity) < 3)
					&& (GetStateName() == NewState)
					&& ((MoveActor.Physics != PHYS_Flying) || !IsInState('PlayerWalking')) )
				{
					return;
				}
				CurrentMove = None;
			}
			else
			{
				FreeMoves.Clear();
				CurrentMove = SavedMoves;
			}
        }
        else
			CurrentMove = None;
    }

	NewFloor.X = NewFloorX;
	NewFloor.Y = NewFloorY;
	NewFloor.Z = NewFloorZ;
	MoveActor.SetBase(NewBase, NewFloor);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	if ( !bDemoOwner )
	{
	    //log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$MoveActor.Location);
	    MoveActor.bCanTeleport = false;
        if ( !MoveActor.SetLocation(NewLocation) && (Pawn(MoveActor) != None)
		    && (MoveActor.CollisionHeight > Pawn(MoveActor).CrouchHeight)
		    && !Pawn(MoveActor).bIsCrouched
		    && (newPhysics == PHYS_Walking)
		    && (MoveActor.Physics != PHYS_Havok) && (MoveActor.Physics != PHYS_HavokSkeletal) )
	    {
		    MoveActor.SetPhysics(newPhysics);
		    Pawn(MoveActor).ForceCrouch();
	    MoveActor.SetLocation(NewLocation);
	    }
	    MoveActor.bCanTeleport = true;
	}
	// Hack. Don't let network change physics mode of karma stuff on the client.
	if( MoveActor.Physics != PHYS_Havok && MoveActor.Physics != PHYS_HavokSkeletal &&
		newPhysics != PHYS_Havok && newPhysics != PHYS_HavokSkeletal)
	{
		MoveActor.SetPhysics(newPhysics);
	}

    MoveActor.Velocity = NewVelocity;

	if( GetStateName() != newstate )
		GotoState(newstate);

	bUpdatePosition = true;
}

function ServerUpdatePing(int NewPing)
{
	PlayerReplicationInfo.Ping = NewPing;
	PlayerReplicationInfo.bReceivedPing = true;
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck, realbJetpack;
	local bool bRealJump;

	// Dont do any network position updates on things running PHYS_Havok
	if( Pawn != None && (Pawn.Physics == PHYS_Havok || Pawn.Physics == PHYS_HavokSkeletal ))
		return;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	realbJetpack = bJetpack;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
 #if IG_TRIBES3	//mrfish
           if ( (Pawn != None) && (Pawn.Physics != CurrentMove.SavedPhysics) && (CurrentMove.SavedPhysics != PHYS_None))
			{
 				Pawn.SetPhysics(CurrentMove.SavedPhysics);
			}
            MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.bDoubleJump, CurrentMove.bJetpack, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
#else
            MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.bDoubleJump, CurrentMove.DoubleClickMove, CurrentMove.Acceleration, rot(0,0,0));
#endif
			CurrentMove = CurrentMove.NextMove;
		}
	}
    if ( PendingMove != None )
    {
#if IG_TRIBES3	//mrfish
        if ( (Pawn != None) && (Pawn.Physics != PendingMove.SavedPhysics) && (PendingMove.SavedPhysics != PHYS_None))
		{
			Pawn.SetPhysics(PendingMove.SavedPhysics);
		}
        MoveAutonomous(PendingMove.Delta, PendingMove.bRun, PendingMove.bDuck, PendingMove.bPressedJump, PendingMove.bDoubleJump, PendingMove.bJetpack, PendingMove.DoubleClickMove, PendingMove.Acceleration, rot(0,0,0));
#else
        MoveAutonomous(PendingMove.Delta, PendingMove.bRun, PendingMove.bDuck, PendingMove.bPressedJump, PendingMove.bDoubleJump, PendingMove.DoubleClickMove, PendingMove.Acceleration, rot(0,0,0));
#endif
    }
     
	//log("Client updated position to "$Pawn.Location);
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bJetpack = realbJetpack;
	bPressedJump = bRealJump;
}

final function SavedMove GetFreeMove()
{
	local SavedMove s, first;
	local int i;

	if ( FreeMoves == None )
	{
        // don't allow more than 100 saved moves
		For ( s=SavedMoves; s!=None; s=s.NextMove )
		{
			i++;
            if ( i > 100 )
			{
				first = SavedMoves;
				SavedMoves = SavedMoves.NextMove;
				first.Clear();
				first.NextMove = None;
				// clear out all the moves
				While ( SavedMoves != None )
				{
					s = SavedMoves;
					SavedMoves = SavedMoves.NextMove;
					s.Clear();
					s.NextMove = FreeMoves;
					FreeMoves = s;
				}
				return first;
			}
		}
		return Spawn(class'SavedMove');
	}
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}	
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(Abs(C), 127) + 128;
	return C;
}

/* 
========================================================================
Here's how player movement prediction, replication and correction works in network games:

Every tick, the PlayerTick() function is called.  It calls the PlayerMove() function (which is implemented 
in various states).  PlayerMove() figures out the acceleration and rotation, and then calls ProcessMove() 
(for single player or listen servers), or ReplicateMove() (if its a network client).

ReplicateMove() saves the move (in the PendingMove list), calls ProcessMove(), and then replicates the move 
to the server by calling the replicated function ServerMove() - passing the movement parameters, the client's 
resultant position, and a timestamp.

ServerMove() is executed on the server.  It decodes the movement parameters and causes the appropriate movement 
to occur.  It then looks at the resulting position and if enough time has passed since the last response, or the 
position error is significant enough, the server calls ClientAdjustPosition(), a replicated function.

ClientAdjustPosition() is executed on the client.  The client sets its position to the servers version of position, 
and sets the bUpdatePosition flag to true.  

When PlayerTick() is called on the client again, if bUpdatePosition is true, the client will call 
ClientUpdatePosition() before calling PlayerMove().  ClientUpdatePosition() replays all the moves in the pending 
move list which occured after the timestamp of the move the server was adjusting.
*/

//
// Replicate this client's desired movement to the server.
//
function ReplicateMove
(
	float DeltaTime, 
	vector NewAccel, 
	EDoubleClickDir DoubleClickMove, 
	rotator DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local float OldTimeDelta, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm, MoveLoc;

	// find the most recent move, and the most recent interesting move
	if ( SavedMoves != None )
	{
        LastMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
        while ( LastMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
            if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
                || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
                OldMove = LastMove;
            LastMove = LastMove.NextMove;
		}
        if ( LastMove.bPressedJump || LastMove.bDoubleJump || ((LastMove.DoubleClickMove != DCLICK_NONE) && (LastMove.DoubleClickMove < 5))
            || ((LastMove.Acceleration != NewAccel) && ((normal(LastMove.Acceleration) Dot AccelNorm) < 0.95)) )
            OldMove = LastMove;
	}
    // Get a SavedMove actor to store the movement in.
    if ( PendingMove != None )
        PendingMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);

	NewMove = GetFreeMove();
	if ( NewMove == None )
		return;
	NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
	
	// Simulate the movement locally.
    bDoubleJump = false;
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);
    
	if ( Pawn != None )
		Pawn.AutonomousPhysics(NewMove.Delta);
	else
		AutonomousPhysics(DeltaTime);

	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
    NewMove.PostUpdate(self);
    NetMoveDelta = FMax(80.0/Player.CurrentNetSpeed, 0.015);
	
    // Decide whether to hold off on move
    // send if double click move, jump, or fire unless really too soon, or if newmove.delta big enough
    if ( !Level.bCapFramerate && !PendingMove.bPressedJump && !PendingMove.bDoubleJump 
		&& ((PendingMove.DoubleClickMove == DCLICK_None) || (PendingMove.DoubleClickMove == DCLICK_Active))
		&& ((PendingMove.Acceleration == NewAccel) || ((Normal(NewAccel) Dot Normal(PendingMove.Acceleration)) > 0.95)) 
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		return;
	}
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
		// old move important to replicate redundantly
		OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel = (CompressAccel(BuildAccel.X) << 23) 
					+ (CompressAccel(BuildAccel.Y) << 15) 
					+ (CompressAccel(BuildAccel.Z) << 7);
		if ( OldMove.bRun )
			OldAccel += 64;
        if ( OldMove.bDoubleJump )
			OldAccel += 32;
		if ( OldMove.bPressedJump )
			OldAccel += 16;
		OldAccel += OldMove.DoubleClickMove;
	}

	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;

	if ( Pawn == None )
		MoveLoc = Location;
	else
		MoveLoc = Pawn.Location;

	if ( IsInState('PlayerRocketing') )
		RocketServerMove
		(
			NewMove.TimeStamp, 
			NewMove.Acceleration * 10,
			MoveLoc,
			ClientRoll, 
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2))
		);
    else if ( (NewMove.Acceleration == vect(0,0,0)) && (NewMove.DoubleClickMove == DCLICK_None) && !NewMove.bDoubleJump )
		ShortServerMove
		(
			NewMove.TimeStamp, 
			MoveLoc, 
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus, 
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
			NewMove.bJetpack
		);
	else
		ServerMove
		(
			NewMove.TimeStamp, 
			NewMove.Acceleration * 10, 
			MoveLoc, 
			NewMove.bRun,
			NewMove.bDuck,
			bJumpStatus, 
            NewMove.bDoubleJump,
			NewMove.DoubleClickMove, 
			ClientRoll,
			(32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)),
			NewMove.bJetpack,
			OldTimeDelta,
			OldAccel 
		);
}

function HandleWalking()
{
	if ( Pawn != None )
		Pawn.SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') ); 
}

function ServerRestartGame()
{
}

function SetFOVAngle(float newFOV)
{
	FovAngle = newFOV;
}
	 
function ClientFlash( float scale, vector fog )
{
    FlashScale = scale * vect(1,1,1);
    flashfog = 0.001 * fog;
}
   
function ClientAdjustGlow( float scale, vector fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * fog;
}

/* ClientShake()
Function called on client to shake view.
Only ShakeView() should call ClientShake()
*/
private function ClientShake(vector ShakeRoll, vector OffsetMag, vector ShakeRate, float OffsetTime)
{
	if ( (MaxShakeRoll < ShakeRoll.X) || (ShakeRollTime < 0.01 * ShakeRoll.Y) )
{
		MaxShakeRoll = ShakeRoll.X;
		ShakeRollTime = 0.01 * ShakeRoll.Y;	
		ShakeRollRate = 0.01 * ShakeRoll.Z;
}
	if ( VSize(OffsetMag) > VSize(MaxShakeOffset) )
	{
		ShakeOffsetTime = OffsetTime * vect(1,1,1);
		MaxShakeOffset = OffsetMag;
		ShakeOffsetRate = ShakeRate;
	}
	}

/* ShakeView()
Call this function to shake the player's view
shaketime = how long to roll view
RollMag = how far to roll view as it shakes
OffsetMag = max view offset
RollRate = how fast to roll view
OffsetRate = how fast to offset view
OffsetTime = how long to offset view (number of shakes)
*/
function ShakeView( float shaketime, float RollMag, vector OffsetMag, float RollRate, vector OffsetRate, float OffsetTime)
{
	local vector ShakeRoll;

	ShakeRoll.X = RollMag;
	ShakeRoll.Y = 100 * shaketime;
	ShakeRoll.Z = 100 * rollrate;
	ClientShake(ShakeRoll, OffsetMag, OffsetRate, OffsetTime);
}

// DLB Controller clean pass: removed AI logic 
/*function damageAttitudeTo(pawn Other, float Damage)
{
	if ( (Other != None) && (Other != Pawn) && (Damage > 0) )
		Enemy = Other;
}*/

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
 	Pawn.bIsTyping = bIsTyping;
	if ( bTyping && (Pawn != None) && !Pawn.bTearOff )
		Pawn.ChangeAnimation();

}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function Jump( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
		SetPause(False);
	else
		bPressedJump = true;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( name Type, int Index, string Callsign )
{
	if(PlayerReplicationInfo.VoiceType != None)
		PlayerReplicationInfo.VoiceType.static.PlayerSpeech( Type, Index, Callsign, Self );
}

exec function RestartLevel()
{
	if( Level.NetMode==NM_Standalone )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( Level.NetMode==NM_Standalone )
		ClientTravel( URL, TRAVEL_Relative, true );
}

// ------------------------------------------------------------------------
// Loading and saving

/* QuickSave()
Save game to slot 9
*/
exec function QuickSave()
{
#if IG_TRIBES3 // dbeswick: allow savegames to have any name
	if ( Level.Game != None && Level.Game.SaveAllowed() && !Level.bIsMojoPlaying )
	{
		ConsoleCommand("SaveGame " $ QuickSaveName);
	}
#else
	if ( (Pawn.Health > 0) 
		&& (Level.NetMode == NM_Standalone) )
	{
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 9");
	}
#endif
}

/* QuickLoad()
Load game from slot 9
*/
#if IG_TRIBES3	// rowan:
native function bool SaveGameExists(string SaveGameName);
#endif

exec function QuickLoad()
{
#if IG_TRIBES3 // dbeswick: allow savegames to have any name
	if ( Level.NetMode == NM_Standalone && !Level.bIsMojoPlaying && SaveGameExists(QuickSaveName))
		ClientTravel( "SaveGame_" $ QuickSaveName, TRAVEL_Absolute, false);
#else
	if ( Level.NetMode == NM_Standalone )
		ClientTravel( "?load=9", TRAVEL_Absolute, false);
#endif
}

/* SetPause()
 Try to pause game; returns success indicator.
 Replicated to server in network games.
 */
function bool SetPause( BOOL bPause )
{
    bFire = 0;
    bAltFire = 0;
	return Level.Game.SetPause(bPause, self);
}

/* Pause()
Command to try to pause the game.
*/
exec function Pause()
{
	// Pause if not already
	if(Level.Pauser == None)
		SetPause(true);
	else
		SetPause(false);
}

exec function ShowMenu()
{
	// Pause if not already
	if(Level.Pauser == None)
		SetPause(true);

	StopForceFeedback();  // jdf - no way to pause feedback
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
/*
	local Powerups Inv;

	Inv = Powerups(Pawn.FindInventoryType(InvItem));
	if ( Inv != None )
		Inv.Activate();
*/
}

// ------------------------------------------------------------------------
// Weapon changing functions

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
exec function ThrowWeapon()
{
/*
    if ( (Pawn == None) || (Pawn.Weapon == None) )
		return;

    ServerThrowWeapon();
*/
}

function ServerThrowWeapon()
{
/*
    local Vector TossVel;

    if (Pawn.CanThrowWeapon())
    {
        TossVel = Vector(GetViewRotation());
        TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
        Pawn.TossWeapon(TossVel);
        ClientSwitchToBestWeapon();
    }
*/
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
/*
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.PrevWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
*/
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
/*
	if( Level.Pauser!=None )
		return;
	if ( Pawn.Weapon == None )
	{
//		SwitchToBestWeapon();
		return;
	}
	if ( Pawn.PendingWeapon != None )
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.PendingWeapon);
	else
		Pawn.PendingWeapon = Pawn.Inventory.NextWeapon(None, Pawn.Weapon);

	if ( Pawn.PendingWeapon != None )
		Pawn.Weapon.PutDown();
*/
}

#if !IG_TRIBES3	// rowan: dont use this
exec function PipedSwitchWeapon(byte F)
{
	if ( (Pawn == None) || (Pawn.PendingWeapon != None) )
		return;

	SwitchWeapon(F);
}
#endif

// The player wants to switch to weapon group number F.
exec function SwitchWeapon (byte F )
{
/*
	local weapon newWeapon;

	if ( (Level.Pauser!=None) || (Pawn == None) || (Pawn.Inventory == None) )
		return;
	if ( (Pawn.Weapon != None) && (Pawn.Weapon.Inventory != None) )
        newWeapon = Pawn.Weapon.Inventory.WeaponChange(F, false);
	else
		newWeapon = None;	
	if ( newWeapon == None )
        newWeapon = Pawn.Inventory.WeaponChange(F, true);

	if ( newWeapon == None )
		return;

	if ( Pawn.Weapon == None )
	{
		Pawn.PendingWeapon = newWeapon;
		Pawn.ChangedWeapon();
	}
    else if ( Pawn.Weapon != newWeapon || Pawn.PendingWeapon != None )
	{
		Pawn.PendingWeapon = newWeapon;
		if ( !Pawn.Weapon.PutDown() )
			Pawn.PendingWeapon = None;
	}
*/
}

/*
exec function GetWeapon(class<Weapon> NewWeaponClass )
{

	local Inventory Inv;
    local int Count;

	if ( (Pawn.Inventory == None) || (NewWeaponClass == None)
		|| ((Pawn.Weapon != None) && (Pawn.Weapon.Class == NewWeaponClass)) )
		return;

	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
		if ( Inv.Class == NewWeaponClass )
		{
			Pawn.PendingWeapon = Weapon(Inv);
			if ( !Pawn.PendingWeapon.HasAmmo() )
			{
				ClientMessage( Pawn.PendingWeapon.ItemName$Pawn.PendingWeapon.MessageNoAmmo );
				Pawn.PendingWeapon = None;
				return;
			}
			Pawn.Weapon.PutDown();
			return;
		}
		Count++;
		if ( Count > 1000 )
			return;
    }
}
*/
	
// The player wants to select previous item
exec function PrevItem()
{
/*
	local Inventory Inv;
	local Powerups LastItem;

    if ( (Level.Pauser!=None) || (Pawn == None) )
		return;
	if (Pawn.SelectedItem==None) 
	{
		Pawn.SelectedItem = Pawn.Inventory.SelectNext();
		return;
	}
	if (Pawn.SelectedItem.Inventory!=None) 
		for( Inv=Pawn.SelectedItem.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		{
			if (Inv==None) Break;
			if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
		}
	for( Inv=Pawn.Inventory; Inv!=Pawn.SelectedItem; Inv=Inv.Inventory ) 
	{
		if (Inv==None) Break;
		if ( Inv.IsA('Powerups') && Powerups(Inv).bActivatable) LastItem=Powerups(Inv);
	}
	if (LastItem!=None) 
		Pawn.SelectedItem = LastItem;
*/
}

// The player wants to active selected item
exec function ActivateItem()
{
	if( Level.Pauser!=None )
		return;
//	if ( (Pawn != None) && (Pawn.SelectedItem!=None) ) 
//		Pawn.SelectedItem.Activate();
}

// The player wants to fire.
#if !IG_TRIBES3 // Alex:
exec function Fire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( bDemoOwner || (Pawn == None) )
		return;
    Pawn.Fire(F);
}
#endif

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}
	if( bDemoOwner || (Pawn == None) )
		return;
#if !IG_TRIBES3	// rowan: we don't use this
	if( Pawn.Weapon!=None )
		Pawn.Weapon.AltFire(F);
#endif
}

// The player wants to use something in the level.
exec function Use()
{
	ServerUse();
}

function ServerUse()
{
	local Actor A;

	if ( Level.Pauser == PlayerReplicationInfo )
	{
		SetPause(false);
		return;
	}

	if (Pawn==None)
		return;
	
	// Send the 'DoUse' event to each actor player is touching.
	ForEach Pawn.TouchingActors(class'Actor', A)
	{
		A.UsedBy(Pawn);
	}
}

exec function Suicide()
{
#if IG_TRIBES3 // Alex: causes potential weirdness on clients
	if (Level.NetMode == NM_Client)
		return;
#endif

	if ( (Pawn != None) && (Level.TimeSeconds - Pawn.LastStartTime > 1) )
		Pawn.KilledBy( Pawn );
}

exec function Name( coerce string S )
{
	SetName(S);
}

exec function SetName( coerce string S)
{
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

function ChangeName( coerce string S )
{
    if ( Len(S) > 20 )
        S = left(S,20);
	ReplaceText(S, " ", "_");
    Level.Game.ChangeName( self, S, true );
}

#if !IG_TRIBES3 // david: not using Unreal team object
exec function SwitchTeam()
{
	if ( (PlayerReplicationInfo.Team == None) || (PlayerReplicationInfo.Team.TeamIndex == 1) )
		ChangeTeam(0);
	else
		ChangeTeam(1);
}
#endif

#if IG_TRIBES3	// michaelj:  Allow admin override
exec function ChangeTeam( int N, optional bool bAdminOverride )
#else
exec function ChangeTeam( int N )
#endif
{
#if !IG_TRIBES3 // david: not using Unreal team object
	local TeamInfo OldTeam;

	OldTeam = PlayerReplicationInfo.Team;
    Level.Game.ChangeTeam(self, N, true);

	// DLB Gameinfo pass: Move this logic to the gameinfo object
	/*if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team != OldTeam) )
    {
		if ( Pawn != None )
		Pawn.Died( None, class'DamageType', Pawn.Location );
	}*/
#endif
}


exec function SwitchLevel( string URL )
{
	if( Level.NetMode==NM_Standalone || Level.NetMode==NM_ListenServer )
		Level.ServerTravel( URL, false );
}

#if IG_TRIBES3 // dbeswick:
event function ProgressCommand(string Cmd, string Msg1, string Msg2, int seconds)
#else
event function ProgressCommand(string Cmd, string Msg1, string Msg2)
#endif
{
	local string c,v,menu,menuName;
	local int p;

	log("PlayerController::ProgressCommand"@Cmd@Msg1@Msg2);
	
	p = InStr(Cmd,":");
	c = Left(Cmd,p);
	v = Right(Cmd,len(Cmd)-p-1);		
	if ( (C~="menu") )
	{
		Player.GUIController.CloseAll();

		p = InStr(v,",");
		if (p == -1)
		{
			menu = v;
		}
		else
		{
			menu = Left(v,p);
			menuName = Mid(v,p+1);
		}
#if IG_TRIBES3 // dbeswick:
		ClientOpenMenu(menu, menuName, false, Msg1, Msg2, seconds);
#else
		ClientOpenMenu(menu, menuName, false, Msg1, Msg2);
#endif
		log("PlayerController::ProgressCommand opened "@menu@menuName);
	}
}


exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<ArrayCount(ProgressMessage); i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i] = class'Canvas'.Static.MakeColor(255,255,255);
	}
}

exec event SetProgressMessage( int Index, string S, color C )
{
	if ( Index < ArrayCount(ProgressMessage) )
	{
		ProgressMessage[Index] = S;
		ProgressColor[Index] = C;
	}
#if IG_TRIBES3	// michaelj:  Dispatch a progress message for UI purposes
	dispatchMessage(new class'MessageLoadProgress'(S));
#endif
}

exec event SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

function Restart()
{
	Super.Restart();
	ServerTimeStamp = 0;
#if !IG_TRIBES3 // dbeswick: unneeded functionality
	EnterStartState();
#endif
	TimeMargin = 0;
	SetViewTarget(Pawn);
#if !IG_TRIBES3 // dbeswick: unneeded functionality
	bBehindView = Pawn.PointOfView();
#endif
	ClientRestart(Pawn, GetStateName());
}

#if !IG_TRIBES3 // dbeswick: unneeded functionality
function EnterStartState()
{
	local name NewState;

	if ( Pawn.PhysicsVolume.bWaterVolume )
	{
		if ( Pawn.HeadVolume.bWaterVolume )
			Pawn.BreathTime = Pawn.UnderWaterTime;
		NewState = Pawn.WaterMovementState;
	}
	else  
		NewState = Pawn.LandMovementState;

	if ( IsInState(NewState) )
		BeginState();
	else
		GotoState(NewState);
}
#endif

#if IG_TRIBES3 // Alex:
function ClientRestart(Pawn aPawn, Name currentState)
{
	// guarantee pawn variable is up to date
	Pawn = aPawn;
#else
function ClientRestart()
{
#endif

	if ( (Pawn != None) && Pawn.bTearOff )
	{
		Pawn.Controller = None;
		Pawn = None;
	}
	if ( Pawn == None )
	{
#if IG_TRIBES3 // Alex:
		if (aPawn != None || currentState == 'PlayerRespawn')
			GotoState(currentState);
		else
			GotoState('WaitingForPawn');
#else
		GotoState('WaitingForPawn');
#endif
		return;
	}
	Pawn.ClientRestart();
	SetViewTarget(Pawn);
#if !IG_TRIBES3 // dbeswick: unneeded functionality
	bBehindView = Pawn.PointOfView();
#endif
    CleanOutSavedMoves();
	
#if IG_TRIBES3 // dbeswick: ClientRestart carries state info
	GotoState(currentState);
#endif
}

exec function BehindView( Bool B )
{
	if ( (Level.NetMode == NM_Standalone) || Level.Game.bAllowBehindView || PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin || IsA('Admin') )
	{
	    bBehindView = B;
	    ClientSetBehindView(bBehindView);
    }
}

exec function ToggleBehindView()
{
	ServerToggleBehindview();
}

function ServerToggleBehindView()
{
	bBehindView = !bBehindView;
	ClientSetBehindView(bBehindView);
}

//=============================================================================
// functions.

// Just changed to pendingWeapon
function ChangedWeapon()
{
#if !IG_TRIBES3	// rowan: we don't use this
    if ( Pawn.Weapon != None )
    {
        Pawn.Weapon.SetHand(Handedness);
        LastPawnWeapon = Pawn.Weapon.Class;
    }
#endif
}

event TravelPostAccept()
{
	if ( Pawn.Health <= 0 )
		Pawn.Health = Pawn.Default.Health;
}

event PlayerTick( float DeltaTime )
{
#if !IG_SHARED	// rowan: this is essentially a hack.. we handle this better now by explicitly precaching actors on the client
	//if ( bForcePrecache && (Level.TimeSeconds > ForcePrecacheTime) )
	//{
	//	bForcePrecache = false;
	//	Level.FillRenderPrecacheArrays();
	//}		
#endif
	PlayerInput.PlayerInput(DeltaTime);
	if ( bUpdatePosition )
		ClientUpdatePosition();
	PlayerMove(DeltaTime);
}

function PlayerMove(float DeltaTime);

//
/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/
/*
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	
	local vector FireDir, AimSpot, HitNormal, HitLocation, OldAim, AimOffset;
	local actor BestTarget;
	local float bestAim, bestDist, projspeed;
	local actor HitActor;
	local bool bNoZAdjust, bLeading;
	local rotator AimRot;

	FireDir = vector(Rotation);
	if ( FiredAmmunition.bInstantHit )
		HitActor = Trace(HitLocation, HitNormal, projStart + 10000 * FireDir, projStart, true);
	else 
		HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		BestTarget = HitActor;
		bNoZAdjust = true;
		OldAim = HitLocation;
		BestDist = VSize(BestTarget.Location - Pawn.Location);
	}
	else
	{
		// adjust aim based on FOV
		bestAim = 0.95;
		if ( AimingHelp == 1 )
		{
			bestAim = 0.93;
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.97; 
			if ( FovAngle < DefaultFOV - 8 )
				bestAim = 0.99;
		}
		else
		{
			if ( FiredAmmunition.bInstantHit )
				bestAim = 0.98; 
			if ( FovAngle != DefaultFOV )
				bestAim = 0.995;
		}
		BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart,FiredAmmunition.MaxAutoAimRange);
		if ( BestTarget == None )
		{
			if (bBehindView)
				return Pawn.Rotation;
			else
				return Rotation;
		}
		FiredAmmunition.WarnTarget(Target,Pawn,FireDir);
		OldAim = projStart + FireDir * bestDist;
	}
    if ( (AimingHelp == 0) || (Level.NetMode != NM_Standalone) )
	{
		if (bBehindView)
			return Pawn.Rotation;
		else
			return Rotation;
	}

	// aim at target - help with leading also
	if ( !FiredAmmunition.bInstantHit )
	{
		projspeed = FiredAmmunition.ProjectileClass.default.speed;
		BestDist = vsize(BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart); 
		bLeading = true;
		FireDir = BestTarget.Location + BestTarget.Velocity * FMin(2, 0.02 + BestDist/projSpeed) - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
		// if splash damage weapon, try aiming at feet - trace down to find floor
		if ( FiredAmmunition.bTrySplash 
			&& ((BestTarget.Velocity != vect(0,0,0)) || (BestDist > 1500)) )
		{
			HitActor = Trace(HitLocation, HitNormal, AimSpot - BestTarget.CollisionHeight * vect(0,0,2), AimSpot, false);
			if ( (HitActor != None)
				&& FastTrace(HitLocation + vect(0,0,4),projstart) )
				return rotator(HitLocation + vect(0,0,6) - projStart);
		}
	}
	else
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
	AimOffset = AimSpot - OldAim;

	// adjust Z of shooter if necessary
	if ( bNoZAdjust || (bLeading && (Abs(AimOffset.Z) < BestTarget.CollisionHeight)) )
		AimSpot.Z = OldAim.Z;
	else if ( AimOffset.Z < 0 )
		AimSpot.Z = BestTarget.Location.Z + 0.4 * BestTarget.CollisionHeight;
	else
		AimSpot.Z = BestTarget.Location.Z - 0.7 * BestTarget.CollisionHeight;

	if ( !bLeading )
	{
		// if not leading, add slight random error ( significant at long distances )
		if ( !bNoZAdjust )
		{
			AimRot = rotator(AimSpot - projStart);
			if ( FovAngle < DefaultFOV - 8 )
				AimRot.Yaw = AimRot.Yaw + 200 - Rand(400);
			else
				AimRot.Yaw = AimRot.Yaw + 375 - Rand(750);
			return AimRot;
		}	
	}
	else if ( !FastTrace(projStart + 0.9 * bestDist * Normal(FireDir), projStart) )
	{
		FireDir = BestTarget.Location - projStart;
		AimSpot = projStart + bestDist * Normal(FireDir);
	}
		
	return rotator(AimSpot - projStart);

	return Rotation;
}
*/

function bool NotifyLanded(vector HitNormal)
{
	return bUpdating;
}

//=============================================================================
// Player Control

// Player view.
// Compute the rendering viewpoint for the player.
//

function AdjustView(float DeltaTime )
{
#if !IG_TRIBES3 // david: we do our own zooming
	// teleporters affect your FOV, so adjust it back down
	if ( FovAngle != DesiredFOV )
	{
		if ( FovAngle > DesiredFOV )
			FovAngle = FovAngle - FMax(7, 0.9 * DeltaTime * (FovAngle - DesiredFOV)); 
		else 
			FovAngle = FovAngle - FMin(-7, 0.9 * DeltaTime * (FovAngle - DesiredFOV)); 
		if ( Abs(FovAngle - DesiredFOV) <= 10 )
			FovAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{	
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	} 
#endif
}

simulated function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
    local float ViewDist,RealDist;

	CameraRotation = Rotation;

	if ( bBlockCloseCamera )
		CameraLocation.Z += 12;

	View = vect(1,0,0) >> CameraRotation;

    // add view radius offset to camera location and move viewpoint up from origin (amb)
    RealDist = Dist;

    if( Trace( HitLocation, HitNormal, CameraLocation - Dist * vector(CameraRotation), CameraLocation,false,vect(10,10,10) ) != None )
	{
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	}
	else
	{
		ViewDist = Dist;
	}
    
    if ( !bBlockCloseCamera || !bValidBehindCamera || (ViewDist > 10 + FMax(ViewTarget.CollisionRadius, ViewTarget.CollisionHeight)) )
	{
		//Log("Update Cam ");
		bValidBehindCamera = true;
		OldCameraLoc = CameraLocation - ViewDist * View;
		OldCameraRot = CameraRotation;
	}
	else
	{
		//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
		SetRotation(OldCameraRot);
	}

    CameraLocation = OldCameraLoc; 
    CameraRotation = OldCameraRot;
}

simulated function CalcFirstPersonView( out vector CameraLocation, out rotator CameraRotation )
{
	// First-person view.
	CameraRotation = Rotation;
	CameraLocation = CameraLocation + Pawn.EyePosition() + ShakeOffset;
}

event AddCameraEffect(CameraEffect NewEffect,optional bool RemoveExisting)
{
	if(RemoveExisting)
		RemoveCameraEffect(NewEffect);

	CameraEffects.Length = CameraEffects.Length + 1;
	CameraEffects[CameraEffects.Length - 1] = NewEffect;
}

event RemoveCameraEffect(CameraEffect ExEffect)
{
	local int	EffectIndex;

	for(EffectIndex = 0;EffectIndex < CameraEffects.Length;EffectIndex++)
		if(CameraEffects[EffectIndex] == ExEffect)
		{
			CameraEffects.Remove(EffectIndex,1);
			return;
		}
}

exec function CreateCameraEffect(class<CameraEffect> EffectClass)
{
	AddCameraEffect(new(self) EffectClass());
}

simulated function rotator GetViewRotation()
{
	if ( bBehindView && (Pawn != None) )
		return Pawn.Rotation;
	return Rotation;
}

simulated event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	// If desired, call the pawn's own special callview
	if( Pawn != None && Pawn.bSpecialCalcView )
	{
		// try the 'special' calcview. This may return false if its not applicable, and we do the usual.
		if( Pawn.SpecialCalcView(ViewActor, CameraLocation, CameraRotation) )
			return;
	}

	if ( (ViewTarget == None) || ViewTarget.bDeleteMe )
	{
#if !IG_TRIBES3 // dbeswick:
		if ( bViewBot && (CheatManager != None) )
			CheatManager.ViewBot();
        else
#endif
		if ( (Pawn != None) && !Pawn.bDeleteMe )
			SetViewTarget(Pawn);
        else if ( RealViewTarget != None )
            SetViewTarget(RealViewTarget);
		else
			SetViewTarget(self);
	}

	ViewActor = ViewTarget;
	CameraLocation = ViewTarget.Location;

	if ( ViewTarget == Pawn )
	{
		if( bBehindView ) //up and behind
			CalcBehindView(CameraLocation, CameraRotation, CameraDist * Pawn.Default.CollisionRadius);
		else
			CalcFirstPersonView( CameraLocation, CameraRotation );
// IGA >>> Cinematic camera shake
		CameraLocation = CameraLocation + CinematicShakeOffset;
		CameraRotation = CameraRotation + CinematicShakeRotate;
// IGA
		return;
	}
	if ( ViewTarget == self )
	{
		if ( bCameraPositionLocked )
			CameraRotation = CheatManager.LockedRotation;
		else
			CameraRotation = Rotation;
// IGA >>> Cinematic camera shake
		CameraLocation = CameraLocation + CinematicShakeOffset;
		CameraRotation = CameraRotation + CinematicShakeRotate;
// IGA
		return;
	}

    if ( ViewTarget.IsA('Projectile') && !bBehindView ) 
    {
        CameraLocation += (ViewTarget.CollisionHeight) * vect(0,0,1);
        CameraRotation = Rotation;
        return;
    }

	CameraRotation = ViewTarget.Rotation;
	PTarget = Pawn(ViewTarget);
	if ( PTarget != None )
	{
		if ( Level.NetMode == NM_Client )
		{
			PTarget.SetViewRotation(TargetViewRotation);
            CameraRotation = BlendedTargetViewRotation;

			PTarget.EyeHeight = TargetEyeHeight;
//			if ( PTarget.Weapon != None )
//				PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
		}
		else if ( PTarget.IsPlayerPawn() )
			CameraRotation = PTarget.GetViewRotation();
		if ( !bBehindView )
			CameraLocation += PTarget.EyePosition();
	}
	if ( bBehindView )
	{
		CameraLocation = CameraLocation + (ViewTarget.Default.CollisionHeight - ViewTarget.CollisionHeight) * vect(0,0,1);
		CalcBehindView(CameraLocation, CameraRotation, CameraDist * ViewTarget.Default.CollisionRadius);
	}
}

function int BlendRot(float DeltaTime, int BlendC, int NewC)
{
	if ( Abs(BlendC - NewC) > 32767 )
	{
		if ( BlendC > NewC )
			NewC += 65536;
		else
			BlendC += 65536;
	}
	if ( Abs(BlendC - NewC) > 4096 )
		BlendC = NewC;
	else
		BlendC = BlendC + (NewC - BlendC) * FMin(1,24 * DeltaTime);

	return (BlendC & 65535);
}

function CheckShake(out float MaxOffset, out float Offset, out float Rate, out float Time)
{
	if ( Abs(Offset) < Abs(MaxOffset) )
		return;

	Offset = MaxOffset;
	if ( Time > 1 )
	{
		if ( Time * Abs(MaxOffset/Rate) <= 1 )
			MaxOffset = MaxOffset * (1/Time - 1);
		else
			MaxOffset *= -1;
		Time -= 1;
		Rate *= -1;
	}
	else
	{
		MaxOffset = 0;
		Offset = 0;
		Rate = 0;
	}
}

function ViewShake(float DeltaTime)
{
	local Rotator ViewRotation;
	local float FRoll;

#if IG_MOJO
	if (Level.bIsMojoPlaying)
	{
		return;
	}
#endif

	if ( ShakeOffsetRate != vect(0,0,0) )
	{
		// modify shake offset
		ShakeOffset.X += DeltaTime * ShakeOffsetRate.X;
		CheckShake(MaxShakeOffset.X, ShakeOffset.X, ShakeOffsetRate.X, ShakeOffsetTime.X);
		
		ShakeOffset.Y += DeltaTime * ShakeOffsetRate.Y;
		CheckShake(MaxShakeOffset.Y, ShakeOffset.Y, ShakeOffsetRate.Y, ShakeOffsetTime.Y);
		
		ShakeOffset.Z += DeltaTime * ShakeOffsetRate.Z;
		CheckShake(MaxShakeOffset.Z, ShakeOffset.Z, ShakeOffsetRate.Z, ShakeOffsetTime.Z);
	}				

	ViewRotation = Rotation;

	if ( ShakeRollRate != 0 )
	{
		ViewRotation.Roll = ((ViewRotation.Roll & 65535) + ShakeRollRate * DeltaTime) & 65535;
		if ( ViewRotation.Roll > 32768 )
			ViewRotation.Roll -= 65536;
		FRoll = ViewRotation.Roll;
		CheckShake(MaxShakeRoll, FRoll, ShakeRollRate, ShakeRollTime);
		ViewRotation.Roll = FRoll;
	}
	else if ( bZeroRoll )
		ViewRotation.Roll = 0;
	SetRotation(ViewRotation);
}

function bool TurnTowardNearestEnemy();

function TurnAround()
{
	if ( !bSetTurnRot )
	{
		TurnRot180 = Rotation;
		TurnRot180.Yaw += 32768;
		bSetTurnRot = true;
	}
	
	DesiredRotation = TurnRot180;
	bRotateToDesired = ( DesiredRotation.Yaw != Rotation.Yaw );
}
					
function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation, ViewRotation;

	if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
	{
		ViewShake(deltaTime);
		return;
	}
	ViewRotation = Rotation;
	DesiredRotation = ViewRotation; //save old rotation
	if ( bTurnToNearest != 0 )
		TurnTowardNearestEnemy();
	else if ( bTurn180 != 0 )
		TurnAround();
	else
	{
		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;
		ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
		ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
	}
	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		If (aLookUp > 0) 
			ViewRotation.Pitch = 18000;
		else
			ViewRotation.Pitch = 49152;
	}

	SetRotation(ViewRotation);

	ViewShake(deltaTime);
	ViewFlash(deltaTime);
		
	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
		Pawn.FaceRotation(NewRotation, deltatime);
}

function ClearDoubleClick()
{
	if (PlayerInput != None)
		PlayerInput.DoubleClickTimer = 0.0;
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;
		local bool OldCrouch;

		if ( Pawn == None )
			return;
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		if ( bDoubleJump && (bUpdating || Pawn.CanDoubleJump()) )
			Pawn.DoDoubleJump(bUpdating);
        else if ( bPressedJump )
			Pawn.DoJump(bUpdating);
		if ( Pawn.Physics != PHYS_Falling )
		{
			OldCrouch = Pawn.bWantsToCrouch;
			if (bDuck == 0)
				Pawn.ShouldCrouch(false);
			else if ( Pawn.bCanCrouch )
				Pawn.ShouldCrouch(true);
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GetAxes(Pawn.Rotation,X,Y,Z);

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		DoubleClickMove = PlayerInput.CheckForDoubleClickMove(DeltaTime);
		
		GroundPitch = 0;	
		ViewRotation = Rotation;
		if ( Pawn.Physics == PHYS_Walking )
		{
			// tell pawn about any direction changes to give it a chance to play appropriate animation
			//if walking, look up/down stairs - unless player is rotating view
			if ( (bLook == 0) 
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
			{
				if ( bLookUpStairs || bSnapToLevel )
				{
//					GroundPitch = FindStairRotation(deltaTime);
					ViewRotation.Pitch = GroundPitch;
				}
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                    if ( Abs(ViewRotation.Pitch) < 200 )
						ViewRotation.Pitch = 0;	
				}
			}
		}	
		else
		{
			if ( !bKeyboardLook && (bLook == 0) && bCenterView )
			{
				ViewRotation.Pitch = ViewRotation.Pitch & 65535;
				if (ViewRotation.Pitch > 32768)
					ViewRotation.Pitch -= 65536;
				ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( Abs(ViewRotation.Pitch) < 200 )
					ViewRotation.Pitch = 0;	
			}
		}
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
       	DoubleClickDir = DCLICK_None;
       	bPressedJump = false;
       	GroundPitch = 0;
		if ( Pawn != None )
		{
		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		Pawn.ShouldCrouch(false);
		if (Pawn.Physics != PHYS_Falling && Pawn.Physics != PHYS_Havok && Pawn.Physics!=PHYS_Movement) // FIXME HACK!!!
			Pawn.SetPhysics(PHYS_Walking);
		}
	}
	
	function EndState()
	{

		GroundPitch = 0;
		if ( Pawn != None && bDuck==0 )
		{
			Pawn.ShouldCrouch(false);
		}
	}
}

// player is climbing ladder
state PlayerClimbing
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		else
			GotoState(Pawn.LandMovementState);
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
		{
			Pawn.DoJump(bUpdating);
			if ( Pawn.Physics == PHYS_Falling )
				GotoState('PlayerWalking');
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GetAxes(Rotation,X,Y,Z);

		// Update acceleration.
		if ( Pawn.OnLadder != None )
			NewAccel = aForward*Pawn.OnLadder.ClimbDir; 
		else
			NewAccel = aForward*X + aStrafe*Y;
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
		
		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
	}
	
	function EndState()
	{
		if ( Pawn != None )
			Pawn.ShouldCrouch(false);
	}
}

// Player movement.
// Player Driving a Karma or Havok vehicle.
//state PlayerDriving
//{
//ignores SeePlayer, HearNoise, Bump;
//
//	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
//	{
//
//	}
//
//    exec function Fire(optional float F)
//    {
//		local KVehicle DrivenVehicle;
//
//		DrivenVehicle = KVehicle(Pawn);
//		if(DrivenVehicle != None)
//		{
//			DrivenVehicle.VehicleFire(false);
//			DrivenVehicle.bVehicleIsFiring = true;
//		}
//    }
//
//    exec function AltFire(optional float F)
//    {
//		local KVehicle DrivenVehicle;
//
//		DrivenVehicle = KVehicle(Pawn);
//		if(DrivenVehicle != None)
//		{
//			DrivenVehicle.VehicleFire(true);
//			DrivenVehicle.bVehicleIsAltFiring = true;
//		}
//    }
//
//	// When you hit use inside the SVehicle or HavokVehicle, you get out.
//	function ServerUse()
//	{
//		local SVehicle DrivenSVehicle;
//		local HavokVehicle DrivenHVehicle;
//
//		if(Role != ROLE_Authority)
//			return;
//
//		DrivenHVehicle = HavokVehicle(Pawn);
//		if(DrivenHVehicle != None)
//		{
//			DrivenHVehicle.bGetOut = true;
//		}
//		else
//		{
//			DrivenSVehicle = SVehicle(Pawn);
//			if(DrivenSVehicle != None)
//			{
//				DrivenSVehicle.bGetOut = true;
//			}
//		}
//	}
//
//	// Set the throttle, steering etc. for the vehicle based on the input provided
//	function ProcessDrive(float InForward, float InStrafe, float InUp, bool InJump)
//	{
//		local KVehicle DrivenVehicle;
//		local SVehicle DrivenSVehicle;
//		local HavokVehicle DrivenHVehicle;
//
//		DrivenVehicle = KVehicle(Pawn);
//
//		if(DrivenVehicle == None)
//		{
//			// URGH! Need to make superclass of KVehicle and SVehicle
//			DrivenSVehicle = SVehicle(Pawn);
//
//			if(DrivenSVehicle == None)
//			{
//				DrivenHVehicle = HavokVehicle(Pawn);
//				
//				// Double URGH! Can't remove the Karma specific stuff in SVehicle, so can't
//				// really use it as a base class..
//				
//				if(DrivenHVehicle == None)
//				{
//					log("PlayerDriving.PlayerMove: No Vehicle");
//					return;
//				}
//				
//				if(InForward > 1)
//					DrivenHVehicle.Throttle = 1;
//				else if(InForward < -1)
//					DrivenHVehicle.Throttle = -1;
//				else
//					DrivenHVehicle.Throttle = 0;
//
//				if(InStrafe < -1)
//					DrivenHVehicle.Steering = 1;
//				else if(InStrafe > 1)
//					DrivenHVehicle.Steering = -1;
//				else
//					DrivenHVehicle.Steering = 0;
//
//				if(InUp < -1)
//					DrivenHVehicle.Rise = -1;
//				else if(InUp > 1)
//					DrivenHVehicle.Rise = 1;
//				else
//					DrivenHVehicle.Rise = 0;
//					
//				return;
//			}
//			
//			//log("Drive:"$InForward$" Steer:"$InStrafe);
//
//			if(InForward > 1)
//				DrivenSVehicle.Throttle = 1;
//			else if(InForward < -1)
//				DrivenSVehicle.Throttle = -1;
//			else
//				DrivenSVehicle.Throttle = 0;
//
//			if(InStrafe < -1)
//				DrivenSVehicle.Steering = 1;
//			else if(InStrafe > 1)
//				DrivenSVehicle.Steering = -1;
//			else
//				DrivenSVehicle.Steering = 0;
//
//			if(InUp < -1)
//				DrivenSVehicle.Rise = -1;
//			else if(InUp > 1)
//				DrivenSVehicle.Rise = 1;
//			else
//				DrivenSVehicle.Rise = 0;
//
//			return;
//		}
//
//		// // // //
//
//		// check for 'jump' to throw the driver out.
//		if(InJump && Role == ROLE_Authority)
//		{
//			DrivenVehicle.bGetOut = true;
//			return;
//		}
//
//		//log("Drive:"$InForward$" Steer:"$InStrafe);
//
//		if(InForward > 1)
//			DrivenVehicle.Throttle = 1;
//		else if(InForward < -1)
//			DrivenVehicle.Throttle = -1;
//		else
//			DrivenVehicle.Throttle = 0;
//
//		if(InStrafe < -1)
//			DrivenVehicle.Steering = 1;
//		else if(InStrafe > 1)
//			DrivenVehicle.Steering = -1;
//		else
//			DrivenVehicle.Steering = 0;
//	}
//
//    function PlayerMove( float DeltaTime )
//		{
//		local KVehicle DrivenVehicle;
//
//		// Only servers can actually do the driving logic.
//		if(Role < ROLE_Authority)
//			ServerDrive(aForward, aStrafe, aUp, bPressedJump);
//		else
//			ProcessDrive(aForward, aStrafe, aUp, bPressedJump);
//
//		// If the vehicle is being controlled here - set replicated variables.
//		DrivenVehicle = KVehicle(Pawn);
//		if(DrivenVehicle != None)
//			{
//			if(bFire == 0 && DrivenVehicle.bVehicleIsFiring)
//			{
//				DrivenVehicle.VehicleCeaseFire(false);
//				DrivenVehicle.bVehicleIsFiring = false;
//			}
//			
//			if(bAltFire == 0 && DrivenVehicle.bVehicleIsAltFiring)
//		{
//				DrivenVehicle.VehicleCeaseFire(true);
//				DrivenVehicle.bVehicleIsAltFiring = false;
//			}
//		}
//
//        // update 'looking' rotation - no affect on driving
//		UpdateRotation(DeltaTime, 2);
//	}
//
//	function BeginState()
//	{
//		CleanOutSavedMoves();
//	}
//	
//	function EndState()
//	{
//		CleanOutSavedMoves();
//	}
//}

// Player movement.
// Player walking on walls
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

	event bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
	    if (Physics!=PHYS_Movement)
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(HitActor, HitNormal);	
		return true;
	}

	// if spider mode, update rotation based on floor					
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
        local rotator ViewRotation;
		local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		if ( bInterpolating || Pawn.bInterpolating )
		{
			ViewShake(deltaTime);
			return;
		}

		TurnTarget = None;
		bRotateToDesired = false;
		bSetTurnRot = false;

		if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
			MyFloor = vect(0,0,1);
		else
			MyFloor = Pawn.Floor;

		if ( MyFloor != OldFloor )
		{
			// smoothly change floor
			RealFloor = MyFloor;
			MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
			if ( (RealFloor Dot MyFloor) > 0.999 )
				MyFloor = RealFloor;

			// translate view direction
			CrossDir = Normal(RealFloor Cross OldFloor);
			FwdDir = CrossDir Cross MyFloor;
			OldFwdDir = CrossDir Cross OldFloor;
			ViewX = MyFloor * (OldFloor Dot ViewX) 
						+ CrossDir * (CrossDir Dot ViewX) 
						+ FwdDir * (OldFwdDir Dot ViewX);
			ViewX = Normal(ViewX);
			
			ViewZ = MyFloor * (OldFloor Dot ViewZ) 
						+ CrossDir * (CrossDir Dot ViewZ) 
						+ FwdDir * (OldFwdDir Dot ViewZ);
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;  
			ViewY = Normal(MyFloor Cross ViewX); 
		}

		if ( (aTurn != 0) || (aLookUp != 0) )
		{
			// adjust Yaw based on aTurn
			if ( aTurn != 0 )
				ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*aTurn));

			// adjust Pitch based on aLookUp
			if ( aLookUp != 0 )
			{
				OldX = ViewX;
				ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*aLookUp));
				ViewZ = Normal(ViewX Cross ViewY);

				// bound max pitch
				if ( (ViewZ Dot MyFloor) < 0.707   )
				{
					OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
					if ( (ViewX Dot MyFloor) > 0)
						ViewX = Normal(OldX + MyFloor);
					else
						ViewX = Normal(OldX - MyFloor);

					ViewZ = Normal(ViewX Cross ViewY);
				}
			}
			
			// calculate new Y axis
			ViewY = Normal(MyFloor Cross ViewX);
		}
		ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
		SetRotation(ViewRotation);
		ViewShake(deltaTime);
		ViewFlash(deltaTime);
		Pawn.FaceRotation(ViewRotation, deltaTime );
	}

	function bool NotifyLanded(vector HitNormal)
	{
	    if (Physics!=PHYS_Movement)
		Pawn.SetPhysics(PHYS_Spider);
		return bUpdating;
	}

	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
		return false;
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;

		if ( bPressedJump )
			Pawn.DoJump(bUpdating);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector NewAccel;
		local EDoubleClickDir DoubleClickMove;
		local rotator OldRotation, ViewRotation;
		local bool	bSaveJump;

		GroundPitch = 0;	
		ViewRotation = Rotation;

		if ( !bKeyboardLook && (bLook == 0) && bCenterView )
		{
			// FIXME - center view rotation based on current floor
		}
		Pawn.CheckBob(DeltaTime,vect(0,0,0));

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		// Update acceleration.
		NewAccel = aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + aStrafe*ViewY; 
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function BeginState()
	{
		if ( Pawn.Mesh == None )
			Pawn.SetMesh();
		OldFloor = vect(0,0,1);
		GetAxes(Rotation,ViewX,ViewY,ViewZ);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling && Physics!=PHYS_Movement)
			Pawn.SetPhysics(PHYS_Spider);
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.Default.CollisionHeight,Pawn.Default.CollisionHeight);
	}
	
	function EndState()
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.Default.bCrawler;
		}
	}
}
	
// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	function bool WantsSmoothedView()
	{
		return ( !Pawn.bJustLanded );
	}

	function bool NotifyLanded(vector HitNormal)
	{
		if ( Pawn.PhysicsVolume.bWaterVolume )
		{
		    if (Physics!=PHYS_Movement)
			Pawn.SetPhysics(PHYS_Swimming);
	    }
		else
			GotoState(Pawn.LandMovementState);
		return bUpdating;
	}
	
	function bool NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		if ( !NewVolume.bWaterVolume )
		{
			if (Physics!=PHYS_Movement)
			Pawn.SetPhysics(PHYS_Falling);
    
            if ( Pawn.Velocity.Z > 0 )
            {
			    if (Pawn.bUpAndOut && Pawn.CheckWaterJump(HitNormal)) //check for waterjump
			    {
				    Pawn.velocity.Z = FMax(Pawn.JumpZ,420) + 2 * Pawn.CollisionRadius; //set here so physics uses this for remainder of tick
				    GotoState(Pawn.LandMovementState);
			    }				
			    else if ( (Pawn.Velocity.Z > 160) || !Pawn.TouchingWaterVolume() )
				    GotoState(Pawn.LandMovementState);
			    else //check if in deep water
			    {
				    checkpoint = Pawn.Location;
				    checkpoint.Z -= (Pawn.CollisionHeight + 6.0);
				    HitActor = Trace(HitLocation, HitNormal, checkpoint, Pawn.Location, false);
				    if (HitActor != None)
					    GotoState(Pawn.LandMovementState);
				    else
				    {
					    Enable('Timer');
					    SetTimer(0.7,false);
				    }
			    }
		    }
        }
		else
		{
			Disable('Timer');

		    if (Physics!=PHYS_Movement)
			Pawn.SetPhysics(PHYS_Swimming);
		}
		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		local vector X,Y,Z, OldAccel;
	
		GetAxes(Rotation,X,Y,Z);
		OldAccel = Pawn.Acceleration;
		Pawn.Acceleration = NewAccel;
		Pawn.bUpAndOut = ((X Dot Pawn.Acceleration) > 0) && ((Pawn.Acceleration.Z > 0) || (Rotation.Pitch > 2048));
		if ( !Pawn.PhysicsVolume.bWaterVolume ) //check for waterjump
			NotifyPhysicsVolumeChange(Pawn.PhysicsVolume);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
	
		GetAxes(Rotation,X,Y,Z);

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1); 
		if ( VSize(NewAccel) < 1.0 )
			NewAccel = vect(0,0,0);
	
		//add bobbing when swimming
		Pawn.CheckBob(DeltaTime, Y);

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	function Timer()
	{
		if ( !Pawn.PhysicsVolume.bWaterVolume && (Role == ROLE_Authority) )
			GotoState(Pawn.LandMovementState);
	
		Disable('Timer');
	}
	
	function BeginState()
	{
		Disable('Timer');
		
	    if (Physics!=PHYS_Movement)
		Pawn.SetPhysics(PHYS_Swimming);
	}
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		Pawn.Acceleration = aForward*X + aStrafe*Y; 
		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
		// Update rotation.
		UpdateRotation(DeltaTime, 2);
		
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
	
	function BeginState()
	{
	    if (Physics!=PHYS_Movement)
		Pawn.SetPhysics(PHYS_Flying);
	}
}

state PlayerRocketing
{
ignores SeePlayer, HearNoise, Bump;

	/* ServerMove() 
	- replicated function sent by client to server - contains client movement and firing info
	Passes acceleration in components so it doesn't get rounded.
	IGNORE VANILLA SERVER MOVES
	*/
	function ServerMove
	(
		float TimeStamp, 
		vector InAccel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus, 
		bool NewbDoubleJump,
		EDoubleClickDir DoubleClickMove, 
		byte ClientRoll, 
		int View,
		bool NewbJetpack,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		if ( CurrentTimeStamp < TimeStamp )
	       Pawn.AutonomousPhysics(TimeStamp - CurrentTimeStamp);
		CurrentTimeStamp = TimeStamp;
		ServerTimeStamp = Level.TimeSeconds;
	}	

	function RocketServerMove
	(
		float TimeStamp, 
		vector InAccel, 
		vector ClientLoc,
		byte ClientRoll, 
		int View
	)
	{
		//if ( InAccel Dot Pawn.Velocity < 0 )
		//	InAccel = 0.1 * Pawn.AccelRate * Normal(Pawn.Velocity);
		Global.ServerMove(TimeStamp,InAccel,ClientLoc,false,false,false,false, DCLICK_NONE,ClientRoll,View, false);
	}	
		
    function PlayerMove(float DeltaTime)
    {
		Pawn.UpdateRocketAcceleration(DeltaTime,aTurn,aLookUp);
		SetRotation(Pawn.Rotation);        
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
    
    function BeginState()
    {
	    if (Physics!=PHYS_Movement)
        Pawn.SetPhysics(PHYS_Flying);
    }
}

function bool IsSpectating()
{
	return false;
}

state BaseSpectating
{
	function bool IsSpectating()
	{
		return true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, EDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
        MoveSmooth(SpectateSpeed * Normal(Acceleration) * DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if ( (Pawn(ViewTarget) != None) && (Level.NetMode == NM_Client) )
		{
			if ( Pawn(ViewTarget).bSimulateGravity )
				TargetViewRotation.Roll = 0;
			BlendedTargetViewRotation.Pitch = BlendRot(DeltaTime, BlendedTargetViewRotation.Pitch, TargetViewRotation.Pitch & 65535);
			BlendedTargetViewRotation.Yaw = BlendRot(DeltaTime, BlendedTargetViewRotation.Yaw, TargetViewRotation.Yaw & 65535);
			BlendedTargetViewRotation.Roll = BlendRot(DeltaTime, BlendedTargetViewRotation.Roll, TargetViewRotation.Roll & 65535);
		}
		GetAxes(Rotation,X,Y,Z);
	
		Acceleration = 0.02 * (aForward*X + aStrafe*Y + aUp*vect(0,0,1));  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DCLICK_None, rot(0,0,0));
	}
}

state Scripting
{
	// FIXME - IF HIT FIRE, AND NOT bInterpolating, Leave script
	exec function Fire( optional float F )
	{
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}
}

function ServerViewNextPlayer()
{
    local Controller C, Pick;
    local bool bFound, bRealSpec, bWasSpec;
#if !IG_TRIBES3 // david: not using Unreal team object
	local TeamInfo RealTeam;
#endif

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;
#if !IG_TRIBES3 // david: not using Unreal team object
    RealTeam = PlayerReplicationInfo.Team;
#endif
	
	// view next player
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
        if ( Level.Game.CanSpectate(self,true,C) )
		{
			if ( Pick == None )
                Pick = C;
			if ( bFound )
			{
                Pick = C;
				break;
			}	
			else
                bFound = ( (RealViewTarget == C) || (ViewTarget == C) );
		}
	}
#if !IG_TRIBES3 // david: not using Unreal team object
    PlayerReplicationInfo.Team = RealTeam;
#endif
	SetViewTarget(Pick);
    ClientSetViewTarget(Pick);
    if ( (ViewTarget == self) || bWasSpec )
		bBehindView = false;
	else
		bBehindView = true; //bChaseCam;
    ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

function ServerViewSelf()
{
	bBehindView = false;
    SetViewTarget(self);
    ClientSetViewTarget(self);
	ClientMessage(OwnCamera, 'Event');
}

function LoadPlayers()
{
	local int i;
	
	if ( GameReplicationInfo == None )
		return;
		
	for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
		GameReplicationInfo.PRIArray[i].UpdatePrecacheRenderData();
}

state Spectating extends BaseSpectating
{
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
	 ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

	exec function Fire( optional float F )
	{
		ServerViewNextPlayer();
	}

	// Return to spectator's own camera.
	exec function AltFire( optional float F )
	{
		bBehindView = false;
		ServerViewSelf();
	}

	function BeginState()
	{
		if ( Pawn != None )
		{
			SetLocation(Pawn.Location);
			UnPossess();
		}
		bCollideWorld = true;
	}

	function EndState()
	{
		PlayerReplicationInfo.bIsSpectator = false;		
		bCollideWorld = false;
	}
}

auto state PlayerWaiting extends BaseSpectating
{
#if IG_SHARED  //tcohen: hooked TakeDamage(), used by effects system and reactive world objects
ignores SeePlayer, HearNoise, NotifyBump, PostTakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon;
#else
ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon;
#endif

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}


#if IG_TRIBES3	// michaelj:  Allow admin override
	exec function ChangeTeam( int N, optional bool bAdminOverride )
#else
	function ChangeTeam( int N )
#endif
	{
        Level.Game.ChangeTeam(self, N, true);
	}

    function ServerRestartPlayer()
	{
#if !IG_TRIBES3 // david: don't wait to spawn player
		if ( Level.TimeSeconds < WaitDelay )
			return;
#endif
		if ( Level.NetMode == NM_Client )
			return;
		if ( Level.Game.bWaitingToStartMatch )
			PlayerReplicationInfo.bReadyToPlay = true;
		else
			Level.Game.RestartPlayer(self);
	}

	exec function Fire(optional float F)
	{
        LoadPlayers();
		ServerReStartPlayer();
	}
	
	exec function AltFire(optional float F)
	{
        Fire(F);
	}

	function EndState()
	{
		if ( Pawn != None )
			Pawn.SetMesh();
        if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(false);
		bCollideWorld = false;
	}

	function BeginState()
	{
		if ( PlayerReplicationInfo != None )
			PlayerReplicationInfo.SetWaitingPlayer(true);
		bCollideWorld = true;
	}
}

state WaitingForPawn extends BaseSpectating
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		AskForPawn();
	}

	exec function AltFire( optional float F )
	{
	}

	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{
		if ( newState == 'GameEnded' )
			GotoState(newState);
	}

	function PlayerTick(float DeltaTime)
	{
		Global.PlayerTick(DeltaTime);

#if !IG_TRIBES3 // dbeswick: shouldn't be needed, should be established by clientrestart
		if ( Pawn != None )
		{
			Pawn.Controller = self;
            Pawn.bUpdateEyeHeight = true;
			ClientRestart();
		}
        else 
#endif
		if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
		{
			SetTimer(0.2,true);
			AskForPawn();
		}
	}

	function Timer()
	{
		AskForPawn();
	}

	function BeginState()
	{
		SetTimer(0.2, true);
        AskForPawn();
	}

	function EndState()
	{
#if !IG_TRIBES3 // david: no need
		bBehindView = false;
#endif
		SetTimer(0.0, false);
	}
}

state GameEnded
{
#if IG_SHARED  //tcohen: hooked TakeDamage(), used by effects system and reactive world objects
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, PostTakeDamage, Suicide;
#else
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;
#endif

	function ServerReStartPlayer()
	{
	}
	
	function bool IsSpectating()
	{
		return true;
	}
	
	exec function ThrowWeapon()
	{
	}

	function ServerReStartGame()
	{
		Level.Game.RestartGame();
	}

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority)
			return;
		if ( !bFrozen )
			ServerReStartGame();
		else if ( TimerRate <= 0 )
			SetTimer(1.5, false);
	}
	
	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
		}
		else if ( ViewTarget != None )
			SetRotation(ViewTarget.Rotation);

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		bPressedJump = false;
	}

	function ServerMove
	(
		float TimeStamp, 
		vector InAccel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus, 
        bool NewbDoubleJump, 
		EDoubleClickDir DoubleClickMove, 
		byte ClientRoll, 
		int View,
		bool NewbJetpack,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
        Global.ServerMove(TimeStamp, InAccel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,NewbDoubleJump,
							DoubleClickMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)), NewbJetpack );

	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}
	
	function Timer()
	{
		bFrozen = false;
	}
	
	function LongClientAdjustPosition
	(
		float TimeStamp, 
		name newState, 
		EPhysics newPhysics,
		float NewLocX, 
		float NewLocY, 
		float NewLocZ, 
		float NewVelX, 
		float NewVelY, 
		float NewVelZ,
		Actor NewBase,
		float NewFloorX,
		float NewFloorY,
		float NewFloorZ
	)
	{   
	}
		 
	function BeginState()
	{
		local Pawn P;

		EndZoom();
        FovAngle = DesiredFOV;
		bFire = 0;
		bAltFire = 0;
		if ( Pawn != None )
		{
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
			Pawn.AmbientSound = None;
#endif
			Pawn.bSpecialHUD = false;
 			Pawn.bNoWeaponFiring = true;
			Pawn.SimAnim.AnimRate = 0;
			Pawn.bPhysicsAnimUpdate = false;
			Pawn.StopAnimating();
            Pawn.SetCollision(true,false,false);
            // DLB Controller clean pass: removed AI logic StopFiring();
 			Pawn.bIgnoreForces = true;
		}
		myHUD.bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			FindGoodView();
			bBehindView = true;
		}
        SetTimer(5, false);
		ForEach DynamicActors(class'Pawn', P)
		{
			if ( P.Role == ROLE_Authority )
				P.RemoteRole = ROLE_DumbProxy;
			P.SetCollision(true,false,false);
#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
			P.AmbientSound = None;
#endif
 			P.bNoWeaponFiring = true;
			P.Velocity = vect(0,0,0);
			P.SetPhysics(PHYS_None);
            P.bPhysicsAnimUpdate = false;
            P.StopAnimating();
            P.bIgnoreForces = true;
		}
	}

Begin:
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon;

	function bool IsDead()
	{
		return true;
	}

	function ServerReStartPlayer()
	{
		Super.ServerRestartPlayer();
	}

	exec function Fire( optional float F )
	{
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
        LoadPlayers();
		ServerReStartPlayer();
	}
	
	exec function AltFire( optional float F )
	{
			Fire(F);
	}

	function ServerMove
	(
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus,
        bool NewbDoubleJump,
		EDoubleClickDir DoubleClickMove, 
		byte ClientRoll, 
		int View,
		bool NewbJetpack,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(
					TimeStamp,
					Accel, 
					ClientLoc,
					false,
					false,
					false,
                    false,
					DoubleClickMove, 
					ClientRoll, 
					View,
					false);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator ViewRotation;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}
        else if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
			bFrozen = false;

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot, ViewRotation;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;
		
		////log("Find good death scene view");
		ViewRotation = Rotation;
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;
		
		for (tries=0; tries<16; tries++)
		{
			cameraLoc = ViewTarget.Location;
			SetRotation(ViewRotation);
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - ViewTarget.Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;	
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}
			
		ViewRotation.Yaw = startYaw + besttry * 4096;
		SetRotation(ViewRotation);
	}
	
	function Timer()
	{
		if (!bFrozen)
			return;
			
		bFrozen = false;
		bPressedJump = false;
	}
	
	function BeginState()
	{
		if ( (Pawn != None) && (Pawn.Controller == self) )
			Pawn.Controller = None;
		EndZoom();
		FovAngle = DesiredFOV;
		Pawn = None;
		// DLB Controller clean pass: removed AI logic Enemy = None;
		bBehindView = true;
		bFrozen = true;
		bJumpStatus = false;
		bPressedJump = false;
        bBlockCloseCamera = true;
		bValidBehindCamera = false;
		FindGoodView();
        SetTimer(1.0, false); 
		StopForceFeedback();
		ClientPlayForceFeedback("Damage");  // jdf
		CleanOutSavedMoves();
	}
	
	function EndState()
	{
		bBlockCloseCamera = false;
		CleanOutSavedMoves();
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
        if ( !PlayerReplicationInfo.bOutOfLives )
			bBehindView = false;
		bPressedJump = false;
		myHUD.bShowScores = false;
}
Begin:
    Sleep(3.0);
    myHUD.bShowScores = true;
}

//------------------------------------------------------------------------------
// Control options	
function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}

// Replace with good code
#if IG_GUI_LAYOUT //dkaplan - command line call to open a menu of given class type
exec function OpenMenu( string theMenu )
{
    Player.GUIController.OpenMenu( theMenu, Right(theMenu,Len(theMenu)-InStr(theMenu,".")-1) );
}
#endif

#if IG_GUI_LAYOUT //dkaplan - removed additional unused param
event ClientOpenMenu (string MenuClass, optional string MenuName, optional bool bDisconnect,optional string Msg1, optional string Msg2, optional int Msg3)
{
	Player.GUIController.OpenMenu(MenuClass, MenuName, Msg1, Msg2, Msg3);
	if (bDisconnect)
		ConsoleCommand("Disconnect");
}

event ClientCloseMenu(optional bool bCloseAll)
{
	if (bCloseAll)
		Player.GUIController.CloseAll();
	else
		Player.GUIController.CloseMenu();
}
#else
event ClientOpenMenu (string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	Player.GUIController.OpenMenu(Menu, Msg1, Msg2);
	if (bDisconnect)
		ConsoleCommand("Disconnect");
}

event ClientCloseMenu(optional bool bCloseAll, optional bool bCancel)
{
	if (bCloseAll)
		Player.GUIController.CloseAll(bCancel);
	else
		Player.GUIController.CloseMenu(bCancel);
}
#endif
function bool CanRestartPlayer()
{
    return !PlayerReplicationInfo.bOnlySpectator;
}

event ServerChangeVoiceChatter( PlayerController Player, int IpAddr, int Handle, bool Add )
{
	if( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
	{
		Level.Game.ChangeVoiceChatter( Player, IpAddr, Handle, Add );
	}
}

event ServerGetVoiceChatters( PlayerController Player )
{
	local int i;
	
	if( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
	{
		for( i=0; i<Level.Game.VoiceChatters.Length; i++ )
		{
			if( Player != Level.Game.VoiceChatters[i].Controller )
			{
				Player.ClientChangeVoiceChatter( Level.Game.VoiceChatters[i].IpAddr, Level.Game.VoiceChatters[i].Handle, true );
			}
		}
	}
}

simulated function ClientChangeVoiceChatter( int IpAddr, int Handle, bool Add )
{
	ChangeVoiceChatter( IpAddr, Handle, Add );
}
	
simulated function ClientLeaveVoiceChat()
{
	LeaveVoiceChat();
}
	
native final function LeaveVoiceChat();
native final function ChangeVoiceChatter( int IpAddr, int Handle, bool Add );

//--------------------- Demo recording stuff

// Called on the client during client-side demo recording
simulated event StartClientDemoRec()
{
	// Here we replicate functions which the demo never saw.
	//DemoClientSetHUD( MyHud.Class, MyHud.ScoreBoard.Class );
	
	// tell server to replicate more stuff to me
	bClientDemo = true;
	ServerSetClientDemo();
}

function ServerSetClientDemo()
{
	bClientDemo = true;
}

// Called on the playback client during client-side demo playback
simulated function DemoClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	//if( MyHUD == None )
	//	ClientSetHUD( newHUDClass, newScoringClass );
}

#if IG_UDN_UTRACE_DEBUGGING // ckline: UDN UTrace code
function ServerUTrace()
{
	if( Level.NetMode != NM_Standalone /*&& AdminManager == None*/ )
		return;
	
	UTrace();
}
exec function UTrace()
{
	// If they're running with "-log", be sure to turn it off
	ConsoleCommand("HideLog");
	if( Role!=ROLE_Authority ) {
		ServerUTrace();
	}
	SetUTracing( !IsUTracing() );
	log("UTracing changed to "$IsUTracing()$" at "$Level.TimeSeconds);
}
#endif // IG_UDN_UTRACE_DEBUGGING 

#if IG_MOJO
exec function showEscapeMenu()
{
	// try to escape any playing cutscenes
	Level.EscapeCutscene();
}
#endif

#if IG_TRIBES3_ADMIN
/////////////////////////////////////////////////////////////////////////////
// Admin Handling : Was previously in Admin.uc
//
// 
//

function MakeAdmin()
{
	if ( AdminManager == None && Level != None && Level.Game != None && Level.Game.AccessControl != None)
	    if (Level.Game.AccessControl.AdminClass == None)
		    Log("AdminClass is None");
        else
	    {
		    log("access control: "$Level.Game.AccessControl.name);
		    log("admin class: "$Level.Game.AccessControl.AdminClass.name);
    		
		    AdminManager = new(self) Level.Game.AccessControl.AdminClass;
		 
		    AdminManager.Created();
		    
		    log("successfully created admin manager: "$AdminManager.name);
	    }
}

/////////////////////////////////////////////////////////////////////////////
// Admin Handling : Was previously in Admin.uc
//
// 
//

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
local string Result;

	if (AdminManager != None)
	{
		Log("Doing Admin Command!:"@CommandLine);
		Result = ConsoleCommand( CommandLine );
		if (Level.Game.AccessControl != None && Level.Game.AccessControl.bReplyToGUI)
			AdminReply(Result);
		else if( Result!="" )
			ClientMessage( Result );
	}
}

#if IG_TRIBES3	// michaelj:  Integrated UT2004 admin login
exec function AdminLogin(string CmdLine)
{
	if ( Level.TimeSeconds < NextLoginTime )
		return;

	NextLoginTime = Level.TimeSeconds + LoginDelay;
	ServerAdminLogin(CmdLine);
}

function ServerAdminLogin( string CmdLine )
{
	local string uname, upass;

	if (AdminManager == None)
	{
		MakeAdmin();
		if ( AdminManager != None )
		{
			if ( !Div(CmdLine, " ", uname, upass) )
				upass = CmdLine;

			AdminManager.DoLogin(uname, upass);
			//ConsoleCommand("DoLogin"@CmdLine);
			if ( !AdminManager.bAdmin )
				AdminManager = None;
			else AddCheats();
		}
	}
}
#else
exec function AdminLogin(string CmdLine)
{
	Log("AdminLogin '"$CmdLine$"'");
	if (AdminManager == None)
	{
		MakeAdmin();
		ConsoleCommand("DoLogin"@CmdLine);
		if (!AdminManager.bAdmin)
		{
		    log("admin login failed");
			AdminManager = None;
		}
		else
		{
		    log("admin login ok");
			AddCheats();
		}
	}
}
#endif

// dbeswick: added functions to allow admins to give rights to other players
exec function AdminPromote(string TargetPlayerName)
{
	local Controller C;
	local PlayerController Target;

	Log("AdminPromote '"$TargetPlayerName$"'");

	if (AdminManager != None)
	{
		C = Level.ControllerList;
		while (C != None)
		{
			if (PlayerController(C) != None && 
				PlayerController(C).PlayerReplicationInfo != None && 
				PlayerController(C).PlayerReplicationInfo.PlayerName ~= TargetPlayerName)
			{
				Target = PlayerController(C);
				break;
			}
			C = C.nextController;
		}
		
		if (Target == None)
		{
			Level.Game.BroadcastHandler.BroadcastText( PlayerReplicationInfo, self, "Admin Promote: Couldn't find a player named"@TargetPlayerName );
			return;
		}

		if (Target.AdminManager == None)
		{
			ConsoleCommand("DoPromote"@Target);
			if (Target.AdminManager == None || !Target.AdminManager.bAdmin)
			{
				log("admin promote failed");
			}
			else
			{
				log("admin promote ok");
			}
		}
	}
}

// forces the current character into admin mode
function ForceAdmin()
{
	if (AdminManager == None)
		MakeAdmin();
	AdminManager.bAdmin = true;
	PlayerReplicationInfo.bAdmin = true;
	AddCheats();
}

function AdminCommand( string CommandLine )
{
	if (CommandLine ~= "Logged")
	{
		ReportAdmin();
	}
	else if (Left(CommandLine, 11) ~= "AdminLogin ")
	{
		AdminLogin(Mid(CommandLine, 11));
		ReportAdmin();
	}
	else if (Left(CommandLine, 11) ~= "AdminLogout")
	{
		AdminLogout();
		ReportAdmin();
	}
	else if (Level.Game.AccessControl != None)
	{
		Level.Game.AccessControl.bReplyToGUI = true;
		Admin(CommandLine);
		Level.Game.AccessControl.bReplyToGUI = false;
	}
}

function ReportAdmin()
{
	if (AdminManager != None && AdminManager.bAdmin)
	{
		if (Level.Game.AccessControl != None)
			AdminReply(Level.Game.AccessControl.GetAdminName(Self));
		else
			AdminReply("Admin");
	}
	else
		AdminReply("");
}

function AdminReply( string Reply )
{
	Log("Received AdminReply: '"$Reply$"'");
	if (Player.GUIController != None)
		Player.GUIController.OnAdminReply(Reply);
}

exec function AdminLogout()
{
  if (AdminManager != None)
  {
	AdminManager.DoLogout();
	if (!AdminManager.bAdmin)
		AdminManager = None;
  }
}

#endif

#if IG_TRIBES3_VOTING   // glenn: voting support
simulated event GainedChild( Actor Other )
{
	Super.GainedChild(Other);
	
	if ( VotingReplicationInfoBase(Other) != None )
	{
		VoteReplicationInfo = VotingReplicationInfoBase(Other);
		//log("*** gained vote info child: "$VoteReplicationInfo$" ***");
    }
}

simulated event LostChild(Actor Other)
{
	Super.LostChild(Other);

	if (VotingReplicationInfoBase(Other) != None)
	{
		VoteReplicationInfo = None;
		//log("*** lost vote info child ***");
	}
}
#endif

#if IG_TRIBES3 // dbeswick: to properly handle travel with in a vehicle
event Pawn GetTravelPawn()
{
	return Pawn;
}
#endif

defaultproperties
{
	 AimingHelp=0.0
     OrthoZoom=+40000.000000
     FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
	 AnnouncerVolume=4
	 FovAngle=85.000
     DesiredFOV=85.000000
	 DefaultFOV=85.000000
     Handedness=1.000000
     bAlwaysMouseLook=True
	 ViewingFrom="Now viewing from"
	 OwnCamera="Now viewing from own camera"
     QuickSaveString="Quick Saving"
	 QuickSaveName="QuickSave";
     NoPauseMessage="Game is not pauseable"
     bTravel=True
     bStasis=False
	 NetPriority=3
    MaxTimeMargin=+0.35
	 LocalMessageClass=class'LocalMessage'
	 bIsPlayer=true
	 Physics=PHYS_None
	 EnemyTurnSpeed=45000
	 CheatClass=class'Engine.CheatManager'
	 InputClass=class'Engine.PlayerInput'
	 CameraDist=+9.0
	 bZeroRoll=true
    bDynamicNetSpeed=true
    // jdf ---
    bEnableWeaponForceFeedback=True
    bEnablePickupForceFeedback=True
    bEnableDamageForceFeedback=True
    bEnableGUIForceFeedback=True
    bForceFeedbackSupported=True
    // --- jdf
    ProgressTimeOut=8.0
    MaxResponseTime=0.7
    SpectateSpeed=+600.0
    DynamicPingThreshold=+400.0
    ClientCap=0
	Texture=None // dbeswick: tribes3
}
