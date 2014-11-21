class x2TankRound extends EquipmentClasses.ProjectileMortar;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
       super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     LifeSpan=10.000000
     GravityScale=1.200000
}
