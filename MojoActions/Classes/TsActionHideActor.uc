class TsActionHideActor extends TsAction;

function bool OnStart()
{
	Actor.bHidden = true;

	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Hide Actor"
	Track			="Effects"
	Help			="Makes a visible actor hidden."
}

