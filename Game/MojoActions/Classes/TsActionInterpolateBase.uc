class TsActionInterpolateBase extends TsAction
	abstract native;

///////////////////////////////////////////////////////////////////////////////
// constants used by native interpolation
///////////////////////////////////////////////////////////////////////////////
// native code updates this keyframe var with the current object position/rotation
var const MojoKeyframe cur_keyframe;

// hermite position vars
var const vector src_tangent;
var const vector dest_tangent;
var const vector src_position;
var const vector dest_position;

// quaternions are used internally for rotation... we have to define spacer equivs here
var const transient noexport float sqx,sqy,sqz,sqw;	// source rotation
var const transient noexport float dqx,dqy,dqz,dqw;	// dest rotation
var const transient noexport float iqx,iqy,iqz,iqw;	// intermediate rotation for squad

final function ApplyCurrentKeyframePos()
{
	Actor.setLocation(cur_keyframe.position);
	Actor.setRotation(cur_keyframe.rotation);
}

function StartActorInterpolation()
{
	if (Actor != None)
	{
		Actor.GotoState('');
		Actor.SetPhysics(PHYS_None);
		Actor.bInterpolating = true;
	}
}

function FinishActorInterpolation()
{
	if (Actor != None)
		Actor.bInterpolating = false;
}

defaultproperties
{
	DName				="Interpolate"
	Track				="Position"
	Help				="Interpolate an object"
	ModifiesLocation = true
}