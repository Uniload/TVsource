class ActionResetRace extends Scripting.Action;

var() editcombotype(enumContainerLabels) Name target;

// execute
latent function Variable execute()
{
	local MPCheckpoint cp;

	Super.execute();

	ForEach parentScript.actorLabel(class'MPCheckpoint', cp, target)
	{
		cp.reset();
		cp.restartPlayer(PlayerCharacterController(parentScript.Level.GetLocalPlayerController()));
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Reset checkpoint " $ propertyDisplayString('target');
}

event function enumContainerLabels(Engine.LevelInfo level, out Array<Name> s)
{
	local MPCheckpoint cp;
	
	ForEach level.AllActors(class'MPCheckpoint', cp)
	{
		if (cp.label != '')
		{
			s[s.Length] = cp.label;
		}
	}
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Reset Checkpoint"
	actionHelp			= "Call this on any checkpoint to reset a race from this checkpoing until the end of the race.  Call it on the first checkpoint to reset the entire race."
	category			= "Actor"
}