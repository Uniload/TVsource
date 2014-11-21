class ActionShowCredits extends Scripting.Action;

var() editcombotype(enumScriptLabels) Name target;

// execute
latent function Variable execute()
{
	local PlayerCharacterController controller;
	local GUIController gc;

	controller = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if( controller != None && 
		controller.Player != None &&
		controller.Player.GUIController != None)
	{
		gc = GUIController(controller.Player.GUIController);
		gc.openMenu("TribesGui.TribesCreditsMenu", "TribesCreditsMenu");
	}

	return None;
}

// editorDisplayString
function editorDisplayString(out string s)
{
	s = "Show the game credits";
}

defaultproperties
{
	returnType			= None
	actionDisplayName	= "Show Game Credits"
	actionHelp			= "Opens a menu that shows the game credits"
	category			= "UI"
}