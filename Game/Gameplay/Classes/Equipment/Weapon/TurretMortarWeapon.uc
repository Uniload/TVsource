class TurretMortarWeapon extends TurretWeapon;

defaultproperties
{
	aimClass = class'AimArcWeapons'

	firstPersonMesh = Mesh'Weapons.GrenadeLauncher'
	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.5
	ammoCount = 10
	ammoUsage = 1

	projectileClass = class'MortarProjectile'
	projectileVelocity = 4500
	projectileInheritedVelFactor = 0.8
}