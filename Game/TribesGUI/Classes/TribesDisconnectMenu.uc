// ====================================================================
//  Class:  TribesGui.TribesDisconnectMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesDisconnectMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    OKButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    ReasonLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TitleLabel "A component of this page which has its behavior defined in the code for this page's class.";

var() localized string GenericDisconnectMessage;
var localized bool OnOKMenu;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	OKButton.OnClick = OnOKClicked;
}

function HandleParameters(string Param1, string Param2, optional int Param3)
{
	if (Param1 != "")
		TitleLabel.SetCaption(Param1);
	else
		TitleLabel.SetCaption("");

	if (Param2 != "")
		ReasonLabel.SetCaption(Param2);
	else
		ReasonLabel.SetCaption(GenericDisconnectMessage);

	OnOKMenu = Param3 != -1;
}

function OnOKClicked(GUIComponent Sender)
{
	Controller.CloseMenu();
	
	if (!OnOKMenu)
	{
		Controller.OpenMenu("TribesGui.TribesMultiplayerMenu", "TribesMultiplayerMenu");
	}

	Controller.ViewportOwner.Actor.SetPause(false);
}


defaultproperties
{
	GenericDisconnectMessage = "Rejected by server"
}