class FailProjectileRocketPod extends EquipmentClasses.ProjectileRocketPod;

var float Health;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal){
	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		radiusDamageAmt *= 0.5;
		damageAmt *= 0.5;
	}
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	Health -= Damage;
	
	if(Health <= 0)
		Destroy();
		
	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}
/*
singular simulated function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
	local Projectile p;
	local Vector HitNormal;

	//Partial damage against sensor.  Prevent distant sensor spamming
	if(BaseObjectClasses.BaseSensor(Other) != None){
		radiusDamageAmt *= 0.5;
		damageAmt *= 0.5;
	}

	if (!projectileTouchProcessing(Other, TouchLocation, TouchNormal))
		return;

	if (ShouldHit(Other, TouchLocation))
	{
		if (!ShouldDeflect(Other, TouchLocation, HitNormal))
		{
			ProjectileHit(Other, TouchLocation, TouchNormal);
		}
		else
		{
			p = bounce(HitNormal, TouchLocation, Other.Velocity);
			p.bounceCount = 0; // Deflection doesn't count as a bounce
		}
	}
	super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}
*/

defaultproperties
{
     Health=5.500000
     bCanBeDamaged=True
}
