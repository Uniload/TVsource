class TsActionInterpolateFOV extends TsCameraAction;

var() float Duration;
var() float EaseIn;
var() float EaseOut;
var() float targetFOV;

var transient float baseFOV;
var transient float diffFOV;

function bool OnStart()
{
	resetInterpolation(EaseIn, Duration, EaseOut);

	baseFOV = PC.FOVAngle;
	diffFOV = targetFOV - baseFOV;

	return true;
}

function bool OnTick(float delta)
{
	local float alpha;
	local bool bFinished;

	bFinished = tickInterpolation(delta, alpha);

	// set FOV
	PC.SetFOV(baseFOV + alpha * diffFOV);

	return bFinished;
}

function OnFinish()
{

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
	DName			="Interpolate FOV"
	Track			="Effects"
	Help			="Interpolates the camera field of view."
	UsesDuration	=true

	targetFOV		=85.0
	Duration		=1
	EaseIn			=1
	EaseOut			=1
}