class promodProjectileChaingun extends EquipmentClasses.ProjectileChaingun config(promod);

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     damageTypeClass=Class'promodDamageTypeChaingun'
     damageAmt=6.0
     Lifespan=2.2
}
