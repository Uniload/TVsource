class TsActionInterpolateTo extends TsActionInterpolateBase
	native;

var(Action) MojoKeyframe Target;
var(Action) float duration;
var(Action) float ease_in_time;
var(Action) float ease_out_time;

var float elapsed_duration;

native function CalculateConstants(vector initial_pos, rotator initial_rot);
native function UpdateCurrentKeyframePos(float time);

function bool OnStart()
{
	elapsed_duration = 0;

	CalculateConstants(Actor.Location, Actor.Rotation);
	StartActorInterpolation();

	return true;
}

function bool OnTick(float delta)
{
	elapsed_duration += delta;
	
	UpdateCurrentKeyframePos(elapsed_duration);
	ApplyCurrentKeyframePos();

	return (elapsed_duration < duration);
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
     duration=1.000000
     DName="Interpolate To"
     Help="Interpolate an object to a point"
     UsesDuration=True
}
