class AntiAircraftWeapon extends TurretWeapon;

var (AntiAircraftWeapon) float energyUsage;

function useAmmo()
{
	rookMotor.useEnergy(energyUsage);
}

simulated function bool hasAmmo()
{
	return true;
}

simulated function bool canFire()
{
	return rookMotor.getEnergy() > energyUsage;
}

simulated protected function FireWeapon()
{
	// alternate fire animation
	if (fireAnimation == 'Fire1')
		fireAnimation = 'Fire2';
	else
		fireAnimation = 'Fire1';

	// alternate projectile mesh

	Super.FireWeapon();
}

simulated function onThirdPersonFireCount()
{
	// Alternate fire animation. This may potentially get out of sync with the server. I am assuming that we
	// can live with this. Otherwise perhaps select animation based on fire count.
	if (fireAnimation == 'Fire1')
		fireAnimation = 'Fire2';
	else
		fireAnimation = 'Fire1';

	Super.onThirdPersonFireCount();
}

defaultproperties
{
     energyUsage=20.000000
     ammoCount=200
     ammoUsage=1
     roundsPerSecond=2.000000
     projectileClass=Class'AntiAircraftProjectile'
     projectileVelocity=2600.000000
     projectileInheritedVelFactor=0.500000
     aimClass=Class'AimProjectileWeapons'
     fireAnimation="Fire1"
     firstPersonMesh=SkeletalMesh'weapons.TurretbuggyFPS'
     firstPersonOffset=(Y=0.000000,Z=0.000000)
}
