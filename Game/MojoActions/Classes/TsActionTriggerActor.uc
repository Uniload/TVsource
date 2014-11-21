class TsActionTriggerActor extends TsAction;

function bool OnStart()
{
	actor.trigger(actor, None);
	return true;
}

function bool OnTick(float delta)
{
	return false;
}

function OnFinish()
{

}

defaultproperties
{
	DName			="Trigger Actor"
	Track			="State"
	Help			="Trigger a particular actor."
}