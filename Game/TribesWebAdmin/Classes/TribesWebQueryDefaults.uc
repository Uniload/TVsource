class TribesWebQueryDefaults extends TribesWebQueryHandler;

var config string DefaultsIndexPage;	// Defaults Menu Page
var config string DefaultsMenuPage;
var config string DefaultsMapsPage;
var config string DefaultsRulesPage;
var config string DefaultsIPPolicyPage;	// Special Case of Multi-part list page
var config string DefaultsRestartPage;

var localized string NoteMapsPage;
var localized string NoteRulesPage;
var localized string NotePolicyPage;

function bool Query(WebRequest Request, WebResponse Response)
{
	owner.MapTitle(Response);

	switch (Mid(Request.URI, 1))
	{
	case DefaultPage:			QueryDefaults(Request, Response); return true;		// Done : General
	case DefaultsMenuPage:		QueryDefaultsMenu(Request, Response); return true;// Done : General
	case DefaultsMapsPage:		if (!owner.MapIsChanging()) QueryDefaultsMaps(Request, Response); return true;
	case DefaultsRulesPage:		if (!owner.MapIsChanging()) QueryDefaultsRules(Request, Response); return true;
	case DefaultsIPPolicyPage:	if (!owner.MapIsChanging()) QueryDefaultsIPPolicy(Request, Response); return true;
	case DefaultsRestartPage:	if (!owner.MapIsChanging()) owner.QueryRestartPage(Request, Response); return true;
	}
	return false;
}

//*****************************************************************************
function QueryDefaults(WebRequest Request, WebResponse Response)
{
	local String GameType, PageStr, Filter;

	// if no gametype specified use the first one in the list
	GameType = Request.GetVariable("GameType", String(owner.Level.Game.Class));

	// if no page specified, use the first one
	PageStr = Request.GetVariable("Page", DefaultsMapsPage);
	Filter = Request.GetVariable("Filter");

	Response.Subst("IndexURI", 	DefaultsMenuPage$"?GameType="$GameType$"&Page="$PageStr$"&Filter="$Filter);
	if (Filter == "")
		Response.Subst("MainURI", 	PageStr$"?GameType="$GameType);
	else
		Response.Subst("MainURI", 	PageStr$"?GameType="$GameType$"&Filter="$Filter);

	owner.ShowFrame(Response, DefaultPage);
}

function QueryDefaultsMenu(WebRequest Request, WebResponse Response)
{
local string	GameType, Page, TempStr, Content;
local int i;

	GameType = owner.SetGamePI(Request.GetVariable("GameType", string(owner.Level.Game.Class)));
	Page = Request.GetVariable("Page");

	// set currently active page

	if (owner.CanPerform("Gt"))
	{
		if (Request.GetVariable("GameTypeSet", "") != "")
		{
			TempStr = Request.GetVariable("GameTypeSelect", GameType);
			if (!(TempStr ~= GameType))
				GameType = TempStr;
		}
		// TODO: Replace with include file.
		Response.Subst("GameTypeButton", "<input class=button type='submit' name='GameTypeSet' value='Select'>");
		Response.Subst("GameTypeSelect", "<select class=mini name='GameType'>"$owner.GenerateGameTypeOptions(GameType)$"</select>");
	}
	else
		Response.Subst("GameTypeSelect", owner.Level.Game.Default.GameName);

	// set background colors
	Response.Subst("DefaultBG", owner.DefaultBG);	// for unused tabs

	// Set URIs
	Content = "";
	Content = Content$MakeMenuRow(Response, GameType$"&Page="$DefaultsMapsPage, "Maps");
	for (i = 0; i<owner.GamePI.Groups.Length; i++)
		Content = Content$MakeMenuRow(Response, GameType$"&Page="$DefaultsRulesPage$"&Filter="$owner.GamePI.Groups[i], owner.GamePI.Groups[i]);

	Content = Content$MakeMenuRow(Response, GameType$"&Page="$DefaultsIPPolicyPage, "IP Bans/Accepts")$"<br>";
	Content = Content$MakeMenuRow(Response, GameType$"&Page="$DefaultsRestartPage, "Restart Level");

	Response.Subst("Content", Content);
	Response.Subst("Filter", Request.GetVariable("Filter", ""));
	Response.Subst("Page", Page);
	Response.Subst("PostAction", DefaultPage);
	owner.ShowPage(Response, DefaultsMenuPage);
}

// TODO: add highlight code
function string MakeMenuRow(WebResponse Response, string URI, string Title)
{
	Response.Subst("URI", DefaultPage$"?GameType="$URI);
	Response.Subst("URIText", Title);
	return Response.LoadParsedUHTM(owner.Path$"/defaults_menu_row.inc");
}

function QueryDefaultsMaps(WebRequest Request, WebResponse Response)
{
local String GameType, MapListType;
local StringArray ExcludeMaps, IncludeMaps, MovedMaps;
local int i, Count, MoveCount, id;

	if (owner.CanPerform("Ml"))
	{
		Response.Subst("Section", "Maps");
		// load saved entries from the page
		GameType = Request.GetVariable("GameType");	// provided by index page
		MapListType = Request.GetVariable("MapListType", "Custom");

		ExcludeMaps = owner.ReloadExcludeMaps(GameType);
		IncludeMaps = owner.ReloadIncludeMaps(ExcludeMaps, GameType);
		MovedMaps = New(None) class'SortedStringArray';

		if (Request.GetVariable("MapListSet", "") != "")
		{
			MapListType = Request.GetVariable("MapListSelect", "Custom");
			if (MapListType != "Custom")
			{
				owner.ApplyMapList(ExcludeMaps, IncludeMaps, GameType, MapListType);
				owner.UpdateDefaultMaps(GameType, IncludeMaps);
			}
		}
		else if (Request.GetVariable("AddMap", "") != "")
		{
			Count = Request.GetVariableCount("ExcludeMapsSelect");
			for (i=0; i<Count; i++)
			{
				if (ExcludeMaps.Count() > 0)
				{
					id = IncludeMaps.MoveFrom(ExcludeMaps, Request.GetVariableNumber("ExcludeMapsSelect", i));
					if (id >= 0)
						MovedMaps.CopyFromId(IncludeMaps, id);
					else
						Log("Exclude map not found: "$Request.GetVariableNumber("ExcludeMapsSelect", i));
				}
			}
			MapListType = "Custom";
			owner.UpdateDefaultMaps(GameType, IncludeMaps);
		}
		else if (Request.GetVariable("DelMap", "") != "" && Request.GetVariableCount("IncludeMapsSelect") > 0)
		{
			Count = Request.GetVariableCount("IncludeMapsSelect");
			for (i=0; i<Count; i++)
			{
				if (IncludeMaps.Count() > 0)
				{
					id = ExcludeMaps.MoveFrom(IncludeMaps, Request.GetVariableNumber("IncludeMapsSelect", i));
					if (id >= 0)
						MovedMaps.CopyFromId(ExcludeMaps, id);
					else
						Log("Include map not found: "$Request.GetVariableNumber("IncludeMapsSelect", i));
				}
			}
			MapListType = "Custom";
			owner.UpdateDefaultMaps(GameType, IncludeMaps);
		}
		else if (Request.GetVariable("AddAllMap", "") != "")
		{
			while (ExcludeMaps.Count() > 0)
			{
				id = IncludeMaps.MoveFromId(ExcludeMaps, ExcludeMaps.Count()-1);
				if (id >= 0)
					MovedMaps.CopyFromId(IncludeMaps, id);
			}
			MapListType = "Custom";
			owner.UpdateDefaultMaps(GameType, IncludeMaps);
		}
		else if (Request.GetVariable("DelAllMap", "") != "")
		{
			while (IncludeMaps.Count() > 0)
			{
				id =  ExcludeMaps.MoveFromId(IncludeMaps, ExcludeMaps.Count()-1);
				if (id >= 0)
					MovedMaps.CopyFromId(ExcludeMaps, id);
			}
			MapListType = "Custom";
			owner.UpdateDefaultMaps(GameType, IncludeMaps);	// IncludeMaps should be empty now.
		}
		else if (Request.GetVariable("MoveMap", "") != "")
		{
			MoveCount = int(Abs(float(Request.GetVariable("MoveMapCount"))));
			if (MoveCount != 0)
			{
				Count = Request.GetVariableCount("IncludeMapsSelect");

				// 1) Create a sorted MovedMaps list
				for (i = 0; i<Count; i++)
					MovedMaps.CopyFrom(IncludeMaps, Request.GetVariableNumber("IncludeMapsSelect", i));
//				Log("MovedMaps.Count="@MovedMaps.Count());
				if (Request.GetVariable("MoveMap") ~= "Down")
				{
					// 2) Browse from Last to 0 until all maps are moved by count
					//    but stop moving them if hitting bottom
					for (i = IncludeMaps.Count()-1; i >= 0; i--)
					{
//						Log("Checking for "$IncludeMaps.GetTag(i));
//						Log("Find Result = "$MovedMaps.FindTagId(IncludeMaps.GetTag(i)));
						if (MovedMaps.FindTagId(IncludeMaps.GetTag(i)) >= 0)
							IncludeMaps.ShiftStrict(i, MoveCount);
					}
				}
				else
				{
					MoveCount = -MoveCount;
					for (i = 0; i<IncludeMaps.Count(); i++)
					{
						if (MovedMaps.FindTagId(IncludeMaps.GetTag(i)) >= 0)
							IncludeMaps.ShiftStrict(i, MoveCount);
					}
				}
				owner.UpdateDefaultMaps(GameType, IncludeMaps);
			}
		}

		// Start output here

		Response.Subst("MapListType", MapListType);

		// Generate maplist options
		Response.Subst("MapListOptions", owner.GenerateMapListOptions(GameType, MapListType));

		// Generate map selects
		Response.Subst("ExcludeMapsOptions", owner.GenerateMapListSelect(ExcludeMaps, MovedMaps));
		Response.Subst("IncludeMapsOptions", owner.GenerateMapListSelect(IncludeMaps, MovedMaps));

		Response.Subst("PostAction", DefaultsMapsPage);
		Response.Subst("GameType", GameType);
		Response.Subst("PageHelp", NoteMapsPage);

		owner.ShowPage(Response, DefaultsMapsPage);
	}
	else
		owner.AccessDenied(Response);
}

function QueryDefaultsRules(WebRequest Request, WebResponse Response)
{
local int i, j;
local bool bMarked, bSave;
local String GameType, Content, Data, Mark, Filter;
local array<string> Options;

	if (!owner.CanPerform("Ms"))
	{
		owner.AccessDenied(Response);
		return;
	}

	GameType = owner.SetGamePI(Request.GetVariable("GameType"));
	Filter = Request.GetVariable("Filter");

	bSave = Request.GetVariable("Save", "") != "";

	Content = "";
	Mark = owner.WebInclude("defaults_mark");
	Response.Subst("Section", Filter);
	Response.Subst("Filter", Filter);
	for (i = 0; i<owner.GamePI.Settings.Length; i++)
	{
		if (owner.GamePI.Settings[i].Grouping == Filter && owner.GamePI.Settings[i].SecLevel <= owner.CurAdmin.MaxSecLevel() && (owner.GamePI.Settings[i].ExtraPriv == "" || owner.CanPerform(owner.GamePI.Settings[i].ExtraPriv)))
		{
			if (bSave)
				owner.GamePI.StoreSetting(i, Request.GetVariable(owner.GamePI.Settings[i].SettingName), owner.GamePI.Settings[i].Data);

			bMarked = bMarked || owner.GamePI.Settings[i].bGlobal;
			if (owner.GamePI.Settings[i].bGlobal)
				Response.Subst("Mark", Mark);
			else
				Response.Subst("Mark", "");

			Response.Subst("DisplayText", owner.HtmlEncode(owner.GamePI.Settings[i].DisplayName));
			Response.Subst("SettingName", owner.GamePI.Settings[i].SettingName);
			if (owner.GamePI.Settings[i].RenderType ~= "Text")
			{
				Response.Subst("MinMaxInfo", "");
				Response.Subst("SettingValue", owner.GamePI.Settings[i].Value);
				Data = "8";
				if (owner.GamePI.Settings[i].Data != "")
				{
					Data = owner.GamePI.Settings[i].Data;
					
					owner.GamePI.SplitStringToArray(Options, Data, ";");
					if (Options.Length > 1)
					{
						Data = Options[0];
						owner.GamePI.SplitStringToArray(Options, Options[1], ":");
						if (Options.Length > 1)
							Response.Subst("MinMaxInfo", " ("$Options[0]$" to "$Options[1]$")");
					}
				}

				Response.Subst("SettingWidth", Data);
				
				Content = Content$Response.LoadParsedUHTM(owner.Path$"/defaults_row_text.inc");
			}
			else if (owner.GamePI.Settings[i].RenderType ~= "Check")
			{
				// Checkbox returns "" when unchecked, which is not fun
				if (bSave && owner.GamePI.Settings[i].Value == "")
					owner.GamePI.StoreSetting(i, "False");

				if (owner.GamePI.Settings[i].Value ~= "true")
					Response.Subst("Checked", " checked");
				else
					Response.Subst("Checked", "");

				Content = Content$Response.LoadParsedUHTM(owner.Path$"/defaults_row_check.inc");
			}
			else if (owner.GamePI.Settings[i].RenderType ~= "Select")
			{
				// Build a set of options from PID.Data
				owner.GamePI.SplitStringToArray(Options, owner.GamePI.Settings[i].Data, ";");
				Data = "";
				for (j = 0; (j+1)<Options.Length; j += 2)
				{
					Data = Data$"<option value='"$Options[j]$"'";
					If (owner.GamePI.Settings[i].Value == Options[j])
						Data=Data@"selected";
					Data=Data$">"$owner.HtmlEncode(Options[j+1])$"</option>";
				}
				Response.Subst("SettingOptions", Data);
				
				Content = Content$Response.LoadParsedUHTM(owner.Path$"/defaults_row_select.inc");
			}
		}
	}
	owner.GamePI.SaveSettings();

	if (Content == "")
		Content = "** You cannot modify any settings in this section **";

	Response.Subst("TableContent", Content);
    Response.Subst("PostAction", DefaultsRulesPage);
   	Response.Subst("GameType", GameType);
	Response.Subst("SubmitValue", "Accept");
	Response.Subst("PageHelp", NoteRulesPage);
	owner.ShowPage(Response, DefaultsRulesPage);
}

function QueryDefaultsIPPolicy(WebRequest Request, WebResponse Response)
{
local int i, j;
local string policies;

	if (owner.CanPerform("Xb"))
	{
		Response.Subst("Section", "IP Bans/Accepts");
		if(Request.GetVariable("Update") != "")
		{
			i = int(Request.GetVariable("PolicyNo", "-1"));
			if(i > -1 && ValidMask(Request.GetVariable("IPMask")))
			{
				if (i >= owner.Level.Game.AccessControl.IPPolicies.Length)
				{
					i = owner.Level.Game.AccessControl.IPPolicies.Length;
					owner.Level.Game.AccessControl.IPPolicies.Length = i+1;
				}
				owner.Level.Game.AccessControl.IPPolicies[i] = Request.GetVariable("AcceptDeny")$","$Request.GetVariable("IPMask");
				owner.Level.Game.AccessControl.SaveConfig();
			}
		}

		if(Request.GetVariable("Delete") != "")
		{
			i = int(Request.GetVariable("PolicyNo", "-1"));

			if( i > -1 && i < owner.Level.Game.AccessControl.IPPolicies.Length )
			{
				owner.Level.Game.AccessControl.IPPolicies.Remove(i,1);
				owner.Level.Game.AccessControl.SaveConfig();
			}
		}

		policies = "";
		for(i=0; i<owner.Level.Game.AccessControl.IPPolicies.Length; i++)
		{
			j = InStr(owner.Level.Game.AccessControl.IPPolicies[i], ",");
			if(Left(owner.Level.Game.AccessControl.IPPolicies[i], j) ~= "DENY")
			{
				Response.Subst("AcceptCheck", "");
				Response.Subst("DenyCheck", "checked");
			}
			else
			{
				Response.Subst("AcceptCheck", "checked");
				Response.Subst("DenyCheck", "");
			}
			Response.Subst("IPMask", Mid(owner.Level.Game.AccessControl.IPPolicies[i], j+1));
			Response.Subst("PostAction", DefaultsIPPolicyPage$"?PolicyNo="$string(i));
			policies = policies$Response.LoadParsedUHTM(owner.Path$"/"$DefaultsIPPolicyPage$"_row.inc");
		}
		Response.Subst("Policies", policies);
		Response.Subst("PostAction", DefaultsIPPolicyPage$"?PolicyNo="$string(i));
		Response.Subst("PageHelp", NotePolicyPage);
		owner.ShowPage(Response, DefaultsIPPolicyPage);
	}
	else
		owner.AccessDenied(Response);
}

function bool ValidMask(string mask)
{
	// TODO: Put in Level.Game.AccessControl ?
	// TODO:
	return true;
}

defaultproperties
{
	Title="Defaults"
	DefaultPage="defaultsframe"
    DefaultsIndexPage="defaults"
    DefaultsMenuPage="defaults_menu"
    DefaultsMapsPage="defaults_maps"
    DefaultsRulesPage="defaults_rules"
    DefaultsIPPolicyPage="defaults_ippolicy"
    DefaultsRestartPage="defaults_restart"

	NoteMapsPage="Manage your maps rotation list by adding them to the right list. You can even decide in which order they will be played."
	NoteRulesPage="Here you can configure how each game type will be loaded when used. Some parameters can affect more than 1 game type."
	NotePolicyPage="Gives you a list of IP and IP range that are currently prevented from accessing this server. You can add new ones and/or remove old ones"
}