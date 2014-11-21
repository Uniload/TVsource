class ActionDisableAllScripts extends Scripting.Action;

var() bool bDisableParent	"If false then disables all scripts except the script in which this action is running";

// execute
latent function Variable execute()
{
	local Script a;

	Super.execute();

	ForEach parentScript.DynamicActors(class'Script', a)
	{
		if (!bDisableParent && a == parentScript)
			continue;

		a.exit();
		a.enabled = false;
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Disable all scripts";
	if (bDisableParent)
		s = s $ " (except this one)";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Disable All Scripts"
	actionHelp			= "Aborts any currently running scripts and sets all scripts disabled. Useful to call on mission failure or player death."
	category			= "Script"
}