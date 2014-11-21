// Base class for all actions that require a pawn
class TsPawnAction extends TsAction
	abstract native;

var transient Engine.Pawn		Pawn;

// Event called when action begins
//	return false to end action
function bool Start()
{
	Pawn = Engine.Pawn(Actor);
	if (Pawn == None)
	{
		Log("TsPawnAction unable to resolve Pawn");
		return false;
	}

	return OnStart();
}

event bool CanBeUsedWith(Actor actor)
{
	// only work on pawns
	return Engine.Pawn(actor) != None;
}