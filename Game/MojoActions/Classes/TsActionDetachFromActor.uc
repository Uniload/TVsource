class TsActionDetachFromActor extends TsAction;

var(Action)		MojoActorRef		Target;

function bool OnStart()
{
	Target = ResolveActorRef(Target);
	if (Target.actor == None)
		Log("TsActionDetachFromActor, Failed to find target actor "$Target.name);

	Target.Actor.SetBase(None);

	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Detach From Actor"
	Track			="Effects"
	Help			="Detach an actor that was previously attached to this actor."
}

