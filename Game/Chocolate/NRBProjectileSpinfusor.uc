class NRBProjectileSpinfusor extends EquipmentClasses.ProjectileSpinfusor;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     LifeSpan=6.000000
}
