// ====================================================================
//  Class:  TribesGui.TribesSaveGameMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesSaveGameMenu extends TribesSaveGameBase
     ;
var(TribesGui) private EditInline Config GUIButton		    SaveButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DeleteButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    SaveGameBox "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config localized string				EnterNameText;
var(TribesGui) private EditInline Config localized string				OverwriteText;
var(TribesGui) private EditInline Config localized string				DeleteText;
var(TribesGui) private EditInline Config localized string				NewSavegameText;

var bool bHasSaved;
var string CallingDlg;
var string savehackname;

delegate OnUserSaved();

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    SaveButton.OnClick=InternalOnClick;
    DeleteButton.OnClick=InternalOnClick;
    CancelButton.OnClick=InternalOnClick;

    OnPopupReturned=InternalOnPopupReturned;
	OnDlgReturned=InternalDlgReturned;
    OnShow=InternalOnShow;
	OnActivate=InternalOnActivate;

	bEscapeable = true;

}

function HandleParameters(string Param1, string Param2, optional int Param3)
{
	CallingDlg = Param1;
}

function InternalOnActivate()
{
	bHasSaved = false;
}

function InternalOnShow()
{
	local int i;

	SaveGameBox.Clear();
    SaveGameBox.AddNewRowElement( "Name",, NewSavegameText );
	SaveGameBox.PopulateRow( "Name" );

	LoadSaveGameList(SaveGameBox, true);
	SaveGameBox.ActiveRowIndex = -1;
	for( i = 0; i < SaveGameBox.MultiColumnList.Length; i++ )
    {
        SaveGameBox.MultiColumnList[i].MCList.OnDblClick=InternalOnClick;
    }
}

function InternalOnPopupReturned( GUIListElem returnObj, optional string Passback )
{
	local int i;
	for (i = 0; i < SaveGameBox.MultiColumnList[0].MCList.Elements.Length; i++)
	{
		if (SaveGameBox.MultiColumnList[0].MCList.Elements[i].extraStrData == returnObj.item)
		{
			OpenDlg(OverwriteText, QBTN_OkCancel, "sav"$returnObj.item);
			return;
		}
	}

	savehackname = returnObj.item;
	SetTimer(0.0001); // hack
}

function Timer()
{
	// hack
	InternalDlgReturned(QBTN_Ok, "sav"$savehackname);
}

function InternalDlgReturned( int Selection, optional string Passback )
{
	local string cmd;
	local string S;

	cmd = Left(Passback, 3);
	S = Mid(Passback, 3);

	if (Selection == QBTN_Ok)
	{
		if (cmd == "sav")
		{
			if (CallingDlg == "TribesSPEscapeMenu")
			{
				PlayerOwner().ConsoleCommand( "PAUSE" );
				Controller.RemoveMenu(CallingDlg);
			}

			Controller.CloseMenu();

			S = EncodeForURL(S);
			Controller.ConsoleCommand("SaveGame"@S);

			bHasSaved = true;
			OnUserSaved();
		}
		else if (cmd == "del")
		{
			DeleteSave(EncodeForURL(S));
			InternalOnShow();
		}
	}
}

function string DefaultSaveName()
{
	return Controller.ViewportOwner.Actor.Level.Summary.Title;
}

function InternalOnClick(GUIComponent Sender)
{
	local string saveStr;

	switch (Sender)
	{
		case DeleteButton:
			if (SaveGameBox.ActiveRowIndex > 0)
				OpenDlg(DeleteText, QBTN_OkCancel, "del"$SaveGameBox.FindColumn( "Name" ).MCList.GetExtra());
			break;
		case CancelButton:
			Controller.CloseMenu();
			if (bHasSaved)
				OnUserSaved();
			return;
		default:
			Controller.OpenMenu( "TribesGui.TribesDefaultTextEntryPopup", "TribesDefaultTextEntryPopup", EnterNameText );
			TribesDefaultTextEntryPopup(Controller.ActivePage).MyEditBox.MaxWidth = 64;
			
			if (SaveGameBox.ActiveRowIndex > 0)
				saveStr = SaveGameBox.FindColumn( "Name" ).MCList.GetExtra();
			else
				saveStr = DefaultSaveName();
			
			if (Len(saveStr) > 64)
				saveStr = Left(saveStr, 64);
				
			TribesDefaultTextEntryPopup(Controller.ActivePage).MyEditBox.SetText(saveStr);
			break;
	}
}

defaultproperties
{
	EnterNameText="Please enter a name for the savegame"
	OverwriteText="Are you sure that you want to overwrite this savegame?"
	DeleteText="Are you sure that you want to delete this savegame?"
	NewSavegameText="New Savegame..."
}