class TsActionKeyframeInterpolate extends TsActionInterpolateBase
	native;

var(Action) float duration;
var(Action) float ease_in_time;
var(Action) float ease_out_time;
var(Action) bool snap_to_first_key;
var(Action) bool use_linear_rotation;

var(keys) array<MojoKeyframe> keys;

var(LookAt) enum LookAtType
{
	LOOKAT_UseKeyframe,
	LOOKAT_Actor,
	LOOKAT_Point,
} look_at_type;
var(LookAt) MojoKeyframe look_at_point;
var(LookAt) MojoActorRef look_at_actor;
var(LookAt) float look_at_ease_time;

var float cur_time;

///////////////////////////////////////////////////////////////////////////////
// constants used by native interpolation
///////////////////////////////////////////////////////////////////////////////

var const int	cur_key;
var const float src_key_distance;
var const float dest_key_distance;
var const transient noexport int spline; // native spline class


native function CalculateConstants(vector initial_pos, rotator initial_rot);
native function bool UpdateCurrentKeyframePos(float time);

function bool OnStart()
{
	if (keys.Length == 0 || duration <= 0)
		return false;

	cur_time = 0;

	if (look_at_type == LOOKAT_Actor)
	{
		look_at_actor = ResolveActorRef(look_at_actor);
		if (look_at_actor.actor == None)
			Log("TsActionKeyframeInterpolate: Warning, unable to resolve look_at_actor, "$look_at_actor.name);
	}

	CalculateConstants(Actor.Location, Actor.Rotation);
	StartActorInterpolation();

	return true;
}

function bool OnTick(float delta)
{
	local bool still_active;

	cur_time += delta;
	still_active = UpdateCurrentKeyframePos(cur_time);
	ApplyCurrentKeyframePos();

	return still_active;
}

function OnFinish()
{
	FinishActorInterpolation();
}

event bool SetDuration(float _duration)
{
	duration = _duration;
	return true;
}

event float GetDuration()
{
	return Duration;
}

defaultproperties
{
	DName				="Path Interpolate"
	Track				="Position"
	Help				="Interpolate an object at constant velocity along a path"
	UsesDuration		=true

	duration		= 4.0f;
	ease_in_time	= 0.0f;
	ease_out_time	= 0.0f;
	snap_to_first_key = false;
}