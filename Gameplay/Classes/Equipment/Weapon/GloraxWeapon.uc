class GloraxWeapon extends Weapon;

simulated function Vector calcProjectileSpawnLocation(Rotator fireRot)
{
	return rookMotor.getFirstPersonEquippableLocation(self) + (projectileSpawnOffset >> fireRot);
}

defaultproperties
{
	aimClass = class'AimArcWeapons'
	animClass = class'EquippableAnimator'

	animPrefix = "Glorax"
}