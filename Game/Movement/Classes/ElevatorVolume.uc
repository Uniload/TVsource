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
    Active = true

    // glenn: disabled optimization in case it has broken elevators (testing)

  	// optimisation:
	//bDisableTouch = true
	bUnlit = true
	bAcceptsProjectors = false
  
    Gravity = (X=0.0,Y=0.0,Z=0.0)
	FluidFriction=0
    TerminalVelocity=100000
    GroundFriction=0

	// display
	bHidden = false
	RenderMaterial = Material'FX.ElevatorShader'
	RenderMaterialWorldSize = (X=500,Y=500,Z=0)
}
