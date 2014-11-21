class x2ProjectileMortar extends EquipmentClasses.ProjectileMortar;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
Lifespan=11
}
