class AnimationSpring extends Core.DeleteableObject native;
	

var float tightness;               // spring tightness
var float maximum;                 // spring maximum delta (offset from target)

var float value;                   // current spring value
var float target;                  // target value (should be updated each frame)

var float normalized;              // normalized spring value in [-1,1]


native function int Update(float delta);
native function Snap(float target);

overloaded function construct(float springTightness, float maximumDelta)
{
    tightness = springTightness;
    maximum = maximumDelta;
}

defaultproperties
{
}
