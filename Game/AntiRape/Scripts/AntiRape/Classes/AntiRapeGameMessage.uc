class AntiRapeGameMessage extends Gameplay.TribesGameMessage;

var localized string RapeDisabled;
var localized string RapeEnabled;

static function string GetString(optional int Switch,
								 optional Core.Object Related1,
								 optional Core.Object Related2,
								 optional Core.Object OptionalObject,
								 optional String OptionalString)
{	
	switch (Switch)
	{
		case 100:
			return default.RapeDisabled;
			break;
		case 101:
			return default.RapeEnabled;
			break;
		default:
			break;
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	RapeDisabled = "AntiRape: Rape has been disabled."
	RapeEnabled = "AntiRape: Rape has been enabled."
}