class ActionResetContainer extends Scripting.Action;

var() editcombotype(enumContainerLabels) Name target;

// execute
latent function Variable execute()
{
	local MPCarryableContainer cc;

	Super.execute();

	ForEach parentScript.actorLabel(class'MPCarryableContainer', cc, target)
	{
		cc.reset();
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Reset container " $ propertyDisplayString('target');
}

event function enumContainerLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local MPCarryableContainer cc;
	
	ForEach level.AllActors(class'MPCarryableContainer', cc)
	{
		if (cc.label != '')
		{
			s[s.Length] = cc.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Reset Carryable Container"
	actionHelp			= "Allows a carryable container to be used again"
	category			= "Actor"
}