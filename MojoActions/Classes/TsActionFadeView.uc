class TsActionFadeView extends TsCameraAction;

var(Action) float FadeTime;
var(Action) color FadeColor;
var(Action) enum EFadeType
{
	FADE_TYPE_In,
	FADE_TYPE_Out,
} fade_type;

var transient float elapsedFadeTime;

function bool OnStart()
{
	local float alpha;

	elapsedFadeTime = 0;

	// set flash fog to target
	PC.FlashFog.X = float(FadeColor.R) / 255;
	PC.FlashFog.Y = float(FadeColor.G) / 255;
	PC.FlashFog.Z = float(FadeColor.B) / 255;

	if (fade_type == FADE_TYPE_In)
		alpha = 1;
	else
		alpha = 0;

	PC.FlashScale.X = alpha;
	PC.FlashScale.Y = alpha;
	PC.FlashScale.Z = alpha;

	return true;
}

function bool OnTick(float delta)
{
	local float alpha;

	if (FadeTime == 0)
		return false;

	// calculate alpha
	alpha = elapsedFadeTime / FadeTime;
	if (alpha > 1)
		alpha = 1;

	// set scale
	if (fade_type == FADE_TYPE_In)
	{
		PC.FlashScale.X = alpha;
		PC.FlashScale.Y = alpha;
		PC.FlashScale.Z = alpha;
	}
	else
	{
		PC.FlashScale.X = 1 - alpha;
		PC.FlashScale.Y = 1 - alpha;
		PC.FlashScale.Z = 1 - alpha;
	}

	// stop if necessary
	if (elapsedFadeTime > FadeTime)
	{
		return false;
	}

	elapsedFadeTime += delta;

	return true;
}

function OnFinish()
{
}

event bool SetDuration(float _duration)
{
	FadeTime = _duration;
	return true;
}

event float GetDuration()
{
	return FadeTime;
}

defaultproperties
{
	DName			="Fade View"
	Track			="Effects"
	Help			="Fade camera view"
	UsesDuration	=true

	FadeTime=+1
}