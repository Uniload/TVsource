class ActionSpawnActor extends Action;

var() actionnoresolve class<Actor> spawnClass;
var() name actorLabel;
var() actionnoresolve vector actorLocation "Used as the spawn location if locationByActor is empty";
var() actionnoresolve rotator actorRotation "Used as the spawn rotation if locationByActor is empty";
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
	local int spawnAttempts;
	local Actor newActor;

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
		location = actorLocation;
		rotation = actorRotation;
	}

	for (spawnAttempts = 0; spawnAttempts < maxSpawnAttempts; ++spawnAttempts)
	{
		newActor = parentScript.Spawn(spawnClass,,, location, rotation);

		if (newActor != None)
			break;

		Sleep(spawnInterval);
	}

	if (newActor == None)
	{
		logError("Failed to spawn a new " $ spawnClass.name);
		return result;
	}

	if (actorLabel != '')
		newActor.label = actorLabel;

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
			s = s $ "(" $ actorLocation.x $ "," $ actorLocation.y $ "," $ actorLocation.z $ ")";
	}
	else
		s = s $ "None";
}

defaultproperties
{
	spawnInterval		= 0.0
	maxSpawnAttempts	= 1

	returnType			= class'Variable'
	actionDisplayName	= "Spawn Actor"
	actionHelp			= "Spawn an actor."
	category			= "Actor"
}