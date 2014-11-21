// ====================================================================
//  Class:  TribesGui.TribesMPServerConfigMenu
//
// ====================================================================

class TribesMPServerConfigMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    DoneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    UpButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DownButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    AddButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    AddAllButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RemoveButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RemoveAllButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckboxButton	AdvertiseButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckboxButton	StatsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckboxButton	WebAdminButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			AdminNameBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			AdminEmailBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			AdminPasswordBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			WebAdminPortBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			MaxPlayersBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			TimeLimitBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIListBox			GameTypeListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox			MapListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox			MapRotationListBox "A component of this page which has its behavior defined in the code for this page's class.";

var Config	string currentGameInfo;

var class<MapList> MapListClass;
var MapList MyList;
var bool bInitialized;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	DoneButton.OnClick = DoneClicked;
	CancelButton.OnClick = CancelClicked;
	UpButton.OnClick = UpClicked;
	DownButton.OnClick = DownClicked;
	AddButton.OnClick = AddClicked;
	AddAllButton.OnClick = AddAllClicked;
	RemoveButton.OnClick = RemoveClicked;
	RemoveAllButton.OnClick = RemoveAllClicked;

	AdvertiseButton.bChecked = class'GameReplicationInfo'.default.bAdvertise;
	StatsButton.bChecked = class'GameReplicationInfo'.default.bCollectStats;
	WebAdminButton.bChecked = class'WebServer'.default.benabled;
	WebAdminPortBox.SetText(string(class'WebServer'.default.ListenPort));

	AdminNameBox.SetText(class'GameReplicationInfo'.default.AdminName);
	AdminEmailBox.SetText(class'GameReplicationInfo'.default.AdminEmail);
	AdminPasswordBox.SetText(class'GameReplicationInfo'.default.AdminPass);

	GameTypeListBox.OnChange = GameTypeListOnChange;
	TimeLimitBox.OnChange = TimeLimitOnChange;

	OnActivate=InternalOnActivate;
	OnDeactivate=InternalOnDeactivate;
	bEscapeable = true;

	class'Utility'.static.refresh();
}

function InternalOnActivate()
{
	Refresh();
	bInitialized = true;
}

function InternalOnDeactivate()
{
	bInitialized = false;
}

function LoadGameInfo(out class<MultiplayerGameInfo> G, out class<RoundInfo> R)
{
	G = class<MultiplayerGameInfo>(DynamicLoadObject(currentGameInfo, class'Class'));

	if (G == None)
	{
		Log("Warning:  GetGameInfoData() could not DLO "$currentGameInfo);
		return;
	}

	R = G.default.RoundInfoClass;//class<RoundInfo>(DynamicLoadObject(string(G.default.RoundInfoClass), class'Class'));

	if (R == None)
	{
		Log("Warning:  GetGameInfoData() could not DLO "$G.default.RoundInfoClass);
	}
}

function LoadGameInfoData()
{
	local class<MultiplayerGameInfo> G;
	local class<RoundInfo> R;

	LoadGameInfo(G, R);

	// If there's no TimeLimit override, set time limit from the first round
	if (G.default.TimeLimit == 0)
		TimeLimitBox.SetText(string(int(R.default.rounds[0].duration)));
	else
		TimeLimitBox.SetText(string(G.default.TimeLimit));

	MaxPlayersBox.SetText(string(G.default.MaxPlayers));
}

function SaveGameInfoData()
{
	local class<MultiplayerGameInfo> G;
	local class<RoundInfo> R;

	LoadGameInfo(G, R);

	// Set a timeLimit override if different than the first round
	if (R.default.rounds[0].duration != float(TimeLimitBox.GetText()))
		G.default.TimeLimit = int(TimeLimitBox.GetText());

	G.default.MaxPlayers = int(MaxPlayersBox.GetText());
	G.static.StaticSaveConfig();
}

function Refresh()
{
	local int i, j;

	MapRotationListBox.clear();
	RefreshGameTypes();
	LoadMapList();
	RefreshMaps();

	for (i=0; i<MapListClass.default.Maps.Length; i++)
	{
		//Log("Adding map rotation "$MapListClass.default.Maps[i]);
		MapRotationListBox.List.Add(MapListClass.default.Maps[i]);
	}

	// Remove any maps from the MapList that are also in the MapRotationList
	for (i=0; i<MapRotationListBox.List.Elements.Length; i++)
	{
		j = MapListBox.List.FindIndex(MapRotationListBox.List.Elements[i].Item);

		if (j >= 0)
			MapListBox.List.Remove(j, 1);
	}
}

function LoadMapList()
{
	local class<GameInfo> G;
	local string MapListString;

	G = class<GameInfo>(DynamicLoadObject(currentGameInfo, class'Class'));

	if (G != None)
		MapListString = G.default.MapListType;
	else
		MapListString = "Gameplay.MapList";

    MapListClass = class<MapList>(DynamicLoadObject(MapListString, class'Class'));
	//if (MapListClass != None)
	//	MyList = PlayerOwner().Spawn(MapListClass);

	Log("Loaded maplist of type "$MapListClass);
}

function RefreshGameTypes()
{
	local array<Utility.GameData> gdList;
	local int i;

	class'Utility'.static.getGameTypeList(gdList);

	// Populate game type list
	GameTypeListBox.List.clear();

	for (i=0; i<gdList.Length; i++)
	{
		GameTypeListBox.List.Add(gdList[i].name,,gdList[i].className);
	}

	GameTypeListBox.List.Sort();

	// Set the current game type
	GameTypeListBox.List.FindExtra(currentGameInfo);
	LoadGameInfoData();
}

function RefreshMaps()
{
	local array<string> mapList;
	local int i;

	MapListBox.clear();
	class'Utility'.static.getLevelListForGameType(GameTypeListBox.List.Get(), mapList);

	for (i=0; i<mapList.Length; i++)
	{
		//Log("Adding "$mapList[i]);
		MapListBox.List.Add(mapList[i]);
	}

	MapListBox.List.Sort();
	MapListBox.List.SetIndex(0);
}

function SaveSettings()
{
	local int i;
	
	SaveConfig();
	SaveGameInfoData();

	class'GameReplicationInfo'.default.AdminName  		= AdminNameBox.GetText();
	class'GameReplicationInfo'.default.AdminEmail 		= AdminEmailBox.GetText();
	class'GameReplicationInfo'.default.AdminPass		= AdminPasswordBox.GetText();
	class'GameReplicationInfo'.default.bAdvertise		= AdvertiseButton.bChecked;
	class'GameReplicationInfo'.default.bCollectStats	= StatsButton.bChecked;

//	class'GameReplicationInfo'.default.MOTDLine1	= MyMOTD1.GetText();
//	class'GameReplicationInfo'.default.MOTDLine2	= MyMOTD2.GetText();
//	class'GameReplicationInfo'.default.MOTDLine3	= MyMOTD3.GetText();
//	class'GameReplicationInfo'.default.MOTDLine4	= MyMOTD4.GetText();
	class'GameReplicationInfo'.static.StaticSaveConfig();

	class'WebServer'.Default.bEnabled = WebAdminButton.bChecked;
	class'WebServer'.Default.ListenPort = int(WebAdminPortBox.GetText());
	class'WebServer'.static.StaticSaveConfig();

	// Save map rotation (clear it first)
	MapListClass.default.Maps.Length = 0;

	for (i=0; i<MapRotationListBox.List.Elements.Length; i++)
	{
		MapListClass.default.Maps[i] = MapRotationListBox.List.Elements[i].Item;
	}
	MapListClass.static.StaticSaveConfig();
}

function DoneClicked(GUIComponent Sender)
{
	SaveSettings();
	GC.advancedGameType = GameTypeListBox.List.Get();
	GC.advancedMap = MapRotationListBox.List.Get();
	Controller.CloseMenu();
}

function CancelClicked(GUIComponent Sender)
{
	Controller.CloseMenu();
}

function UpClicked(GUIComponent Sender)
{
	// Move the currently selected map in the map schedule down one slot
	MapRotationListBox.List.Swap(MapRotationListBox.List.Index, MapRotationListBox.List.Index - 1);
	MapRotationListBox.List.SetIndex(MapRotationListBox.List.Index - 1);
}

function DownClicked(GUIComponent Sender)
{
	// Move the currently selected map in the map schedule up one slot
	MapRotationListBox.List.Swap(MapRotationListBox.List.Index, MapRotationListBox.List.Index + 1);
	MapRotationListBox.List.SetIndex(MapRotationListBox.List.Index + 1);
}

function AddClicked(GUIComponent Sender)
{
	// Add the currently selected available map to the map schedule
	if (MapListBox.List.Get() == "")
		return;

	MapRotationListBox.List.Add(MapListBox.List.Get());
	MapListBox.List.Remove(MapListBox.List.Index, 1);
}

function AddAllClicked(GUIComponent Sender)
{
	local int i;

	// Add all available maps for the current game type to the map schedule
	for (i=0; i<MapListBox.List.Elements.Length; i++)
	{
		MapRotationListBox.List.Add(MapListBox.List.Elements[i].Item);
	}

	MapListBox.List.Clear();
}

function RemoveClicked(GUIComponent Sender)
{
	// Remove the currently selected map from the map schedule
	if (MapRotationListBox.List.Get() == "")
		return;

	MapListBox.List.Add(MapRotationListBox.List.Get());
	MapRotationListBox.List.Remove(MapRotationListBox.List.Index, 1);
	MapListBox.List.Sort();
}

function RemoveAllClicked(GUIComponent Sender)
{
	local int i;

	// Remove all maps from the map schedule
	for (i=0; i<MapRotationListBox.List.Elements.Length; i++)
	{
		MapListBox.List.Add(MapRotationListBox.List.Elements[i].Item);
	}
	MapRotationListBox.List.Clear();
	MapListBox.List.Sort();
}

function GameTypeListOnChange(GUIComponent Sender)
{
	// Clear rotation and update maps
	if (!bInitialized)
		return;

	MapRotationListBox.List.Clear();

	if (GameTypeListBox.List.GetExtra() != "")
		currentGameInfo = GameTypeListBox.List.GetExtra();

	//Log("Set currentGameInfo to "$currentGameInfo);

	RefreshMaps();
	LoadGameInfoData();
}

function TimeLimitOnChange(GUIComponent Sender)
{
	SaveGameInfoData();
}

defaultproperties
{
	currentGameInfo="GameClasses.ModeCTF"
}
