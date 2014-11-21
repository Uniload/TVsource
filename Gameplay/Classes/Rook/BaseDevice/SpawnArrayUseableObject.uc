class SpawnArrayUseableObject extends BaseDeviceAccess;

//
// Called to check if the UseableObject can be used
// by a specific actor.
//
function bool CanBeUsedBy(Pawn user)
{
	if(user.IsA('Character'))
	{
		if (user.FastTrace(user.Location, Owner.Location))
			return SpawnArray(Owner).team() != None && SpawnArray(Owner).isFriendly(Character(user)) && SpawnArray(Owner).isFunctional();
	}

	return false;
}

function UsedBy(Pawn user)
{
	super.UsedBy(user);

	if (!CanBeUsedBy(user))
		return;

	SpawnArray(Owner).use(user);
}

defaultproperties
{
	prompt = "Press '%1' to access the Spawn Array"
	markerOffset = (X=0,Y=0,Z=20)
}