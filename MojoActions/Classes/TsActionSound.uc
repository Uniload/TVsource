class TsActionSound extends TsAction;

var()		Engine.sound		Sound;
var()		float				Volume;
var()		float				Pitch;
var()		float				Radius;
var()		float				cutoffTime;
var()		bool				bLooping;

var transient float elapsedTime;
var transient float duration;
var Engine.Pawn PlayerPawn;

function bool OnStart()
{
	local bool bAttenuate;
	local PlayerController C;
	C = Actor.Level.GetLocalPlayerController();
	if (C != None)
		PlayerPawn = C.Pawn;

	bAttenuate = Controller(Actor) == None;

	if (Sound != None)
	{
		duration = Actor.GetSoundDuration(Sound);
		if (!bLooping)
			Actor.PlaySound(Sound, Volume, false, 0, Radius, Pitch, 0, 0, bAttenuate);
		else
			Actor.PlayLoopedSound(Sound, Volume, false, 0, Radius, Pitch, 0, bAttenuate);
	}
	else
	{
		duration = 0;
	}

	elapsedTime = 0;

	return true;	
}

event Interrupt()
{
	Actor.InterruptSound(Sound);
}

event Pause()
{
	Actor.PauseSound(Sound);
}

event Resume()
{
	Actor.ResumeSound(Sound);
}

function bool OnTick(float delta)
{
	elapsedTime += delta;
	
	if ((cutoffTime != 0) && (elapsedTime > cutoffTime))
	{
		Actor.InterruptSound(Sound);
		return false;
	}
	else if (!bLooping && elapsedTime > duration)
	{
		Actor.InterruptSound(Sound);
		return false;
	}
	else
	{
		return true;
	}
}


function bool CanGenerateOutputKeys()
{
	return false;
}


defaultproperties
{
	DName			="Play Sound"
	Track			="Sound"
	Help			="Play a sound at the location of the object."

	Volume			=+1.0
	Pitch			=+1.0
	Radius			=+800.0

	FastForwardSkip = true
	
	cutoffTime		=0
}

