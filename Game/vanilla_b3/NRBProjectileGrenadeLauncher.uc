class NRBProjectileGrenadeLauncher extends EquipmentClasses.ProjectileGrenadeLauncher;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     LifeSpan=100.000000
}
