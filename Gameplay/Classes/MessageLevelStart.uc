class MessageLevelStart extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "The level starts";
}

defaultproperties
{
     specificTo=Class'Character'
}
