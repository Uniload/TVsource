class TribesGUIController extends Gameplay.TribesGUIControllerBase
	native;

import enum eTribesGameState from Gameplay.TribesGuiConfig;

var(TribesGUIController) Editinline EditConst	Array<GUIPage>	StorageStack "Holds an out-of-game set of page names for recreating the stack";

// profile manager for tribes
var TribesGUI.ProfileManager profileManager;
var Color neutralColor, neutralHighlightColor;

#if IG_TRIBES3 // Alex: used by localisation tool to load GUI pages for dumping

event AutoLoadMenuClass(class<Object> menuClass)
{
	local GUIComponent NewMenu;

	// ignore if not a class we are interested in
	if (!ClassIsChildOf(menuClass, class'TribesGuiPage'))
		return;

	NewMenu = CreateComponent(menuClass.outer.name $ "." $ String(menuClass.name), String(menuClass.name));
	if (NewMenu==None)
		log("Could not Autoload" @ menuClass.name);
	else
	{
		if (!NewMenu.bInited)
			NewMenu.InitComponent(None);
		log("AutoLoaded Menu " $ menuClass.name);
	}
}

#endif

event bool ShouldSuppressLevelRender()
{
	if(TribesGUIPage(ActivePage) != None)
		return TribesGUIPage(ActivePage).bSuppressLevelRender;

	return false;
}

/////////////////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////////////////
function InitializeController()
{
log("[dkaplan] >>> InitializeController of (TribesGUIController) "$self);
    Super.InitializeController();

	// if the current level is not the entry level, we've specified a map on the command
	// line and shouldn't show the main menu
    if( GuiConfig.TribesGameState==GAMESTATE_None && ViewportOwner.Actor.Level.IsEntry() )
    {
        OpenMenu( class'GameEngine'.default.MainMenuClass );
    }

	// create the ProfileManager
	profileManager = new class'TribesGUI.ProfileManager';
	profileManager.LoadProfiles(self);
}

event PreLevelChange(string DestURL, LevelSummary NewSummary)
{
	local int iMenu;

	for(iMenu = 0; iMenu < MenuStack.Length; ++iMenu)
	{
		if(TribesGUIPage(MenuStack[iMenu]) != None)
			TribesGUIPage(MenuStack[iMenu]).OnPreLevelChange(DestURL, NewSummary);
	}

	for(iMenu = 0; iMenu < PersistentStack.Length; ++iMenu)
	{
		if(TribesGUIPage(PersistentStack[iMenu]) != None)
			TribesGUIPage(PersistentStack[iMenu]).OnPreLevelChange(DestURL, NewSummary);
	}

	super.PreLevelChange(DestURL, NewSummary);
}

/////////////////////////////////////////////////////////////////////////////
// Entry stack loading/saving utilities
/////////////////////////////////////////////////////////////////////////////
function SaveEntryStack()
{
    local int i;
    StorageStack.Remove(0,StorageStack.Length);
	for (i=0;i<MenuStack.Length;i++)
	{
		StorageStack[i]=MenuStack[i];
	}
}

function OpenEntryStack()
{
    local int i;
    CloseAll();
	for (i=0;i<StorageStack.Length-1;i++)
	{
	    MenuStack[i]=StorageStack[i];
	}
	InternalOpenMenu(StorageStack[StorageStack.Length-1]);
}

native function FindQuickChatNames(out Array<string> Names);

function int GetGameSpyProfileId()
{
	return profileManager.GetActiveProfile().statTrackingID;
}

function int GetGameSpyTeamId()
{
	return profileManager.GetActiveProfile().affiliatedTeamId;
}

function bool UseGameSpyTeamAffiliation()
{
	return profileManager.GetActiveProfile().bUseTeamAffiliation;
}

function String GetGameSpyPassword()
{
	return profileManager.GetActiveProfile().statTrackingPassword;
}

event bool OnNetworkBrowse(string URL, string ProfileOption, bool bSelectProfile)
{
// TEAMTAG: Removed
	//local TribesGameSpyManager tgm;
	local TribesMultiplayerMenu mpMenu;
	local PlayerProfile p;

	// unreal always seems to prepend '='
	ProfileOption = Mid(ProfileOption, 1);

	// bring up modified profile screen if profile select was desired
	if (bSelectProfile)
	{
		if (TribesMultiplayerMenu(ActivePage) == None)
			OpenMenu("TribesGui.TribesMultiplayerMenu");

		mpMenu = TribesMultiplayerMenu(ActivePage);
		if (mpMenu != None)
		{
			mpMenu.SetGamespyMode(true, URL);
			return false;
		}
	}
	else
	{
		// see if a specific player profile was requested
		log("Trying to find profile "$DecodeFromURL(ProfileOption)$"...");
		if (ProfileOption != "")
		{
			profileManager.SetActiveProfile(profileManager.GetProfileByName(DecodeFromURL(ProfileOption)));
		}

		p = profileManager.GetActiveProfile();

		if (p == None)
		{
			log("No active player profile -- can't log into gamespy");
			return true;
		}

		log("Active profile is "$p$", "$p.playerName);

		if (TribesMultiplayerMenu(ActivePage) == None)
		{
// TEAMTAG: Removed
			if ((p.bUseStatTracking && ViewportOwner.Actor.GetUrlOption("HasStats") == "1")/* || p.bUseTeamAffiliation*/)
			{
// TEAMTAG: Removed
				if (p.needStatTrackingUserInput()/* || p.needTeamAffiliationUserInput()*/)
				{
					log("Connecting to "$URL$" via join screen...");
					OpenMenu("TribesGui.TribesMultiplayerMenu");
					
					mpMenu = TribesMultiplayerMenu(ActivePage);
					if (mpMenu != None)
					{
						mpMenu.MyTabControl.OpenTab(mpMenu.MPGameGuidePanel);
						mpMenu.MPGameGuidePanel.AttemptURL(URL);
						return false;
					}
				}
// TEAMTAG: Removed
				//else
				//{
				//	tgm = TribesGameSpyManager(ViewportOwner.Actor.Level.GetGameSpyManager());

				//	if (tgm != None)
				//	{
				//		tgm.OnLoginTeamResult = OnGamespyTeamLoginResult;
				//		tgm.LoginTeam(p.statTrackingID, p.affiliatedTeamId, p.affiliatedTeamPassword, true);
				//	}
				//	else
				//	{
				//		Log("Couldn't log into team because there was no GameSpy manager");
				//	}
				//}
			}
		}
	}

	return true;
}

private function OnGamespyTeamLoginResult(bool succeeded, String ResponseData)
{
	local string teamTag;
	local string teamName;
	local PlayerProfile p;

	if (succeeded)
	{
		if (ResponseData != "INVALID PASSWORD" && ResponseData != "INVALID PARAMETER")
		{
			Div(ResponseData, "|", teamTag, teamName);

			p = profileManager.GetActiveProfile();

			p.affiliatedTeamTag = teamTag;
			p.affiliatedTeamName = teamName;
		}
	}
}

function String EncodePlayerName(GUIComponent Sender, TribesReplicationInfo TRI)
{
	local int Index;
	local String NameReplacementTag;
	local String ReturnString;
	local Color NameColor, TagColor;
	local TeamInfo ownTeam, otherTeam;
	local PlayerCharacterController PlayerOwner;

	PlayerOwner = PlayerCharacterController(ViewportOwner.Actor);

	if (PlayerOwner == None)
		return "";

	ownTeam = PlayerOwner.getOwnTeam();
	otherTeam = TRI.team;

	// Only use the absolute coloring scheme.  Relative coloring looks strange in the GUI
	//if(PlayerOwner.bTeamMarkerColors)
	//{
		if (otherTeam == None)
		{
			NameColor = neutralColor;
			TagColor = neutralHighlightColor;
		}
		else if(ownTeam == otherTeam)
		{
			NameColor = ownTeam.TeamColor;
			TagColor = ownTeam.TeamHighlightColor;
		}
		else
		{
			NameColor = otherTeam.TeamColor;
			TagColor = otherTeam.TeamHighlightColor;
		}
	//}
	//else
	//{
	//	if (ownTeam == None)
	//	{
	//		NameColor = neutralColor;
	//		TagColor = neutralHighlightColor;
	//	}
	//	else if(ownTeam == otherTeam)
	//	{
	//		NameColor = ownTeam.relativeFriendlyTeamColor;
	//		TagColor = ownTeam.relativeFriendlyHighlightColor;
	//	}
	//	else
	//	{
	//		NameColor = ownTeam.relativeEnemyTeamColor;
	//		TagColor = ownTeam.relativeEnemyHighlightColor;
	//	}
	//}

	NameReplacementTag = "<NAME>";
	Index = InStr(TRI.TeamTag, NameReplacementTag);
	if(Index == -1)
	{
		Index = 0;
		NameReplacementTag = "";
	}

	if(TRI.TeamTag != "")
		ReturnString = Sender.MakeColorCode(TagColor) $ 
						Left(TRI.TeamTag, Index) $ 
						Sender.MakeColorCode(NameColor) $ 
						TRI.PlayerName $ 
						"[\\C]" $ 
						Mid(TRI.TeamTag, Index + Len(NameReplacementTag)) $ 
						"[\\C]";
	else
		ReturnString = 	Sender.MakeColorCode(NameColor) $ 
						TRI.PlayerName $ 
						"[\\C]";


	return ReturnString;
}

defaultproperties
{
    bDontDisplayHelpText=false
	neutralColor				= (R=210,G=210,B=210,A=255)
	neutralHighlightColor		= (R=255,G=255,B=255,A=255)
}