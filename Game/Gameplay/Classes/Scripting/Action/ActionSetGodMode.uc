class ActionSetGodMode extends Scripting.Action;

var() editcombotype(enumRookLabels) Name target;
var() bool godMode;

// execute
latent function Variable execute()
{
	local Rook r;
	local Character character;
	local Vehicle vehicle;

	Super.execute();

	ForEach parentScript.actorLabel(class'Rook', r, target)
	{
		character = Character(r);
		if (character != None)
			character.bGodMode = godMode;
		else
		{
			vehicle = Vehicle(r);
			if (vehicle != None)
				vehicle.bGodMode = godMode;
		}
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Set "$propertyDisplayString('target')$"'s god mode flag.";
}

event function enumRookLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Rook r;
	
	ForEach level.AllActors(class'Rook', r)
	{
		if (r.label != '')
		{
			s[s.Length] = r.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set God Mode"
	actionHelp			= "Sets Rook's god mode flag. Only works on characters and vehicles."
	category			= "Actor"
}