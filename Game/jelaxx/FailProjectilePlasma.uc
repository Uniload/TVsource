class FailProjectilePlasma extends EquipmentClasses.ProjectileBurner;

var bool bEndedLife;

var() float radiusDamageAmt; 
var() float radiusDamageSize;
var() float radiusDamageMomentum;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector Normal)
{
	endLife(Other, TouchLocation, Normal);
	super.ProjectileHit(Other, TouchLocation, Normal);
}

simulated function endLife(Actor HitActor, vector TouchLocation, Optional vector TouchNormal)
{
	local float speed;
	local Vector direction;

	SpawnBurningArea();

	if (bEndedLife)
		return;

	bEndedLife = true;

	HurtRadius(radiusDamageAmt, radiusDamageSize, damageTypeClass, radiusDamageMomentum, TouchLocation, HitActor, direction);

	Super.endLife(None, TouchLocation, TouchNormal);
}

simulated function triggerHitEffect(Actor HitActor, vector TouchLocation, vector TouchNormal, optional Name HitEffect)
{
	SpawnBurningArea();
}

simulated function BurnTarget(Rook target)
{
}

defaultproperties
{
     radiusDamageAmt=50.000000
     radiusDamageSize=400.000000
     ignitionDelay=2.500000
     burningAreaClass=Class'FailPlasmaArea'
     damageAmt=0.000000
     bDeflectable=False
     knockbackAliveScale=1.000000
     LifeSpan=2.500000
     CollisionRadius=30.000000
     CollisionHeight=30.000000
}
