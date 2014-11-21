class promodGameMessage extends Gameplay.TribesGameMessage; //thank you rapher

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
	TKWarnMessage="promod: Warning! You are about to be removed for team killing!"
	TKKickMessage="promod: %1 was kicked for team killing."
        TKBanMessage="promod: %1 was banned for team killing."
}