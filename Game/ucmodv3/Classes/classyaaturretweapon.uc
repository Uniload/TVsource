class classyaaturretweapon extends EquipmentClasses.WeaponRocketPod;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	angleIncreament = (2 * Pi / (float(numProjectiles)/2));
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local RocketPodProjectile p;

	p = RocketPodProjectile(Super.makeProjectile(fireRot, fireLoc));

	if (p != None)
	{
		GetAxes(fireRot, p.xAxis, p.yAxis, p.zAxis);

		p.offsetVecAngle = numProjectilesFired * angleIncreament +(Pi/4);

		p.zAxis = QuatRotateVector(QuatFromAxisAndAngle(p.xAxis, p.offsetVecAngle), p.zAxis);

		p.initialZAxis.X = p.zAxis.X;
		p.initialZAxis.Y = p.zAxis.Y;
		p.initialZAxis.Z = p.zAxis.Z;
	}

	return p;
}

defaultproperties
{
     numProjectiles=8
     ammoUsage=0
     projectileClass=Class'ucmodv2.classyProjectileturretaa'
     firstPersonMesh=SkeletalMesh'weapons.TurretbuggyFPS'
     thirdPersonMesh=SkeletalMesh'weapons.TurretAA'
}
