// ====================================================================
//  Class:  GUI.GUIButton
//
//	GUIGFXButton - The basic button class.  It can be used for icon buttons
//  or Checkboxes
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

class GUIGFXButton extends GUIButton
        HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GUIGFXButton) config Material 		Graphic "The graphic to display";
var(GUIGFXButton) config eIconPosition	Position "How do we draw the Icon";
var(GUIGFXButton) config bool			bCheckBox "Is this a check box button (ie: supports 2 states)";
var(GUIGFXButton) config bool			bClientBound "Graphic is drawn using clientbounds if true";

var(DEBUG)		bool			bChecked;
var(DEBUG)		bool			bForceUpdate;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
}

event Show()
{
	bForceUpdate = false;
    Super.Show();
}

function SetChecked(bool bNewChecked)
{
	if (bCheckBox && (bChecked != bNewChecked || bForceUpdate) )
	{
		bChecked = bNewChecked;
		bForceUpdate = false;
		OnChange(Self);
	}
}

event Click()
{
	SetChecked( !bChecked );
	Super.Click();
}

cpptext
{
		void Draw(UCanvas* Canvas);

}


defaultproperties
{
     bTabStop=False
}
