class GrenadeLauncherProjectile extends ArcProjectile;

defaultproperties
{
	FuseTimer = 1
	BounceVelocityModifier = 0.24
	damageAmt = 0
	radiusDamageAmt = 50
	radiusDamageSize = 600
	radiusDamageMomentum = 105000
	GravityScale = 1.0
	DrawScale3D = (X=0.5,Y=0.5,Z=0.5)

	bNetTemporary = false

	StaticMesh = StaticMesh'Weapons.Grenade'
	deathMessage = '%s copped it off %s\'s GrenadeLauncher'
}