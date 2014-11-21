// ====================================================================
//  Class:  TribesGui.TribesDebugLoadMapMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesDebugLoadMapMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    LoadButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    LoadCutsceneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    MainMenuButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    LoadGameBox "A component of this page which has its behavior defined in the code for this page's class.";

var string menuCallerName;

function InitComponent(GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyOwner);

    LoadButton.OnClick=InternalOnClick;
    LoadCutsceneButton.OnClick=InternalOnClick;
    CancelButton.OnClick=InternalOnClick;
	MainMenuButton.OnClick=InternalOnClick;

	for( i = 0; i < LoadGameBox.MultiColumnList.Length; i++ )
    {
        LoadGameBox.MultiColumnList[i].MCList.OnDblClick=InternalOnClick;
    }

	LoadMapList();
	bEscapeable = true;
}

event HandleParameters( string Param1, string Param2, optional int param3)
{
	menuCallerName = Param1;

	if (menuCallerName == "TribesSPEscapeMenu")
	{
		MainMenuButton.Hide();
		PageOpenedAfterEscape = "";
	}
	else
	{
		CancelButton.Hide();
		PageOpenedAfterEscape = class'GameEngine'.default.MainMenuClass;
	}
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap;

	FirstMap = PlayerOwner().GetMapName("", "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
	{
		//Log("LOADBOX:  Adding "$NextMap);
        LoadGameBox.AddNewRowElement( "Name",,    NextMap );
		LoadGameBox.PopulateRow( "Name" );
		NextMap = PlayerOwner().GetMapName("", NextMap, 1);
		TestMap = NextMap;
	}
    LoadGameBox.SetActiveColumn( "Name" );
    LoadGameBox.Sort();
    LoadGameBox.SetIndex(0);
}

function InternalOnClick(GUIComponent Sender)
{
	local string mapName;
	local int idx;

	switch (Sender)
	{
		case MainMenuButton:
			Controller.CloseMenu();
			Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
			return;
		case CancelButton:
			Controller.CloseMenu();
			return;
		case LoadCutsceneButton:
		    mapName = LoadGameBox.FindColumn( "Name" ).MCList.GetExtra();
			GC.CurrentCampaign = new(Outer, "Default") class'CampaignInfo';
			idx = GC.CurrentCampaign.findMission(Left(mapName, Len(mapName) - 4));
			if (idx != -1)
			{
				LOG("LOADING WITH CUTSCENE MISSION "$idx);
				TribesGUIControllerBase(Controller).startNewCampaignAt(idx, class'CampaignInfo'.default.selectedDifficulty);
				return;
			}
			else
			{
				LOG("SELECTION IS NOT A CAMPAIGN MISSION");
				return;
			}
		default:
	}

	mapName = LoadGameBox.FindColumn( "Name" ).MCList.GetExtra();
	GC.CurrentMission = mapName;
	GameStart();
}

defaultproperties
{
}
