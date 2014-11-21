class TsSubactionShowActor extends TsAction;

var(Action)		MojoActorRef		Target;

function bool OnStart()
{
	if (Target.Actor == None)
		Actor.bHidden = false;
	else
		Target.Actor.bHidden = false;

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
	DName			="Show Actor"
	Track			="Subaction"
	Help			="Subaction, makes the actor specified in 'Target' visible. If 'Target' is None, the owner of the action is made visible."
}

