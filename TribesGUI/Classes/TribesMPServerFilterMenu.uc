// ====================================================================
//  Class:  TribesGui.TribesMPServerFilterMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPServerFilterMenu extends TribesGUIPage
     ;
var(TribesGui) private EditInline Config GUIButton		    DoneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DefaultButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    AddButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RemoveButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			FilterNameEntryBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBox			FilterQueryEntryBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    FilterListBox "A component of this page which has its behavior defined in the code for this page's class.";

var ServerFilterInfo defaultFilterInfo, customFilterInfo;
var localized string noneString;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    DoneButton.OnClick=OnDoneClicked;
    DefaultButton.OnClick=OnDefaultClicked;
    AddButton.OnClick=OnAddClicked;
    RemoveButton.OnClick=OnRemoveClicked;

	OnActivate = InternalOnActivate;

	defaultFilterInfo = new(Outer, "Default") class'ServerFilterInfo';
	customFilterInfo = new(Outer, "Custom") class'ServerFilterInfo';

	// If custom filters are empty, fill them with defaults
	if (customFilterInfo.filterList.Length == 0)
		customFilterInfo.copy(defaultFilterInfo);

}

function InternalOnActivate()
{
	RefreshData();
}

function RefreshData()
{
	local int i;

	FilterListBox.Clear();
	for (i=0; i<customFilterInfo.filterList.Length; i++)
	{
		FilterListBox.AddNewRowElement("Name",,customFilterInfo.filterList[i].filterName);
		FilterListBox.AddNewRowElement("Query",,customFilterInfo.filterList[i].queryString);
		FilterListBox.PopulateRow( "Name" );
	}
}

function OnDoneClicked(GUIComponent Sender)
{
	// Save filters here
	customFilterInfo.SaveConfig();
	Controller.CloseMenu();
}

function OnDefaultClicked(GUIComponent Sender)
{
	// Reset defaults here
	customFilterInfo.copy(defaultFilterInfo);
	RefreshData();
}

function OnAddClicked(GUIComponent Sender)
{
	// Add filter currently specified in FilterName and FilterQuery
	if (FilterNameEntryBox.GetText() == "" || FilterQueryEntryBox.GetText() == "" || FilterNameEntryBox.GetText() ~= noneString)
		return;

	customFilterInfo.addFilter(FilterNameEntryBox.GetText(), FilterQueryEntryBox.GetText());
	FilterNameEntryBox.SetText("");
	FilterQueryEntryBox.SetText("");
	RefreshData();
}

function OnRemoveClicked(GUIComponent Sender)
{
	// Remove currently selected filter
	customFilterInfo.removeFilter(FilterListBox.FindColumn("Name").MCList.GetExtra());
	RefreshData();
}

defaultproperties
{
	noneString = "None"
}