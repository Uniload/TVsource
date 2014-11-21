class FailDegrappleProjectile extends Gameplay.GrapplerProjectile;

var float Health;
var float damageAmt;
var float knockback;
var float knockbackAliveScale;


// Thank you Rapher
function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	Health -= Damage;
	
	if(Health <= 0)
		Destroy();
		
	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(true, true, true);
}


//Thank you IRGames
simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	victim = Other.Name;
	
	triggerHitEffect(Other, TouchLocation, TouchNormal);
	simulatedAttach(Other, TouchLocation);
	Other.TakeDamage(damageAmt, Instigator, TouchLocation, (normal(velocity) * knockback), damageTypeClass, 1.0-knockbackAliveScale);
	
}

defaultproperties
{
     Health=25.000000
     damageAmt=7.000000
     Knockback=45000.000000
     knockbackAliveScale=15000.000000
     bCanBeDamaged=True
}
