///////////////////////////////////////////////////////////////////////////////
//
// Emergency Station Access point
//
class EmergencyStationAccess extends UseableObject;

var() localized String AlreadyHavePackPrompt;

var private EmergencyStation emergencyStation;

function initialise(EmergencyStation station)
{
	emergencyStation = station;
}

//
// Called to check if the UseableObject can be used
// by a specific actor.
//
function bool CanBeUsedBy(Pawn user)
{
	local RepairPack repairPack;

	if(user.IsA('Character') && emergencyStation.isOnCharactersTeam(Character(user)) && emergencyStation.isRepairPackAvailable())
	{
		repairPack = RepairPack(Character(user).nextEquipment(None, class'Pack'));
		if(repairPack == None)
			return true;
	}

	return false;
}

function byte GetPromptIndex(Character PotentialUser)
{
	local RepairPack repairPack;

	if(CanBeUsedBy(PotentialUser))
		return 0;		// standard use message
	else
	{
		repairPack = RepairPack(PotentialUser.nextEquipment(None, class'Pack'));
		if(repairPack != None)
			return 1;	// "already have pack" message
	}

	return 255;
}

// returns a prompt string based on the prompt index
static function string GetPrompt(byte PromptIndex, class<Actor> dataClass)
{
	switch(promptIndex)
	{
	case 0:
		return default.prompt;
	case 1:
		return default.AlreadyHavePackPrompt;
	}

	return "";
}

// Called on server when user presses use key in vicinity of emergency station.
function UsedBy(Pawn user)
{
	local Character characterUser;
	local Pack pack;
	local Vector DropLocation, xAxis, zAxis;

	characterUser = Character(user);

	// do nothing if used by non-character
	if(characterUser == None)
		return;

	// if an enemy do nothing
	if(! emergencyStation.isOnCharactersTeam(characterUser))
	{
		log("Attempted To Use Enemy Emergency Station");
		return;
	}

	//
	// Give the user an emergency repair pack. We need to force them to drop
	// an existing pack if they have no space for one
	//
	pack = Pack(characterUser.nextEquipment(None, class'Pack'));
	if(pack != None)
	{
		if(pack.IsA('RepairPack'))
			return;
		else
		{
			emergencyStation.GetAxes(rotation, xAxis, DropLocation, zAxis);
			DropLocation *= 260;
			DropLocation += emergencyStation.Location;
			pack.GotoState('Dropped');
			pack.Move(DropLocation - pack.Location);
			characterUser.removeEquipment(pack);
		}
	}
	//
	// Let emergency station know.
	//
	emergencyStation.repairPackTaken();

	if(emergencyStation.repairPackClass != None)
	{
		characterUser.newPack(emergencyStation.repairPackClass);
		characterUser.pack.setCharged();
	}
	else
		log("WARNING: Repair pack class is none for "$emergencyStation);

	// we do the super.usedby last so that the useable indicator will update properly
	super.UsedBy(user);
}

defaultproperties
{
	RemoteRole = ROLE_None

	prompt = "Press '%1' to use the Emergency Station"
	AlreadyHavePackPrompt = "You already have a Repair Pack"
	markerOffset = (X=0,Y=-40,Z=0)
}