class ExplosiveProjectile extends Projectile;

var bool bEndedLife;

var() float radiusDamageAmt; 
var() float radiusDamageSize;
var() float radiusDamageMomentum;

var() class<Explosion> ExplosionClass;

var() bool orientDecalToVelocity;

var EDrawType storedDrawType;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	storedDrawType = DrawType;
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	if (bHidden)
	{
		SetPhysics(PHYS_None);
		bEndedLife = true;
		Destroy();
	}
}

simulated function bool ShouldHit(Actor Other, vector TouchLocation)
{
	if (ClientDetectDeflection(Other, TouchLocation))
	{
		SetDrawType(DT_None);
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		SetLocation(TouchLocation);
		return false;
	}

	return super.ShouldHit(Other, TouchLocation);
}

simulated function Destroyed()
{
	if (!bEndedLife)
	{
		SetDrawType(storedDrawType);
		endLife(None, Location);
	}

	super.Destroyed();
}

function PostBounce(Projectile newProjectile)
{
	makeHarmless();
	bHidden = true;
	bEndedLife = true;
	LifeSpan = 5.0;
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	victim = Other.Name;
	endLife(Other, TouchLocation, TouchNormal);
}

simulated function triggerHitEffect(Actor HitActor, vector TouchLocation, vector TouchNormal, optional Name HitEffect)
{
	local vector pushBack;

	if (HitEffect == '')
		HitEffect = 'Hit';

	TriggerEffectEvent(HitEffect, None, None, TouchLocation);

	if (orientDecalToVelocity)
	{
		pushBack = Normal(-Velocity);
		TriggerEffectEvent('Decal', None, None, TouchLocation + 100.f * pushback, Rotator(pushBack));
	}
	else
	{
		if (vsize(TouchNormal) > 0.5)
			TriggerEffectEvent('Decal', None, None, TouchLocation, Rotator(TouchNormal));
		else
			TriggerEffectEvent('Decal', None, None, TouchLocation, Rotator(vect(0,0,1)));
	}
}


// endLife
simulated function endLife(Actor HitActor, vector TouchLocation, Optional vector TouchNormal)
{
    local float speed;
    local Vector direction;

	if (bEndedLife)
		return;

	bEndedLife = true;

	if(ExplosionClass != None)
	{
	    // this explosive damage case does not have a "direct hit" concept
	    // therefore should only be used for things like grenades and mortars.
	
		spawn(ExplosionClass, , , TouchLocation, Rotation).Trigger(self, None);
	}
	else
	{
	    // this hurt radius case includes "direct hit" handling code that applies 
	    // knockback momentum in the direction that the projectile was travelling for direct hits,
	    // otherwise standard radial knockback is applied. this is ideal for spinfusor projectiles.
	
	    speed = FMax(1,VSize(Velocity));
	    direction = Velocity / speed;
		HurtRadius(radiusDamageAmt, radiusDamageSize, damageTypeClass, radiusDamageMomentum, TouchLocation, HitActor, direction);
	}

	Super.endLife(None, TouchLocation, TouchNormal);
}

// makeHarmless
function makeHarmless()
{
	Super.MakeHarmless();

	radiusDamageAmt = 0;
	radiusDamageSize = 0;
	radiusDamageMomentum = 0;
}

defaultproperties
{
	damageTypeClass = class'DamageType'
	
	knockback = 0                   	// note that knockback is applied via HurtRadius instead
	knockbackAliveScale = 1             // must apply full knockback to characters while alive
}