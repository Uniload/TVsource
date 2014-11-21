class classyGrapplerProjectile extends Gameplay.GrapplerProjectile;

var float Health;

function PostTakeDamage(float Damage, Engine.Pawn EventInstigator, vector HitLocation, vector Momentum, class<Engine.DamageType> DamageType, optional float projectileFactor)
{
	Health -= Damage;

	if(Health <= 0) Destroy();

	Super.PostTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, projectileFactor);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	Super.simulatedAttach(Other, TouchLocation);

	SetCollision(True, True, True);
}

defaultproperties
{
     Health=25.000000
     bCanBeDamaged=True
}
