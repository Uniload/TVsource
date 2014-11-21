// ====================================================================
//  Class:  TribesGui.TribesOptionsCreditsPanel
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesOptionsCreditsPanel extends TribesSettingsPanel
     ;

var(TribesGui) private EditInline Config GUIButton		    DefaultsButton "A component of this page which has its behavior defined in the code for this page's class.";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OnShow = InternalOnShow;
}

function InternalOnShow()
{
	DefaultsButton.bCanBeShown = false;
	DefaultsButton.Hide();
}

function InternalOnChange(GUIComponent Sender)
{
}

defaultproperties
{
}
