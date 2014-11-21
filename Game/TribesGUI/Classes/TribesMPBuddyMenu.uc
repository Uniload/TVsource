// ====================================================================
//  Class:  TribesGui.TribesMPBuddyMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPBuddyMenu extends TribesGUIPage
     ;
var(TribesGui) private EditInline Config GUIButton		    AddButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    RemoveButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    DoneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIListBox			BuddyBox "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIEditBOx			EntryBox "A component of this page which has its behavior defined in the code for this page's class.";

var ProfileManager playerProfileManager;
var PlayerProfile activeProfile;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    AddButton.OnClick=InternalOnClick;
    RemoveButton.OnClick=InternalOnClick;
    DoneButton.OnClick=InternalOnClick;

	OnActivate= InternalOnActivate;
}

function InternalOnActivate()
{
	playerProfileManager = TribesGUIController(Controller).profileManager;
	activeProfile = playerProfileManager.GetActiveProfile();

	RefreshData();
}

function RefreshData()
{
	local int i;
	local Array<String> buddies;

	BuddyBox.List.Clear();

	if (activeProfile == none)
		return;

	buddies = activeProfile.buddyList;

	for (i=0; i<buddies.Length; i++)
		BuddyBox.List.Add(buddies[i]);
}

function InternalOnClick(GUIComponent Sender)
{
	switch (Sender)
	{
		case AddButton:	
			// Add buddy here
			addBuddy(EntryBox.GetText());
			EntryBox.SetText("");
			break;
		case RemoveButton:
			removeBuddy(BuddyBox.List.Get());
			break;
		case DoneButton:
			playerProfileManager.Store();
			Controller.CloseMenu();
			return;
	}
}

function AddBuddy(string buddy)
{
	local int i;

	// Add buddy to current profile and refresh
	if (activeProfile == None || buddy == "")
		return;

	// Don't allow duplicates
	for (i=0; i<activeProfile.buddyList.Length; i++)
	{
		if (activeProfile.buddyList[i] == buddy)
			return;
	}
	
	activeProfile.buddyList[activeProfile.buddyList.Length] = buddy;

	playerProfileManager.Store();
	RefreshData();
}

function RemoveBuddy(string buddy)
{
	local int i;

	// Remove buddy from current profile and refresh
	if (activeProfile == None)
		return;

	for (i=0; i<activeProfile.buddyList.Length; i++)
	{
		if (activeProfile.buddyList[i] == buddy)
			activeProfile.buddyList.Remove(i, 1);
	}

	playerProfileManager.Store();
	RefreshData();
}

defaultproperties
{
}