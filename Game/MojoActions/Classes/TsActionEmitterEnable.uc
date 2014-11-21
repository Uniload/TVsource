class TsActionEmitterEnable extends TsAction;

var(Action) bool enable;

function bool OnStart()
{
	local Engine.Emitter psys;
	
	psys = Engine.Emitter(Actor);
	if (psys == None)
	{
		Log("Error: TsActionEmitterEnable attached to non emitter actor "$Actor.Name);
		return false;
	}

	if (enable)
	{
		psys.PlayEmitters();
	}
	else
	{
		psys.StopEmitters(true);
	}

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

event bool CanBeUsedWith(Actor actor)
{
	// only work on emitters
	return Engine.Emitter(actor) != None;
}

defaultproperties
{
	DName			="Enable Emitter"
	Track			="Particles"
	Help			="Enable/Disable the emitters of a particle system"

	enable = true
}