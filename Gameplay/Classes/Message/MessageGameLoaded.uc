class MessageGameLoaded extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "A save game is loaded";
}


defaultproperties
{
	specificTo	= class'Actor'
}