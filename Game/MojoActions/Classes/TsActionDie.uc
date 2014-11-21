class TsActionDie extends TsPawnAction;

function bool OnStart()
{
	Log("KARL: Currently Broken");
//	Pawn.Level.Game.Killed(None, Pawn.Controller, Pawn, class'Crushed');
	Pawn.GotoState('Dying');
	Pawn.Health = 0;

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

defaultproperties
{
	DName			="Die"
	Track			="State"
	Help			="Forces a pawn to die."
}