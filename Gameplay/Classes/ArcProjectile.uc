class ArcProjectile extends ExplosiveProjectile;

var bool bReadyToExplode;
var() float FuseTimer;
var() float BounceVelocityModifier;
var() float noBounceVelocityThreshold;
var() bool bExplodeInAir;
var bool bShouldBounce; // The projectile can't bounce off the instigator until after the first bounce.
						// This stops the projectile bouncing off the instigator when first fired.

var int lastCatapultHitTick;

// construct
overloaded function construct(Rook attacker, optional actor Owner, optional name Tag, 
				  optional vector Location, optional rotator Rotation)
{
	bReadyToExplode = false;
	bShouldBounce = false;

	super.construct(attacker, Owner, Tag, Location, Rotation);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (FuseTimer > 0.0)
		SetTimer(FuseTimer, false); //how long it takes for the fuse to burn out
	else
		bReadyToExplode = true;
}

simulated function Tick(float Delta)
{
	super.Tick(Delta);
	SetRotation(Rotator(Velocity));
}
	
simulated function Timer()
{
	bReadyToExplode = true;
	bShouldBounce = true;

	if (bExplodeInAir)
		endLife(None, Location);
}

simulated function bool ShouldHit(Actor Other, vector TouchLocation)
{
	return !ClientDetectDeflection(Other, TouchLocation) && Other.ShouldProjectileHit(Instigator) && (Other != Instigator || bShouldBounce);
}

simulated function bool projectileTouchProcessing(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (Other.IsA('Catapult'))
	{
		// move to projectile touch location and trigger catapult
		Move(TouchLocation - Location);
		Catapult(Other).TouchProcessing(self);
		lastCatapultHitTick = LastTick;
		return false;
	}

	return true;
}

simulated function Vector CalcBounceVelocity(Vector HitNormal)
{
	return VSize(Velocity) * BounceVelocityModifier * MirrorVectorByNormal(Normal(Velocity), HitNormal);
}

// Touch
simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	if (bReadyToExplode)
	{
		endLife(Other, TouchLocation, TouchNormal);
	}
	else if (Other != Instigator || bShouldBounce)
	{
		bShouldBounce = true;
		Velocity = CalcBounceVelocity(TouchNormal);
	}
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	// do not bounce off catapults

	// ... appeared to collide with level at the instant of colliding with catapult so handle that here (+1 is for the client side case)
	if (!bReadyToExplode && (LastTick == lastCatapultHitTick || LastTick == (lastCatapultHitTick + 1) || Wall.IsA('Catapult')))
		return;

	if (bReadyToExplode)
	{
		endLife(None, Location, HitNormal);
	}
	else
	{
		bShouldBounce = true;
		Velocity = CalcBounceVelocity(HitNormal);

		if (VSize(Velocity) > noBounceVelocityThreshold)
			TriggerEffectEvent('Bounce');
	}
}

defaultproperties
{
     noBounceVelocityThreshold=10.000000
     Physics=PHYS_Falling
     StaticMesh=StaticMesh'weapons.Grenade'
     bBounce=True
}
