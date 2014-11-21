class TribesGUIConfig extends Core.Object
    config(TribesGuiState)
    HideCategories(Object)
	native
    ;

var() config string	ExitMenuClass;	// If specfiied, will be displayed when the game exits
var() config string	EntryMenuClass;	// If specfiied, will be displayed when the game starts
var bool bShownEntryMenu;

//////////////////////////////////////////////////////////////////////////////////////
// Environment
//////////////////////////////////////////////////////////////////////////////////////
var LevelSummary CurrentLevelSummary; // set on PreLevelChange. Do not keep references, invalidated on map load.
var String CurrentURL; // set on PreLevelChange, contains the URL of the currently loaded (or loading) level.

var() config String openingMusic;

//////////////////////////////////////////////////////////////////////////////////////
// Campaigns & SP Missions
//////////////////////////////////////////////////////////////////////////////////////
var(Missions) Config String CurrentMission		"The current mission selected for Single Player";
var(Missions) Config string	LastCutscene		"The last cutscene loaded.";
var CampaignInfo CurrentCampaign; // the active campaign (with progress)
var bool bTravelMission; // whether or not to travel when GameStart is called
var String CurrentGameInfo;
var bool bMissionFailed;

//////////////////////////////////////////////////////////////////////////////////////
// Video Settings
//////////////////////////////////////////////////////////////////////////////////////
var(VideoSettings) config array<string> ScreenResolutionChoices "Choices for screen resolution";


//////////////////////////////////////////////////////////////////////////////////////
// Game State
//////////////////////////////////////////////////////////////////////////////////////

enum eTribesGameState
{
    GAMESTATE_None,             //Not in game at all, GUI only
    GAMESTATE_EntryLoading,     //Currently loading the entry level
    GAMESTATE_LevelLoading,     //Currently loading a (non-entry) level
    GAMESTATE_CutsceneMissionStart, //Playing a mojo cutscene at the start of the mission
    GAMESTATE_CutsceneMissionEnd,	//Playing a mojo cutscene at the end of the mission
    GAMESTATE_PreGame,          //Level has loaded but round not yet begun
    GAMESTATE_MidGame,          //Game in progress
    GAMESTATE_PostGame,         //Level completed
	GAMESTATE_ClientTravel,		//Traveling
};

var(TribesGame) eTribesGameState TribesGameState;
var(MPSettings) String MPHostURL; // used in initiating MP games. Once the game has started, the current URL will be contained within CurrentURL.
var(MPSettings) bool bDedicated;

// Used to pass current selection back from advanced server configuration menu
var(MPSettings) String advancedGameType;
var(MPSettings) String advancedMap;



defaultproperties
{
    CurrentMission=""
	openingMusic="Rocky1_exploring"
}