class TsActionShakeActor extends TsAction;

var() Vector amplitude;
var() Vector frequency;
var() float easeIn;
var() float easeOut;
var() float duration;

var transient Vector baseLocation;


function bool OnStart()
{
	resetInterpolation(easeIn, duration, easeOut);

	baseLocation = Actor.Location;

	return true;
}

function bool OnTick(float delta)
{
	local float alpha;
	local float pingPongAlpha;
	local Vector offset;
	local bool bFinished;

	bFinished = tickInterpolation(delta, alpha);

	// calculate new offset
	offset.X = Sin(interpTime * frequency.X);
	offset.Y = Sin(interpTime * frequency.Y);
	offset.Z = Sin(interpTime * frequency.Z);

	if (alpha >= 0.5)
		pingPongAlpha = 1 - ((alpha - 0.5) * 2);
	else
		pingPongAlpha = alpha * 2;

	offset *= amplitude * pingPongAlpha;

	Actor.SetLocation(baseLocation + offset);

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
	DName			="Shake Actor"
	Track			="Position"
	Help			="Shakes an actor."
	ModifiesLocation = true
	UsesDuration	=true

  	easeIn			=1
  	duration		=3
  	easeOut			=1
  	frequency		=(X=100,Y=100,Z=100)
  	amplitude		=(X=100,Y=100,Z=100)
}