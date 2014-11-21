class ActionTeleport extends Scripting.Action;

var() editcombotype(enumScriptLabels) Name target;
var() actionnoresolve vector teleportLocation "Used as the teleport location if locationByActor is empty";
var() editcombotype(enumScriptLabels) Name locationByActor "Teleport to the location/rotation of the specified actor";
var() bool bAffectRotation "If true then the teleporting actor takes on the rotation of the target actor/teleportRotator, otherwise its rotation remains the same";
var() actionnoresolve rotator teleportRotation "Used as the teleport location if locationByActor is empty";

// execute
latent function Variable execute()
{
	local Actor locationActor;
	local Vector location;
	local Rotator rotation;
	local Actor a;

	Super.execute();

	if (locationByActor != '')
	{
		locationActor = findStaticByLabel(class'Actor', locationByActor);

		if (locationActor != None)
		{
			rotation = locationActor.Rotation;
			location = locationActor.Location;
		}
		else
		{
			logError("Failed to find location actor " $ locationByActor);
			return None;
		}
	}
	else
	{
		location = teleportLocation;
		rotation = teleportRotation;
	}

	a = findByLabel(class'Actor', target);

	if (a != None)
	{
		a.unifiedSetPosition(location);
		a.unifiedSetVelocity(vect(0,0,0));
		if (bAffectRotation)
		{
			a.unifiedSetRotation(rotation);
			if (Pawn(a).Controller != None)
				Pawn(a).Controller.SetRotation(rotation);
		}
    }
	else
		logError("Failed to find actor " $ target);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	if (locationByActor != '')
		s = "Teleport " $ propertyDisplayString('target') $ " to '" $ locationByActor $ "'";
	else
		s = "Teleport " $ propertyDisplayString('target') $ " to (" $ teleportLocation $ ")";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Teleport Actor"
	actionHelp			= "Moves an actor to an abitrary location"
	category			= "Actor"
	bAffectRotation		= false
}