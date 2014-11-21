class classyWeaponVehicleAssaultShip extends EquipmentClasses.WeaponVehicleAssaultShip;


var() int numProjectiles			"The number of rockets to fire";
var int numProjectilesFired;

var() float launchDelay				"The number of seconds to wait in between each rocket firing";

var float angleIncreament;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	angleIncreament = 2 * Pi / float(numProjectiles);
}

simulated function Timer()
{
	if (equipped)
		FireWeapon();
}

simulated protected function FireWeapon()
{
	local Name fireAnim;

	if (numProjectilesFired < numProjectiles)
	{
		++numProjectilesFired;

		Super.FireWeapon();

		fireAnim = Name("Fire_0" $ numProjectilesFired);

		animClass.static.playEquippableAnim(self, fireAnim, 1.0);

		SetTimer(launchDelay , false);
	}
	else
		numProjectilesFired = 0;
}



//protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
//{
//	local EquipmentClasses.ProjectileMortarBomb p;

//	p = EquipmentClasses.ProjectileMortarBomb(Super.makeProjectile(fireRot, fireLoc));

//	if (p != None)
//	{
//		GetAxes(fireRot, p.xAxis, p.yAxis, p.zAxis);
  //
//		p.offsetVecAngle = numProjectilesFired * angleIncreament;
  //
//		p.zAxis = QuatRotateVector(QuatFromAxisAndAngle(p.xAxis, p.offsetVecAngle), p.zAxis);
  //
//		p.initialZAxis.X = p.zAxis.X;
//		p.initialZAxis.Y = p.zAxis.Y;
//		p.initialZAxis.Z = p.zAxis.Z;
//	}

//	return p;
//}

defaultproperties
{
     numProjectiles=3
     launchDelay=0.500000
     ammoCount=0
     ammoUsage=0
     roundsPerSecond=0.050000
     projectileClass=Class'EquipmentClasses.ProjectileMortarBomb'
     projectileVelocity=4000.000000
     projectileInheritedVelFactor=0.400000
     thirdPersonMesh=SkeletalMesh'Vehicles.AssaultShipGun'
}
