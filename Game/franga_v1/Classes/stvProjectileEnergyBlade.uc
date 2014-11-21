class stvProjectileEnergyBlade extends Gameplay.Projectile;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
     damageTypeClass=Class'stvBladeProjectileDamageType'
}
