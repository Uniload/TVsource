class MovementObject extends Core.Object
	abstract
	native;

enum GroundState
{
    GroundState_Standing,
    GroundState_Walking,
    GroundState_Running,
    GroundState_Sprinting,
    GroundState_Any,
};

final native function setInput(float forward, float strafe, float jump, float ski, float jetpack, int groundState);

final native function forceMovementState(int state);

final native function setPosition(vector newPosition);

final native function setEndPosition(vector newPosition);

final native function setStartPosition(vector newPosition);

final native function vector getStartPosition();

final native function vector getEndPosition();

final native function setAccumulator(float accumulator);

final native function float getAccumulator();

final native function setVelocity(vector velocity);

final native function addVelocity(vector velocity);

final native function addImpulse(vector impulse);

final native function setAcceleration(vector newAcceleration);

final native function addForce(vector force);

final native function wake();

final native function calculateExtents();

defaultproperties
{
}
