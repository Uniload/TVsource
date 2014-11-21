class compBurnerProjectile extends EquipmentClasses.ProjectileBurner;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
	}

defaultproperties
{
     burningAreaClass=Class'compBurningArea'
     Lifespan=2
}
