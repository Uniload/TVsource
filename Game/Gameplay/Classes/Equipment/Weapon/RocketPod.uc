class RocketPod extends Weapon;

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

		animClass.static.playEquippableAnim(self, fireAnim, speedPackScale);

		SetTimer(launchDelay / speedPackScale, false);
	}
	else
		numProjectilesFired = 0;
}

function bool canUnequip()
{
	return numProjectilesFired == 0;
}

simulated function playIdleAnim()
{
	if (numProjectilesFired == 0)
		Super.playIdleAnim();
}

simulated protected function playPostFireAnim()
{
	if (numProjectilesFired == 0)
		Super.playPostFireAnim();
}

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local RocketPodProjectile p;

	p = RocketPodProjectile(Super.makeProjectile(fireRot, fireLoc));

	if (p != None)
	{
		GetAxes(fireRot, p.xAxis, p.yAxis, p.zAxis);

		p.offsetVecAngle = numProjectilesFired * angleIncreament;

		p.zAxis = QuatRotateVector(QuatFromAxisAndAngle(p.xAxis, p.offsetVecAngle), p.zAxis);

		p.initialZAxis.X = p.zAxis.X;
		p.initialZAxis.Y = p.zAxis.Y;
		p.initialZAxis.Z = p.zAxis.Z;
	}

	return p;
}

simulated state Dropped
{
	simulated function BeginState()
	{
		numProjectilesFired = 0;
		super.BeginState();
	}
}

defaultproperties
{
	firstPersonMesh = Mesh'Weapons.RocketPod'
	firstPersonOffset = (X=-33,Y=22,Z=-15)

	numProjectiles = 6
	numProjectilesFired = 0
	launchDelay = 0.15

	roundsPerSecond = 0.5
	ammoCount = 128
	ammoUsage = 1

	projectileClass = class'RocketPodProjectile'
	projectileVelocity = 500
	projectileInheritedVelFactor = 1.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "RocketPod"
}