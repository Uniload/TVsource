class AdminIni extends Engine.AdminBase Within Engine.PlayerController;

var AccessControlIni	Manager;
var TribesAdminUser		AdminUser;
var GameConfigSet		ConfigSet;

var protected string	NextMutators;
var protected string	NextGameType;

// Localization
var localized string Msg_PlayerList;
var localized string Msg_FinishGameEditFirst;
var localized string Msg_FinishGameRestart;
var localized string Msg_GameNoSupportBots;
var localized string Msg_StatsNoBots;
var localized string Msg_NextMapNotFound;
var localized string Msg_ChangingMapTo;
var localized string Msg_PlayerBanned;
var localized string Msg_SessionBanned;
var localized string Msg_PlayerKicked;
var localized string Msg_NoBotGameFull;
var localized string Msg_NoAddNamedBot;
var localized string Msg_NoBotsPlaying;
var localized string Msg_SetBotNeedVal;
var localized string Msg_MutNeedGameEdit;
var localized string Msg_NoMutatorInUse;
var localized string Msg_NoUnusedMuts;
var localized string Msg_AddedMutator;
var localized string Msg_ErrAddingMutator;
var localized string Msg_RemovedMutator;
var localized string Msg_ErrRemovingMutator;
var localized string Msg_MapListNeedGameEdit;
var localized string Msg_MapRotationList;
var localized string Msg_NoMapInRotation;
var localized string Msg_NoMapsAdded;
var localized string Msg_AddedMapToList;
var localized string Msg_NoMapsRemoved;
var localized string Msg_RemovedMapFromList;
var localized string Msg_NoMapsFound;
var localized string Msg_MapIsInRotation;
var localized string Msg_MapNotInRotation;
var localized string Msg_MustEndGameEdit;
var localized string Msg_EditingClass;
var localized string Msg_EditFailed;
var localized string Msg_AlreadyEdited;
var localized string Msg_NotEditing;
var localized string Msg_EditingCompleted;
var localized string Msg_EditingCancelled;
var localized string Msg_UnknownParam;
var localized string Msg_NoParamsFound;
var localized string Msg_ParamModified;
var localized string Msg_ParamNotModified;
var localized string Msg_PlayerSpectified;
var localized string Msg_TimeLimitChanged;
var localized string Msg_TourneyModeEnabled;
var localized string Msg_TourneyModeDisabled;
var localized string Msg_ForceStart;
var localized string Msg_TeamDamageEnabled;
var localized string Msg_TeamDamageDisabled;


event Created()
{
	if (AccessControlIni(Level.Game.AccessControl) != None)
		Manager = AccessControlIni(Level.Game.AccessControl);
		
	log("created admin ini: outer="$outer$" owner="$owner$" manager="$manager);
}

// Execute an administrative console command on the server.
function DoLogin( string Username, string Password )
{
    log("TribesAdmin.DoLogin: "$Username$" "$Password$" ("$Outer$")");

	if (AdminUser == None && Manager.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
		AdminUser = Manager.GetLoggedAdmin(Outer);
		Manager.AdminEntered(Outer, Username);
	}
}

// promotes the target player controller to admin
exec function DoPromote(PlayerController Target)
{
	if (Target == None)
	{
		log("DoPromote: Target is None");
		return;
	}

	log("Promoting: "$Outer.PlayerReplicationInfo.PlayerName$" promotes "$Target.PlayerReplicationInfo.PlayerName);

	if (Level.Game.AccessControl.AdminPromote(Outer, Target))
	{
		ForceAdmin();
		Level.Game.AccessControl.AdminPromoted(Outer, Target, true);
	}
	else
	{
		Level.Game.AccessControl.AdminPromoted(Outer, Target, false);
	}
}

function DoLogout()
{
	if (Manager.AdminLogout(Outer))
	{
		Manager.ReleaseConfigSet(ConfigSet, Self);
		Manager.AdminExited(Outer);
		bAdmin=false;
	}
}

// TODO: Remove for release ?
exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log(Msg_PlayerList);
	ForEach DynamicActors(class'PlayerReplicationInfo', PRI)
		log(PRI.PlayerName@"( ping"@PRI.Ping$")");
}

exec function RestartMap()
{
	if (CanPerform("Mr") || CanPerform("Mc"))	  // Mr = MapRestart, Mc = Map Change
	{
		if (ConfigSet == None)
			// ClientTravel( "?restart", TRAVEL_Relative, false );
			DoSwitch("?restart");
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}
}

exec function Switch( string URL )
{
	DoSwitch(URL);
}

function DoSwitch( string URL)
{
	// MJTEMP:  Allow any admin to change maps.  For some reason you weren't allowed to change maps when
	//          auto-logging in as an admin.  Decided to allow all admins to change maps rather than not
	//          have this working.  Should fix the underlying problem in the future.
	//if (CanPerform("Mc"))
	//{
		if (ConfigSet == None)
		{
			// TODO: See which problems could be coming from setting CTFGame with DM Map.. etc
			//       Find a way to avoid that problem.

			// Rebuild the URL based on edited game settings
			if (NextGameType != "" && Level.Game.ParseOption(URL, "Game") == "")
				URL=URL$"?Game="$NextGameType;

			if (NextMutators != "" && Level.Game.ParseOption(URL, "Mutator") == "")
				URL=URL$"?Mutator="$NextMutators;

			Level.ServerTravel( URL, false );
		}
		else
			ClientMessage(Msg_FinishGameRestart);
	//}
}

function GotoNextMap()
{
local string NextMap;
local Engine.MapList MyList;
local Engine.GameInfo G;

	if (CanPerform("Mc"))
	{
		if (ConfigSet == None)
		{

			G = Level.Game;
			if ( G.bChangeLevels && !G.bAlreadyChanged && (G.MapListType != "") )
			{
				// open a the nextmap actor for this game type and get the next map
				G.bAlreadyChanged = true;
				MyList = G.GetMapList(G.MapListType);
				if (MyList != None)
				{
					NextMap = MyList.GetNextMap();
					MyList.Destroy();
				}
				if ( NextMap == "" )
					NextMap = GetMapName(G.MapPrefix, NextMap,1);

				if ( NextMap != "" )
				{
					DoSwitch(NextMap);
					ClientMessage(ReplaceTag(Msg_ChangingMapTo, "NextMap", NextMap));
					return;
				}
			}
			ClientMessage(Msg_NextMapNotFound);
			Level.ServerTravel( "?Restart", false );
		}
		else
			ClientMessage(Msg_FinishGameEditFirst);
	}	
}

exec function Kick( string Cmd, string Extra )
{
local array<string> Params;
local array<PlayerReplicationInfo> AllPRI;
local Controller	C, NextC;
local int i;

	if (CanPerform("Kp") || CanPerform("Kb"))		// Kp = Kick Players, Kb = Kick/Ban
	{
		if (Cmd ~= "List")
		{
			// Get the list of players to kick by showing their PlayerID
			// TODO: Display Fixed Playername (no garbage chars in name)?
			// TODO: Display Sorted ?
			Level.Game.GameReplicationInfo.GetPRIArray(AllPRI);
			for (i = 0; i<AllPRI.Length; i++)
				ClientMessage(Right("   "$AllPRI[i].PlayerID, 3)$")"@AllPRI[i].PlayerName);
			return;
		}

		if (Cmd ~= "Ban" || Cmd ~= "Session")
			Params = SplitParams(Extra);
		else if (Extra != "")
			Params = SplitParams(Cmd@Extra);
		else
			Params = SplitParams(Cmd);

		// go thru all Players
		for (C = Level.ControllerList; C != None; C = NextC)
		{
			NextC = C.NextController;
			// Allow to kick bots too, for now i dont
			// What about Spectators ?? hummm ...
			if (C != Owner && PlayerController(C) != None && C.PlayerReplicationInfo != None)
			{
				for (i = 0; i<Params.Length; i++)
				{
					if ((IsNumeric(Params[i]) && C.PlayerReplicationInfo.PlayerID == int(Params[i]))
							|| MaskedCompare(C.PlayerReplicationInfo.PlayerName, Params[i]))
					{
						// Kick that player
						if (Cmd ~= "Ban")
						{
							ClientMessage(ReplaceTag(Msg_PlayerBanned, "Player", C.PlayerReplicationInfo.PlayerName));
							Manager.BanPlayer(PlayerController(C));
						}
						else if (Cmd ~= "Session")
						{
							ClientMessage(ReplaceTag(Msg_SessionBanned, "Player", C.PlayerReplicationInfo.PlayerName));
							Manager.BanPlayer(PlayerController(C), true);
						}
						else
						{
							Manager.KickPlayer(PlayerController(C));
							ClientMessage(ReplaceTag(Msg_PlayerKicked, "Player", C.PlayerReplicationInfo.PlayerName));
						}
						break;
					}
				}
			}
		}
	}
}

exec function Map( string Cmd )
{
	if (Cmd ~= "Restart")
	{
		RestartMap();
	}
	else if (Cmd ~= "Next")
	{
		GotoNextMap();
	}
	else
	{
		DoSwitch(Cmd);
	}
}

exec function User( string Cmd, string Extra)
{
	if (Cmd ~= "List")	// Admin User List *mask*
	{
		SendUserList(Extra);
	}
	else if (Cmd ~= "Del")	// Admin User Del *mask*
	{
		// TODO: Later .. need to make sure its acceptable to do so
	}
	else if (Cmd ~= "Logged") // List of currently logged admins
	{
		SendLoggedList();
	}
}

// TODO: Mutators Logic should be separate from GameConfigSet since
//       they are not associated to a game type.
exec function Mutators( string Cmd, string Extra)
{
local array<string> Values;
local int i;

	if (CanPerform("Mu"))
	{
		// TODO: Separate Mutator stuff from ConfigSet ?
		if  (ConfigSet == None)
		{
			ClientMessage(Msg_MutNeedGameEdit);
			return;
		}

		if (Cmd ~= "Used")
		{
			// List Used Mutators
			Values = ConfigSet.GetUsedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoMutatorInUse);
		}
		else if (Cmd ~= "Unused")
		{
			Values = ConfigSet.GetUnusedMutators();
			for (i = 0; i<Values.Length; i++)
				ClientMessage(i$")"@Values[i]);
			if (i == 0)
				ClientMessage(Msg_NoUnusedMuts);
		}
		else if (Cmd ~= "Add")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.AddMutator(Values[i]))
					ClientMessage(ReplaceTag(Msg_AddedMutator, "Mutator", Values[i]));
				else
					ClientMessage(ReplaceTag(Msg_ErrAddingMutator, "Mutator", Values[i]));
			}
		}
		else if (Cmd ~= "Del")
		{
			Split(Extra, " ", Values);
			for (i = 0; i<Values.Length; i++)
			{
				if (ConfigSet.DelMutator(Values[i]))
					ClientMessage(ReplaceTag(Msg_RemovedMutator, "Mutator", Values[i]));
				else
					ClientMessage(ReplaceTag(Msg_ErrRemovingMutator, "Mutator", Values[i]));
			}
		}
	}
}

exec function GetMapList( string Cmd, string Extra )
{
local array<string> Values;
local Engine.MapList	Maps;
local int i;

	if (CanPerform("Ml"))
	{
		if (Cmd ~= "Used")
		{
			if (ConfigSet == None)
			{
				ClientMessage(ReplaceTag(Msg_MapRotationList, "Game", Level.Game.Acronym));
				Maps = Level.Game.GetMapList(Level.Game.MapListType);
			}
			else
			{
				ClientMessage(ReplaceTag(Msg_MapRotationList, "Game", ConfigSet.GetGameAcronym()));
				Maps = ConfigSet.GetMaps();
			}
			ClientMessage("-------------------");
			if (Maps == None || Maps.Maps.Length == 0)
				ClientMessage(Msg_NoMapInRotation);
			else
			{
				for (i = 0; i<Maps.Maps.Length; i++)
				{
					ClientMessage(Right("   "$i, 4)$")"@Maps.Maps[i]);
				}
			}
			return;
		}

		if  (ConfigSet == None)
		{
			ClientMessage(Msg_MapListNeedGameEdit);
			return;
		}

		if (Cmd ~= "Add")
		{
			Values = ConfigSet.AddMaps(Extra);
			if (Values.Length == 0)
				ClientMessage(Msg_NoMapsAdded);
			else
				for (i = 0; i<Values.Length; i++)
					ClientMessage(ReplaceTag(Msg_AddedMapToList, "Map", Values[i]));
		}
		else if (Cmd ~= "Del")
		{
			Values = ConfigSet.RemoveMaps(Extra);
			if (Values.Length == 0)
				ClientMessage(Msg_NoMapsRemoved);
			else
				for (i = 0; i<Values.Length; i++)
					ClientMessage(ReplaceTag(Msg_RemovedMapFromList ,"Map", Values[i]));
		}
		else if (Cmd ~= "Find")
		{
			Values = ConfigSet.FindMaps(Extra);
			if (Values.Length == 0)
				ClientMessage(Msg_NoMapsFound);
			else
			{
				for (i = 0; i<Values.Length; i++)
				{
					if (Left(Values[i], 1) == "+")
						ClientMessage(ReplaceTag(Msg_MapIsInRotation, "Map", Mid(Values[i], 1)));
					else
						ClientMessage(ReplaceTag(Msg_MapNotInRotation, "Map", Values[i]));
				}
			}
		}
	}
}

exec function Game( string Cmd, string Extra )
{
local array<string> Params;
local string LastParam, LastValue;
local int p;

	if (Cmd ~= "ChangeTo")	// Admin Game ChangeTo <gameclass>
	{
		if (CanPerform("Mt"))
		{
			if (ConfigSet != None)
			{
				ClientMessage(Msg_MustEndGameEdit);
				return;
			}
			NextGameType = FindGameType(Extra);
		}
		return;
	}

	if (!CanPerform("Ms"))
		return;

	if (Cmd ~= "Edit")	// Admin Game Edit [CTF]
	{
		if (Manager.LockConfigSet(ConfigSet, Self))
		{
			if (ConfigSet.StartEdit(Extra))
				ClientMessage(ReplaceTag(Msg_EditingClass, "Class", ConfigSet.GetEditedClass()));
			else
			{
				ClientMessage(Msg_EditFailed);
				Manager.ReleaseConfigSet(ConfigSet, Self);
			}
		}
		else
			ClientMessage(Msg_AlreadyEdited);
		return;
	}

	if  (ConfigSet == None)
	{
		ClientMessage(Msg_NotEditing);
		return;
	}

	if (Cmd ~= "EndEdit")
	{
		ConfigSet.EndEdit(true);
		NextMutators = ConfigSet.NextMutators;
//		Log("NextMutators="@NextMutators);
		Manager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCompleted);
	}
	else if (Cmd ~= "CancelEdit")
	{
		ConfigSet.EndEdit(false);
		Manager.ReleaseConfigSet(ConfigSet, Self);
		ClientMessage(Msg_EditingCancelled);
	}
	else if (Cmd ~= "Get")
	{
		if (Instr(Extra, "*") == -1 && Instr(Extra, " ") == -1)
		{
			LastValue = ConfigSet.GetNamedParam(Extra);
			if (LastValue == "")
				ClientMessage(ReplaceTag(Msg_UnknownParam,"Value", Extra));
			else
				ClientMessage(Extra@"="@LastValue);
		}	
		else
		{
			Params = ConfigSet.GetMaskedParams(Extra);
			if (Params.Length == 0)
				ClientMessage(Msg_NoParamsFound);
			else
				for (p = 0; p<Params.Length; p+=2)
					ClientMessage(Params[p]@"="@Params[p+1]);
		}
	}
	else if (Cmd ~= "Set")
	{
		p = Instr(Extra, " ");
		if (p >= 0)
		{
			LastParam = Left(Extra, p);
			LastValue = Mid(Extra, p+1);
			if (ConfigSet.SetNamedParam(LastParam, LastValue))
			{
				ClientMessage(Msg_ParamModified);
				return;
			}
		}
		ClientMessage(Msg_ParamNotModified);
	}
}

exec function SetJoinPassword( string Cmd )
{
	local array<string> Params;

	Params = SplitParams(Cmd);
	Manager.SetGamePassword( Params[0] );
}

exec function RemoveJoinPassword( string Cmd )
{
	Manager.SetGamePassword( "" );
}

exec function Spectify( string Cmd )
{
	local array<string> Params;
	local PlayerController PC;

	Params = SplitParams(Cmd);
	PC = FindController(Params[0]);

	if (PC != None && PlayerCharacterController(PC) != None && !PC.PlayerReplicationInfo.bIsSpectator)
	{
		PlayerCharacterController(PC).spectate();
		ClientMessage(ReplaceTag(Msg_PlayerSpectified, "Player", PC.PlayerReplicationInfo.PlayerName));
	}
}

exec function TeamChange( string Cmd )
{
	local PlayerController PC;
	local string team;
	local int TeamNum;
	local array<string> Params;

	Params = SplitParams(Cmd);
	PC = FindController(Params[0]);
	if (Params.Length > 1)
		Team = Params[1];

	//Log("Teamchange called on PC "$PC$" with team "$Team);

	// Handle forcing to a particular team
	if (Team != "")
	{
		TeamNum = int(Team);
		PlayerCharacterController(PC).changeTeam(TeamNum, true);
	}

//	else if (PC.PlayerReplicationInfo.bIsSpectator)
//		Level.Game.RestartPlayer(PC);
	else
		PlayerCharacterController(PC).switchTeam(true);
}

exec function SetTimeLimit( string Cmd )
{
	local array<string> Params;
	local float duration;

	Params = SplitParams(Cmd);
	duration = float(Params[0]);
	if (duration < 0)
		duration = 0;
	ConsoleCommand("set rounddata duration "$string(duration));
	ClientMessage(ReplaceTag(Msg_TimeLimitChanged, "Value", ModeInfo(Level.Game).roundInfo.currentRound().duration));
}

exec function EnableTournamentMode( string Cmd )
{
	MultiplayerGameInfo(Level.Game).enableTournamentMode();
	ClientMessage(Msg_TourneyModeEnabled);
}

exec function DisableTournamentMode( string Cmd )
{
	MultiplayerGameInfo(Level.Game).disableTournamentMode();
	ClientMessage(Msg_TourneyModeDisabled);
}

exec function ForceStart( string Cmd )
{
	MultiplayerGameInfo(Level.Game).bForceStart = true;
	ClientMessage(Msg_ForceStart);
}

exec function SetTeamDamage( string Cmd )
{
	local array<string> Params;
	Params = SplitParams(Cmd);

	MultiplayerGameInfo(Level.Game).setPlayerTeamDamagePercentage(float(Params[0]));
	if (Params[0] == "0")
		ClientMessage(Msg_TeamDamageEnabled);
	else if (Params[0] == "1")
		ClientMessage(Msg_TeamDamageDisabled);
}

protected function bool CanPerform(string priv)
{
  return AdminUser != None && AdminUser.HasPrivilege(priv);
}

protected function SendUserList(string mask)	// Todo: Mask Feature
{
local TribesAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(Manager.Groups);
	for (i=0; i<uList.Count(); i++)
		ClientMessage(string(i)$uList.Get(i).UserName);
}

/// TODO: Check if should send ALL logged admins or only 
protected function SendLoggedList()
{
local TribesAdminUserList	uList;
local int i;

	uList = AdminUser.GetManagedUsers(Manager.Groups);
	for (i=0; i<uList.Count(); i++)
		if (Manager.IsLogged(uList.Get(i)))
			ClientMessage(string(i)$uList.Get(i).UserName);
}

protected function string FindGameType(string GameType)
{
local class<GameInfo>	TempClass;
local String 			NextGame;
local int				i;

	// Compile a list of all gametypes.
	i = 0;
	NextGame = Level.GetNextInt("Engine.GameInfo", 0); 
	while (NextGame != "")
	{
		TempClass = class<GameInfo>(DynamicLoadObject(NextGame, class'Class'));
		if (TempClass != None)
		{
			if (GameType ~= string(TempClass))				break;
			if (GameType ~= TempClass.default.Acronym)		break;
			if (GameType ~= TempClass.default.DecoTextName)	break;
			if (Right(string(TempClass), Len(GameType)+1) ~= ("."$GameType))			break;
			if (Right(TempClass.default.DecoTextName, Len(GameType)+1) ~= ("."$GameType))	break;
		}			
		NextGame = Level.GetNextInt("Engine.GameInfo", ++i);
	}
	return NextGame;
}

////////////////////////////////////////////////////////////
// TODO: Find Centralized place for the following functions
////////////////////////////////////////////////////////////

// TODO: Improve mask wildcards .. "*" = Any Size, "?" = 1 char
// Mask can be *|*Name|Name*|*Name*|Name
protected function bool MaskedCompare(string SettingName, string Mask)
{
local bool bMaskLeft, bMaskRight;
local int MaskLen;

	if (Mask == "*" || Mask == "**")
		return true;

	MaskLen = Len(Mask);
	bMaskLeft = Left(Mask, 1) == "*";
	bMaskRight = Right(Mask, 1) == "*";

	if (bMaskLeft && bMaskRight)
		return Instr(Caps(SettingName), Mid(Caps(Mask), 1, MaskLen-2)) >= 0;

	if (bMaskRight)
		return Left(SettingName, MaskLen -1) ~= Left(Mask, MaskLen - 1);

	if (bMaskRight)
		return Right(SettingName, MaskLen -1) ~= Right(Mask, MaskLen - 1);

	return SettingName ~= Mask;
}

// TODO: Add support for bPositiveOnly
function bool IsNumeric(string Param, optional bool bPositiveOnly)
{
local int p;

	p=0;
	while (Mid(Param, p, 1) == " ") p++;
	while (Mid(Param, p, 1) >= "0" && Mid(Param, p, 1) <= "9") p++;
	while (Mid(Param, p, 1) == " ") p++;

	if (Mid(Param, p) != "")
		return false;

	return true;
}

function array<string> SplitParams(string Params)
{
local array<string> Splitted;
local string Delim;
local int p, start;

	while (Params != "")
	{
		p = 0;
		while (Mid(Params, p, 1) == " ") p++;
		if (Mid(Params, p) == "")
			break;

		// Special case: Delimited string
		start = p;
		if (Mid(Params, p, 1) == "\"")
		{
			p++;
			start++;
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != "\"")
				p++;

			// Do not accept unfinished quoted strings
			if (Mid(Params, p, 1) == "\"")
			{
				Splitted[Splitted.Length] = Mid(Params, start, p-start);
				p++;
			}
		}
		else
		{
			while (Mid(Params, p, 1) != "" && Mid(Params, p, 1) != Delim)
				p++;
			Splitted[Splitted.Length] = Mid(Params, start, p-start);
		}
		Params = Mid(Params, p);
	}
	return Splitted;
}

function PlayerController FindController(string playerNameOrId)
{
	local Controller C, NextC;

	for (C = Level.ControllerList; C != None; C = NextC)
	{
		NextC = C.NextController;
		if (C != Owner && PlayerController(C) != None && C.PlayerReplicationInfo != None)
		{
			if ((IsNumeric(playerNameOrId) && C.PlayerReplicationInfo.PlayerID == int(playerNameOrId))
					|| MaskedCompare(C.PlayerReplicationInfo.PlayerName, playerNameOrId))
			{
				return PlayerController(C);
			}
		}
	}
	return None;
}

function string ReplaceTag(string from, string tag, coerce string value)
{
local string rep;

	rep = from;
	ReplaceText(rep, "%"$tag$"%", value);
	return rep;
}


defaultproperties
{
	Msg_PlayerList="Player List:"
	Msg_FinishGameEditFirst="You must finish your Game Edit before restarting the map"
	Msg_FinishGameRestart="You must finish your Game Edit before changing or restarting the map"
	Msg_GameNoSupportBots="The current Game Type does not support Bots"
	Msg_StatsNoBots="Cannot control bots when Worlds Stats are enabled"
	Msg_NextMapNotFound="Next Map Not Found, Restarting Same Map"
	Msg_ChangingMapTo="Changing Map to %NextMap%"

	Msg_PlayerBanned="%Player% has been Banned from this server"
	Msg_SessionBanned="%Player% has been Banned for this match"
	Msg_PlayerKicked="%Player% has been kicked"
	Msg_NoBotGameFull="Cannot add a bot, Game is full"
	Msg_NoAddNamedBot="Can Only Add Named Bots once the Match has Started"
	Msg_NoBotsPlaying="No Bots are currently playing"
	Msg_SetBotNeedVal="This Command Requires a Numeric Value between 0 and 32"

	Msg_MutNeedGameEdit="You must use 'Game Edit' command before 'Mutators' commands"
	Msg_NoMutatorInUse="No Mutators in use"
	Msg_NoUnusedMuts="Found No Unused Mutators"
	Msg_AddedMutator="Added '%Mutator%' To Used Mutator List"
	Msg_ErrAddingMutator="Error Adding '%Mutator%'To Used Mutator List"
	Msg_RemovedMutator="Removed '%Mutator%' From Used Mutator List"
	Msg_ErrRemovingMutator="Error Removing '%Mutator%' From Used Mutator List"

	Msg_MapListNeedGameEdit="You must use 'Game Edit' command before 'MapList' command"
	Msg_MapRotationList="List of maps in rotation for %Game%"
	Msg_NoMapInRotation="No Maps in rotation list"
	Msg_NoMapsAdded="No Maps Added to the List"
	Msg_AddedMapToList="Added '%Map%' To Map Rotation List"
	Msg_NoMapsRemoved="No Maps Removed from the List"
	Msg_RemovedMapFromList="Removed '%Map%' From Map Rotation List"
	Msg_NoMapsFound="No Maps were Found"
	Msg_MapIsInRotation="Map '%Map%' Is In Map Rotation List"
	Msg_MapNotInRotation="Map '%Map%' Is Not In Map Rotation List"

	Msg_MustEndGameEdit="You must end your Game Edit first"
	Msg_EditingClass="Editing %Class%"
	Msg_EditFailed="Failed Starting To Edit"
	Msg_AlreadyEdited="Game Already being edited by Someone Else"
	Msg_NotEditing="You are not editing Game Settings, use 'Game Edit' first"
	Msg_EditingCompleted="Editing Completed"
	Msg_EditingCancelled="Editing Cancelled"
	Msg_UnknownParam="Unknown Parameter : %Value%"
	Msg_NoParamsFound="No Parameters found!"
	Msg_ParamModified="Modification SuccessFull"
	Msg_ParamNotModified="Could not Modify Parameter"

	Msg_PlayerSpectified="%Player% has been put into spectator mode"
	Msg_TimeLimitChanged="The time limit has been changed to %Value%"
	Msg_TourneyModeEnabled="Tournament mode has been enabled"
	Msg_TourneyModeDisabled="Tournament mode has been disabled"
	Msg_ForceStart="The match has been forced to start"
	Msg_TeamDamageEnabled="Team damage has been enabled"
	Msg_TeamDamageDisabled="Team damage has been disabled"
}
