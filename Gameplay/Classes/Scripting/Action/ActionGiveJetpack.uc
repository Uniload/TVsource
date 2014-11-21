class ActionGiveJetpack extends Scripting.Action;

var() Name target;
var() actionnoresolve class<Jetpack> jetpackClass;

// execute
latent function Variable execute()
{
	local SingleplayerCharacter c;

	Super.execute();

	ForEach parentScript.actorLabel(class'SingleplayerCharacter', c, target)
	{
		c.giveJetpack(jetpackClass);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Give jetpack class " $ jetpackClass $ " to " $ propertyDisplayString('target');
}

defaultproperties
{
	actionDisplayName	= "Give Jetpack"
	actionHelp			= "Gives jetpack class to a single player character"
	category			= "Actor"
}