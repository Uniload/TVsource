class TurretAntiAircraftWeapon extends TurretWeapon;

var() name fireAnimationVariant1;
var() name fireAnimationVariant2;

simulated function onThirdPersonFireCount()
{
	setFireAnimation();
	super.onThirdPersonFireCount();
}

simulated function setFireAnimation()
{
	if (fireAnimation != fireAnimationVariant2)
		fireAnimation = fireAnimationVariant2;
	else
		fireAnimation = fireAnimationVariant1;
}

simulated protected function FireWeapon()
{
	setFireAnimation();
	super.FireWeapon();
}


defaultproperties
{
	firstPersonMesh = Mesh'Weapons.Spinfusor'
	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.56
	ammoCount = 20
	ammoUsage = 1

	projectileClass = class'SpinfusorProjectile'
	projectileVelocity = 2600
	projectileInheritedVelFactor = 0.5

	aimClass = class'AimProjectileWeapons'

	animPrefix = "Spinfusor"
	fireAnimationVariant1 = "Fire1"
	fireAnimationVariant2 = "Fire2"
}