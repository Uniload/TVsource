class ActionReturnCarryable extends Scripting.Action;

var() editcombotype(enumCarryableLabels) Name target;

// execute
latent function Variable execute()
{
	local MPCarryable c;

	Super.execute();

	ForEach parentScript.actorLabel(class'MPCarryable', c, target)
	{
		c.returnToHome();
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Force the carryable " $ propertyDisplayString('target') $ " to return";
}

event function enumCarryableLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local MPCarryable c;
	
	ForEach level.AllActors(class'MPCarryable', c)
	{
		if (c.label != '')
		{
			s[s.Length] = c.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Return Carryable"
	actionHelp			= "Forces the specified carryable to return to its home location"
	category			= "Actor"
}