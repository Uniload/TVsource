//=============================================================================
// LevelInfo contains information about the current level. There should 
// be one per level and it should be actor 0. UnrealEd creates each level's 
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native
	nativereplication;

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.
var			  float	PauseDelay;		// time at which to start pause

//-----------------------------------------------------------------------------
// Level Summary Info

var(LevelSummary) localized String 	Title;
var(LevelSummary)           String 	Author;
#if !IG_TRIBES3	// michaelj:  Use min and max instead
var(LevelSummary)			int 	RecommendedNumPlayers;
#endif

#if IG_TRIBES3	// rowan: name of localisation file for this level
var(LevelSummary)			String	LocalisationFile;
#endif

#if IG_TRIBES3	// michaelj:  Additional information (some integrated from UT2004)
var(LevelSummary) Array< class<GameInfo> >	SupportedModes				"List of modes that this map supports.";
var(LevelSummary) Array< int >				SupportedModesScoreLimits	"Parallels the SupportedModes array.  Score limit for each game type.  0 to disable.";
var(LevelSummary) localized String  Description		"Description of this level.";
var(LevelSummary)			Material Screenshot		"A screenshot of this level.";
var(LevelSummary)			int		IdealPlayerCountMin		"Recommended minimum number of players for this level.";
var(LevelSummary)			int		IdealPlayerCountMax		"Recommended maximum number of players for this level.";
var(LevelSummary)			String	ExtraInfo;
#endif

#if IG_TRIBES3	// rowan: music manager
var MusicManagerBase		MusicMgr;
#endif

var() config enum EPhysicsDetailLevel
{
	PDL_Low,
	PDL_Medium,
	PDL_High
} PhysicsDetailLevel;


// Karma - jag
var(Karma) float KarmaTimeScale;		// Karma physics timestep scaling.
var(Karma) float RagdollTimeScale;		// Ragdoll physics timestep scaling. This is applied on top of KarmaTimeScale.
var(Karma) int   MaxRagdolls;			// Maximum number of simultaneous rag-dolls.
var(Karma) float KarmaGravScale;		// Allows you to make ragdolls use lower friction than normal.
var(Karma) bool  bKStaticFriction;		// Better rag-doll/ground friction model, but more CPU.

var()	   bool bKNoInit;				// Start _NO_ Karma for this level. Only really for the Entry level.
// jag

var(Havok)    bool bHavokDisabled;          //  Disable Havok for this level.
var(Havok)    float HavokStepTimeQuantum;   // Usually 0.016f (1/60) of a sec)
var(Havok)    string HavokMoppCodeFilename; // The optional filename to load the static (prebuilt) Mopp code from.
var(Havok)    int HavokBroadPhaseDimension; // Something like 50,000 or so. Must encompase the whole world from the orign

#if IG_TRIBES3 // Alex:
var (Havok) bool vehicleCeilingEnabled;
var (Havok) float vehicleCeilingHeight;
#endif

#if IG_TRIBES3 // Alex:
var() bool bNoPathfinding;
#endif

var config float	DecalStayScale;		// 0 to 2 - affects decal stay time

var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             PlayerReplicationInfo Pauser;          // If paused, name of person pausing the game.
var		LevelSummary Summary;
var           string VisibleGroups;			// List of the group names which were checked when the level was last saved
var transient string SelectedGroups;		// A list of selected groups in the group browser (only used in editor)
//-----------------------------------------------------------------------------
// Flags affecting the level.

var(LevelSummary) bool HideFromMenus;
var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var const EDetailMode	DetailMode;      // Client detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var config bool		 bLowSoundDetail;
var	bool			 bPathsRebuilt;	  // True if path network is valid
var bool			 bHasPathNodes;
var globalconfig bool bCapFramerate;		// frame rate capped in net play if true (else limit number of servermove updates)
var	bool			bLevelChange;

//-----------------------------------------------------------------------------
// Renderer Management.
var config bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Legend - used for saving the viewport camera positions
var() vector  CameraLocationDynamic;
var() vector  CameraLocationTop;
var() vector  CameraLocationFront;
var() vector  CameraLocationSide;
var() rotator CameraRotationDynamic;

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) string	Song;			// Filename of the streaming song.
var(Audio) float	PlayerDoppler;	// Player doppler shift, 0=none, 1=full.
var(Audio) float	MusicVolumeOverride;

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
#if !IG_TRIBES3	// michaelj:  Use material in LevelSummary instead (see above)
var() texture Screenshot;
#endif
var texture DefaultTexture;
var texture WireframeTexture;
var texture WhiteSquareTexture;
var texture LargeVertex;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

var transient GameReplicationInfo GRI;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
#if IG_SHARED // karl:
var string BuildVersion; // Engine version.
#endif

//-----------------------------------------------------------------------------
// Gameplay rules

var() string DefaultGameType;
var() string PreCacheGame;
var GameInfo Game;
var float DefaultGravity;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
#if IG_TRIBES3
var transient const Controller ControllerList;
#else
var const Controller ControllerList;
#endif // IG
var private PlayerController LocalPlayerController;		// player who is client here

#if IG_SHARED
var transient const Pawn PawnList;
#endif

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Global object recycling pool.

#if IG_TRIBES3 // Ryan: ObjectPool no longer transient
var ObjectPool ObjectPool;
#else
var transient ObjectPool	ObjectPool;
#endif // IG

//-----------------------------------------------------------------------------
// Additional resources to precache (e.g. Playerskins).

var transient array<material>	PrecacheMaterials;
var transient array<staticmesh> PrecacheStaticMeshes;
#if IG_SHARED	// rowan: precache skeletal meshes
var transient array<mesh>		PrecacheMeshes;
#endif

#if IG_EFFECTS
var config enum EPlatform
{
	PC,
	PS2,
	XBOX
} Platform;

var IGEffectsSystemBase EffectsSystem;

var private array<Actor>		InterestedActorsGameStarted;		//these are the Actors who are interested in game started, ie. currently registered for notification
#endif

#if IG_SCRIPTING // david:
var MessageDispatcher messageDispatcher;
#endif

#if IG_SCRIPTING // Paul: CutsceneManager class
var transient Object	cutsceneManager;
#endif

#if IG_TRIBES3 // Paul: SpeechManager instance
var transient SpeechManager speechManager;
#endif // IG_TRIBES3

#if IG_SHARED	// marc: class to hang global AI data from 
var Tyrion_Setup	AI_Setup;
#endif

#if IG_SHARED || IG_EFFECTS // tcohen: effects needs this to support Actor.bTriggerEffectEventsBeforeGameStarts
var private transient bool bGameStarted;  // use HasGameStarted() to access
#endif

#if IG_MOJO
var globalconfig bool	bSkipMojoCutscenes;
var string				MojoFileURL; // URL to the mojo file. Will be blank for a newly loaded level and filled in on level load, used to 
									 // ensure that savegames can find the correct mojo file when loading.
#endif

//-----------------------------------------------------------------------------
// Replication
var float MoveRepSize;

// these two properties are valid only during replication
var const PlayerController ReplicationViewer;	// during replication, set to the playercontroller to
												// which actors are currently being replicated
var const Actor  ReplicationViewTarget;				// during replication, set to the viewtarget to
												// which actors are currently being replicated

#if IG_MOJO
var bool bIsMojoPlaying;
#endif

#if IG_TRIBES3 // dbeswick: campaign
var deepcopy Object savedCampaign;	// do not use, access TribesGUIControllerBase.GuiConfig.CurrentCampaign
#endif

//-----------------------------------------------------------------------------
// Team changed interface support

var array<IInterestedTeamChanged> teamChangedListeners;

//-----------------------------------------------------------------------------
// Functions.

#if IG_TRIBES3 // Paul: accessor functions for map data
native function Material GetMapTexture();
native function Vector GetMapTextureOrigin();
native function float GetMapTextureExtent();
#endif

#if IG_SHARED // Ryan: Allow access to the GameSpy manager
final native function GameSpyManager GetGameSpyManager();
#endif // IG

//#if UNREAL_HAVOK

// Update the collidabilty between two layers (A and B). See the HavokRigidBody.uc for details on 
// layers. If you are doing a few of these updates at once, only updateWorldInfo as true on the last one.
// updateWorldInfo needs to be set for at least one before the next step, BUT it is slow to do.
native final function HavokSetCollisionLayerEnabled(int layerA, int layerB, bool enabled, bool updateWorldInfo);

// If you use collision layers, and want to use the system layers in those, you can use this
// func to find the next free (unused) system layer (32K of them) and once you call this it will be deemed to be used.
// Be careful as any object can use which ever layer they like so if you don't use this func
// for all of them they may overlap if handcoded ones are not very high (this auto starts at 1)
// Will return -1 if none left.
native final function HavokGetNextFreeSystemLayer(out int systemLayer);

//endif

#if IG_MOJO // rowan: 
native final function PlayMojoCutscene(name cutsceneName);
native final function PlayAllMojoCutscenes();
native function bool EscapeCutscene();
#endif // IG

native final function UpdateMovementConfiguration();

native simulated function DetailChange(EDetailMode NewDetailMode);
native simulated function bool IsEntry();
#if IG_TRIBES3 // dbeswick:
native simulated function bool IsPendingActive();
#endif

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	DecalStayScale = FClamp(DecalStayScale,0,2);
}


#if IG_EFFECTS
simulated function CreateEffectsSystem()
{
    local class<IGEffectsSystemBase> EffectsSystemClass;

    EffectsSystemClass = class'IGEffectsSystemBase'.static.GetEffectsSystemClass();
	EffectsSystem = new(self, "EffectsSystem", 0) EffectsSystemClass;
    assertWithDescription(EffectsSystem != None,
        "The EffectsSystem could not be created.  (LevelInfo tried to create a new instance of class "$EffectsSystemClass$")");
}

simulated function InitializeEffectsSystem()
{
	local float time;
	time = AppSeconds();
    EffectsSystem.Init(self);
	time = AppSeconds() - time;

	log( "LevelInfo::InitializeEffectsSystem() called. Initialised in "$time$" seconds.");
}
#endif

#if IG_TRIBES3 // Ryan: effects system initialisation when loading a save game
event PostLoadGame()
{
	SetupTransientData();
}
#endif // IG

simulated function class<GameInfo> GetGameClass()
{
	local class<GameInfo> G;

	if(Level.Game != None)
		return Level.Game.Class;

	if (GRI != None && GRI.GameClass != "")
		G = class<GameInfo>(DynamicLoadObject(GRI.GameClass,class'Class'));
	if(G != None)
		return G;

	if ( DefaultGameType != "" )
		G = class<GameInfo>(DynamicLoadObject(DefaultGameType,class'Class'));

	return G;
}

simulated event FillRenderPrecacheArrays()
{
	local Actor A;
	local class<GameInfo> G;
	
	if ( NetMode == NM_DedicatedServer )
		return;
	if ( Level.Game == None )
	{
		if ( (GRI != None) && (GRI.GameClass != "") )
			G = class<GameInfo>(DynamicLoadObject(GRI.GameClass,class'Class'));
		if ( (G == None) && (DefaultGameType != "") )
			G = class<GameInfo>(DynamicLoadObject(DefaultGameType,class'Class'));
		if ( G == None )
			G = class<GameInfo>(DynamicLoadObject(PreCacheGame,class'Class'));
		if ( G != None )
			G.Static.PreCacheGameRenderData(self);
	}
	ForEach AllActors(class'Actor',A)
	{
		A.UpdatePrecacheRenderData();
	}
}

#if IG_SHARED	// rowan:
simulated function AddPrecacheMesh(Mesh mesh)
{
	local int i, Index;

	if ( NetMode == NM_DedicatedServer )
		return;
    if (mesh == None)
        return;

	// keep unique items in array
	// hmmm, need non unique items, so we can create mesh pool instances
	for (i=0; i<PrecacheMeshes.length; i++)
	{
		if (PrecacheMeshes[i] == mesh)
			return;
	}

//	LOG("PRECACHING MESH "$mesh.Name);

    Index = Level.PrecacheMeshes.Length;
	PrecacheMeshes.Insert(Index, 1);
	PrecacheMeshes[Index] = mesh;
}
#endif

simulated function AddPrecacheMaterial(Material mat)
{
    local int i, Index;

	if ( NetMode == NM_DedicatedServer )
		return;
    if (mat == None)
        return;

#if IG_SHARED	// rowan: keep unique entries in array
	for (i=0; i<PrecacheMaterials.length; i++)
	{
		if (PrecacheMaterials[i] == mat)
			return;
	}
#endif

//	LOG("PRECACHING MATERIAL "$mat.Name);

    Index = Level.PrecacheMaterials.Length;
    PrecacheMaterials.Insert(Index, 1);
	PrecacheMaterials[Index] = mat;
}

simulated function AddPrecacheStaticMesh(StaticMesh stat)
{
    local int i, Index;

	if ( NetMode == NM_DedicatedServer )
		return;
    if (stat == None)
        return;

#if IG_SHARED	// rowan: keep unique entries in array
	for (i=0; i<PrecacheStaticMeshes.length; i++)
	{
		if (PrecacheStaticMeshes[i] == stat)
			return;
	}
#endif

//	LOG("PRECACHING STATICMESH "$stat.Name);

    Index = Level.PrecacheStaticMeshes.Length;
    PrecacheStaticMeshes.Insert(Index, 1);
	PrecacheStaticMeshes[Index] = stat;
}

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Demo build flag
//
native simulated final function bool IsDemoBuild();  // True if this is a demo build.


//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if( NextURL=="" )
	{
		bLevelChange = true;
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted()
{
	local DefaultPhysicsVolume P;
	P = None;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation, DefaultGravity;

	reliable if( bNetInitial && Role==ROLE_Authority )
		RagdollTimeScale, KarmaTimeScale, KarmaGravScale;
}


#if IG_EFFECTS
//register for notification that game has started... will get OnGameStarted() call.
simulated function InternalRegisterNotifyGameStarted(Actor registeree) 
{ 
	local int i;

	for (i=0; i<InterestedActorsGameStarted.length; i++)
		if (InterestedActorsGameStarted[i] == registeree)
			AssertWithDescription(false, registeree$" is re-registering for NotifyGameStarted");

	InterestedActorsGameStarted[InterestedActorsGameStarted.length] = registeree;
}

//called by ULevel::Tick on the first frame of the game
simulated event NotifyGameStarted()
{
	local int i;

	assert(!bGameStarted);
	log( "LevelInfo::NotifyGameStarted() called on Level '"$Outer.Name$"' that has Label '"$Label$"'");

//    if (Outer.Name != 'Entry') 
//    {
#if IG_EFFECTS // Carlos: Moved this from PostBeginPlay so Flushing of queued events happens after the game has started
        Level.InitializeEffectsSystem();
        EffectsSystem.AddPersistentContext(name("Level_"$Label));
#endif

	    //notify interested Actors
	    for (i=0; i<InterestedActorsGameStarted.length; i++)
		{
		    InterestedActorsGameStarted[i].OnGameStarted();
		}
//    }
}

//add a string tag to the current frame about a potentially slow code operation
simulated function GuardSlow(String GuardString) { assert(false); }
#endif

#if IG_SHARED // ckline: notifications upon Pawn death and Actor destruction

// NOTE: When an object that has previously registered via any of the following
// RegisterNotifyXXXX() methods is itself destroyed, it will automatically be
// UnRegistered for all subsequent notifications. Therefore, while possible, 
// it is not necessary for an object to UnRegisterXXX() itself upon destruction.

// WARNING: These methods only guaranteed send notification during normal
// gameplay. During level transitions all listeners will be un-registered 
// and no further notifications will be sent to any listeners (unless 
// they re-register themselves when the next level begins). 
//
// For these reasons, objects should not rely on these notifications for 
// cleanup during level transitions.

// Register for notification whenever Died() is called on a Pawn, or 
// PawnDied() is called on the pawn's Controller (whichever happens first). 
// See comments in IInterestedPawnDied.uc for additional details.
// 
// Note: If ObjectToNotify is itself a pawn, it *will* receive notification of its
// own death.
native final function RegisterNotifyPawnDied(IInterestedPawnDied ObjectToNotify);
native final function UnRegisterNotifyPawnDied(IInterestedPawnDied RegisteredObject);

// Register for notification whenever a Engine.Actor for which bStatic=false
// is destroyed during gameplay. Static actors will not generate notifications
// when they are destroyed.
//  
// See comments in IInterestedActorDestroyed.uc for additional details.
//
// WARNING: Even if ObjectToNotify is itself an Actor, it will NOT be 
// notified of its own destruction. If it wishes to handle its own 
// destruction, it should override Pawn.Destroyed().
native final function RegisterNotifyActorDestroyed(IInterestedActorDestroyed ObjectToNotify);
native final function UnRegisterNotifyActorDestroyed(IInterestedActorDestroyed RegisteredObject);

#endif // IG_SHARED

#if IG_TRIBES3
// Team change interface
function registerNotifyTeamChanged( IInterestedTeamChanged objectToNotify )
{
	assert( objectToNotify != None );

    teamChangedListeners[teamChangedListeners.Length] = objectToNotify;
}

function unRegisterNotifyTeamChanged( IInterestedTeamChanged registeredObject )
{
    local int i;
    
    assert( registeredObject != None );
    
    for( i = 0; i < teamChangedListeners.Length; ++i )
    {
        if ( teamChangedListeners[i] == registeredObject )
        {
            teamChangedListeners.Remove(i, 1);
            break;
        }
    }
}

function notifyListenersTeamChanged( Pawn pawn )
{
	local int i;
	local IInterestedTeamChanged listener;

    //log( "+++ Received notification that" @ pawn.name @ "has changed team" );

    for ( i = 0; i < teamChangedListeners.length; ++i )
    {
        listener = teamChangedListeners[i];
		//log( "+++    -> Notifying" @ listener.name );
		listener.onTeamChanged( pawn );
    }
}
#endif

//
//	PreBeginPlay
//

simulated event PreBeginPlay()
{
	// Create the object pool.
#if IG_TRIBES3 // Ryan: ObjectPool no longer transient
	ObjectPool = new class'ObjectPool';
#else
	ObjectPool = new(none) class'ObjectPool';
#endif // IG

#if IG_SCRIPTING // david:
	MessageDispatcher = new class'MessageDispatcher';
#endif

#if IG_SHARED	// marc: class to hang global AI data from
	AI_Setup = spawn( class<Tyrion_Setup>( DynamicLoadObject( "Tyrion.Setup", class'Class') ));
#endif

#if IG_TRIBES3 // rowan: called by prebeginplay and postloadgame
	SetupTransientData();
#endif
}

#if IG_TRIBES3 // rowan: called by prebeginplay and postloadgame
simulated function SetupTransientData()
{
#if IG_EFFECTS
	CreateEffectsSystem();
#endif

#if IG_SCRIPTING // Paul: Cutscene manager initialisation
	cutsceneManager = new Class(DynamicLoadObject( "Scripting.CutsceneManager", class'Class'));
#endif
}
#endif

#if IG_SHARED || IG_EFFECTS // tcohen: effects needs this to support Actor.bTriggerEffectEventsBeforeGameStarts

simulated function bool HasGameStarted()
{
    return bGameStarted;
}
#endif // IG_SHARED || IG_EFFECTS

simulated event PlayerController GetLocalPlayerController()
{
	local PlayerController PC;

	if ( Level.NetMode == NM_DedicatedServer )
		return None;
	if ( LocalPlayerController != None )
		return LocalPlayerController;

	ForEach DynamicActors(class'PlayerController', PC)
	{
// IGB: mcj-- I'm commenting this test out. The player doesn't appear to have a
// Viewport by this point. Mongo says that there is only one PlayerController in
// a network game, so it's irrelevant whether it has a viewport or not.
		// Actually, this is only true on the client. On the server, though, the
		// LocalPlayerController variable is set before the second PlayerController is
		// created, so this should work. It's a hack, though, so we need a better way.
		// The viewport thing below doesn't work.
#if !IG_SHARED
		if ( Viewport(PC.Player) != None )
		{
#endif
			LocalPlayerController = PC;
			break;
#if !IG_SHARED
		}
#endif
	}
	return LocalPlayerController;
}

#if IG_TRIBES3 // dbeswick: added AllControllers iterator: iterates through the level's controller list
native iterator function AllControllers( class<Controller> BaseClass, out actor Actor );
#endif

#if IG_TRIBES3 // dbeswick: this function is called to determine whether a projectile can hit this actor
simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	return true;
}
#endif

defaultproperties
{
     TimeDilation=1.000000
     Title="Untitled"
     PhysicsDetailLevel=PDL_High
     KarmaTimeScale=0.900000
     RagdollTimeScale=1.000000
     MaxRagdolls=4
     KarmaGravScale=1.000000
     bKStaticFriction=True
     HavokBroadPhaseDimension=524288
     vehicleCeilingEnabled=True
     vehicleCeilingHeight=3000.000000
     DecalStayScale=1.000000
     VisibleGroups="None"
     DetailMode=DM_SuperHigh
     bCapFramerate=True
     MusicVolumeOverride=-1.000000
     Brightness=1.000000
     DefaultTexture=Texture'Engine_res.DefaultTexture'
     WireframeTexture=Texture'Engine_res.WireframeTexture'
     WhiteSquareTexture=Texture'Engine_res.WhiteSquareTexture'
     LargeVertex=Texture'Engine_res.LargeVertex'
     PreCacheGame="Engine.GameInfo"
     DefaultGravity=-1160.000000
     MoveRepSize=42.000000
     bWorldGeometry=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_DumbProxy
     bHiddenEd=True
}
