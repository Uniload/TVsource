class ActionOpenDoor extends Scripting.Action;

var() editcombotype(enumDoorLabels) Name target;

// execute
latent function Variable execute()
{
	local Door d;

	Super.execute();

	ForEach parentScript.actorLabel(class'Door', d, target)
	{
		d.GotoState(d.GetStateName(), 'Open');
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Open door " $ propertyDisplayString('target');
}

event function enumDoorLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local Door d;
	
	ForEach level.AllActors(class'Door', d)
	{
		if (d.label != '')
		{
			s[s.Length] = d.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Open Door"
	actionHelp			= "Opens a door"
	category			= "Actor"
}