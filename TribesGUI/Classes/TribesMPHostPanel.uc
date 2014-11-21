	// ====================================================================
//  Class:  TribesGui.TribesMPHostPanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPHostPanel extends TribesMPPanel
     ;

var(TribesGui) private EditInline Config GUIButton		    StartServerButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    AdvancedButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckboxButton	DedicatedButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox		    MapListBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox		    GameTypeListBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUILabel           GameTypeDescriptionLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel           MapDescriptionLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIProgressBar     progressBar "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIImage		    screenshotImage "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIEditBox         ServerNameBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox         PasswordBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config localized string   BadPassword;

var bool bInitialized;
var array<LevelSummary> summaryList;
var array<String> fileList;
var array<String> gameTypeDescriptions;
var string currentGameType;
var string currentMap;
var Canvas progressCanvas;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	StartServerButton.OnClick=OnStartServerClick;
	AdvancedButton.OnClick=OnAdvancedClick;
	MapListBox.List.OnChange=MapListOnChange;
	GameTypeListBox.List.OnChange=GameTypeListOnChange;
	progressBar.OnDraw=ProgressOnDraw;

	ServerNameBox.SetText(class'GameReplicationInfo'.default.ServerName);
}

function bool ProgressOnDraw(Canvas C)
{
	progressCanvas = C;
	return true;
}

function LoadLevelSummaries(out array<String> levelFileList, out array<LevelSummary> levelSummaryList )
{
	local LevelSummary L;
	local int i, numLevelsToLoad;

	local string FirstMap, NextMap, TestMap, LoadMap;

	FirstMap = PlayerOwner().GetMapName("MP-", "", 0);
	NextMap = FirstMap;

	// Count number of maps first
	while (!(FirstMap ~= TestMap))
	{
		numLevelsToLoad++;

		if(Right(NextMap, 4) ~= ".tvm")
			LoadMap = Left(NextMap, Len(NextMap) - 4);
		else
			LoadMap = NextMap;

		//Log("LOADBOX:  Adding "$LoadMap);
		NextMap = PlayerOwner().GetMapName("MP-", NextMap, 1);
		TestMap = NextMap;

		if (LoadMap != "")
			levelFileList[levelFileList.Length] = LoadMap;
	}

//GUIFIX	progressBar.High = numLevelsToLoad ;

	// Now load the actual LevelSummaries (potentially slow)
	for (i=0; i<levelFileList.Length; i++)
	{
		L = Controller.LoadLevelSummary(levelFileList[i]$".LevelSummary");
		// Old method
		//L = LevelSummary(DynamicLoadObject(levelFileList[i]$".LevelSummary", class'LevelSummary'));

		// Update progress bar
		progressBar.Value = i+1;
		//progressBar.UpdateComponent(progressCanvas);

		if (L == None)
		{
			Log("The map named "$levelFileList[i]$" doesn't have a LevelSummary!");
			continue;
		}

		levelSummaryList[levelSummaryList.Length] = L;
	}
}

function LoadMapList()
{
	local int i,j;
	local LevelSummary L;

	MapListBox.List.Clear();
	
	for (i=0; i<summaryList.Length; i++)
	{
		// See if this map supports the currently selected game type
		L = summaryList[i];

		if (L == None)
		{
			Log("Warning:  while loading maps, levelSummaryList has no levelSummary at index "$i);
			continue;
		}

		for (j=0; j<L.SupportedModes.Length; j++)
		{
			if (L.SupportedModes[j] == None)
				continue;

			if (currentGameType == L.SupportedModes[j].default.acronym)
			{
				//Log(L.Title $ " supports game type "$currentGameType$" -- "$levelFileList[i]);
		        //if (L.Title != "Untitled")
				//	MapListBox.List.Add( L.Title,L, fileList[i] );
				//else
					MapListBox.List.Add( fileList[i],L, fileList[i]);
			}
		}
	}

	MapListBox.List.SetIndex(0);
    MapListBox.List.Sort();
}

function LoadGameTypes()
{
	local LevelSummary L;
	local int i,j;

	for (i=0; i<summaryList.Length; i++)
	{
		// See if this map supports the currently selected game type
		L = summaryList[i];

		if (L == None)
		{
			Log("Warning:  while loading game types, levelSummaryList has no levelSummary at index "$i);
			continue;
		}

		for (j=0; j<L.SupportedModes.Length; j++)
		{
			if (L.SupportedModes[j] == None || L.SupportedModes[j].default.acronym == "")
				continue;

			if (GameTypeListBox.List.Find(L.SupportedModes[j].default.acronym) == "")
			{
				//Log("GAMETYPE:  A gametype was detected!  "$L.SupportedModes[j].default.acronym$", classname = "$L.SupportedModes[j]);
				// Store GameTypeDescriptions since I couldn't get it to properly store the GameInfo class
				GameTypeListBox.List.Add(L.SupportedModes[j].default.acronym,L.SupportedModes[j],string(L.SupportedModes[j]), GameTypeDescriptions.Length);
				GameTypeDescriptions[GameTypeDescriptions.Length] = L.SupportedModes[j].default.GameDescription;
			}
		}
	}
	GameTypeListBox.List.Sort();
}


function string getSelectedGameInfoName()
{
	return GameTypeListBox.List.GetExtra();
}

function OnStartServerClick(GUIComponent Sender)
{
	local string mapName;
	local string serverName, password;

	mapName = MapListBox.List.GetExtra();

	// Remember server name save it out
	serverName = ServerNameBox.GetText();
	class'GameReplicationInfo'.default.ServerName = ServerName;
	class'GameReplicationInfo'.static.StaticSaveConfig();

	// Setup join password
	password = PasswordBox.GetText();
	if (password != "")
	{
		if (!IsValidForURL(password))
		{
			GUIPage(MenuOwner.MenuOwner).OpenDlg(BadPassword, QBTN_Ok);
			return;
		}
		else
			GC.MPHostURL = GC.MPHostURL$"?GamePassword="$password;
	}

	// Setup gameinfo subclass
	GC.MPHostURL = GC.MPHostURL$"?game="$getSelectedGameInfoName();

	// Setup stat tracking (configured in advanced screen)
	GC.MPHostURL = GC.MPHostURL$"?GameStats="$ class'GameReplicationInfo'.default.bCollectStats;

	// Setup internet or LAN only (configured in advanced screen)
	if (!class'GameReplicationInfo'.default.bAdvertise)
		GC.MPHostURL = GC.MPHostURL$"?LAN";

	// Setup max players (configured in advanced screen)
	GC.MPHostURL = GC.MPHostURL $ "?MaxPlayers="$class'MultiplayerGameInfo'.default.MaxPlayers;

	// Setup session admin name and password, if applicable (configured in advanced screen)
	if ( class'GameReplicationInfo'.default.AdminName!="")
		GC.MPHostURL = GC.MPHostURL$"?AdminName="$class'GameReplicationInfo'.default.AdminName;
	if ( class'GameReplicationInfo'.default.AdminPass != "")
		GC.MPHostURL = GC.MPHostURL$"?AdminPassword="$class'GameReplicationInfo'.default.AdminPass;

	GC.CurrentMission = mapName;	
	GC.bDedicated = DedicatedButton.bChecked;
	GC.bTravelMission = false;

	// If it's a listen server then also fetch profile options
	if (!GC.bDedicated)
		GC.MPHostURL = GC.MPHostURL$"?listen?"$TribesGUIController(Controller).profileManager.GetURLOptions();

	TribesGUIController(Controller).GameStart();
}

function OnAdvancedClick(GUIComponent Sender)
{
	Controller.OpenMenu("TribesGui.TribesMPServerConfigMenu", "TribesMPServerConfigMenu");
}

function MapListOnChange(GUIComponent Sender)
{
	local LevelSummary L;

	currentMap = MapListBox.List.Get();
	L = LevelSummary(MapListBox.List.GetObject());

	if (L != None)
	{
		screenshotImage.Image = L.screenshot;
	}
	else
	{
		screenshotImage.Image = screenshotImage.default.Image;
	}
}

function GameTypeListOnChange(GUIComponent Sender)
{
	if (!bInitialized)
		return;

	currentGameType = GameTypeListBox.List.Get();

	GameTypeDescriptionLabel.Caption = GameTypeDescriptions[GameTypeListBox.List.GetExtraIntData()];

	if (currentGameType != "")
		LoadMapList();
}

function InternalOnActivate()
{
	// If coming back from the advanced server config menu, change the selection
	if (GC.advancedGameType != "")
	{
		GameTypeListBox.List.Find(GC.advancedGameType);
		GC.advancedGameType = "";
	}

	if (GC.advancedMap != "")
	{
		MapListBox.List.Find(GC.advancedMap);
		GC.advancedMap = "";
	}

	SetTimer(0.2, false);
}

function Timer()
{
	if (!bInitialized)
	{
		LoadLevelSummaries(fileList, summaryList);
		LoadGameTypes();
		bInitialized = true;
		GameTypeListBox.List.SetIndex(0);
		LoadMapList();
	}
}

defaultproperties
{
	OnActivate=InternalOnActivate
	bInitialized=false
	BadPassword="The password contains invalid characters. You cannot use spaces or puncuation in the server password."
}
