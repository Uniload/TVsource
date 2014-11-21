// Base class for all camera related actions
class TsCameraAction extends TsAction
	native abstract;

var transient Engine.PlayerController PC;

function bool Start()
{
	PC = Engine.PlayerController(Actor);
	if (PC == None)
	{
		Log("TsCameraAction unable to resolve PlayerController");
		return false;
	}

	return OnStart();
}

event bool CanBeUsedWith(Actor actor)
{
	return Engine.PlayerController(actor) != None;
}

defaultproperties
{
}
