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
	bHardAttach=True
	bHidden=True
	bCollideActors=false
	bStatic=false
	CollisionRadius=+0080.000000
	CollisionHeight=+0400.000000
	bCollideWhenPlacing=False
	bOnlyAffectPawns=true
	RemoteRole=ROLE_None
	bAlwaysUse=true
	bDoNotPromptWhenNotUseable=true
}