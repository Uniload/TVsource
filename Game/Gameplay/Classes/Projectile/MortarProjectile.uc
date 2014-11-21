class MortarProjectile extends ArcProjectile;

defaultproperties
{
	FuseTimer = 1.5
	BounceVelocityModifier = 0.25
	damageAmt = 0
	radiusDamageAmt = 100
	radiusDamageSize = 1000
	radiusDamageMomentum = 250000
	GravityScale = 1.0

	bNetTemporary = false

	StaticMesh = StaticMesh'Weapons.Grenade'
	deathMessage = '%s copped it off %s\'s Mortar'
}