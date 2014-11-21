class MessageInventoryUIWeaponSelected extends Engine.Message
	editinlinenew;

// construct
overloaded function construct()
{
	SLog("User selected a weapon");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "User selects a weapon from the Inventory station";
}


defaultproperties
{
	specificTo	= class'Character'
}