class AntiAircraftProjectile extends ExplosiveProjectile;

var (AntiAircraftProjectile) float armingPeriod;

var (AntiAircraftProjectile) float armedCollisionRadius;
var (AntiAircraftProjectile) float armedCollisionHeight;

var ProjectileRadius nearCollisionExplode;

var bool armed;

simulated function postNetBeginPlay()
{
	super.postNetBeginPlay();

	setTimer(armingPeriod, false);
}

simulated function cleanupNearCollisionExplode()
{
	if (nearCollisionExplode != None)
		nearCollisionExplode.Destroy();
}

simulated function Destroyed()
{
	cleanupNearCollisionExplode();
	super.Destroyed();
}

simulated function endLife(Optional Actor HitActor, Optional vector TouchLocation, Optional vector TouchNormal)
{
	cleanupNearCollisionExplode();

	if (armed)
	{
		Super.endLife(HitActor, TouchLocation, TouchNormal);
	}
	else
	{
		bEndedLife = true;
		Destroy();
	}
}

simulated function timer()
{
	// arm

	nearCollisionExplode = spawn(class'ProjectileRadius', self,, Location);
	nearCollisionExplode.SetCollisionSize(armedCollisionRadius, armedCollisionHeight);
	nearCollisionExplode.SetCollision(true, false, false);

	armed = true;
}

simulated function Tick(float Delta)
{
	super.Tick(Delta);

	if (nearCollisionExplode != None)
		nearCollisionExplode.Move(Location - nearCollisionExplode.Location);
}

defaultproperties
{
	bDeflectable = false

	damageAmt = 0
	radiusDamageAmt = 40
	radiusDamageSize = 400
	radiusDamageMomentum = 105000

	StaticMesh = StaticMesh'Weapons.Disc'
	DrawScale3D = (X=0.75,Y=0.75,Z=0.75)	
	deathMessage = '%s copped it off %s\'s Spinfusor'

	armedCollisionHeight = 500
	armedCollisionRadius = 500

	armingPeriod = 1

	armed = false

	collisionRadius = 5
	collisionHeight = 5
}