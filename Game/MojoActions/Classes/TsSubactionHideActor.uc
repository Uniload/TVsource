class TsSubactionHideActor extends TsAction;

var(Action)		MojoActorRef		Target;

function bool OnStart()
{
	Target = ResolveActorRef(Target);
	if (Target.Actor == None)
		Actor.bHidden = true;
	else
		Target.Actor.bHidden = true;

	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

function bool IsSubaction()
{
	return true;
}

defaultproperties
{
	DName			="Hide Actor"
	Track			="Subaction"
	Help			="Subaction, hides the actor specified in 'Target'. If 'Target' is None, the owner of the action is hidden."
}

