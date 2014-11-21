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
     Gravity=(Z=0.000000)
     GroundFriction=0.000000
     TerminalVelocity=100000.000000
     bUnlit=True
}
