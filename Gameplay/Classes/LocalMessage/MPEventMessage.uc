//
// This is the base Tribes multiplayer event message class.
// each even message defines functions for retreiving two strings
// and a related icon, which can then be displayed in the message
// HUD element.
//
class MPEventMessage extends TribesLocalMessage;

import enum EMessageType from ClientSideCharacter;

// Override to divert message to the hud before calling the super implementation
static simulated function ClientReceive(PlayerController P,
										optional int Switch,
										optional Core.Object Related1, 
										optional Core.Object Related2,
										optional Object OptionalObject,
										optional String OptionalString)
{
	if ( P.myHUD != None )
		P.myHUD.LocalizedMessage( Default.Class, Switch, Related1, Related2, OptionalObject,,OptionalString );

	super.ClientReceive(P, Switch, Related1, Related2, OptionalObject, OptionalString);
}

static function SetMessageTypeByTeam(out EMessageType messageType, Actor Other)
{
	if(Other != None)
	{
		if(PlayerCharacterController(Other.Level.GetLocalPlayerController()).IsFriendly(Other))
			messageType = MessageType_Ally;
		else
			messageType = MessageType_Enemy;
	}
}

static function String GetStringOne(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString);

static function String GetStringTwo(out EMessageType messageType,
									optional int Switch,
									optional Core.Object Related1, 
									optional Core.Object Related2,
									optional Object OptionalObject,
									optional String OptionalString);

static function Material GetIconMaterial(optional int Switch,
										 optional Core.Object Related1, 
										 optional Core.Object Related2,
										 optional Object OptionalObject,
										 optional String OptionalString);
