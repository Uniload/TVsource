class MPTargetMessages extends Engine.LocalMessage;

var localized string	targetDestroyed;


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
	case 0: return replaceStr(default.targetDestroyed, TribesReplicationInfo(Related1).PlayerName, TeamInfo(Related2).localizedName);
	}
}


defaultproperties
{
	targetDestroyed	= "%1 destroyed one of team %2's targets."
}