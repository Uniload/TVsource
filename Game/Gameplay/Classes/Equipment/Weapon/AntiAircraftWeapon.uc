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
	firstPersonMesh = Mesh'Weapons.TurretBuggyFPS'
	firstPersonOffset = (X=0,Y=0,Z=0)

	roundsPerSecond = 2
	ammoCount = 200
	ammoUsage = 1

	projectileClass = class'AntiAircraftProjectile'
	projectileVelocity = 2600
	projectileInheritedVelFactor = 0.5

	aimClass = class'AimProjectileWeapons'

	energyUsage = 20

	bFirstPersonUseTrace = false

	fireAnimation = Fire1
}