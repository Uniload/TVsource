// ====================================================================
//  Class:  TribesGui.TribesMPHintsPanel
//  Parent: TribesGUIPage
//
// ====================================================================

class TribesMPHintsPanel extends TribesMPEscapePanel
     ;

var(TribesGui) private EditInline Config GUIButton		    NextButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    PrevButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel			HintLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIButton		    HelpButton "A component of this page which has its behavior defined in the code for this page's class.";

var() color HintColor;
var() color BindColor;

var int currentHintIndex;
var class<MultiplayerGameinfo> G;	

function InitComponent(GUIComponent MyOwner)
{

	Super.InitComponent(MyOwner);

    NextButton.OnClick=OnNextClick;
    PrevButton.OnClick=OnPrevClick;
	HelpButton.OnClick=OnHelpClick;
	currentHintIndex = 0;
}

function InternalOnShow()
{
	UpdateHint();
}

function UpdateHint()
{	
	G = class<MultiplayerGameInfo>(PlayerCharacterController(PlayerOwner()).clientSideChar.gameClass);

	if (G != None && G.default.gameHints.Length > 0)
	{
		HintLabel.Caption = G.static.ParseLoadingHint(G.default.gameHints[currentHintIndex], PlayerOwner(), HintColor, BindColor);
	}
}

function OnNextClick(GUIComponent Sender)
{
	currentHintIndex++;

	if (currentHintIndex > G.default.gameHints.Length - 1)
		currentHintIndex = 0;

	UpdateHint();
}

function OnPrevClick(GUIComponent Sender)
{
	currentHintIndex--;

	if (currentHintIndex < 0)
		currentHintIndex = G.default.gameHints.Length - 1;

	UpdateHint();
}

function OnHelpClick(GUIComponent Sender)
{
	Controller.OpenMenu("TribesGui.TribesMPHelpMenu", "TribesMPHelpMenu");
}

defaultproperties
{
	OnShow=InternalOnShow
	HintColor	= (R=255,G=255,B=255)
	BindColor	= (R=255,G=255,B=255)
}