//
// Localized secondary message.
// 
class MPSecondaryMessage extends MPEventMessage;

struct msg
{
	var() localized string stringOne	"An optional string override.  If provided, it will be displayed; if not, a PlayerName will be displayed";
	var() localized string stringTwo	"An optional string override.  If provided, it will be displayed and %1 (if provided) will be replaced with a special int; if not, either nothing or a Playername will be displayed";
	var() Material icon					"The icon to display in this message.";
};

var() localized array<msg> secondaryMessages;

static function String GetStringOne(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString)
{
	if (Switch >= default.secondaryMessages.Length)
		return "";

	SetMessageTypeByTeam(messageType, Actor(Related1));

	if (default.secondaryMessages[Switch].stringOne != "")
		return default.secondaryMessages[Switch].stringOne$" ";

	if(Related1.IsA('TribesReplicationInfo'))
		return TribesReplicationInfo(Related1).playerName$" ";

	return "";
}

static function String GetStringTwo(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString)
{
	local TribesReplicationInfo TRI1, TRI2;
	local int amount;

	// If a special int was passed, use that in conjunction with the second string
	if (Switch >= default.secondaryMessages.Length)
		return "";

	TRI1 = TribesReplicationInfo(Related1);
	TRI2 = TribesReplicationInfo(Related2);

	if (TRI1 == None)
		return "";

	SetMessageTypeByTeam(messageType, TRI2);

	amount = int(OptionalString);

	if (default.secondaryMessages[Switch].stringTwo != "")
	{
		if (TRI2 == None)
		{
			if (amount == 0)
				return " "$default.secondaryMessages[Switch].stringTwo;
			else
				return " "$replaceStr(default.secondaryMessages[Switch].stringTwo, amount);
		}
		else
			return " "$ TribesReplicationInfo(Related2).playerName;
	}

	return "";

	// Otherwise, try
	//if((Related2.IsA('TribesReplicationInfo') && (Related2 == Related1)) || Related1 == None)
	//{
	//	if(TribesReplicationInfo(Related2).bIsFemale)
	//		return default.HerselfText;
	//	else
	//		return default.HimselfText;
	//}
	//else if(Related1.IsA('TribesReplicationInfo'))
	//{
	//	return TribesReplicationInfo(Related2).playerName;
	//}

	//return " ";
}

static function Material GetIconMaterial(optional int Switch,
										 optional Core.Object Related1, 
										 optional Core.Object Related2,
										 optional Object OptionalObject,
										optional String OptionalString)
{
	if (Switch >= default.secondaryMessages.Length)
		return None;

	return default.secondaryMessages[Switch].icon;
}

defaultproperties
{
}
