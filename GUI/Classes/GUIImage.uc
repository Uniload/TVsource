// ====================================================================
//  Class:  GUI.GUIImage
//
//	GUIImage - A graphic image used by the menu system.  It encapsulates
//	Material.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUIImage extends GUIComponent
        HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GUIImage) config Material 			Image "The Material to Render";
var(GUIImage) config color				ImageColor "What color should we set";
var(GUIImage) config eImgStyle			ImageStyle "How should the image be displayed";
var(GUIImage) config EMenuRenderStyle	ImageRenderStyle "How should we display this image";
var(GUIImage) config eImgAlign			ImageAlign "If ISTY_Justified, how should image be aligned";
var(GUIImage) config int				X1,Y1,X2,Y2 "If set, it will pull a subimage from inside the image";

function InitComponent(GUIComponent Owner)
{
    Super.InitComponent(Owner);
}

cpptext
{
		void Draw(UCanvas* Canvas);

}


defaultproperties
{
     ImageColor=(B=255,G=255,R=255,A=255)
     ImageStyle=ISTY_Scaled
     ImageRenderStyle=MSTY_Alpha
     x1=-1
     y1=-1
     x2=-1
     y2=-1
     bAcceptsInput=False
     RenderWeight=0.100000
}
