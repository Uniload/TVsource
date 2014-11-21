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
     ammoCount=200
     ammoUsage=0
     roundsPerSecond=2.000000
     projectileClass=Class'PodWeaponProjectile'
     projectileVelocity=2600.000000
     projectileInheritedVelFactor=0.500000
     aimClass=Class'AimProjectileWeapons'
     firstPersonOffset=(X=-26.000000,Y=22.000000,Z=-18.000000)
     DrawType=DT_None
}
