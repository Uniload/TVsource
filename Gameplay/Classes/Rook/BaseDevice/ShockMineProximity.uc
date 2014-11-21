class ShockMineProximity extends Engine.Actor;

function Touch(Actor Other)
{
	if (Owner == None || Role != ROLE_Authority)
		return;

	ShockMine(Owner).WithinProximity(Other);
}

defaultproperties
{
	DrawType = DT_None
}