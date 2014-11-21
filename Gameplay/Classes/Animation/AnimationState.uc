class AnimationState extends Core.DeleteableObject native;
	
enum AnimationType
{
	AnimationType_IdleWithTurn,                             // idle standing with turn left/right
	AnimationType_StrafeDirectional,                        // directional blending based on strafe
	AnimationType_DisplacementDirectional,                  // directional blending based on displacement
	AnimationType_VelocitySpringAndAirborneUpDown,          // ground based velocity spring with airborne up/down
	AnimationType_AirborneUpDown                            // airborne up/down
};

var String name;

var AnimationType type;

var float blendInTime;       // time to blend into this state (seconds)
var float blendTightness;    // internal state blending tightness (lerp seconds -> non-linear ease-in)

var String centre;
var String left;
var String right;
var String forward;
var String back;
var String up;
var String down;

var float speed;             // animation speed in unreal units per second (used for walk/run/sprint anti-footslip)
