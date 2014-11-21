class MessageTerritoryConquering extends Engine.Message
	editinlinenew;

var Name territory;


// construct
overloaded function construct(Name _territory)
{
	territory = _territory;

	SLog(territory $ " is being conquered ");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return triggeredBy$" territory is being conquered";
}


defaultproperties
{
	specificTo	= class'MPTerritory'
}