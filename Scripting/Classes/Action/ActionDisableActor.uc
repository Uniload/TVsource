class ActionDisableActor extends Scripting.Action;

var() editcombotype(enumScriptLabels) Name target;

// execute
latent function Variable execute()
{
	local Actor a;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', a, target)
	{
		if (a.IsA('BaseDevice'))
			SLog("WARNING: Disable Actor used on base device"@a.label@", use Set Base Device Power Switch instead");

		a.makeDormant( true );
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Disable " $ propertyDisplayString('target');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Disable Actor"
	actionHelp			= "Stops this actor from ticking, makes it invisible and unaffected by collisions"
	category			= "Actor"
}