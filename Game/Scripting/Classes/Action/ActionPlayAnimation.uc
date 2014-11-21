class ActionPlayAnimation extends Action;

var() Name animName;
var() editcombotype(enumScriptLabels) Name actorLabel;

// execute
latent function Variable execute()
{
	local Actor actor;

	Super.execute();

	ForEach parentScript.actorLabel(class'Actor', actor, actorLabel)
	{
		if (actor.HasAnim(animName))
			actor.PlayScriptedAnim(animName);
		else
			logError(actor $ " doesn't have an animation called " $ animName);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Play animation " $ propertyDisplayString('animName') $ " on " $ propertyDisplayString('actorLabel');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Play Animation"
	actionHelp			= "Plays an animation"
	category			= "AudioVisual"
}