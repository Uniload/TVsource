class TsActionRotateTo extends TsPawnAction;

var(Action) MojoKeyframe target;

var transient TsMojoController MojoController;

function bool OnStart()
{
	local vector dummy;

	// get mojo controller
	MojoController = TsMojoController(Pawn.Controller);
	if (MojoController == None)
	{
		Log("TsMojoController OnStart failed");
		return false;
	}

	MojoController.BeginMoveToPoint(pawn.location, target.rotation, None, dummy, true, false);

	return true;
}

function bool OnTick(float delta)
{
	return !MojoController.FinishedState();
}

function OnFinish()
{
	Log("Finished Move To");
}

function float GetLength()
{
	return 3;
}

defaultproperties
{
	DName			="Rotate To"
	Track			="Position"
	Help			="Rotate to a particular key frame."
}