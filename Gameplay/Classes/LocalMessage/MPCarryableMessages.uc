class MPCarryableMessages extends TribesLocalMessage;

var() localized string	energyBarrierCollision;
var() localized string	cantGrappleAtHome;
var() localized string	cantGrappleInField;

var(EffectEvents) Name	collidedWithEnergyBarrierEffectEvent;
var(EffectEvents) Name	cantGrappleAtHomeEffectEvent;
var(EffectEvents) Name	cantGrappleInFieldEffectEvent;

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
		case 10: return default.energyBarrierCollision;
		case 11: return default.cantGrappleAtHome;
		case 12: return default.cantGrappleInField;
			break;
	}
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional Core.Object Related1, 
	optional Core.Object Related2,
	optional Object OptionalObject,
	optional String OptionalString
	)
{
	Super.ClientReceive(P, Switch, Related1, Related2, OptionalObject, OptionalString);

	switch (Switch)
	{
		case 10: P.TriggerEffectEvent(default.collidedWithEnergyBarrierEffectEvent);
			break;
		case 11: P.TriggerEffectEvent(default.cantGrappleAtHomeEffectEvent);
			break;
		case 12: P.TriggerEffectEvent(default.cantGrappleInFieldEffectEvent);
			break;
	}
}

defaultproperties
{
	announcements(0)=(effectEvent=CarryablePickedUp,speechTag="",debugString="%1 carryable picked up.")
	announcements(1)=(effectEvent=CarryableDropped,speechTag="",debugString="%1 carryable dropped.")
	announcements(2)=(effectEvent=CarryableReturned,speechTag="",debugString="%1 carryable returned.")

	energyBarrierCollision =	"You can't pass through while carrying a carryable."
	cantGrappleAtHome =			"You can't grapple this carryable when it's at home."
	cantGrappleInField =		"You can't grapple this carryable."
	collidedWithEnergyBarrierEffectEvent = CollidedWithEnergyBarrier
}
