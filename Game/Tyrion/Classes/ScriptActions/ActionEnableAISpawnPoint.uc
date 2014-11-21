class ActionEnableAISpawnPoint extends Scripting.Action;

var() Name AISpawnPointLabel;

// execute
latent function Variable execute()
{
	local AISpawnPoint a;

	Super.execute();

	ForEach parentScript.actorLabel(class'AISpawnPoint', a, AISpawnPointLabel)
	{
		a.enableSpawning();
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Enable spawning from AI spawn point " $ propertyDisplayString('AISpawnPointLabel');
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enable AI spawn point"
	actionHelp			= "Allows an AI spawn point to spawn new AIs"
	category			= "AI"
}