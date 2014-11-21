class ActionDisableUse extends Scripting.Action;

// execute
latent function Variable execute()
{
	local PlayerCharacterController target;

	Super.execute();

	target = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if (target != None)
		target.bUseEnabled = false;

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Prevents player from executing the 'use' function.";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Disable Use"
	actionHelp			= "Prevents player from executing the 'use' function."
	category			= "Actor"
}