class x2TurretBurnerProjectile extends EquipmentClasses.ProjectileBurnerTurret;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
	}

defaultproperties
{
     burningAreaClass=Class'x2TurretBurningArea'
     Lifespan=2
}
