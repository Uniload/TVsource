class x2ProjectileBurner extends EquipmentClasses.ProjectileBurner;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
        {
	 super.ProjectileTouch(Other, TouchLocation, TouchNormal);
	}

defaultproperties
{
     burningAreaClass=Class'x2BurningArea'
     LifeSpan=2.000000
}
