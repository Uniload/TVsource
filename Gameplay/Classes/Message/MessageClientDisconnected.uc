class MessageClientDisconnected extends Engine.Message;

var () PlayerCharacterController client;

overloaded function construct(PlayerCharacterController _c)
{
	client = _c;

	SLog("Client "$client$" disconnected from the game");
}


// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Client "$triggeredBy$" disconnected from the game";
}


defaultproperties
{
	specificTo	= class'Controller'
}