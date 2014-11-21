class EquipmentPickupProxy extends Engine.Actor;

function Touch(Actor Other)
{
	Equipment(Owner).PickupProxyTouch(Other);
}

function Untouch(Actor Other)
{
	Equipment(Owner).PickupProxyUntouch(Other);
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
