class Timer extends Actor;

// PROTECTED! users: please use Start() and Stop()
var float InitialTime;
var bool Looping;
var bool Running;

function StartTimer(float newTime, optional bool loop, optional bool reset)
{
	if (Running && !reset)
		return;

	InitialTime = newTime;
	Looping = loop;

	SetTimer(newTime, false);
	Running = true;

	StartTimerHook(newTime, loop, reset);
}
function StartTimerHook(float newTime, bool loop, bool reset);

function StopTimer()
{
	SetTimer(0, false);	//this is the Unreal Way (tm)... not what I'd suggest
	Running = false;
}

event Timer()
{
	StopTimer();

	TimerHook();
	TimerDelegate();

	if (Looping) StartTimer(InitialTime, true);
}
//for subclasses of Timer to react to Timer popping
function TimerHook();
//for users of a Timer to receive notification of a Timer popping
delegate TimerDelegate()
{
    assertWithDescription(false,
        name$"'s time expired, but nobody is interested. (delegate is unassigned)");
}

defaultproperties
{
     bHidden=True
}
