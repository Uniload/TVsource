class x2GameMessage extends Gameplay.TribesGameMessage; //thank you rapher

var localized string MTDisabled;
var localized string MTEnabled;
var localized string Announce;

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
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	MTDisabled = "x2 bot: Mines and Turrets have been disabled."
	MTEnabled = "x2 bot: Mines and Turrets have been enabled."
	Announce = "x2 bot: A player was killed for exploiting."
}
