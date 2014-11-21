// ====================================================================
//  Class:  GUI.GUIHorzScrollZone
//  Parent: GUI.GUIComponent
//
//  <Enter a description here>
// ====================================================================

class GUIHorzScrollZone extends GUIComponent
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

	perc = ( Controller.MouseX - ActualLeft() ) / ActualWidth();
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
}
