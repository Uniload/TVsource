class ActionPlaySound extends Action;

const SF_No3D = 16;

var() actionnoresolve Sound soundToPlay;
var() editcombotype(enumScriptLabels) Name actorLabel;
var() float volume;
var() float radius;
var() bool attenuate;

// execute
latent function Variable execute()
{
	local Actor actor;
	local int flags;

	Super.execute();

	if (!attenuate)
		flags = SF_No3D;

	ForEach parentScript.staticActorLabel(class'Actor', actor, actorLabel)
	{
		actor.PlaySound(soundToPlay, volume, , 0.0, radius, , flags, , , radius);
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Play sound " $ soundToPlay.Name $ " on " $ propertyDisplayString('actorLabel');
}

defaultproperties
{
	volume				= 1.0
	radius				= 1000.0
	attenuate			= true

	returnType			= None
	actionDisplayName	= "Play Sound"
	actionHelp			= "Plays a sound on an actor"
	category			= "AudioVisual"
}