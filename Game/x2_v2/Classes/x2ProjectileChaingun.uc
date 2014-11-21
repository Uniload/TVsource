class x2ProjectileChaingun extends EquipmentClasses.ProjectileChaingun;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
damageTypeClass=Class'x2DamageTypeChaingun'
}
