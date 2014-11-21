class SwitchStationUseableObject extends UseableObject;

function bool CanBeUsedBy(Pawn user)
{
	local Character CharacterUser;

	CharacterUser = Character(user);

	// can be used if the switched base does not have the same team as the user
	return (CharacterUser != None) && 
		   SwitchStation(Owner).ownerBase.team != CharacterUser.team();
}


function UsedBy(Pawn user)
{
	SwitchStation(Owner).useSwitch(user);
	super.UsedBy(user);
}