// ====================================================================
//  Class:  GUI.GUIGFXToggleButton
//
//	GUIGFXToggleButton - Extension of the GUIGFXButton which allow a button
//  to render pressed when it is selected.
//
//  Written by Paul Dennison
//  (c) 2003, Irrational Games Australia.  All Rights Reserved
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

class GUIToggleButton extends GUIButton
        HideCategories(Menu,Object)
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GFXToggleButton) config Material	Icon			"The graphic to display";
var(GFXToggleButton) config bool		bUserControlled	"Whether the toggle should occur on the click or not";

var bool bChecked;

// overridden to check that a change will
// actually be made
function SetChecked(bool bNewChecked)
{
	if(bNewChecked != bChecked)
	{
		bChecked = bNewChecked;
		OnChange(Self);
	}
}

event Click()
{
	Super.Click();
	if(bUserControlled)
		SetChecked(! bChecked);
}

cpptext
{
		void Draw(UCanvas* Canvas);

}


defaultproperties
{
}
