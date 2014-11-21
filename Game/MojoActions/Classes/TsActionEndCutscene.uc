class TsActionEndCutscene extends TsAction;

event bool EndCutscene()
{
	return true;
}

defaultproperties
{
	DName			="End Cutscene"
	Track			="State"
	Help			="Force this cutscene to end"
}
