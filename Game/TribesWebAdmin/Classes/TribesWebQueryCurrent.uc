class TribesWebQueryCurrent extends TribesWebQueryHandler;

var config string CurrentIndexPage;		// This is the page with the Menu
var config string CurrentPlayersPage;
var config string CurrentGamePage;
var config string CurrentConsolePage;
var config string CurrentConsoleLogPage;
var config string CurrentConsoleSendPage;
var config string CurrentMutatorsPage;
var config string CurrentRestartPage;
var config string DefaultSendText;		// TODO : Move to Defaults

var localized string NoteGamePage;
var localized string NotePlayersPage;
var localized string NoteConsolePage;
var localized string NoteMutatorsPage;

var StringArray	SpeciesNames;

function bool Query(WebRequest Request, WebResponse Response)
{
    log("Current.Query");

	switch (Mid(Request.URI, 1))
	{
	    case DefaultPage:			QueryCurrentFrame(Request, Response); return true;
	    case CurrentIndexPage:		QueryCurrentMenu(Request, Response); return true;
	    case CurrentPlayersPage:	if (!owner.MapIsChanging()) QueryCurrentPlayers(Request, Response); return true;
	    case CurrentGamePage:		if (!owner.MapIsChanging()) QueryCurrentGame(Request, Response); return true;
	    case CurrentConsolePage: 	if (!owner.MapIsChanging()) QueryCurrentConsole(Request, Response); return true;
	    case CurrentConsoleLogPage:	if (!owner.MapIsChanging()) QueryCurrentConsoleLog(Request, Response); return true;
	    case CurrentConsoleSendPage:	QueryCurrentConsoleSend(Request, Response); return true;
	    case CurrentMutatorsPage:	if (!owner.MapIsChanging()) QueryCurrentMutators(Request, Response); return true;
	    case CurrentRestartPage:	if (!owner.MapIsChanging()) owner.QueryRestartPage(Request, Response); return true;
	}
	return false;
}		

//*****************************************************************************
function QueryCurrentFrame(WebRequest Request, WebResponse Response)
{
local String Page;
	
    log("Current.QueryCurrentFrame");

	// if no page specified, use the default
	Page = Request.GetVariable("Page", CurrentGamePage);

	Response.Subst("IndexURI", 	CurrentIndexPage$"?Page="$Page);
	Response.Subst("MainURI", 	Page);
	
	owner.ShowFrame(Response, DefaultPage);
}

function QueryCurrentMenu(WebRequest Request, WebResponse Response)
{
	local String Page;
	
    log("Current.QueryCurrentMenu");

	Page = Request.GetVariable("Page", CurrentGamePage);
		
	// set background colors
	Response.Subst("DefaultBG", owner.DefaultBG);	// for unused tabs

	Response.Subst("PlayersBG", owner.DefaultBG);
	Response.Subst("GameBG", 	owner.DefaultBG);
	Response.Subst("ConsoleBG",	owner.DefaultBG);
	Response.Subst("MutatorsBG",owner.DefaultBG);
	Response.Subst("RestartBG", owner.DefaultBG);
	
	switch(Page) {
	case CurrentPlayersPage:
		Response.Subst("PlayersBG",	owner.HighlightedBG); break;
	case CurrentGamePage:
		Response.Subst("GameBG", 	owner.HighlightedBG); break;
	case CurrentConsolePage:
		Response.Subst("ConsoleBG",	owner.HighlightedBG); break;
	case CurrentMutatorsPage:
		Response.Subst("MutatorsBG",owner.HighlightedBG); break;
	case CurrentRestartPage:
		Response.Subst("RestartBG", owner.HighlightedBG); break;
	}

	// Set URIs
	Response.Subst("PlayersURI", 	DefaultPage$"?Page="$CurrentPlayersPage);
	Response.Subst("GameURI",		DefaultPage$"?Page="$CurrentGamePage);
	Response.Subst("ConsoleURI", 	DefaultPage$"?Page="$CurrentConsolePage);
	Response.Subst("MutatorsURI", 	DefaultPage$"?Page="$CurrentMutatorsPage);
	Response.Subst("RestartURI", 	DefaultPage$"?Page="$CurrentRestartPage);
	
	owner.ShowPage(Response, CurrentIndexPage);
}

function QueryCurrentPlayers(WebRequest Request, WebResponse Response)
{
local string Sort, PlayerListSubst, TempStr, TempTag, TempData, TeamName;
local string KickButtonText[3], TableHeaders;
local StringArray	PlayerList;
local Controller P;
local int i, Cols;
local string IP;
local bool bCanKick, bCanBan;

    log("Current.QueryCurrentPlayers");

	Response.Subst("Section", "Player List");
	Response.Subst("PostAction", CurrentPlayersPage);

	if (owner.CanPerform("Xp|Kp|Kb|Mb"))
	{	
		PlayerList = new(None) class'SortedStringArray';
	
		Sort = Request.GetVariable("Sort", "Name");
		Cols = 0;
	
		bCanKick = owner.CanPerform("Kp|Mb");
		bCanBan = owner.CanPerform("Kb");
		
		if (bCanKick || bCanBan)
		{
			for ( P=owner.Level.ControllerList; P!=None; P=P.NextController )
			{
				if(		PlayerController(P) != None 
					&&	P.PlayerReplicationInfo != None
					&&	NetConnection(PlayerController(P).Player) != None)
				{
					if ( bCanBan && Request.GetVariable("BanPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "" )
						owner.Level.Game.AccessControl.KickBanPlayer(PlayerController(P));
					else if ( bCanKick && Request.GetVariable("KickPlayer"$string(P.PlayerReplicationInfo.PlayerID)) != "" )
						P.Destroy();
				}
			}
			
			KickButtonText[0] = "Kick";
			KickButtonText[1] = "Ban";
			KickButtonText[2] = "Kick/Ban";
			if (bCanKick) Cols += 1;
			if (bCanBan) Cols += 2;
			Response.Subst("KickButton", "<input class=button type='submit' name='Kick' value='"$KickButtonText[Cols-1]$"'>");
			
			// Build of valid TableHeaders
			TableHeaders = "";
			if (bCanKick)
			{
				Response.Subst("HeadTitle", "Kick");
				TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head");
			}
			
			if (bCanBan)
			{
				Response.Subst("HeadTitle", "Ban");
				TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head");
			}
			Response.Subst("HeadTitle", "Name");
			TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head_link");
			
			Response.Subst("HeadTitle", "Team");
			TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head_link");
			
			Response.Subst("HeadTitle", "Ping");
			TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head_link");
			Response.Subst("HeadTitle", "Score");
			TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head_link");
			Response.Subst("HeadTitle", "IP");
			TableHeaders = TableHeaders$owner.WebInclude(CurrentPlayersPage$"_list_head");
			Response.Subst("TableHeaders", TableHeaders);
		}

		for (P=owner.Level.ControllerList; P!=None; P=P.NextController)
		{
			if (!P.bDeleteMe && P.bIsPlayer && P.PlayerReplicationInfo != None)
			{
				TempData = "<tr>";
				
				Response.Subst("PlayerId", string(P.PlayerReplicationInfo.PlayerID));
				if (owner.CanPerform("Kp"))
					TempData = TempData$owner.WebInclude(CurrentPlayersPage$"_kick_col");

				if (owner.CanPerform("Kb"))
				{
					if (PlayerController(P) != None)
						TempData = TempData$owner.WebInclude(CurrentPlayersPage$"_ban_col");
					else
						TempData = TempData$owner.WebInclude(CurrentPlayersPage$"_empty_col");
				}

                if (P.PlayerReplicationInfo.bIsSpectator)
					TempStr = "&nbsp;(Spectator)";
				else
					TempStr = "&nbsp;";

				if( PlayerController(P) != None )
				{
					IP = PlayerController(P).GetPlayerNetworkAddress();
					if (IP!="")
    					IP = Left(IP, InStr(IP, ":"));
    				else
    				    IP = "localhost";
				}
				else
					IP = "";

				TempData = TempData$"<td><div align=\"left\" nowrap>"$owner.HtmlEncode(P.PlayerReplicationInfo.PlayerName)$TempStr$"</div></td>";
				
				TeamName = owner.HtmlEncode(TribesReplicationInfo(P.PlayerReplicationInfo).team.localizedName);
				TempData = TempData$"<td nowrap align=center>"$TeamName$"&nbsp;</td>";

				TempData = TempData$"<td><div align=\"center\">"$P.PlayerReplicationInfo.Ping$"</div></td>";
				TempData = TempData$"<td><div align=\"center\">"$int(P.PlayerReplicationInfo.Score)$"</div></td>";
				TempData = TempData$"<td><div align=\"center\">"$IP$"</div></td></tr>";

				switch (Sort)
				{
					case "Name":
						TempTag = P.PlayerReplicationInfo.PlayerName; break;
					case "Team":	// Ordered by Team + TeamId
						TempTag = TeamName; break;
					case "Ping":
						TempTag = Right("0000"$string(P.PlayerReplicationInfo.Ping), 5); break;
					default:
						TempTag = Right("000"$string(int(P.PlayerReplicationInfo.Score)), 4); break;
				}

				PlayerList.Add(TempData, TempTag);
			}
		}
		PlayerListSubst = "";
		if (PlayerList.Count() > 0)
		{
			for ( i=0; i<PlayerList.Count(); i++)
			{
				if (Sort ~= "Score")
					PlayerListSubst = PlayerList.GetItem(i)$PlayerListSubst;
				else
					PlayerListSubst = PlayerListSubst$PlayerList.GetItem(i);
			}
		}
		else
			PlayerListSubst = "<tr align=\"center\"><td colspan=\"5\">** No Players Connected **</td></tr>";

		Response.Subst("PlayerList", PlayerListSubst);
		Response.Subst("Sort", Sort);

		Response.Subst("PageHelp", NotePlayersPage);
		owner.MapTitle(Response);
		owner.ShowPage(Response, CurrentPlayersPage);
	}
	else
		owner.AccessDenied(Response);	
}

function QueryCurrentGame(WebRequest Request, WebResponse Response)
{
local StringArray	ExcludeMaps, IncludeMaps, MovedMaps;
local class<Engine.GameInfo> GameClass;
local string NewGameType, SwitchButtonName;
local bool bMakeChanges;

    log("Current.QueryCurrentGame");

	if (owner.CanPerform("Mt|Mm"))
	{
		if (Request.GetVariable("SwitchGameTypeAndMap", "") != "")
		{
			if (owner.CanPerform("Mt"))
			{
				owner.ServerChangeMap(Request, Response, Request.GetVariable("MapSelect"), Request.GetVariable("GameTypeSelect"));
			}
			else
				owner.AccessDenied(Response);
			
			return;
		}
		else if (Request.GetVariable("SwitchMap", "") != "")
		{
			if (owner.CanPerform("Mm|Mt"))
			{
				// TODO: Add a check to see if already changing
				owner.Level.ServerTravel(Request.GetVariable("MapSelect")$"?game="$owner.Level.Game.Class$"?mutator="$owner.UsedMutators(), false);
				owner.ShowMessage(Response, "Please Wait", "The server is now switching to map '"$Request.GetVariable("MapSelect")$"'.    Please allow 10-15 seconds while the server changes levels.");
			}
			else
				owner.AccessDenied(Response);
			
			return;
		}

		bMakeChanges = (Request.GetVariable("ApplySettings", "") != "");

		if (owner.CanPerform("Mt") && (bMakeChanges || Request.GetVariable("SwitchGameType", "") != ""))
		{
			NewGameType = Request.GetVariable("GameTypeSelect");
			GameClass = class<GameInfo>(DynamicLoadObject(NewGameType, class'Class'));
		}
		else
			GameClass = None;
		
		if (GameClass == None)
		{
   			GameClass = owner.Level.Game.Class;
			NewGameType = String(GameClass);
		}

		ExcludeMaps = owner.ReloadExcludeMaps(NewGameType);
		IncludeMaps = owner.ReloadIncludeMaps(ExcludeMaps, NewGameType);

		if (GameClass == owner.Level.Game.Class)
		{
			SwitchButtonName="SwitchMap";
			MovedMaps = New(None) Class'SortedStringArray';
			MovedMaps.CopyFromId(IncludeMaps, IncludeMaps.FindItemId(Left(string(owner.Level), InStr(string(owner.Level), "."))$".unr"));
		}
		else
			SwitchButtonName="SwitchGameTypeAndMap";
	
		if (owner.CanPerform("Mt"))
		{
			Response.Subst("GameTypeSelect", "<select name=\"GameTypeSelect\">"$owner.GenerateGameTypeOptions(NewGameType)$"</select>");
			Response.Subst("GameTypeButton", "<input class=button type='submit' name='SwitchGameType' value='Switch'>");
		}
		else
			Response.Subst("GameTypeSelect", owner.Level.Game.Default.GameName);
		
		Response.Subst("MapButton", "<input class=button type='submit' name='"$SwitchButtonName$"' value='Switch'>");
		Response.Subst("MapSelect", owner.GenerateMapListSelect(IncludeMaps, MovedMaps ));
		Response.Subst("PostAction", CurrentGamePage);
	
		Response.Subst("Section", "Current Game");
		Response.Subst("PageHelp", NoteGamePage);
		owner.MapTitle(Response);
		owner.ShowPage(Response, CurrentGamePage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryCurrentConsole(WebRequest Request, WebResponse Response)
{
local String SendStr, OutStr;

    log("Current.QueryCurrentConsole");

	if (owner.CanPerform("Xc"))
	{
		SendStr = Request.GetVariable("SendText", "");
		if (SendStr != "" && !(Left(SendStr, 6) ~= "debug " || SendStr ~= "debug"))
		{
			if (Left(SendStr, 4) ~= "say ")
				owner.Level.Game.Broadcast(owner.Spectator, Mid(SendStr, 4), 'Say');
			else if (SendStr ~= "dump")
				owner.Spectator.Dump();
			else
			{
				OutStr = owner.Level.ConsoleCommand(SendStr);
				if (OutStr != "")
					owner.Spectator.AddMessage(None, OutStr, 'Console');
			}
		}
		
		Response.Subst("LogURI", CurrentConsoleLogPage);
		Response.Subst("SayURI", CurrentConsoleSendPage);
		owner.ShowPage(Response, CurrentConsolePage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryCurrentConsoleLog(WebRequest Request, WebResponse Response)
{
local String LogSubst, LogStr;
local int i;


    log("Current.QueryCurrentConsoleLog");

	if (owner.CanPerform("Xc"))
	{
		Response.Subst("Section", "Server Console");
		Response.Subst("SubTitle", owner.Level.Game.GameReplicationInfo.GameName$" in "$owner.Level.Title);
//		Spectator.Dump();
		i = owner.Spectator.LastMessage();
		LogStr = owner.HtmlEncode(owner.Spectator.NextMessage(i));
		while (LogStr  != "")
		{
			LogSubst = LogSubst$"&gt; "$LogStr$"<br>";
			LogStr = owner.HtmlEncode(owner.Spectator.NextMessage(i));
		}
		Response.Subst("RefreshMeta", "<meta http-equiv=\"refresh\" CONTENT=\"5; URL="$owner.WebServer.ServerURL$owner.Path$"/"$CurrentConsoleLogPage$"#END\">");
		Response.Subst("LogText", LogSubst);
		Response.Subst("PageHelp", NoteConsolePage);
		owner.MapTitle(Response);
		owner.ShowPage(Response, CurrentConsoleLogPage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryCurrentConsoleSend(WebRequest Request, WebResponse Response)
{
    log("Current.QueryCurrentConsoleSend");

	if (owner.CanPerform("Xc"))
	{
		Response.Subst("DefaultSendText", DefaultSendText);
		Response.Subst("PostAction", CurrentConsolePage);
		owner.ShowPage(Response, CurrentConsoleSendPage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryCurrentMutators(WebRequest Request, WebResponse Response)
{
    local int i, j, k, l, id;
    local bool bHasSelected;
    local string selectedmutes, lastgroup, nextgroup, thisgroup;
    local string GrpValue;
    local StringArray	GroupedMutators;

	if (owner.CanPerform("Mu"))
	{
	    // glenn: workaround for stupid unreal code
	    
	    owner.LoadMutators();
	
	    GroupedMutators = new(None) class'SortedStringArray';
		if (Request.GetVariable("SetMutes", "") != "")
		{
			owner.AIncMutators.Reset();
			lastgroup = "";
			for (i = 0; i<owner.AExcMutators.Count(); i++)
			{
				j = int(owner.AExcMutators.GetItem(i));
				
				thisgroup = owner.AllMutators[j].GroupName;

				if (Request.GetVariable(owner.AExcMutators.GetTag(i), "") != "" || Request.GetVariable(thisgroup) == owner.AllMutators[j].ClassName)
					owner.AIncMutators.Add(owner.AExcMutators.GetItem(i), owner.AExcMutators.GetTag(i));
			}
		}
		
		// Make a list sorted by groupname.classname
		for (i = 0; i<owner.AExcMutators.Count(); i++)
		{
			j = int(owner.AExcMutators.GetItem(i));
			GroupedMutators.Add(string(j), owner.AllMutators[j].GroupName$"."$owner.AllMutators[j].ClassName);
			
			log("grouped mutators add: "$string(j)$", "$owner.AllMutators[j].GroupName$"."$owner.AllMutators[j].ClassName);
		}

		// First, Display Selected Mutators, 1 per line
		selectedmutes = "";
		for (i = 0; i<owner.AIncMutators.Count(); i++)
		{
		j = int(owner.AIncMutators.GetItem(i));

			Response.Subst("MutatorName", owner.HtmlEncode(owner.AllMutators[j].FriendlyName));
			Response.Subst("MutatorDesc", owner.HtmlEncode(owner.AllMutators[j].Description));

			selectedmutes = selectedmutes$owner.WebInclude("current_mutators_selected");
		}
		if (selectedmutes != "")
		{
			Response.Subst("TableTitle", "Selected Mutators");
			Response.Subst("TableRows", selectedmutes);
			Response.Subst("SelectedTable", owner.WebInclude("current_mutators_table"));
		}


		// Then, Display All mutators with CheckBoxes/Radio Buttons based on Groups
		lastgroup = "";
		selectedmutes="";
		for (i = 0; i<GroupedMutators.Count(); i++)
		{
			j = int(GroupedMutators.GetItem(i));

			if ( (i + 1) == GroupedMutators.Count())
				nextgroup = "";
			else
			{
				k = int(GroupedMutators.GetItem(i + 1));
				nextgroup = owner.AllMutators[k].GroupName;
			}

			thisgroup = owner.AllMutators[j].GroupName;

			Response.Subst("GroupName", nextgroup);
			if (lastgroup != thisgroup && thisgroup == nextgroup)
			{
				bHasSelected = false;
				GrpValue = "None";
				// See if any items in group is selected
				for (k = i; k<GroupedMutators.Count(); k++)
				{
					l = int(GroupedMutators.GetItem(k));
					if (owner.AllMutators[l].GroupName != nextgroup)
						break;

					id = owner.AIncMutators.FindTagId(owner.AllMutators[l].ClassName);

					if (id != -1)
					{
						GrpValue = owner.AllMutators[l].ClassName;
						bHasSelected = true;
						break;
					}
				}

				// Output Group Row + None Row
				Response.Subst("GroupValue", GrpValue);
				if (GrpValue == "None")
					Response.Subst("Checked", "checked");

				selectedmutes = selectedmutes$owner.WebInclude("current_mutators_group");
			}

			id = owner.AIncMutators.FindTagId(owner.AllMutators[j].ClassName);
			Response.Subst("Checked", "");
			if (id >= 0)
				Response.Subst("Checked", "checked");

			Response.Subst("MutatorClass", owner.AllMutators[j].ClassName);
			Response.Subst("MutatorName", owner.AllMutators[j].FriendlyName);
			Response.Subst("MutatorDesc", owner.AllMutators[j].Description);
			if (nextgroup == thisgroup || thisgroup == lastgroup)
				selectedmutes = selectedmutes$owner.WebInclude("current_mutators_group_row");
			else
				selectedmutes = selectedmutes$owner.WebInclude("current_mutators_row");

			lastgroup = thisgroup;
		}
		Response.Subst("TableTitle", "Pick your Mutators");
		Response.Subst("TableRows", selectedmutes);
		Response.Subst("ChooseTable", owner.WebInclude("current_mutators_table"));


		owner.MapTitle(Response);
		Response.Subst("Section", "Mutators");
		Response.Subst("PageHelp", NoteMutatorsPage);
		Response.Subst("PostAction", CurrentMutatorsPage);
		owner.ShowPage(Response, CurrentMutatorsPage);
	}
	else
		owner.AccessDenied(Response);
}

function string GetTeamColor(TeamInfo Team)
{
    // ADMIN TODO - team color (blue, yellow, red)

    /*
	if (Team == None)
		return "";

	if (Team.TeamIndex < 4)
		return Team.ColorNames[Team.TeamIndex];
		*/

	return "#CCCCCC";
}

function string GetTeamName(TeamInfo Team)
{
	if (Team == None)
		return "";

	return Team.GetHumanReadableName();
}


defaultproperties
{
	Title="Current"
	DefaultPage="currentframe"
    CurrentIndexPage="current_menu"
    CurrentPlayersPage="current_players"
    CurrentGamePage="current_game"
    CurrentConsolePage="current_console"
    CurrentConsoleLogPage="current_console_log"
    CurrentConsoleSendPage="current_console_send"
    CurrentMutatorsPage="current_mutators"
    CurrentRestartPage="current_restart"
    DefaultSendText="say "
	NoteGamePage="Choose a game type and/or maps then click on the corresponding change button."
	NotePlayersPage="Shows you who is currently playing. You can kick and ban players. Use the checkboxes to choose who gets evicted."
	NoteConsolePage="Here you you tell the players when you intend to make some changes or restart with a different map. You can also see what the players are saying, as long as its not team only messages."
	NoteMutatorsPage="Select which mutators you want to be used when you hit the Restart Server Link"
}
