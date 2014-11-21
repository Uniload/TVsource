// ====================================================================
//  Class:  TribesGui.TribesOptionsControlsMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesOptionsControlsPanel extends TribesSettingsPanel
	native;

var(TribesGUI) private EditInline Config GUIMultiColumnListBox   MyKeyBindingsBox;
var(TribesGUI) private EditInline Config GUIButton               MyKeyChoose;

var(TribesGUI) private EditInline Config GUICheckBoxButton       InvertMouseButton;
var(TribesGUI) private EditInline Config GUICheckBoxButton       TeamColorsButton;
//var(TribesGUI) private EditInline Config GUIComboBox		     MyCategoryList;
var(TribesGUI) private EditInline Config GUISlider			     MyMouseSensSlider;
var(TribesGui) private EditInline Config GUIButton DefaultsButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGUI) private string LastCategory;

var() private config localized string KeyChangeMessage;
var() private config localized string NoBindKeyChangeMessage;

function InitComponent(GUIComponent MyOwner)
{
    local int i;
//	local int j;
//	local bool bFound;
    
	Super.InitComponent(MyOwner);
	MyKeyChoose.OnClick=InternalOnClick;
	MyMouseSensSlider.OnChange=OnSensitivityChange;
	MyMouseSensSlider.UpdateFreq=0;
	InvertMouseButton.OnClick=OnInvertMouseClick;
	TeamColorsButton.OnClick=OnTeamColorsClick;
	
	// discover categories
    /*for( i = 0; i < class'KeyBindings'.default.CommandCategory.Length; i++ )
    {
		bFound = false;
		for( j = 0; j < MyCategoryList.List.Elements.Length; j++)
		{
			if (MyCategoryList.List.Elements[j].ExtraStrData == class'KeyBindings'.default.CommandCategory[i])
			{
				bFound = true;
				break;
			}
		}

		if (!bFound)
		{
			MyCategoryList.List.Add(class'KeyBindings'.default.LocalizedCommandCategories[MyCategoryList.List.Elements.Length],,class'KeyBindings'.default.CommandCategory[i]);
		}
    }
	MyCategoryList.OnListIndexChanged = CategorySelectorOnClick;
	MyCategoryList.ReadOnly(true);*/

	LastCategory = class'KeyBindings'.default.CommandCategory[0];
	
	for( i = 0; i < MyKeyBindingsBox.MultiColumnList.Length; i++ )
    {
        MyKeyBindingsBox.MultiColumnList[i].MCList.OnDblClick=InternalOnClick;
    }
}

function InternalOnActivate()
{
	DefaultsButton.bCanBeShown = true;
	DefaultsButton.Show();

    GUIPage(MenuOwner.MenuOwner).OnPopupReturned=InternalOnPopupReturned;
	DefaultsButton.OnClick=OnDefaults;
	LoadSettings(false);
}

function InternalOnHide()
{
	EnsureConsistency();
}

function SaveSettings()
{
    //no generic save needed for this panel
	class'KeyBindings'.static.StaticSaveConfig();
}

function LoadSettings(bool bEnsureConsistency)
{
    //no generic load needed for this panel
    LoadCategory( LastCategory );
	MyMouseSensSlider.Value=float(PlayerOwner().ConsoleCommand("Get WinDrv.WindowsClient MouseXMultiplier"));
	InvertMouseButton.bChecked=bool(PlayerOwner().ConsoleCommand("Get PlayerInput bInvertMouse"));
	TeamColorsButton.bChecked=bool(PlayerOwner().ConsoleCommand("Get Gameplay.PlayerCharacterController bTeamMarkerColors"));

	if (bEnsureConsistency)
		EnsureConsistency();
}

private function LoadCategory( string Category )
{
    local int i;
	local string primaryMapping;
	local string secondaryMapping;
	local string currentSelection;
    
	//MyCategoryList.Edit.SetText(Category);

    LastCategory=Category;
	currentSelection=MyKeyBindingsBox.FindColumn("Functions").MCList.GetExtra();
    MyKeyBindingsBox.Clear();
    
    for( i = 0; i < class'KeyBindings'.default.CommandString.Length; i++ )
    {
        //only load ones in this category
        if( class'KeyBindings'.default.CommandCategory[i] != Category )
            continue;

        MyKeyBindingsBox.AddNewRowElement( "Functions",,class'KeyBindings'.default.LocalizedCommandString[i],i);

		// add primary and secondary mappings
		primaryMapping = PlayerOwner().ConsoleCommand("LOCALIZEDKEYNAME"@PlayerOwner().ConsoleCommand("KEYNUM"@class'KeyBindings'.default.PrimaryBinds[i]));
		secondaryMapping = PlayerOwner().ConsoleCommand("LOCALIZEDKEYNAME"@PlayerOwner().ConsoleCommand("KEYNUM"@class'KeyBindings'.default.SecondaryBinds[i]));
		//primaryMapping = class'KeyBindings'.default.PrimaryBinds[i];
		//secondaryMapping = class'KeyBindings'.default.SecondaryBinds[i];

		MyKeyBindingsBox.AddNewRowElement( "MappedKey",,primaryMapping,i);
        MyKeyBindingsBox.AddNewRowElement( "MappedKeySecondary",,secondaryMapping,i);

        MyKeyBindingsBox.PopulateRow( "Functions" );
    }

	if (currentSelection == "")
		MyKeyBindingsBox.SetIndex(0);
	else
		MyKeyBindingsBox.FindColumn("Functions").MCList.FindExtra(currentSelection);
    
    MyKeyBindingsBox.SetEnabled( Category != "Reserved" );
    MyKeyChoose.SetEnabled( Category != "Reserved" );
}

function InternalOnClick( GUIComponent Sender )
{
    local string LocalizedFunc, Func, Bound;

	LocalizedFunc = MyKeyBindingsBox.GetColumn( "Functions" ).GetExtra();
    Func = class'KeyBindings'.default.CommandString[MyKeyBindingsBox.GetColumn( "Functions" ).GetExtraIntData()];

	if (MyKeyBindingsBox.LastClickedIndex <= 1)
	{
	    Bound = MyKeyBindingsBox.GetColumn( "MappedKey" ).GetExtra();
	}
	else
	{
	    Bound = MyKeyBindingsBox.GetColumn( "MappedKeySecondary" ).GetExtra();
	}

	if (Bound != "")
	    Controller.OpenMenu( "TribesGui.TribesKeyMappingPopup", "TribesKeyMappingPopup", replaceStr(KeyChangeMessage, LocalizedFunc, Bound), Func );
	else
	    Controller.OpenMenu( "TribesGui.TribesKeyMappingPopup", "TribesKeyMappingPopup", replaceStr(NoBindKeyChangeMessage, LocalizedFunc), Func );
}

function InternalOnPopupReturned( GUIListElem returnObj, optional string Passback )
{
	local int i;
	local string key;

	key = returnObj.ExtraStrData;
	log("Pressed"@returnObj.ExtraStrData);

	// if we pressed escape, clear binding
	if ( key ~= "Escape" )
		key = "";

	//remove the old binding
    for( i = 0; i < class'KeyBindings'.default.CommandString.Length; i++ )
    {
		if (class'KeyBindings'.default.CommandString[i] == Passback)
		{
			if (MyKeyBindingsBox.LastClickedIndex <= 1)
			{
				PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.PrimaryBinds[i]);
			}
			else
			{
				PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.SecondaryBinds[i]);
			}
		}
	}

    //map the new binding
    PlayerOwner().ConsoleCommand("SET Input"@key@Passback);

    for( i = 0; i < class'KeyBindings'.default.CommandString.Length; i++ )
    {
		if (class'KeyBindings'.default.CommandString[i] == Passback)
		{
			if (MyKeyBindingsBox.LastClickedIndex <= 1)
			{
				class'KeyBindings'.default.PrimaryBinds[i] = key;
				if (class'KeyBindings'.default.SecondaryBinds[i] == key)
				{
					PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.SecondaryBinds[i]);
					class'KeyBindings'.default.SecondaryBinds[i] = "";
				}
			}
			else
			{
				class'KeyBindings'.default.SecondaryBinds[i] = key;
				if (class'KeyBindings'.default.PrimaryBinds[i] == key)
				{
					PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.PrimaryBinds[i]);
					class'KeyBindings'.default.PrimaryBinds[i] = "";
				}
			}
		}
		else
		{
			if (class'KeyBindings'.default.PrimaryBinds[i] == key)
			{
				PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.PrimaryBinds[i]);
				class'KeyBindings'.default.PrimaryBinds[i] = "";
			}
			if (class'KeyBindings'.default.SecondaryBinds[i] == key)
			{
				PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.SecondaryBinds[i]);
				class'KeyBindings'.default.SecondaryBinds[i] = "";
			}
		}
	}

    //Update the MCLB
    LoadCategory(LastCategory);

	// force an update on the keybindings in the hud, because 
	// re-checking every frame is prohibitively expensive
	if(PlayerCharacterController(PlayerOwner()) != None && PlayerCharacterController(PlayerOwner()).clientSideChar != None)
		PlayerCharacterController(PlayerOwner()).clientSideChar.bHotKeysUpdated = false;

	class'KeyBindings'.static.StaticSaveConfig();
}

private function CategorySelectorOnClick( GUIComponent Sender )
{
    //LoadCategory(MyCategoryList.List.Elements[MyCategoryList.Index].ExtraStrData);
}

private function OnSensitivityChange( GUIComponent Sender )
{
	PlayerOwner().ConsoleCommand("Set WinDrv.WindowsClient MouseXMultiplier"@GUISlider(Sender).Value);
	PlayerOwner().ConsoleCommand("Set WinDrv.WindowsClient MouseYMultiplier"@GUISlider(Sender).Value);
}

private function OnInvertMouseClick( GUIComponent Sender )
{
	PlayerOwner().ConsoleCommand("set PlayerInput bInvertMouse "$(InvertMouseButton.bChecked));
}

private function OnTeamColorsClick( GUIComponent Sender )
{
	PlayerOwner().ConsoleCommand("set Gameplay.PlayerCharacterController bTeamMarkerColors "$(TeamColorsButton.bChecked));
}

function OnDefaults(GUIComponent Sender)
{
	RestoreDefaults();
	PlayerOwner().ConsoleCommand("set PlayerInput bInvertMouse 0");
	PlayerOwner().ConsoleCommand("set Gameplay.PlayerCharacterController bTeamMarkerColors "$class'PlayerCharacterController'.default.bTeamMarkerColors);
	LoadSettings(true);
}

native function RestoreDefaults();

// ensure that user.ini corresponds with the primary/secondary binds list 
function EnsureConsistency()
{
	local int i;

    for( i = 0; i < class'KeyBindings'.default.CommandString.Length; i++ )
    {
		if (class'KeyBindings'.default.PrimaryBinds[i] != "")
			PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.PrimaryBinds[i]@class'KeyBindings'.default.CommandString[i]);
		if (class'KeyBindings'.default.SecondaryBinds[i] != "")
			PlayerOwner().ConsoleCommand("SET Input"@class'KeyBindings'.default.SecondaryBinds[i]@class'KeyBindings'.default.CommandString[i]);
	}

	PlayerOwner().ConsoleCommand("RELOADKEYBINDINGS");
}


defaultproperties
{
	KeyChangeMessage="The %1 function is already assigned to %2.  Press a new key to change it."
	NoBindKeyChangeMessage="Press the key you want to assign to %1."

	OnActivate=InternalOnActivate
	OnHide=InternalOnHide
}