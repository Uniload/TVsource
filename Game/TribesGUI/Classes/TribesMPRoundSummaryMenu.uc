// ====================================================================
//  Class:  TribesGui.TribesMPRoundSummaryMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPRoundSummaryMenu extends TribesGUIPage
     ;

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

var(TribesGui) private EditInline Config GUILabel		    titleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    teamOneScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    teamTwoScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    teamOneNameLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    teamTwoNameLabel "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIButton		    ResumeButton "A component of this page which has its behavior defined in the code for this page's class.";

var localized string wonRound;
var localized string lostRound;

var localized TeamInfo TeamOne, TeamTwo;

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    ResumeButton.OnClick=InternalOnClick;
	OnShow=InternalOnShow;
	OnHide=InternalOnHide;
}

function InternalOnClick(GUIComponent Sender)
{
	switch (Sender)
	{
		case ResumeButton:
			Controller.CloseAll();
			break;
	}
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( bVisible && bActiveInput &&
        Key == EInputKey.IK_Escape && State == EInputAction.IST_Press )
    {
        Controller.CloseAll();
        return true;
    }
    return false;
}

function InternalOnShow()
{
	Update();
}

function InternalOnHide()
{
	// Forget references to TeamInfos to appease garbage collector
	TeamOne = None;
	TeamTwo = None;
}


function Update()
{
	local TeamInfo team;

	// Find teams
	if (TeamOne == None || TeamTwo == None)
	{
		TeamOne = None;
		TeamTwo = None;

		ForEach PlayerOwner().Level.AllActors(class'TeamInfo', team)
		{
			if (team.TeamIndex == 0)
				TeamOne = team;
			else
				TeamTwo = team;
		}
	}

	if (PlayerCharacterController(PlayerOwner()).getOwnTeam().bWonLastRound)
	{
		titleLabel.Caption = wonRound;
	}
	else
	{
		titleLabel.Caption = lostRound;
	}

	teamOneScoreLabel.Caption = string(TeamOne.score);
	teamOneNameLabel.Caption = TeamOne.localizedName;
	teamTwoScoreLabel.Caption = string(TeamTwo.score);
	teamTwoNameLabel.Caption = TeamTwo.localizedName;
}

defaultproperties
{
    OnKeyEvent=InternalOnKeyEvent;
	wonRound = "Your team won the round!"
	lostRound = "Your team lost the round."
	//bSwallowAllKeyEvents = false
	bAcceptsInput = false
	//bPlayerMoveAllowed = true
	bHideMouseCursor = true
}
