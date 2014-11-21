class MessageTerritoryContested extends Engine.Message
	editinlinenew;

var Name territory;


// construct
overloaded function construct(Name _territory)
{
	territory = _territory;

	SLog(territory $ " is contested ");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" territory is contested";
}


defaultproperties
{
	specificTo	= class'MPTerritory'
}