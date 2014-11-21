class promodGameMessage extends Gameplay.TribesGameMessage; //thank you rapher

var localized string MTDisabled;
var localized string MTEnabled;
var localized string BRDisabled;
var localized string BREnabled;
var localized string SniperDisabled;
var localized string SniperEnabled;
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
		case 108:
			return default.SniperDisabled;
			break;		
		case 109:
			return default.SniperEnabled;
			break;		
        }

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	MTDisabled="promod: Mines and turrets have been disabled."
	MTEnabled="promod: Mines and turrets have been enabled."
	BRDisabled="promod: Base rape has been disabled."
	BREnabled="promod: Base rape has been enabled."
	TKWarnMessage="promod: Warning! You are about to be removed for team killing!"
	TKKickMessage="promod: %1 was kicked for team killing."
    TKBanMessage="promod: %1 was banned for team killing."
	SniperDisabled="promod: Sniper Rifle has been enabled."
	SniperEnabled="promod: Sniper Rifle has been disabled."
}