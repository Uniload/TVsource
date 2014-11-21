class MessageInventoryUIExited extends Engine.Message
	editinlinenew;

// construct
overloaded function construct()
{
	SLog("Inventory UI was exited");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Inventory station UI is exited";
}


defaultproperties
{
	specificTo	= class'Character'
}