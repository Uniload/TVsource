class TurretSentryWeapon extends TurretWeapon;

var() float spread;

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Rotator r;
	local float spreadInRotUnits;

	spreadInRotUnits = spread * 65536 / 360;

	r.Yaw = spreadInRotUnits * (2.0f * FRand() - 1);
	r.Pitch = spreadInRotUnits * (2.0f * FRand() - 1);

	return Super.makeProjectile( fireRot + r, fireLoc );
}

defaultproperties
{
	spread = 4

	aimClass = class'AimProjectileWeapons'

	firstPersonMesh = Mesh'Weapons.Spinfusor'
	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.56
	ammoCount = 20
	ammoUsage = 1

	projectileClass = class'SentryProjectile'
	projectileVelocity = 2600
	projectileInheritedVelFactor = 0.5

	animPrefix = "Spinfusor"
}