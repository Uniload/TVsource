class TsSubactionAttachToActor extends TsActionAttachToActor;

function bool IsSubaction()
{
	return true;
}

defaultproperties
{
	Track			="Subaction"
	Help			="Subaction, attach an actor to the owner of a track, i.e. particle systems."
}

