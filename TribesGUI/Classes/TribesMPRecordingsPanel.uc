// ====================================================================
//  Class:  TribesGui.TribesMPRecordingsPanel
//
// ====================================================================

class TribesMPRecordingsPanel extends TribesMPPanel
     ;

var(TribesGui) private EditInline Config GUIButton	PlayButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	CancelButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	DeleteButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton	RenameButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox	 DemoListBox "A component of this page which has its behavior defined in the code for this page's class.";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	PlayButton.OnClick=OnPlayClick;
	CancelButton.OnClick=OnCancelClick;
	DeleteButton.OnClick=OnDeleteClick;
	RenameButton.OnClick=OnRenameClick;

	OnActivate=InternalOnActivate;
}

function InternalOnActivate()
{
	RefreshList();
}

function RefreshList()
{
	local array<string> demoList;
	local int i;
	local int ScoreLimit, TimeLimit, ClientSide;
	local string MapName, GameType, RecordedBy, TimeStamp, ReqPackages;
	local class<GameInfo> gi;

	Controller.GetDEMList(demoList);

	demoListBox.clear();
	for (i=0; i<demoList.Length; i++)
	{
		Controller.GetDEMHeader(demoList[i], MapName, GameType, ScoreLimit, TimeLimit, ClientSide, RecordedBy, Timestamp, ReqPackages);
		Log("Demo found: "$demoList[i]@MapName@GameType@RecordedBy@Timestamp);
		demoListBox.AddNewRowElement( "Name",,demoList[i] );
		demoListBox.AddNewRowElement( "PlayerName",,RecordedBy );
		demoListBox.AddNewRowElement( "MapName",,MapName );
		gi = class<GameInfo>(DynamicLoadObject(GameType, class'Class'));
		demoListBox.AddNewRowElement( "GameType",,gi.default.acronym );
		demoListBox.AddNewRowElement( "Timestamp",,Timestamp );
		demoListBox.PopulateRow( "Name" );
	}
}

function OnPlayClick(GUIComponent Sender)
{
	if (getSelectedDemoName() == "")
		return;

	PlayerOwner().ConsoleCommand("demoplay "$getSelectedDemoName());
	Controller.CloseMenu();
}

function OnCancelClick(GUIComponent Sender)
{
	Controller.CloseMenu();
}

function OnDeleteClick(GUIComponent Sender)
{
	// Not yet supported
}

function OnRenameClick(GUIComponent Sender)
{
	// Not yet supported
}

function string getSelectedDemoName()
{
	return demoListBox.FindColumn("Name").MCList.GetExtra();;
}

defaultproperties
{
}