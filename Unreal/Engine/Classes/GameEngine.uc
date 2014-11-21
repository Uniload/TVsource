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
    MainMenuClass=""
    InitialMenuClass=""
    ConnectingMenuClass=""
    DisconnectMenuClass=""
    LoadingClass=""
}