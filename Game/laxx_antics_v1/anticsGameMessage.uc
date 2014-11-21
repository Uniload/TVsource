class anticsGameMessage extends Gameplay.TribesGameMessage;

var localized string BanCheater;
var localized string DetectedCheater;
var localized string KickCheater;

static function string GetString(optional int Switch,
								 optional Core.Object Related1,
								 optional Core.Object Related2,
								 optional Core.Object OptionalObject,
								 optional String OptionalString)
{

	local PlayerReplicationInfo PRI;

	PRI = PlayerReplicationInfo(Related1);
	
	switch (Switch)
	{
		case 30:
			return replaceStr(default.DetectedCheater, PRI.PlayerName);
			break;
		case 31:
			return replaceStr(default.KickCheater, PRI.PlayerName);
			break;
		case 32:
			return replaceStr(default.BanCheater, PRI.PlayerName);
			break;
		default:
			break;
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
     BanCheater="antics: Player '%1' has been banned from this server for cheating!"
     DetectedCheater="antics: Player '%1' has been detected as a cheater!"
     KickCheater="antics: Player '%1' has been kicked from this server for cheating!"
}
