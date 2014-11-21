class MessageRoundEnd extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Round ends (use TriggeredBy GAMEINFO)";
}


defaultproperties
{
	specificTo	= class'Actor'
}