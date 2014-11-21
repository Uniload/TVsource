class ActionEnableActor extends Scripting.Action;

var() editcombotype(enumScriptLabels) Name target;

// execute
latent function Variable execute()
{
	local Actor a;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		if (a.IsA('BaseDevice'))
			SLog("WARNING: Enable Actor used on base device"@a.label@", use Set Base Device Power Switch instead");

		a.makeDormant( false );
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Enable " $ propertyDisplayString('target');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enable Actor"
	actionHelp			= "Returns a disabled actor to its normal (default) state"
	category			= "Actor"
}