class MessageClientConnected extends Engine.Message;

var () PlayerCharacterController client;

overloaded function construct(PlayerCharacterController _c)
{
	client = _c;

	SLog("Client "$client$" connected to the game");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Client "$triggeredBy$" connected to the game";
}


defaultproperties
{
	specificTo	= class'Controller'
}