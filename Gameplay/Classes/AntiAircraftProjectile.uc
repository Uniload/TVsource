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
     armingPeriod=1.000000
     armedCollisionRadius=500.000000
     armedCollisionHeight=500.000000
     radiusDamageAmt=40.000000
     radiusDamageSize=400.000000
     radiusDamageMomentum=105000.000000
     bDeflectable=False
     DrawScale3D=(X=0.750000,Y=0.750000,Z=0.750000)
     CollisionRadius=5.000000
     CollisionHeight=5.000000
}
