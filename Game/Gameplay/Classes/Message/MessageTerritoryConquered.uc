class MessageTerritoryConquered extends Engine.Message
	editinlinenew;

var Name territory;
var() Name team;


// construct
overloaded function construct(Name _territory, Name _team)
{
	territory = _territory;
	team = _team;

	SLog(territory $ " was conquered by "$_team);
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" territory is conquered";
}


defaultproperties
{
	specificTo	= class'MPTerritory'
}