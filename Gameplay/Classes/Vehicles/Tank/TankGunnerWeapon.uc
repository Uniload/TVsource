class TankGunnerWeapon extends TurretWeapon;

var() float spread;

protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Rotator r;
	local float spreadInRotUnits;

	spreadInRotUnits = spread * 65536 / 360;

	r.Yaw = spreadInRotUnits * (2.0f * FRand() - 1);
	r.Pitch = spreadInRotUnits * (2.0f * FRand() - 1);

	return Super.makeProjectile( fireRot + r, fireLoc );
}

defaultproperties
{
	spread = 0.078

	firstPersonMesh = Mesh'Weapons.Chaingun'
	firstPersonOffset = (X=-23,Y=26,Z=-24)

	roundsPerSecond = 12
	ammoCount = 150
	ammoUsage = 0

	projectileClass = class'ChaingunProjectile'
	projectileVelocity = 5500
	projectileInheritedVelFactor = 1.0

	aimClass = class'AimProjectileWeapons'
	animClass = class'CharacterEquippableAnimator'

	animPrefix = "Chaingun"

	fireState = FirePressed
	releaseFireState = FireReleased

	inventoryIcon		= texture'GUITribes.InvButtonChaingun'
	hudIcon				= texture'HUD.Tabs'
	hudIconCoords		= (U=205,V=472,UL=80,VL=40)
	hudRefireIcon		= texture'HUD.Tabs'
	hudRefireIconCoords	= (U=205,V=421,UL=80,VL=40)
}