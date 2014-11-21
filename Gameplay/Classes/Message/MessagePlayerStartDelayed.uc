class MessagePlayerStartDelayed extends Engine.Message;
 // TEMP fix for player start happening way before the first frame

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "10 seconds after player "$triggeredBy$" starts the game";
}


defaultproperties
{
	specificTo	= class'Character'
}