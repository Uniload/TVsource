class MessageCountDownExpired extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "The count down timer expires";
}

defaultproperties
{
     specificTo=Class'GameInfo'
}
