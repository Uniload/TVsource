/*=============================================================================
	In Game GUI Editor System V1.0
	2003 - Irrational Games, LLC.
	* Dan Kaplan
=============================================================================*/
#if !IG_GUI_LAYOUT
#error This code requires IG_GUI_LAYOUT to be defined due to extensive revisions of the origional code. [DKaplan]
#endif
/*===========================================================================*/

class GUIProgressBar extends GUIComponent
        HideCategories(Menu,Object)
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(GUIProgressBar) config  Material	        BarMaterial "The material of the filled portion of the bar";
var(GUIProgressBar) config  Color		        BarColor "The Color of the filled portion of the bar";
var(GUIProgressBar) config  EMenuRenderStyle	BarRenderStyle "How should we display this image";
var(GUIProgressBar) config  float		        Value "The current percent filled value (clamped 0-1)";
var(GUIProgressBar) config  eProgressDirection  BarDirection "The direction to fill the bar";

cpptext
{
	void Draw(UCanvas* Canvas);

}


defaultproperties
{
     BarMaterial=Texture'GUITribes.BorderBasic'
     BarColor=(G=203,R=255,A=255)
     BarRenderStyle=MSTY_Alpha
     StyleName="STY_ProgressBar"
}
