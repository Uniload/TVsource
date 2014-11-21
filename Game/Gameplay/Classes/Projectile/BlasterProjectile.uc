class BlasterProjectile extends Projectile;

var bool bShouldBounce;
var() float bounceTime "The amount of time for which a projectile is allowed to bounce";
var() int maxBounces;

const AI_FRIENDLY_FIRE_MULTIPLIER = 0.2;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	SetTimer(bounceTime, false); // blaster projectiles can only bounce over a short range
}
	
simulated function Timer()
{
	bShouldBounce = false;
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	if (bShouldBounce && bounceCount < maxBounces)
	{
		bounce(HitNormal, Location, Vect(0.0, 0.0, 0.0));
		TriggerEffectEvent('Bounce');

		if (Level.NetMode == NM_Client)
			Destroy();
	}
	else
	{
		endLife(None, Location, HitNormal);
	}
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	local Rook rookOther;

	if (Level.NetMode == NM_StandAlone && Instigator != None && Instigator.Controller != None && !Instigator.Controller.bIsPlayer)
	{
		rookOther = Rook(Other);

		if (rookOther != None && rookOther.isFriendly(Rook(Instigator)))
			damageAmt *= AI_FRIENDLY_FIRE_MULTIPLIER;
	}

	super.ProjectileHit(Other, TouchLocation, TouchNormal);
}

defaultproperties
{
	bScaleProjectile = true
	initialXDrawScale = 0.05
	xDrawScalePerSecond = 10.0

	bShouldBounce = true
	bounceTime = 0.5
	maxBounces = 2
	bounceCount = 0
	damageAmt = 7
	StaticMesh = StaticMesh'Weapons.Disc'
	DrawScale3D = (X=0.3,Y=0.3,Z=0.3)	
	deathMessage = '%s copped it off %s\'s Blaster'
	
	knockback = 15000           // note that each individual shot applies knockback so this adds up to be quite large knockback
	knockbackAliveScale = 0 //0.5   // we dont want to push alive characters back as much with the shotgun as ragdolls and havok objects
}