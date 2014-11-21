class PodWeapon extends Weapon;

simulated function bool canFire()
{
	return true;
}

// Had problem of clients occasionally thinking they were using this weapon in first person when exitting vehicle. Added this function
// to make sure it is always used in third person.
simulated function bool firstPersonStatus()
{
	return false;       
}

// Want to be in Held start initially so as the "equip" event will be correcrtly replicated.
auto simulated state PodHeld extends Held
{

}

simulated function moveWeapon()
{
	// do nothing
}

defaultproperties
{
	drawType = DT_None
	bHidden = false

	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 2
	ammoCount = 200
	ammoUsage = 0

	projectileClass = class'PodWeaponProjectile'
	projectileVelocity = 2600
	projectileInheritedVelFactor = 0.5

	aimClass = class'AimProjectileWeapons'

	thirdPersonMesh = None
}