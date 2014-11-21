class TsActionLightColour extends TsLightAction;

var() float Duration;
var() float EaseIn;
var() float EaseOut;
var() float TargetBrightness;
var() float TargetHue;
var() float TargetSaturation;
var() float TargetRadius;

var transient float startBrightness;
var transient float startHue;
var transient float startSaturation;
var transient float startRadius;

function bool OnStart()
{
	resetInterpolation(EaseIn, Duration, EaseOut);

	startBrightness = Light.LightBrightness;
	startHue = Light.LightHue;
	startSaturation = Light.LightSaturation;
	startRadius = Light.LightRadius;

	return true;
}

function bool OnTick(float delta)
{
	local float alpha;
	local bool bFinished;

	bFinished = tickInterpolation(delta, alpha);

	if (TargetBrightness != -1)
		Light.LightBrightness = startBrightness + (TargetBrightness - startBrightness) * alpha;
	if (TargetHue != -1)
		Light.LightHue = startHue + (TargetHue - startHue) * alpha;
	if (TargetSaturation != -1)
		Light.LightSaturation = startSaturation + (TargetSaturation - startSaturation) * alpha;
	if (TargetRadius != -1)
		Light.LightRadius = startRadius + (TargetRadius - startRadius) * alpha;

	return bFinished;
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
	DName				="Light Colour"
	Track				="Effects"
	Help				="Interpolates the light's colour and intensity"
	UsesDuration		=true

	Duration			=1
	EaseIn				=1
	EaseOut				=1
	TargetBrightness	=-1
	TargetHue			=-1
	TargetSaturation	=-1
	TargetRadius		=-1
}