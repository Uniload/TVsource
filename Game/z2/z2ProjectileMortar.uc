class z2ProjectileMortar extends EquipmentClasses.ProjectileMortar;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     LifeSpan=11.000000
}
