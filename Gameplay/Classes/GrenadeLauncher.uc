class GrenadeLauncher extends Weapon;

defaultproperties
{
     ammoCount=10
     roundsPerSecond=1.000000
     projectileClass=Class'GrenadeLauncherProjectile'
     projectileVelocity=2100.000000
     projectileInheritedVelFactor=0.800000
     aimClass=Class'AimArcWeapons'
     hudReticule=Texture'HUD.reticuleLob'
     hudReticuleHeight=256.000000
     firstPersonMesh=SkeletalMesh'weapons.GrenadeLauncher'
     firstPersonOffset=(X=-36.000000,Y=22.000000,Z=-15.000000)
     animPrefix="GrenadeLauncher"
     animClass=Class'CharacterEquippableAnimator'
}
