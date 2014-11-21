class AssaultShipWeapon extends Weapon;

simulated function bool canFire()
{
	return true;
}

// Want to be in Held start initially so as the "equip" event will be correcrtly replicated.
auto simulated state AssaultShipHeld extends Held
{

}

simulated function moveWeapon()
{
	// do nothing
}

// Had problem of clients occasionally thinking they were using this weapon in first person when exitting vehicle. Added this function
// to make sure it is always used in third person.
simulated function bool firstPersonStatus()
{
	return false;       
}

defaultproperties
{
	drawType = DT_None

	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.5
	ammoCount = 10
	ammoUsage = 0

	projectileClass = class'MortarProjectile'
	projectileVelocity = 4500
	projectileInheritedVelFactor = 0.8

	aimClass = class'AimArcWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Mortar"
}