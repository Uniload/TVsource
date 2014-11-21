class x2GameMessage extends Gameplay.TribesGameMessage; //thank you rapher

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
		case 31:
			return replaceStr(default.KickCheater, PRI.PlayerName);
			break;
		default:
			break;
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
     KickCheater="x2 AdminBot: Player '%1' has been kicked from this server for attempted cheating!"
}
