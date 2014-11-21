class TsActionShowActor extends TsAction;

function bool OnStart()
{
	Actor.bHidden = false;

	return true;	
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Show Actor"
	Track			="Effects"
	Help			="Makes a hidden actor visible."
}

