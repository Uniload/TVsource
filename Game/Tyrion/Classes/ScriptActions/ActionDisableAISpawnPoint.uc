class ActionDisableAISpawnPoint extends Scripting.Action;

var() Name AISpawnPointLabel;

// execute
latent function Variable execute()
{
	local AISpawnPoint a;

	Super.execute();

	ForEach parentScript.actorLabel(class'AISpawnPoint', a, AISpawnPointLabel)
	{
		a.disableSpawning();
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Disable spawning from AI spawn point " $ propertyDisplayString('AISpawnPointLabel');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Disable AI spawn point"
	actionHelp			= "Stops an AI spawn point from spawning new AIs"
	category			= "AI"
}