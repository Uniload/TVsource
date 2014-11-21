class TsActionCrouch extends TsPawnAction;

var(Action) bool crouch;

function bool OnStart()
{
	Log("Start Crouch");

	Pawn.ShouldCrouch(crouch);

	return true;
}

function bool OnTick(float delta)
{
	return false;
}

function OnFinish()
{
	Log("Finish Crouch");
}

event bool CanBeUsedWith(Actor actor)
{
	// DISABLE this action for the moment
	return false;
}

defaultproperties
{
	DName			="Crouch"
	Track			="Animation"
	Help			="Change character crouch state"
}