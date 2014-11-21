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
     Spread=0.078000
     ammoCount=150
     roundsPerSecond=12.000000
     projectileClass=Class'ChaingunProjectile'
     projectileVelocity=5500.000000
     projectileInheritedVelFactor=1.000000
     aimClass=Class'AimProjectileWeapons'
     firstPersonMesh=SkeletalMesh'weapons.Chaingun'
     firstPersonOffset=(X=-23.000000,Y=26.000000,Z=-24.000000)
     animPrefix="Chaingun"
     animClass=Class'CharacterEquippableAnimator'
     inventoryIcon=Texture'GUITribes.InvButtonChaingun'
     hudIcon=Texture'HUD.Tabs'
     hudIconCoords=(U=205.000000,V=472.000000)
     hudRefireIcon=Texture'HUD.Tabs'
     hudRefireIconCoords=(U=205.000000,V=421.000000)
}
