class ActionInventoryFlashButton extends ActionInventoryBase;

var() actionnoresolve class<Weapon> WeaponClass;
var() actionnoresolve class<CombatRole> CombatRoleClass;
var() float duration;

// execute
latent function Variable execute()
{
	local TribesInventorySelectionMenu InventoryMenu;

	Super.execute();

	InventoryMenu = GetInventoryMenu();

	if(InventoryMenu != None)
	{
		if(CombatRoleClass != None)
			InventoryMenu.FlashArmor(CombatRoleClass, duration);
		else if(WeaponClass != None)
			InventoryMenu.FlashWeapon(WeaponClass, duration);
	}
	else
		SLog("No active inventory station menu found!");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	if(CombatRoleClass != None)
		s = "Flash the button for " $CombatRoleClass $" in the inventory station";
	else
		s = "Flash the button for " $WeaponClass $" in the inventory station";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Flash Inventory station button"
	actionHelp			= "Flashes a button for a class in the active Inventory station"
	category			= "UI"
}