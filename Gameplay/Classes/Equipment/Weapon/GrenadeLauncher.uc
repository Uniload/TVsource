class GrenadeLauncher extends Weapon;

defaultproperties
{
	firstPersonMesh = Mesh'Weapons.GrenadeLauncher'
	firstPersonOffset = (X=-36,Y=22,Z=-15)

	roundsPerSecond = 1
	ammoCount = 10
	ammoUsage = 1

	projectileClass = class'GrenadeLauncherProjectile'
	projectileVelocity = 2100
	projectileInheritedVelFactor = 0.8

	aimClass = class'AimArcWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "GrenadeLauncher"

	hudReticule			= texture'HUD.ReticuleLob'
	hudReticuleWidth	= 128
	hudReticuleHeight	= 256
	hudReticuleCenterX	= 64
	hudReticuleCenterY	= 64
}