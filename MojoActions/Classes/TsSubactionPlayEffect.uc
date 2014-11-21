class TsSubactionPlayEffect extends TsAction;

var(Action) class<Engine.Emitter>	EffectClass;
var(Action)	Vector					RelativeLocation;
var(Action)	Rotator					RelativeRotation;
var(Action)	Name					AttachmentBone;
var(Action) float					Duration;

var transient Engine.Emitter		EffectActor;
var transient float					elapsed_duration;

function bool OnStart()
{
	local Engine.Pawn P;
/*	local int i;
	local int size;
	local float lifetime;
	local Engine.ParticleEmitter PE;
	local array<Engine.ParticleEmitter> ARR;*/

	EffectActor = Actor.Spawn(EffectClass);

	if (EffectActor == None)
	{
		LOG("TsSubactionPlayEffect, could not spawn effect of class "$EffectClass);
		return false;
	}

	if (AttachmentBone != '')
	{
		P = Engine.Pawn(Actor);
		if (P == None)
		{
			Log("TsSubactionPlayEffect, actor requesting bone attachment is not a pawn, "$Actor.Name);
			return false;
		}

		P.AttachToBone(EffectActor, AttachmentBone);
	}
	else
	{
		EffectActor.SetLocation(Actor.Location);
		EffectActor.SetBase(Actor);
	}

	EffectActor.SetRelativeLocation(RelativeLocation);
	EffectActor.SetRelativeRotation(RelativeRotation);

	elapsed_duration = 0;

/*	if (Duration == 0)
	{
		size = EffectActor.Emitters.Length;
		for (i=0; i<size; i++)
		{
			ARR = EffectActor.Emitters;
			ARR(i).Trigger();
			lifetime = PE.LifetimeRange.Max;
			if (Duration < lifetime)
				Duration = lifetime;
		}
	}*/

	return true;	
}

function bool OnTick(float Delta)
{
	elapsed_duration += Delta;

	if (elapsed_duration >= Duration)
	{
		EffectActor.Destroy();

		return false;
	}

	return true;
}

function bool CanSetDuration()
{
	return true;
}

event bool SetDuration(float _Duration)
{
	Duration = _Duration;
	return true;
}

event float GetDuration()
{
	return Duration;
}

function bool IsSubaction()
{
	return true;
}

defaultproperties
{
	DName			="Play Effect"
	Track			="Subaction"
	Help			="Subaction, spawn and attach an effect, and destroy it after the specified duration."
	UsesDuration	=true
	Duration		=0
}

