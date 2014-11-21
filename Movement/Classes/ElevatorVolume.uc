// Elevator Volume class

class ElevatorVolume extends Engine.PhysicsVolume implements PathfindingObstacle native;

var (Elevator) bool Active;

function Trigger(Actor Other, Pawn EventInstigator)
{
    Active = !Active;

    Gravity = vect(0,0,0);

    if (!Active)
        Gravity = Level.PhysicsVolume.Gravity;
}

function bool canBePassed(name teamName)
{
	return true;
}

defaultproperties
{
     Active=True
     Gravity=(Z=0.000000)
     GroundFriction=0.000000
     TerminalVelocity=100000.000000
     RenderMaterial=Shader'FX.ElevatorShader'
     RenderMaterialWorldSize=(X=500.000000,Y=500.000000)
     bHidden=False
     bUnlit=True
}
