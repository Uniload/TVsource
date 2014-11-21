class TsActionGameSpeed extends TsAction;

var(Action) float gameSpeed;
var(Action) float duration;
var(Action) float easeIn;
var(Action) float easeOut;

var float baseGameSpeed;
var float clampedGameSpeed;

function bool OnStart()
{
	resetInterpolation(easeIn, duration, easeOut);

	baseGameSpeed = actor.Level.TimeDilation;
	clampedGameSpeed = FMax(gameSpeed, 0.1); // warfares code does this, so i guess we should too

	return true;
}

function bool OnTick(float delta)
{
	local float alpha;
	local bool bFinished;

	bFinished = tickInterpolation(delta, alpha);

	actor.Level.TimeDilation = baseGameSpeed + alpha * (clampedGameSpeed - baseGameSpeed);

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
	DName			="Game Speed"
	Track			="Game Speed"
	Help			="Sets the current game speed."
	UsesDuration	=true

	gameSpeed	=1.0
	easeIn		=3.0
}