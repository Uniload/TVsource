class MessagePlayerStart extends Engine.Message;

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Player "$triggeredBy$" starts the game";
}

defaultproperties
{
     specificTo=Class'Character'
}
