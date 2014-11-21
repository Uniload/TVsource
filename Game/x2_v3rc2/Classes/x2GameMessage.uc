class x2GameMessage extends Gameplay.TribesGameMessage; //thank you rapher

var localized string MTDisabled;
var localized string MTEnabled;
var localized string Announce;
var localized string BRDisabled;
var localized string BREnabled;

static function string GetString(optional int Switch,
				 optional Core.Object Related1,
				 optional Core.Object Related2,
				 optional Core.Object OptionalObject,
				 optional String OptionalString)
{
        
        switch (Switch)
	{
		case 100:
			return default.MTDisabled;
			break;
		case 101:
			return default.MTEnabled;
			break;
		case 102:
                        return default.Announce;
			break;
		case 103:
			return default.BRDisabled;
			break;
		case 104:
			return default.BREnabled;
			break;
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	MTDisabled = "x2: Mines and turrets have been disabled."
	MTEnabled = "x2: Mines and turrets have been enabled."
	Announce = "x2: A player was killed for attempted exploiting."
	BRDisabled = "x2: Base rape has been disabled."
	BREnabled = "x2: Base rape has been enabled."
}
