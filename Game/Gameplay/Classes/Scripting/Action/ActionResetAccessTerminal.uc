class ActionResetAccessTerminal extends Scripting.Action;

var() editcombotype(enumAccessTerminalLabels) Name target;

// execute
latent function Variable execute()
{
	local AccessTerminal at;

	Super.execute();

	ForEach parentScript.actorLabel(class'AccessTerminal', at, target)
	{
		at.resetTerminal();
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Reset access terminal " $ propertyDisplayString('target');
}

event function enumAccessTerminalLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local AccessTerminal at;
	
	ForEach level.AllActors(class'AccessTerminal', at)
	{
		if (at.label != '')
		{
			s[s.Length] = at.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Reset Access Terminal"
	actionHelp			= "Allows an access terminal to be used again"
	category			= "Actor"
}