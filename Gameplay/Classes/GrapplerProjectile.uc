class GrapplerProjectile extends Projectile;

simulated function HitWall(Vector HitNormal, Actor HitWall)
{
	triggerHitEffect(HitWall, Location, HitNormal);
	simulatedAttach(HitWall, Location);
}

simulated function bool ShouldHit(Actor Other, vector TouchLocation)
{
	if (Equipment(Other) != None)
		return true;

	return super.ShouldHit(Other, TouchLocation);
}

simulated function ProjectileHit(Actor Other, vector TouchLocation, vector TouchNormal)
{
	triggerHitEffect(Other, TouchLocation, TouchNormal);
	simulatedAttach(Other, TouchLocation);
}

simulated function simulatedAttach(Actor Other, vector TouchLocation)
{
	SetPhysics(PHYS_None);
	SetCollision(false, false, false);
	SetLocation(TouchLocation);

	serverAttach(Other);
}

function serverAttach(Actor Other)
{
	SetBase(Other);

	if (bDeleteMe)
		return;

	if (Character(Other) != None)
		Character(Other).addGrapplerCharacter(Character(Instigator));

	Character(Instigator).attachGrapple();
}

defaultproperties
{
     bReceivedInitialVelocity=True
     bReplicateInitialVelocity=False
     bDeflectable=False
     Knockback=0.000000
     StaticMesh=StaticMesh'weapons.GrappleHook'
     bNetTemporary=False
     bReplicateMovement=True
     bHardAttach=True
}
