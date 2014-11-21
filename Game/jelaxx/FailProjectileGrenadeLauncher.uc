class FailProjectileGrenadeLauncher extends EquipmentClasses.ProjectileGrenadeLauncher;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     radiusDamageAmt=25.000000
     radiusDamageSize=400.000000
}
