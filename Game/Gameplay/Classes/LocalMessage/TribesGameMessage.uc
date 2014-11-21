class TribesGameMessage extends Engine.GameMessage;

var localized string ReadyMessage;
var localized string NotReadyMessage;
var localized string AwaitingSingleReadyMessage;
var localized string AwaitingDoubleReadyMessage;
var localized string AwaitingTripleReadyMessage;
var localized string UnbalancedMessage;

static function string GetString(optional int Switch,
								 optional Core.Object Related1, 
								 optional Core.Object Related2,
								 optional Core.Object OptionalObject,
								 optional String OptionalString)
{
	local PlayerReplicationInfo PRI1, PRI2, PRI3;

	PRI1 = PlayerReplicationInfo(Related1);

	switch (Switch)
	{
	case 3:
		// overriding team switching because we use our own TeamInfo
		if (Related1 == None)
			return "";
		if (OptionalObject == None)
			return "";

		return PRI1.PlayerName@Default.NewTeamMessage@TeamInfo(OptionalObject).GetHumanReadableName()$Default.NewTeamMessageTrailer;
		break;
	case 20: return replaceStr(default.ReadyMessage, PRI1.PlayerName);
		break;
	case 21: return replaceStr(default.NotReadyMessage, PRI1.PlayerName);
		break;
	case 22:
		PRI2 = PlayerReplicationInfo(Related2);
		PRI3 = PlayerReplicationInfo(OptionalObject);

		if (PRI1 == None)
			return "";

		if (PRI2 == None && PRI3 == None)
			return replaceStr(default.AwaitingSingleReadyMessage, PRI1.PlayerName);
		else if (PRI3 == None)
			return replaceStr(default.AwaitingDoubleReadyMessage, PRI1.PlayerName, PRI2.PlayerName);
		else
			return replaceStr(default.AwaitingTripleReadyMessage, PRI1.PlayerName, PRI2.PlayerName, PRI3.PlayerName);
		break;
	case 23:
		return default.UnbalancedMessage;
	default:
		break;
	}

	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
	ReadyMessage					= "%1 is ready to start"
	NotReadyMessage					= "%1 is not ready to start"
	AwaitingSingleReadyMessage		= "%1 is holding up the tournament"
	AwaitingDoubleReadyMessage		= "%1 and %2 are holding up the tournament"
	AwaitingTripleReadyMessage		= "%1, %2 and %3 are holding up the tournament"
	UnbalancedMessage				= "The teams aren't balanced."
}
