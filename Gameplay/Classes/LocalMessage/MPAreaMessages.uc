class MPAreaMessages extends Engine.LocalMessage;

var localized string	selfEnter;
var localized string	selfExit;

static function string GetString(
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString
	)
{
	switch (Switch)
	{
	case 1: return default.selfEnter;
	case 2: return default.selfExit;
	}
}

defaultproperties
{
	selfEnter					= "You entered an area."
	selfExit					= "You exited an area."
}	