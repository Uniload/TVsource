class TsActionSpawnEmitter extends TsAction;

var() MojoKeyframe		spawnLocation		"The location at which the emitter will appear (not necessary for attach to bone)";
var() bool				bUseRotation		"If false, the rotation value in 'spawnLocation' is ignored";
var() class<Emitter>	emitterType			"The type of emitter to spawn";
var() Name				bone				"Attach to the track owner's bone";
var() Vector			relativeLocation	"The relative location for the emitter when attaching to a bone";
var() Rotator			relativeRotation	"The relative rotation for the emitter when attaching to a bone";
var() float				duration			"Length of time before the emitter is destroyed (0 to ignore)";

var float				time;
var transient Actor		emitter;

function bool OnStart()
{
	// spawn emitter
	if (emitterType != None)
	{
		if (bUseRotation)
			emitter = Actor.spawn(emitterType,,,spawnLocation.position,spawnLocation.rotation);
		else
			emitter = Actor.spawn(emitterType,,,spawnLocation.position);
	}

	if (bone != '')
	{
		Actor.AttachToBone(emitter, bone);
		emitter.SetRelativeLocation(relativeLocation);
		emitter.SetRelativeRotation(relativeRotation);
	}

	time = 0;

	return true;
}

function bool OnTick(float delta)
{
	if (duration == 0 || emitter == None)
		return false;

	time += delta;

	if (time >= duration)
	{
		if (!emitter.bDeleteMe)
		{
			emitter.Destroy();
			emitter = None;
		}
		return false;
	}

	return true;
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
	DName			="Spawn Emitter"
	Track			="Particles"
	Help			="Spawn an emitter at the given location"
	UsesDuration	=true
}