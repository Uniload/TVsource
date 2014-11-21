class ActionSpawnRook extends Scripting.Action;

var() actionnoresolve class<Rook> spawnClass;
var() name rookLabel;
var() name teamLabel;
var() name squadLabel;
var() actionnoresolve vector rookLocation "Used as the spawn location if locationByActor is empty";
var() actionnoresolve rotator rookRotation "Used as the spawn rotation if locationByActor is empty";
var() name locationByActor "Spawn at the location and with the rotation of the specified actor";
var() float spawnInterval;
var() int maxSpawnAttempts;

// execute
latent function Variable execute()
{
	local VariableBool result;
	local Actor locationActor;
	local Vector location;
	local Rotator rotation;
	local Rook newRook;
	local TeamInfo rooksTeam;
	local SquadInfo rooksSquad;
	local int spawnAttempts;

	super.execute();

	result = VariableBool(newTemporaryVariable(class'VariableBool', "false"));

	// Determine spawn location
	if (locationByActor != '')
	{
		locationActor = findStaticByLabel(class'Actor', locationByActor);

		if (locationActor != None)
		{
			location = locationActor.Location;
			rotation = locationActor.Rotation;
		}
		else
		{
			SLog("Failed to find actor " $ locationByActor);
			return result;
		}
	}
	else
	{
		location = rookLocation;
		rotation = rookRotation;
	}

	for (spawnAttempts = 0; spawnAttempts < maxSpawnAttempts; ++spawnAttempts)
	{
		newRook = parentScript.Spawn(spawnClass,,, location, rotation);

		if (newRook != None)
			break;

		Sleep(spawnInterval);
	}

	if (newRook == None)
	{
		logError("Failed to spawn a new " $ spawnClass.name);
		return result;
	}

	if (rookLabel != '')
		newRook.label = rookLabel;

	if (teamLabel != '')
	{
		rooksTeam = TeamInfo(findByLabel(class'TeamInfo', teamLabel));

		if (rooksTeam != None)
			newRook.setTeam(rooksTeam);
		else
			SLog("Couldn't find team " $ teamLabel);
	}

	if (squadLabel != '')
	{
		rooksSquad = SquadInfo(findByLabel(class'SquadInfo', squadLabel));

		if (rooksSquad != None)
			newRook.setSquad(rooksSquad);
		else
			SLog("Couldn't find squad " $ squadLabel);
	}

	result.value = true;

	return result;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Spawn ";

	if (spawnClass != None)
	{
		s = s $ spawnClass.name $ " at ";

		if (locationByActor != '')
			s = s $ propertyDisplayString('locationByActor');
		else
			s = s $ "(" $ rookLocation.x $ "," $ rookLocation.y $ "," $ rookLocation.z $ ")";

		if (teamLabel != '')
			s = s $ ", on team " $ propertyDisplayString('teamLabel');

		if (squadLabel != '')
			s = s $ ", in squad " $ propertyDisplayString('squadLabel');
	}
	else
		s = s $ "None";
}

defaultproperties
{
	spawnInterval		= 0.0
	maxSpawnAttempts	= 1

	returnType			= class'Variable'
	actionDisplayName	= "Spawn Rook"
	actionHelp			= "Spawn an actor derived from Rook."
	category			= "Actor"
}