class PodWeaponProjectile extends ExplosiveProjectile;

defaultproperties
{
	damageAmt = 0
	radiusDamageAmt = 40
	radiusDamageSize = 400
	radiusDamageMomentum = 105000
	
	StaticMesh = StaticMesh'Weapons.Disc'
	DrawScale3D = (X=0.75,Y=0.75,Z=0.75)	
	deathMessage = '%s copped it off %s\'s Spinfusor'
}