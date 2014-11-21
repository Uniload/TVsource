// ====================================================================
//  Class:  GUI.GUIHorzGripButton
//  Parent: GUI.GUIGFXButton
//
//  <Enter a description here>
// ====================================================================

class GUIHorzGripButton extends GUIGFXButton
		Native;

var(GUIHorzGripButton) config  Material	GripButtonImage "Image to use for a grip button";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	Graphic = GripButtonImage;
}

defaultproperties
{
     Position=ICP_Bound
}
