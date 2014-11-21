class ActionInventoryEnableExit extends ActionInventoryBase;

// execute
latent function Variable execute()
{
	local TribesInventorySelectionMenu InventoryMenu;

	Super.execute();

	InventoryMenu = GetInventoryMenu();

	if(InventoryMenu != None)
		InventoryMenu.EnableExit();

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Enable the active Inventory station's Exit button";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enable Inventory station exit button"
	actionHelp			= "Enables the active Inventory station's Exit button"
	category			= "UI"
}