class TsSubactionFakeShoot extends TsActionFakeShoot;

function bool IsSubaction()
{
	return true;
}


defaultproperties
{
	Track			="Subaction"
	Help			="Subaction, spawn a faked projectile from the given bone"
}