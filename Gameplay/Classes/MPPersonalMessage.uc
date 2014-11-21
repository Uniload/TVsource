//
// Base personal message class
//
class MPPersonalMessage extends Engine.LocalMessage;

import enum EMessageType from ClientSideCharacter;

static function String GetPersonalString(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString)
{
	// By default just return parent's implementation
	return super.GetString(Switch, Related1, Related2, OptionalObject, OptionalString);
}

defaultproperties
{
}
