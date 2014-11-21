class MessageClientChangedTeam extends Engine.Message;

var () PlayerCharacterController client;
var () TeamInfo team;
var () TeamInfo oldTeam;

overloaded function construct(PlayerCharacterController _c, TeamInfo newTeam, TeamInfo _oldTeam)
{
	client = _c;
	team = newTeam;
	oldTeam = _oldTeam;

	SLog("Client "$client$" changed teams to: "$team);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "Client "$triggeredBy$" changed teams";
}


defaultproperties
{
	specificTo	= class'Controller'
}