//
// Base personal message class
//
class MPPersonalStatMessage extends MPPersonalMessage;

var array<string> personalMessages;
var localized string offenseStr, defenseStr, styleStr;

static function string GetPersonalString(
	out EMessageType messageType,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Core.Object OptionalObject,
	optional String OptionalString
	)
{
	local class<Stat> s;
	local PlayerReplicationInfo PRI;
	local int amount;

	// Expect Related1 to be a stat (required)
	// Expect Related2 to be a target PRI (optional)
	s = class<Stat>(Related1);
	if (s == None)
		return "";

	if (Related2 != None)
		PRI = PlayerReplicationInfo(Related2);

	// If an amount wasn't explicitly sent, assume 1
	amount = int(OptionalString);
	if (amount <= 0)
	{
		amount = 1;
	}

	// Check if it's a penalty
	if (s.default.offensePointsPerStat < 0 || s.default.defensePointsPerStat < 0 || s.default.stylePointsPerStat < 0)
		messageType = MessageType_StatPenalty;
	// Otherwise set messagetype depending on stat level
	else if (s.default.logLevel <= 1)
		messageType = MessageType_StatHigh;
	else if (s.default.logLevel == 2)
		messageType = MessageType_StatMedium;
	else
		messageType = MessageType_StatLow;

	//Log("MPPersonalStatMessage set messageType to "$messageType$" due to logLevel "$s.default.logLevel$" for stat "$s);

	if (Switch == 0)
	{
		if (PRI == None)
			return s.default.personalMessage @ createScoreString(s, amount);
		else
			return replaceStr(s.default.personalmessage, PRI.PlayerName) @ createScoreString(s, amount);
	}

	// A custom message has been defined
	if (default.personalMessages.Length < Switch)
		return "";

	if (PRI == None)
		return default.personalMessages[Switch] @ createScoreString(s, amount);
	else
		return replaceStr(default.personalMessages[Switch], PRI.PlayerName) @ createScoreString(s, amount);

	return "";
}

static function string createScoreString(class<Stat> s, int amount)
{
	local string str;
	local array<string> strList;
	local int i;
	local string operatorString;

	if (s.default.offensePointsPerStat < 0 || s.default.defensePointsPerStat < 0 || s.default.stylePointsPerStat < 0)
		operatorString = "";
	else
		operatorString = "+";


	if (s.default.offensePointsPerStat != 0)
	{
		strList[strList.Length] = operatorString $ s.default.offensePointsPerStat*amount @ default.offenseStr;
	}

	if (s.default.defensePointsPerStat != 0)
	{
		strList[strList.Length] = operatorString $ s.default.defensePointsPerStat*amount @ default.defenseStr;
	}

	if (s.default.stylePointsPerStat != 0)
	{
		strList[strList.Length] = operatorString $ s.default.stylePointsPerStat*amount @ default.styleStr;
	}

	str = "(";

	// Append all but the last string using comma separators
	for (i=0; i<strList.Length - 1; i++)
	{
		str = str $ strList[i] $ ", ";
	}

	// Append the last string with a bracket on the end
	str = str $ strList[i] $ ")";

	return str;
}

defaultproperties
{
	personalMessages(0)="This index is reserved for a personal message stored in a Stat."

	offenseStr = "Offense"
	defenseStr = "Defense"
	styleStr   = "Style"
}

// You killed Kaka (+1 Offense)
// You midair'd Kaka (+1 Style)
// You protected your Generator (+1 Defense)
// You teamkilled Kaka (-1 Offense)
// Kaka teamkilled you
// You returned the flag with good timing (+3 Defense)