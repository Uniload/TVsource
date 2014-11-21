class MessageRoundWarmup extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Round warmup starts (use TriggeredBy GAMEINFO)";
}


defaultproperties
{
	specificTo	= class'Actor'
}