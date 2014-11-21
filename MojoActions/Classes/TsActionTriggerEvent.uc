class TsActionTriggerEvent extends TsAction;

var(Action) name Event;

function bool OnStart()
{
	actor.triggerEvent(Event, actor, None);
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
	DName			="Trigger Event"
	Track			="State"
	Help			="Trigger a particular event."
}