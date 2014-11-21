class z2TurretBurnerProjectile extends EquipmentClasses.ProjectileBurnerTurret;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
	}

defaultproperties
{
     burningAreaClass=Class'z2TurretBurningArea'
     LifeSpan=2.000000
}
