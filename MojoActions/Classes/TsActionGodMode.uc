class TsActionGodMode extends TsPawnAction;

var(Action) enum EGodMode
{
	GOD_MODE_On,
	GOD_MODE_Off
} godMode;

function bool OnStart()
{
	// confirm controller exists
	if (Pawn.Controller == None)
	{
		Log("Attempted to set god mode for pawn with no controller.");
		return true;
	}

	// set god mode state
	switch (godMode)
	{
	case GOD_MODE_On:
		Pawn.Controller.bGodMode = true;
		break;

	case GOD_MODE_Off:
		Pawn.Controller.bGodMode = false;
		break;
	}

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="God Mode"
	Track			="State"
	Help			="Sets the God Mode state of a pawn."

	godMode			=GOD_MODE_Off
}