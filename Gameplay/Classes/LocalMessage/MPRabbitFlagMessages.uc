class MPRabbitFlagMessages extends Engine.LocalMessage;
var localized string	RabbitFlagPickedUp;
var localized string	RabbitFlagDropped;
var localized string	RabbitKilled;

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
	case 0: return default.RabbitFlagPickedUp;
	case 1: return default.RabbitFlagDropped;
	case 2: return replaceStr(default.RabbitKilled, TribesReplicationInfo(Related1).PlayerName);
	}
}


defaultproperties
{
	RabbitFlagPickedUp	= "A Rabbit flag was picked up."
	RabbitFlagDropped	= "A Rabbit flag was dropped."
	RabbitKilled		= "%1 killed a Rabbit!"
}