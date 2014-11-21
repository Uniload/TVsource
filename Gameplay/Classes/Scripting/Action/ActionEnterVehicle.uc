class ActionEnterVehicle extends Scripting.Action
	dependson(Vehicle);

var() editcombotype(enumCharacterLabels) Name targetCharacter;
var() editcombotype(enumVehicleLabels) Name targetVehicle;
var() Vehicle.VehiclePositionType position;

event function enumCharacterLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Character c;
	
	ForEach level.AllActors(class'Character', c)
	{
		if (c.label != '')
		{
			s[s.Length] = c.label;
		}
	}
}

event function enumVehicleLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Vehicle v;

	ForEach level.AllActors(class'Vehicle', v)
	{
		if (v.label != '')
		{
			s[s.Length] = v.label;
		}
	}
}

// execute
latent function Variable execute()
{
	local Character c;
	local Vehicle v;
	local array<Vehicle.VehiclePositionType> secondaryPositions;

	Super.execute();

	ForEach parentScript.actorLabel(class'Character', c, targetCharacter)
		break;

	if (c == None)
		return None;

	ForEach parentScript.actorLabel(class'Vehicle', v, targetVehicle)
		break;

	if (v == None)
		return None;

	if (v.tryToOccupy(c, position, secondaryPositions) == -1)
		slog(c @ " failed to enter " @ v);

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = propertyDisplayString('targetCharacter') @ "enters" @ propertyDisplayString('targetVehicle');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enter Vehicle"
	category			= "Actor"
}