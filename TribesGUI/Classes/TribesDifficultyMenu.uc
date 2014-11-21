// ====================================================================
//  Class:  TribesGui.TribesMainMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesDifficultyMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    EasyButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    NormalButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    HardButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    CancelButton "A component of this page which has its behavior defined in the code for this page's class.";

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    EasyButton.OnClick=InternalOnClick;
    NormalButton.OnClick=InternalOnClick;
    HardButton.OnClick=InternalOnClick;
	CancelButton.OnClick=InternalOnClick;

	bEscapeable = true;
	PageOpenedAfterEscape = class'GameEngine'.default.MainMenuClass;
}

function InternalOnClick(GUIComponent Sender)
{
	local int difficulty;

	switch (Sender)
	{
		case EasyButton:
			difficulty = 0;
			break;
		case NormalButton:
			difficulty = 1;
			break;
		case HardButton:
			difficulty = 2;
			break;
		case CancelButton:
			Controller.CloseMenu();
			Controller.OpenMenu(class'GameEngine'.default.MainMenuClass);
			return;
	}

	if (!TribesGUIController(Controller).StartNewCampaign(difficulty))
	{
		Log("Campaign error:  no campaign has been defined");
	}
}

defaultproperties
{
}