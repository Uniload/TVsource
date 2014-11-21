class TribesGUIControllerBase extends GUI.GUIController
	dependsOn(Utility)
	native;

var ClientSideCharacter clientSideChar;

var TribesGUIConfig   GuiConfig;  // GUI Config object to use

var private String LastChatMessage;                   // Last chat message recieved
var bool bMusicPlaying;
var int CurrentSongHandle;

/////////////////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////////////////
function InitializeController()
{
log("[dkaplan] >>> InitializeController of (TribesGUIControllerBase) "$self);
    GuiConfig = new class'TribesGUIConfig';
    Super.InitializeController();

	clientSideChar = new class'ClientSideCharacter';

    // glenn: smart precache of level data
    
    //class'Utility'.static.smartRefresh();
    //class'Utility'.static.save();
    
    // note: i have disabled this until we get the smart cache working
    // just doing the 'smartRefresh' will currently scan all levels (5 secs?)
    // at the moment, because it does not detect minimum level changes with
    // checksums etc...

	// Play opening music when controller is first initialized
	if (!bMusicPlaying)
	{
		CurrentSongHandle = ViewportOwner.Actor.PlayMusic(GuiConfig.openingMusic, 0);
		bMusicPlaying = true;
	}
}

/////////////////////////////////////////////////////////////////////////////
// Game State / Game Systems Reference
/////////////////////////////////////////////////////////////////////////////
event PreLevelChange(string DestURL, LevelSummary NewSummary)
{
	local RoundInfo ri;

	Super.PreLevelChange(DestURL, NewSummary);

	// Cleanup all RoundInfos
	ForEach ViewportOwner.Actor.Level.AllActors(class'RoundInfo', ri)
	{
		ri.cleanup();
	}

	ViewportOwner.Actor.Level.dispatchMessage(new class'MessageGameEnd');

	GuiConfig.CurrentLevelSummary = NewSummary;
	GuiConfig.CurrentURL = DestURL;

	// show loading screen (except for entry level)
	if (InStr(DestURL, "?entry") == -1 && InStr(DestURL, "Entry.tvm") == -1) // fix: hardcoded reference to 'entry'
	{
		CloseAll();
		OpenMenu(class'GameEngine'.default.LoadingClass);
		PaintProgress();
	}

	// Stop playing opening music
	if (bMusicPlaying)
	{
		ViewportOwner.Actor.StopMusic(CurrentSongHandle, 1);
		bMusicPlaying = false;
	}
}

event PostLevelChange(LevelInfo newLevel, bool bSaveGame)
{
	local int missionIdx;

	if (bSaveGame)
	{
		GuiConfig.LastCutscene = "";
	}

	GuiConfig.bMissionFailed = false;

	// Play opening music when changing back to Entry level
	if (NewLevel.IsEntry() && !bMusicPlaying)
	{
		CurrentSongHandle = ViewportOwner.Actor.PlayMusic(GuiConfig.openingMusic, 0);
		bMusicPlaying = true;
	}
	// Stop playing opening music
	else if (bMusicPlaying)
	{
		ViewportOwner.Actor.StopMusic(CurrentSongHandle, 1);
		bMusicPlaying = false;
	}

	// copy the saved level campaign to the current campaign, if it is present
	if (newLevel.savedCampaign != None)
	{
		GuiConfig.CurrentCampaign = new(Outer) class'CampaignInfo';
		CampaignInfo(newLevel.savedCampaign).copy(GuiConfig.CurrentCampaign);
		GuiConfig.CurrentMission = GuiConfig.CurrentCampaign.missions[GuiConfig.CurrentCampaign.progressIdx].mapName;
	}
	else
	{
		// If we're not switching to the mission nominated by GuiConfig.CurrentMission, then
		// the user must have manually switched missions using 'open' or the main menu, and
		// the current campaign should be considered invalid.
		if (GuiConfig.CurrentCampaign != None &&
			Caps(GuiConfig.CurrentMission) != Caps(newLevel.Outer.Name) &&
			Caps(GuiConfig.CurrentCampaign.missions[GuiConfig.CurrentCampaign.progressIdx].startCutsceneMap) != Caps(newLevel.Outer.Name) &&
			Caps(GuiConfig.CurrentCampaign.missions[GuiConfig.CurrentCampaign.progressIdx].endCutsceneMap) != Caps(newLevel.Outer.Name))
		{
			log("Mission load out of campaign sequence ("$Caps(GuiConfig.CurrentMission)$" != "$Caps(newLevel.Outer.Name)$"), clearing campaign");
			GuiConfig.CurrentCampaign = None;
		}

		// If there is no campaign saved in the level and no active campaign, then
		// a campaign mission may have been loaded standalone. Make a new campaign and advance
		// to the loaded mission, if possible.
		if (GuiConfig.CurrentCampaign == None)
		{
			GuiConfig.CurrentCampaign = new(Outer, "Default") class'CampaignInfo';
			missionIdx = GuiConfig.CurrentCampaign.findMission(newLevel.Outer.Name);
			if (missionIdx == -1)
			{
				GuiConfig.CurrentCampaign = None;
				log("Couldn't find a mission in the campaign called "$newLevel.Outer.Name);
			}
			else
			{
				log("Advancing new campaign to mission"@missionIdx);
				GuiConfig.CurrentCampaign.progressIdx = missionIdx;
				GuiConfig.CurrentCampaign.highestProgressIdx = missionIdx;
				// persistant health and items
				if (missionIdx >= 0)
					GuiConfig.bTravelMission = GuiConfig.CurrentCampaign.missions[missionIdx].bPersist;
				else
					GuiConfig.bTravelMission = false;
			}
		}

		// copy the active campaign to the level, to ensure that campaign progress will be saved
		if (GuiConfig.CurrentCampaign != None)
		{
			newLevel.savedCampaign = new(newLevel) class'CampaignInfo';
			GuiConfig.CurrentCampaign.copy(CampaignInfo(newLevel.savedCampaign));
		}
	}

	// send difficulty level to gameinfo
	// don't set difficulty on savegame load
	if (GuiConfig.CurrentCampaign != None && !bSaveGame)
	{
		if (SingleplayerGameInfo(ViewportOwner.Actor.Level.Game) != None)
			SingleplayerGameInfo(ViewportOwner.Actor.Level.Game).setCampaignDifficulty(GuiConfig.CurrentCampaign.selectedDifficulty);
	}

	// If this isn't the entry level, close all menus
	if (!ViewportOwner.Actor.Level.IsEntry())
		CloseAll();
	else
	{
		// Make sure that the main menu will always be accessible -- but don't display during the 'pending' level
		if (MenuStack.Length == 0 && !ViewportOwner.Actor.Level.IsPendingActive())
			OpenMenu(class'GameEngine'.default.MainMenuClass);
	}
}

final function GameInfo GetGameInfo()
{
    return GameInfo(GetLevelInfo().Game);
}

final function LevelInfo GetLevelInfo()
{
    return ViewportOwner.Actor.Level;
}

/////////////////////////////////////////////////////////////////////////////
// Client -> Server Requests
/////////////////////////////////////////////////////////////////////////////
final function ChangeTeams()
{
    //PlayerCharacterController(ViewportOwner.Actor).ServerChangePlayerTeam();
}

final function PlayerDisconnect()
{
    //disconnect client from the server
	LoadLevel( "?entry" );
}

function Quit()
{
	//Log("Quit called with exit menu "$GuiConfig.ExitMenuClass);
    PlayerDisconnect();
	// Check for exit menu here
	if (GuiConfig.ExitMenuClass != "")
	{
		OpenMenu(GuiConfig.ExitMenuClass);
	}
	else
	{
	    CloseAll();
		ConsoleCommand( "quit" );
	}
}

// Starts a campaign cutscene
private function StartCampaignCutscene(string map, string scene)
{
	local string cutsceneCommand;
	local int found;

	cutsceneCommand = map$"?playmojo="$scene;

	// convert spaces to %20
	found = InStr(cutsceneCommand, " ");
	while (found != -1)
	{
		cutsceneCommand = Left(cutsceneCommand, found) $ "%20" $ Mid(cutsceneCommand, found + 1);
		found = InStr(cutsceneCommand, " ");
	}

	// just play the cutscene if the cutscene map is already loaded
	if (GuiConfig.LastCutscene == map)
	{
		ConsoleCommand("cutscene \""$scene$"\"");
	}
	else
	{
		GuiConfig.LastCutscene = map;
		OpenMenu("TribesGui.TribesMissionLoadingMenu", "TribesMissionLoadingMenu"); 
		
		if (GuiConfig.bTravelMission)
		{
			cutsceneCommand = "servertravelwithitems"@cutsceneCommand;
		}
		else
		{
			cutsceneCommand = "open"@cutsceneCommand;
		}

		ConsoleCommand(cutsceneCommand);
	}
}

// Starts the game at the first defined campaign mission. Returns false if no campaign missions are defined.
function bool StartNewCampaign(int difficulty)
{
	return StartNewCampaignAt(0, difficulty);
}

function bool StartNewCampaignAt(int missionIdx, int difficulty)
{
	GuiConfig.LastCutscene = "";
	GuiConfig.CurrentCampaign = new(Outer, "Default") class'CampaignInfo';
	GuiConfig.CurrentCampaign.selectedDifficulty = difficulty;

	return PlayCampaignMission(missionIdx);
}

// Advances to the next campaign mission and starts the game, playing cutscenes if required.
// Returns false and exits to main menu if no more missions are available.
function bool NextCampaignMission()
{
	if (!PlayCampaignMission(GuiConfig.CurrentCampaign.progressIdx + 1))
	{
		LOG("Campaign finished");
		LoadLevel( "?entry" );
		OpenMenu(class'GameEngine'.default.MainMenuClass);
		OpenMenu("TribesGUI.TribesCreditsMenu"); 
		return false;
	}

	return true;
}

// Starts the campaign at the given mission index, playing the start cutscene if given.
// Returns false if the mission is not defined for the index.
function bool PlayCampaignMission(int idx)
{
	local CampaignInfo.MissionInfo mission;

	GuiConfig.CurrentMission = "";

	if (GuiConfig.CurrentCampaign == None)
	{
		LOG("No campaign available");
		return false;
	}

	if (idx >= GuiConfig.CurrentCampaign.missions.Length)
	{
		LOG("Campaign mission index out of range ("$idx$")");
		return false;
	}

	GuiConfig.CurrentCampaign.progressIdx = idx;

	if (GuiConfig.CurrentCampaign.highestProgressIdx < idx)
		GuiConfig.CurrentCampaign.highestProgressIdx = idx;

	mission = GuiConfig.CurrentCampaign.missions[idx];
	GuiConfig.CurrentMission = mission.mapName;
	if (GuiConfig.CurrentMission == "")
		return false;

	// persistant health and items
	if (idx - 1 >= 0)
		GuiConfig.bTravelMission = GuiConfig.CurrentCampaign.missions[idx - 1].bPersist;
	else
		GuiConfig.bTravelMission = false;

	if (mission.startCutsceneMap != "")
	{
	    GuiConfig.TribesGameState = GAMESTATE_CutsceneMissionStart;
		StartCampaignCutscene(mission.startCutsceneMap, mission.startCutsceneName);
	}
	else
	{
		GameStart();
	}

	return true;
}

// To be called at the completion of a campaign mission: plays the mission end cutscene if given
// and starts the next campaign mission if available.
function bool FinishCampaignMission()
{
	local int idx;
	local CampaignInfo.MissionInfo mission;

	if (GuiConfig.CurrentCampaign == None)
	{
		LOG("No campaign available");
		return false;
	}

	idx = GuiConfig.CurrentCampaign.progressIdx;

	if (idx >= GuiConfig.CurrentCampaign.missions.Length)
		return false;

	mission = GuiConfig.CurrentCampaign.missions[idx];

	if (mission.endCutsceneMap != "")
	{
	    GuiConfig.TribesGameState = GAMESTATE_CutsceneMissionEnd;
		StartCampaignCutscene(mission.endCutsceneMap, mission.endCutsceneName);
	}
	else
	{
		NextCampaignMission();
	}

	return true;
}

event OnMojoFinished()
{
	if (GuiConfig.TribesGameState == GAMESTATE_CutsceneMissionStart)
	{
		// start mission cutscene finished, load mission
		if (GuiConfig.CurrentMission != "")
		{
			GuiConfig.LastCutscene = "";
			GameStart();
		}
	}
	else if (GuiConfig.TribesGameState == GAMESTATE_CutsceneMissionEnd)
	{
		// end mission cutscene finished
		NextCampaignMission();
	}
}

function GameStart()
{
	local string extraParams;

    //start of game hook
    GuiConfig.TribesGameState = GAMESTATE_LevelLoading;

	extraParams = extraParams $ GuiConfig.MPHostURL;

	Log("GAMESTART:  "$GuiConfig.CurrentMission $ extraParams);

	if (GuiConfig.bTravelMission)
		ConsoleCommand("servertravelwithitems"@GuiConfig.CurrentMission$extraParams);
	else if (GuiConfig.bDedicated)
		ConsoleCommand( "RELAUNCH " $ GuiConfig.CurrentMission $ extraParams $ " -server -log=Server.log ");
	else
		LoadLevel(GuiConfig.CurrentMission $ extraParams);

	GuiConfig.MPHostURL = "";

	// reset last cutscene -- next map loaded will be next cutscene file
	GuiConfig.LastCutscene = "";
}

function GameOver()
{
    //end of game hook
    GuiConfig.TribesGameState = GAMESTATE_EntryLoading;
	LoadLevel( "?entry" );
}

function GameResume()
{
    //resume game hook
}


function LoadLevel( string URL )
{
    ConsoleCommand( "open"@URL );
}

function int GetGameSpyProfileId();

function int GetGameSpyTeamId();

function bool UseGameSpyTeamAffiliation();

function String GetGameSpyPassword();