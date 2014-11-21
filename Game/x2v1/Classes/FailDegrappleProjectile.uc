class FailDegrappleProjectile extends Gameplay.GrapplerProjectile;

var float Health;
var float burningDamagerPerSecond;

function PostTakeDamage(float Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional float projectileFactor)
{
	Health -= Damage;
	
	if(Health <= 0)
		Destroy();
		
	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	local Character c;
	c = Character(Other);
	if(c != None)
		Destroy();
	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(true, true, true);
}

defaultproperties
{
     Health=30.000000
     bCanBeDamaged=True
     burningDamagerPerSecond=55.000000
     bProjTarget=True
}
