//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var int 			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>	ServerActors,
					ServerPackages;

var array<object> DummyArray;	// Do not modify
var object        DummyObject;  // Do not modify

var bool		  bCheatProtection;

var config String MainMenuClass;			// Menu that appears when you first start
var config String InitialMenuClass;			// The initial menu that should appear
var config String ConnectingMenuClass;		// Menu that appears when you are connecting
var config String DisconnectMenuClass;		// Menu that appears when you are disconnected
var config String LoadingClass;				// Loading screen that appears
var config String ConnectFailureClass;		// When a client fails to connect to a network game
var config String ReceiveFileClass;			// When the client receives a file

#if IG_SHARED // Ryan:
var config String GameSpyManagerClass;
var GameSpyManager GameSpyManager;
#endif // IG
#if IG_TRIBES3 // dbeswick:
var float Padding1;
var float Padding2;
var float Padding3;
#endif

defaultproperties
{
     ServerActors(0)="IpDrv.UdpBeacon"
     ServerActors(1)="UWeb.WebServer"
     ServerPackages(0)="Core"
     ServerPackages(1)="Engine"
     ServerPackages(2)="IGEffectsSystem"
     ServerPackages(3)="IGVisualEffectsSubsystem"
     ServerPackages(4)="IGSoundEffectsSubsystem"
     ServerPackages(5)="Editor"
     ServerPackages(6)="UWindow"
     ServerPackages(7)="GUI"
     ServerPackages(8)="TVEd"
     ServerPackages(9)="IpDrv"
     ServerPackages(10)="UWeb"
     ServerPackages(11)="UDebugMenu"
     ServerPackages(12)="Tyrion"
     ServerPackages(13)="AICommon"
     ServerPackages(14)="Scripting"
     ServerPackages(15)="MojoCore"
     ServerPackages(16)="MojoActions"
     ServerPackages(17)="PathFinding"
     ServerPackages(18)="Movement"
     ServerPackages(19)="Gameplay"
     ServerPackages(20)="Physics"
     ServerPackages(21)="CharacterClasses"
     ServerPackages(22)="GameClasses"
     ServerPackages(23)="AIClasses"
     ServerPackages(24)="BaseObjectClasses"
     ServerPackages(25)="VehicleClasses"
     ServerPackages(26)="EquipmentClasses"
     ServerPackages(27)="TribesTVServer"
     ServerPackages(28)="TribesVoting"
     MainMenuClass="TribesGUI.TribesMainMenu"
     ConnectingMenuClass="TribesGUI.TribesMissionLoadingMenu"
     DisconnectMenuClass="TribesGUI.TribesDisconnectMenu"
     LoadingClass="TribesGUI.TribesMissionLoadingMenu"
     ConnectFailureClass="TribesGUI.TribesDisconnectMenu"
     ReceiveFileClass="TribesGUI.TribesReceiveFile"
     GameSpyManagerClass="Gameplay.TribesGameSpyManager"
     CacheSizeMegs=256
     UsePerforce=0
}
