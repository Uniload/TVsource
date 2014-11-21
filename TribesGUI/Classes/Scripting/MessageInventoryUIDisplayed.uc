class MessageInventoryUIDisplayed extends Engine.Message
	editinlinenew;

// construct
overloaded function construct()
{
	SLog("Inventory UI was displayed");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Inventory station UI is displayed";
}


defaultproperties
{
	specificTo	= class'Character'
}