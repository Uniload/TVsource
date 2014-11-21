class VehicleFlipTrigger extends UseableObject
	notplaceable;

var byte promptIndex;

var Vehicle ownerVehicle;

function UsedBy(Pawn user)
{
	local Character characterUser;

	characterUser = Character(user);
	if (characterUser == None)
		return;

	if (Vehicle(owner).flip())
		super.UsedBy(user);
}

// Paul: Can't 'use' the flip trigger if the vehicle
// is not flipped
simulated function bool CanBeUsedBy(Pawn User)
{
	if(Vehicle(Owner).bSettledUpsideDown)
		return true;

	return false;
}

static function string getPrompt(byte PromptIndex, class<Actor> dataClass)
{
	local class<Vehicle> VehicleClass;

	if (PromptIndex == 255)
		return super.getPrompt(PromptIndex, dataClass);

	VehicleClass = class<Vehicle>(dataClass);
	if (VehicleClass != None)
		return VehicleClass.static.getPrompt(PromptIndex);

	return "";
}

function byte GetPromptIndex(Character PotentialUser)
{
	if (!Vehicle(Owner).bSettledUpsideDown)
		return 255;

	return promptIndex;
}

function class<Actor> GetPromptDataClass()
{
	return ownerVehicle.class;
}

defaultproperties
{
     bAlwaysUse=True
     bDoNotPromptWhenNotUseable=True
     bOnlyAffectPawns=True
     RemoteRole=ROLE_None
     bHardAttach=True
     CollisionRadius=80.000000
     CollisionHeight=400.000000
     bCollideActors=False
}
