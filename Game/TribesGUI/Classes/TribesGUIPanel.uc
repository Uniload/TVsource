// ====================================================================
//  Class:  TribesGui.TribesGUIPanel
//  Parent: TribesGUIPage
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesGUIPanel extends GUI.GUIPanel
     native;

var(DynamicConfig) EditInline EditConst protected   TribesGUIConfig   GC "Config class for the GUI";

function InitComponent(GUIComponent MyOwner)
{
	GC = TribesGUIController(Controller).GuiConfig;
	Super.InitComponent(MyOwner);
}

defaultproperties
{
	WinTop=0
	WinLeft=0
	WinWidth=1
	WinHeight=1
	bAcceptsInput=true
}