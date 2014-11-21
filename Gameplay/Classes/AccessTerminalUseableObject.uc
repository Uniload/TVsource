class AccessTerminalUseableObject extends UseableObject;

function UsedBy(Pawn user)
{
	if (AccessTerminal(Owner).used) return;

	super.UsedBy(user);
	AccessTerminal(Owner).useTerminal();
}

function bool CanBeUsedBy(Pawn user)
{
	if (AccessTerminal(Owner).used) 
		return false;

	return true;
}

defaultproperties
{
}
