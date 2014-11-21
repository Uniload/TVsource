class TsSubactionDetachFromActor extends TsActionDetachFromActor;

function bool IsSubaction()
{
	return true;
}

defaultproperties
{
	Track			="Subaction"
	Help			="Subaction, detach an actor that was previously attached to this actor."
}

