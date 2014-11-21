class TsSubactionPlayLIPSinc extends TsActionPlayLIPSinc;

function bool IsSubaction()
{
	return true;
}

defaultproperties
{
	Track			="Subaction"
	Help			="Subaction, run a particular LIPSinc animation"
}