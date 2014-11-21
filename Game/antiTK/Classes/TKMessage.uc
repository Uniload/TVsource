//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TKMessage extends Engine.LocalMessage;

var localized string TKWarnMessage;
var localized string TKKickMessage;
var localized string TKBanMessage;

static function string GetString(
	optional int Switch,
	optional Core.Object Related1,
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	)
{
    local PlayerReplicationInfo PRI1;

    PRI1 = PlayerReplicationInfo(Related1);

    switch (Switch)
	{
		case 0:
			return Default.TKWarnMessage;
			break;
		case 1:
			return PRI1.PlayerName$Default.TKKickMessage;
			break;
		case 2:
			return PRI1.PlayerName$Default.TKBanMessage;
			break;
	}
	return "";
}

defaultproperties
{
     TKWarnMessage="You are about to be removed for TKing!"
     TKKickMessage=" was kicked for TKing!"
     TKBanMessage=" was banned for TKing!"
     bIsSpecial=False
}
