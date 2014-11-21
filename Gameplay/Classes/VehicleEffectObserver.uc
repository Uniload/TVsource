class VehicleEffectObserver extends Core.DeleteableObject implements IEffectObserver
	native;

var Emitter			emitter;
var SoundInstance	sound;		// rowan: we need to cleanup our sound instance properly
var float originalParticlesPerSecond;

function cleanup()
{
	// remove us from sound observer, or else it will crash when de-reffing us
	if (sound != None)
		sound.SetObserver(None);
}

function OnEffectStarted(Actor inStartedEffect)
{
	// if already bound to sound, unbind (or else we might fail to unbind properly in Cleanup)
	if (sound != None)
		sound.SetObserver(None);

	emitter = Emitter(inStartedEffect);
	sound = SoundInstance(inStartedEffect);
	if (emitter != None)
		originalParticlesPerSecond = emitter.emitters[0].ParticlesPerSecond;
}

function OnEffectStopped(Actor inStoppedEffect, bool Completed)
{
	sound = None;
}

function OnEffectInitialized(Actor inInitializedEffect)
{
}

defaultproperties
{
}
