class FailProjectileGrenadeLauncher extends EquipmentClasses.ProjectileGrenadeLauncher;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     radiusDamageSize=1080.000000
}
