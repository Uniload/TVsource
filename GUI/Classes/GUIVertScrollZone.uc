// ====================================================================
//  Class:  GUI.GUIVertScrollZone
//
//  The VertScrollZone is the background zone for a vertical scrollbar.
//  When the user clicks on the zone, it caculates it's percentage.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertScrollZone extends GUIComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);
}

event Click()
{
	local float perc;

	Super.Click();

	if (!IsInBounds())
		return;

	perc = ( Controller.MouseY - ActualTop() ) / ActualHeight();
	OnScrollZoneClick(perc);
}


delegate OnScrollZoneClick(float Delta)		// Should be overridden
{
}

cpptext
{
		void Draw(UCanvas* Canvas);

}


defaultproperties
{
     StyleName="STY_ScrollZone"
     bCaptureMouse=True
     bDrawStyle=True
     bNeverFocus=True
     bRepeatClick=True
     RenderWeight=0.250000
}
