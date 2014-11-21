class VehicleEntry extends UseableObject
	notplaceable;

var float EntryTriggerDelay;
var	float TriggerTime;

var private Vehicle.VehiclePositionType primaryPosition;
var private int primaryPositionIndex;
var array<Vehicle.VehiclePositionType> secondaryPositions;

var private Vehicle ownerVehicle;

function InventoryStationAccess getCorrespondingInventoryStation()
{
	if (ownerVehicle.isInventoryPosition(primaryPosition))
		return ownerVehicle.getUnusedInventoryStation();
	return None;
}

function initialiseVehicleEntry(Vehicle.VehiclePositionType _primaryPosition, Vehicle _ownerVehicle)
{
	ownerVehicle = _ownerVehicle;
	primaryPosition = _primaryPosition;
	primaryPositionIndex = ownerVehicle.getPositionIndex(primaryPosition);
}

function Vehicle.VehiclePositionType getPrimaryPosition()
{
	return primaryPosition;
}

simulated function Touch(Actor Other)
{
	// copied from BulldogTrigger

	local Pawn user;

	// Paul: added super.Touch() for UseableObject triggers.
	super.Touch(Other);

	if (Other.Instigator != None)
	{
		user = Pawn(Other);

		if (user == None)
			return;

		if (EntryTriggerDelay > 0 )
		{
			if (Level.TimeSeconds - TriggerTime < EntryTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		// send a string message to the toucher
		
	}
}

function UsedBy(Pawn user)
{
	local Character characterUser;

	if (bDeleteMe || !ownerVehicle.isAlive())
		return;

	characterUser = Character(user);
	if (characterUser == None)
		return;

	if (ownerVehicle.tryToOccupy(characterUser, primaryPosition, secondaryPositions) >= 0)
		super.UsedBy(user);
}

//
// TBD: Can't use an entry point if it is already full. Not quite sure
// how to handle this, because it looks like an attempt will be made to
// go for the secondary position if this one is taken. Also, the prompt
// should probably reflect what you are REALLY going to do if you press 
// Use on this entry point. Another problem: the entries in the vehicle
// are not client side, so calling this function will require a client to
// server replicated call in vehicle... Alex?
//
simulated function bool CanBeUsedBy(Pawn User)
{
	local byte dummy;
	return ownerVehicle.canOccupy(Character(user), primaryPosition, secondaryPositions, dummy) != -1;
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
	local byte promptIndex;

	if (bDeleteMe)
	{
		warn("attempting to get prompt index on a deleted vehicle entry");
		return 255;
	}

	ownerVehicle.canOccupy(PotentialUser, primaryPosition, secondaryPositions, promptIndex);

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
	EntryTriggerDelay=0.1
	bOnlyAffectPawns=true
	RemoteRole=ROLE_None
	bAlwaysUse=true
}