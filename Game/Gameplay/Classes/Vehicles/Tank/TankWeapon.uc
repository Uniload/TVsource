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
	thirdPersonMesh = SkeletalMesh'Vehicles.TankCannon'

	firstPersonOffset = (X=-26,Y=22,Z=-18)

	roundsPerSecond = 0.5
	ammoCount = 10
	ammoUsage = 0

	projectileClass = class'MortarProjectile'
	projectileVelocity = 4500
	projectileInheritedVelFactor = 0.8

	aimClass = class'AimArcWeapons'

	animPrefix = "Mortar"
}