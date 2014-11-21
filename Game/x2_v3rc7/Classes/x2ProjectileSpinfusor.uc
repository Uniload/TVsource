class x2ProjectileSpinfusor extends EquipmentClasses.ProjectileSpinfusor config(x2);

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
       super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     radiusDamageSize=650.000000
     radiusDamageMomentum=255000.000000
     MaxVelocity=10000.000000
}
