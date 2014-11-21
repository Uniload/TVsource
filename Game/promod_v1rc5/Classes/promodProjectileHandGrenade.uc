class promodProjectileHandGrenade extends Gameplay.HandGrenadeProjectile config(promod);

defaultproperties
{
	FuseTimer = 3
	BounceVelocityModifier = 0.24
	damageAmt = 0
	radiusDamageAmt = 20
	radiusDamageSize = 300
	radiusDamageMomentum = 80000
	GravityScale = 1.0
	DrawScale3D = (X=0.5,Y=0.5,Z=0.5)
	bExplodeInAir = true

	bNetTemporary = false

	StaticMesh = StaticMesh'Weapons.Grenade'
	deathMessage = '%s copped it off %s\'s Hand Grenade'
}