class TankWeapon extends Weapon;

simulated function PostNetBeginPlay()
{
	local Mesh currMesh;
	local Rotator currRotation;

	Super.PostNetBeginPlay();

	// set projectileSpawnOffset to be the third person mesh muzzle bone
	currMesh = Mesh;
	currRotation = Rotation;
	LinkMesh(thirdPersonMesh);
	SetRotation(Rot(0.0, 0.0, 0.0));
	projectileSpawnOffset = GetBoneCoords(projectileSpawnBone).origin - Location;
	LinkMesh(currMesh);
	SetRotation(currRotation);
}

// Want to be in Held start initially so as the "equip" event will be correcrtly replicated.
auto simulated state TankWeaponHeld extends Held
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
     ammoCount=10
     ammoUsage=0
     projectileClass=Class'MortarProjectile'
     projectileVelocity=4500.000000
     projectileInheritedVelFactor=0.800000
     aimClass=Class'AimArcWeapons'
     thirdPersonMesh=SkeletalMesh'Vehicles.TankCannon'
     firstPersonOffset=(X=-26.000000,Y=22.000000,Z=-18.000000)
     animPrefix="Mortar"
}
