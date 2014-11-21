class ActionInventoryBase extends Scripting.Action
	abstract;

function TribesInventorySelectionMenu GetInventoryMenu()
{
	local PlayerCharacterController controller;
	local GUIController gc;

	controller = PlayerCharacterController(parentScript.Level.GetLocalPlayerController());
	if( controller != None && 
		controller.Player != None &&
		controller.Player.GUIController != None)
	{
		gc = GUIController(controller.Player.GUIController);
		if(gc != None && gc.ActivePage != None && gc.ActivePage.IsA('TribesInventorySelectionMenu'))
			return TribesInventorySelectionMenu(gc.ActivePage);
	}

	return None;
}