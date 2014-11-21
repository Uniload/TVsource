//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Core.Subsystem
	native
	noexport
	transient;

// Drivers.
var(Drivers) config class<AudioSubsystem> AudioDevice;
var(Drivers) config class<Interaction>    Console;				// The default system console
var(Drivers) config class<Interaction>	  DefaultMenu;			// The default system menu 
var(Drivers) config class<Interaction>	  DefaultPlayerMenu;	// The default player menu
var(Drivers) config class<NetDriver>      NetworkDevice;
var(Drivers) config class<Core.Language>  Language;

// Variables.
var primitive Cylinder;
var const client Client;
var const audiosubsystem Audio;
var const renderdevice GRenDev;

#if IG_SHARED	// rowan: exec hook
var transient const int	GameExecHook;
#endif


// Stats.
var int bShowFrameRate;
var int bShowRenderStats;
var int bShowHardwareStats;
var int bShowGameStats;
var int bShowNetStats;
var int bShowAnimStats;		 // Show animation statistics.
#if IG_TRIBES3
var int bShowEngineStats;
#endif

#if IG_SHARED
var int bShowAIStats;
#endif

// ifdef WITH_LIPSINC
var int bShowLIPSincStats;   // Show LIPSinc statistics.
// endif

// IGA >>> DEBUG_GUI: Debug gui interface members
var transient const int m_debugGui;
var int m_ownDebugGui;
// IGA

var int bShowHistograph;
var int bShowXboxMemStats;
var int bShowMatineeStats;	// Show Matinee specific information
var int bShowAudioStats;
var int bShowLightStats;

var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;

#if IG_SHARED	// ryan: allow perforce support to be enabled/disabled
var(Advanced) config int UsePerforce;
var config int ForceActorCleanup;
#endif // IG

var(Settings) config bool UseSound;
var(Settings) config bool UseStaticMeshBatching;
#if IG_SHARED	// rowan: disable dev tools stuff
var(Settings) config bool EnableDevTools;
#endif
#if IG_TRIBES3 // dbeswick:
var(Settings) config bool EnableCheatProtection;
#endif
var(Settings) float CurrentTickRate;

var int ActiveControllerId;	// The ID of the active controller
// Color preferences.
var(Colors) config color
	C_WorldBox,
	C_GroundPlane,
	C_GroundHighlight,
	C_BrushWire,
	C_Pivot,
	C_Select,
	C_Current,
	C_AddWire,
	C_SubtractWire,
	C_GreyWire,
	C_BrushVertex,
	C_BrushSnap,
	C_Invalid,
	C_ActorWire,
	C_ActorHiWire,
	C_Black,
	C_White,
	C_Mask,
	C_SemiSolidWire,
	C_NonSolidWire,
	C_WireBackground,
	C_WireGridAxis,
	C_ActorArrow,
	C_ScaleBox,
	C_ScaleBoxHi,
	C_ZoneWire,
	C_Mover,
	C_OrthoBackground,
	C_StaticMesh,
	C_StaticMeshDynamic,
	C_VolumeBrush,
	C_ConstraintLine,
	C_AnimMesh,
	C_TerrainWire;

defaultproperties
{
     Console=Class'Console'
     CacheSizeMegs=2
     UsePerforce=1
     UseSound=True
     UseStaticMeshBatching=True
     EnableCheatProtection=True
     C_WorldBox=(B=107,A=255)
     C_GroundPlane=(B=63,A=255)
     C_GroundHighlight=(B=127,A=255)
     C_BrushWire=(B=63,G=63,R=255,A=255)
     C_Pivot=(G=255,A=255)
     C_Select=(B=127,A=255)
     C_Current=(A=255)
     C_AddWire=(B=255,G=127,R=127,A=255)
     C_SubtractWire=(B=63,G=192,R=255,A=255)
     C_GreyWire=(B=163,G=163,R=163,A=255)
     C_BrushVertex=(A=255)
     C_BrushSnap=(A=255)
     C_Invalid=(B=163,G=163,R=163,A=255)
     C_ActorWire=(G=63,R=127,A=255)
     C_ActorHiWire=(G=127,R=255,A=255)
     C_Black=(A=255)
     C_White=(B=255,G=255,R=255,A=255)
     C_Mask=(A=255)
     C_SemiSolidWire=(G=255,R=127,A=255)
     C_NonSolidWire=(B=32,G=192,R=63,A=255)
     C_WireBackground=(A=255)
     C_WireGridAxis=(B=119,G=119,R=119,A=255)
     C_ActorArrow=(R=163,A=255)
     C_ScaleBox=(B=11,G=67,R=151,A=255)
     C_ScaleBoxHi=(B=157,G=149,R=223,A=255)
     C_ZoneWire=(A=255)
     C_Mover=(B=255,R=255,A=255)
     C_OrthoBackground=(B=163,G=163,R=163,A=255)
     C_StaticMesh=(B=255,G=255,A=255)
     C_StaticMeshDynamic=(B=255,G=127,R=127,A=255)
     C_VolumeBrush=(B=225,G=196,R=255,A=255)
     C_ConstraintLine=(G=255,A=255)
     C_AnimMesh=(B=28,G=221,R=221,A=255)
     C_TerrainWire=(B=255,G=255,R=255,A=255)
}
