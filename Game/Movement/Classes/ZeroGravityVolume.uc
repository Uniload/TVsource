// Zero Gravity Volume class

class ZeroGravityVolume extends Engine.PhysicsVolume native;

function Trigger(Actor Other, Pawn EventInstigator)
{
    Active = !Active;

    Gravity = vect(0,0,0);

    if (!Active)
        Gravity = Level.PhysicsVolume.Gravity;
}

defaultproperties
{
    Active = true

	// optimisation:
	bUnlit = true
	bAcceptsProjectors = false

    Gravity = (X=0.0,Y=0.0,Z=0.0)
	FluidFriction=0
    TerminalVelocity=100000
    GroundFriction=0
}
