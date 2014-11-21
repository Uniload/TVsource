class promodProjectileChaingun extends EquipmentClasses.ProjectileChaingun config(promod);

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     damageTypeClass=Class'promodDamageTypeChaingun'
     damageAmt=5.0
}
