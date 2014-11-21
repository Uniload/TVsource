// ====================================================================
//  Class:  TribesGui.TribesMPHelpMenu
//
// ====================================================================

class TribesMPHelpMenu extends TribesGUIPage
     ;

var(TribesGui) private EditInline Config GUIButton		    DoneButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUICheckboxButton	DontShowButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			MovementLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			TeamworkLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			EscapeLabel "A component of this page which has its behavior defined in the code for this page's class.";

var localized string MovementText;
var localized string TeamworkText;
var localized string EscapeText;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

	DoneButton.OnClick=InternalOnClick;
	bEscapeable = true;
	OnShow=InternalOnShow;
	DontShowButton.bChecked=TribesGUIController(Controller).profileManager.GetActiveProfile().bShownMPHelp;
}

function InternalOnShow()
{
	local string skiKey, jetKey, chatKey, quickChatKey, commandKey, escapeKey;

	skiKey = Controller.Master.GetKeyFromBinding("Ski", true);
	jetKey = Controller.Master.GetKeyFromBinding("Jet", true);
	chatKey = Controller.Master.GetKeyFromBinding("TribesTalk", true);
	quickChatKey = Controller.Master.GetKeyFromBinding("Button bQuickChat", true);
	commandKey = Controller.Master.GetKeyFromBinding("Button bObjectives", true);
	escapeKey = Controller.Master.GetKeyFromBinding("ShowEscapeMenu", true);

	MovementLabel.Caption = replaceStr(MovementText, jetKey, skiKey);
	TeamworkLabel.Caption = replaceStr(TeamworkText, chatKey, quickChatKey, commandKey);
	EscapeLabel.Caption = replacestr(EscapeText, escapeKey);
}

function InternalOnClick(GUIComponent Sender)
{
	local PlayerProfile p;

	p = TribesGUIController(Controller).profileManager.GetActiveProfile();

	p.bShownMPHelp = DontShowButton.bChecked;
	p.Store();
    Controller.CloseMenu();
}

defaultproperties
{
	MovementText="Tribes is about the freedom of movement.  Press '%1' to use your jetpack and fly into the air.  Your jetpack has a limited amount of energy, but it recharges quickly.  Press '%2' to ski down slopes.  This ability is unlimited but requires practice."
	TeamworkText="Tribes is about teamwork.  Coordinate with your team to maximize your effectiveness.  Press '%1' to chat to your team.  Press and hold '%2' to access a menu of pre-recorded chats.  Press '%3' to see a strategic command map."
	EscapeText="To browse game hints, press '%1' while playing, then click the Hints tab.  To see this message again, press the Help button on the Hints tab."
}
