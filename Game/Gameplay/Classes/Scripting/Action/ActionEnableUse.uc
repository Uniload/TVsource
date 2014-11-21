class ActionEnableUse extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerCharacterController target;

	Super.execute();

	target = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if (target != None)
		target.bUseEnabled = true;

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Allows player to execute the 'use' function.";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Enable Use"
	actionHelp			= "Allows player to execute the 'use' function."
	category			= "Actor"
}