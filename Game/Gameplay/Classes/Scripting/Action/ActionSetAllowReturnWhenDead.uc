class ActionSetAllowReturnWhenDead extends Scripting.Action;

var() bool allow;

// execute
latent function Variable execute()
{
	local SinglePlayerGameInfo gi;

	Super.execute();

	gi = SinglePlayerGameInfo(parentScript.Level.Game);

	if (gi != None)
		gi.bAllowReturnToGameWhenDead = allow;
	else
		SLog("The set 'allow return when dead' action only works for single player games");

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	if (allow)
		s = "Allow 'Return To Game' when player is dead";
	else
		s = "Disallow 'Return To Game' when player is dead";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Set 'Return To Game' allowed when dead"
	actionHelp			= "Allow or disallow the escape menu's 'Return To Game' button when the player is dead"
	category			= "Level"
}