// ====================================================================
//  Class:  TribesGui.TribesLoadGameMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesLoadGameMenu extends TribesSaveGameBase
     ;

var(TribesGui) private EditInline Config GUIButton		    LoadButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DeleteButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    MainMenuButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    LoadGameBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config localized string	DeleteText;

var string menuCallerName;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    LoadButton.OnClick=InternalOnClick;
    DeleteButton.OnClick=InternalOnClick;
    CancelButton.OnClick=InternalOnClick;
	MainMenuButton.OnClick=InternalOnClick;

	OnDlgReturned=InternalDlgReturned;
	OnShow=InternalOnShow;

	bEscapeable = true;
}

function InternalOnShow()
{
	local int i;

	LoadSaveGameList(LoadGameBox);
	LoadGameBox.ActiveRowIndex = -1;
	for( i = 0; i < LoadGameBox.MultiColumnList.Length; i++ )
    {
        LoadGameBox.MultiColumnList[i].MCList.OnDblClick=InternalOnClick;
    }
}

event HandleParameters( string Param1, string Param2, optional int param3)
{
	menuCallerName = Param1;

	if (menuCallerName == "TribesSPEscapeMenu")
	{
		MainMenuButton.bCanBeShown = false;
		MainMenuButton.Hide();
		CancelButton.bCanBeShown = true;
		CancelButton.Show();
		PageOpenedAfterEscape = "";
	}
	else
	{
		MainMenuButton.bCanBeShown = true;
		MainMenuButton.Show();
		CancelButton.bCanBeShown = false;
		CancelButton.Hide();
		PageOpenedAfterEscape = class'GameEngine'.default.MainMenuClass;
	}
}

function InternalDlgReturned( int Selection, optional string Passback )
{
	if (Selection == QBTN_Ok)
	{
		DeleteSave(EncodeForURL(Passback));
		InternalOnShow();
	}
}

function InternalOnClick(GUIComponent Sender)
{
	local string mapName;

	switch (Sender)
	{
		case DeleteButton:
			if (LoadGameBox.MultiColumnList[0].MCList.Elements.Length > 0)
				OpenDlg(DeleteText, QBTN_OkCancel, LoadGameBox.FindColumn( "Name" ).MCList.GetExtra());
			break;
		case MainMenuButton:
			Controller.CloseMenu();
			Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
			return;
		case CancelButton:
			Controller.CloseMenu();
			return;
		default:
			if (LoadGameBox.MultiColumnList[0].MCList.Elements.Length > 0)
			{
				mapName = LoadGameBox.FindColumn( "Name" ).MCList.GetExtra();
				GC.CurrentMission = EncodeForURL("SaveGame_" $ mapName);
				GC.bTravelMission = false;
				GameStart();
			}
			break;
	}
}

defaultproperties
{
	DeleteText="Are you sure that you want to delete this savegame?"
}
