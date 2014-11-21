class promodProjectileChaingun extends EquipmentClasses.ProjectileChaingun config(promod);

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     damageAmt=5.000000
     damageTypeClass=Class'promodDamageTypeChaingun'
}
