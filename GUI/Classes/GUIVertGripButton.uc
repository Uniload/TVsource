// ====================================================================
//  Class:  GUI.GUIVertGripButton
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertGripButton extends GUIGFXButton
		Native;

var(GUIVertGripButton) config  Material	GripButtonImage "Image to use for a grip button";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
	Graphic = GripButtonImage;
}

defaultproperties
{
     GripButtonImage=Texture'GUITribes.BorderDull'
     Position=ICP_Bound
     StyleName="STY_VertGrip"
     OnClickSound=CS_None
}
