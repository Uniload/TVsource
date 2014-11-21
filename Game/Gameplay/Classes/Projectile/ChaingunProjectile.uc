class ChaingunProjectile extends Projectile;

defaultproperties
{
	damageAmt = 6
	bNeedLifetimeEffectEvents = false

	StaticMesh = StaticMesh'Weapons.ChaingunTracer'
	deathMessage = '%s copped it off %s\'s Chaingun'
	
	knockback = 25000               // large because its only a single projectile that hits on death unlike blaster
	knockbackAliveScale = 0 //0.1       // disable character knockback because its really silly pushing guys around with the chain
}