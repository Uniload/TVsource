//
// Localized death message. string one is the killers name,
// string two is the victims name, and theicon is the damage
// type icon which caused the death.
// 
class MPDeathMessages extends MPEventMessage;

var localized String HimselfText;
var localized String HerselfText;

static function String GetStringOne(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString)
{
	if(Related1 != None && Related1.IsA('TribesReplicationInfo'))
	{
		SetMessageTypeByTeam(messageType, Actor(Related1));
		return TribesReplicationInfo(Related1).playerName;
	}
	else if(Related1 == None && Related2.IsA('TribesReplicationInfo'))
	{
		SetMessageTypeByTeam(messageType, Actor(Related2));
		return TribesReplicationInfo(Related2).playerName;
	}

	return " ";
}


static function String GetStringTwo(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString)
{
	if((Related2.IsA('TribesReplicationInfo') && (Related2 == Related1)) || Related1 == None)
	{
		if(TribesReplicationInfo(Related2).bIsFemale)
			return default.HerselfText;
		else
			return default.HimselfText;
	}
	else if(Related1.IsA('TribesReplicationInfo'))
	{
		SetMessageTypeByTeam(messageType, Actor(Related2));
		return TribesReplicationInfo(Related2).playerName;
	}

	return " ";
}

static function Material GetIconMaterial(optional int Switch,
										 optional Core.Object Related1, 
										 optional Core.Object Related2,
										 optional Object OptionalObject,
										 optional String OptionalString)
{
	if(class<DamageType>(OptionalObject) != None)
		return class<DamageType>(OptionalObject).default.deathMessageIconMaterial;
}

defaultproperties
{
	HimselfText="himself"
	HerselfText="herself"
}