// ====================================================================
//  Class:  GUI.GUIHelpText
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

class GUIHelpText extends GUILabel
    HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GUIHelpText) config		float	XOverlapPercent "The percentage of the ActiveControl to overlap by this label";
var(GUIHelpText) config		float	YOverlapPercent "The percentage of the ActiveControl to overlap by this label";
var(GUIHelpText) config		float	XBorderPercent "The percentage of border around the text (typically in the range 1.0 - 1.5)";
var(GUIHelpText) config		float	YBorderPercent "The percentage of border around the text (typically in the range 1.0 - 1.5)";
var(GUIHelpText) config		float	MaxWidth "The maximum width of the label, if exceded, will word wrap";

function InitComponent(GUIComponent Owner)
{
    Super.InitComponent(Owner);
}

cpptext
{
		void PreDraw(UCanvas* Canvas);
	void UpdateComponent(UCanvas* Canvas);

}


defaultproperties
{
     XOverlapPercent=0.200000
     YOverlapPercent=0.200000
     XBorderPercent=1.100000
     YBorderPercent=1.200000
     MaxWidth=160.000000
     TextAlign=TXTA_Center
}
