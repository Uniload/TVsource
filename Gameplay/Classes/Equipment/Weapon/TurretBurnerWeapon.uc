class TurretBurnerWeapon extends TurretWeapon;

defaultproperties
{
	aimClass = class'AimProjectileWeapons'

	firstPersonMesh = Mesh'Weapons.Spinfusor'
	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.56
	ammoCount = 20
	ammoUsage = 1

	projectileClass = class'SpinfusorProjectile'
	projectileVelocity = 2600
	projectileInheritedVelFactor = 0.5

	animPrefix = "Spinfusor"
}