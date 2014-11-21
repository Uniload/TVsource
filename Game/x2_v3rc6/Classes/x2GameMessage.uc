class x2GameMessage extends Gameplay.TribesGameMessage; //thank you rapher

var localized string MTDisabled;
var localized string MTEnabled;
var localized string BRDisabled;
var localized string BREnabled;
var localized string TKWarnMessage;
var localized string TKKickMessage;
var localized string TKBanMessage;

static function string GetString(optional int Switch,
				 optional Core.Object Related1,
				 optional Core.Object Related2,
				 optional Core.Object OptionalObject,
				 optional String OptionalString)
{
   local PlayerReplicationInfo PRI1;

   PRI1 = PlayerReplicationInfo(Related1);
   
        switch (Switch)
	{
		case 100:
			return default.MTDisabled;
			break;
		case 101:
			return default.MTEnabled;
			break;
		case 103:
			return default.BRDisabled;
			break;
		case 104:
			return default.BREnabled;
			break;
		case 105:
			return default.TKWarnMessage;
			break;
                case 106:
                        return replaceStr(default.TKBanMessage, PRI1.PlayerName);
		        break;
		case 107:
                        return replaceStr(default.TKKickMessage, PRI1.PlayerName);
		        break;
        }

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	MTDisabled="x2: Mines and turrets have been disabled."
	MTEnabled="x2: Mines and turrets have been enabled."
	BRDisabled="x2: Base rape has been disabled."
	BREnabled="x2: Base rape has been enabled."
	TKWarnMessage="x2: Warning! You are about to be removed for team killing!"
	TKKickMessage="x2: %1 was kicked for team killing."
        TKBanMessage="x2: %1 was banned for team killing."
}