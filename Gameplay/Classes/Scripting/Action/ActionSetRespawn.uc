class ActionSetRespawn extends Scripting.Action;

var() bool allowRespawning;

// execute
latent function Variable execute()
{
	local SinglePlayerGameInfo gi;

	Super.execute();

	gi = SinglePlayerGameInfo(parentScript.Level.Game);

	if (gi != None)
		gi.setAllowRespawn(allowRespawning);
	else
		SLog("The set respawn action only works for single player games");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Turn respawning on or off";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set Respawn"
	actionHelp			= "Allow or disallow respawning when the player dies"
	category			= "Level"
}