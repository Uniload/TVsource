// Base class for all actions that require a light
class TsLightAction extends TsAction
	abstract;

var transient Engine.Light		Light;

// Event called when action begins
//	return false to end action
function bool Start()
{
	Light = Engine.Light(Actor);
	if (Light == None)
	{
		Log("TsLightAction unable to resolve Light");
		return false;
	}

	return OnStart();
}

event bool CanBeUsedWith(Actor actor)
{
	// only work on pawns
	return Engine.Light(actor) != None;
}