// ====================================================================
//  Class:  TribesGui.TribesMPGameSummaryMenu
//
//  Menu to load map from entry screen.
// ====================================================================

class TribesMPGameSummaryMenu extends TribesGUIPage
     ;

import enum EInputKey from Engine.Interactions;
import enum EInputAction from Engine.Interactions;

var(TribesGui) private EditInline Config GUILabel		    TitleLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TeamOneLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TeamTwoLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TeamOneScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUILabel		    TeamTwoScoreLabel "A component of this page which has its behavior defined in the code for this page's class.";

var(TribesGui) private EditInline Config GUIButton		    ResumeButton "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    TeamOnePlayerList "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    TeamTwoPlayerList "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    StatList "A component of this page which has its behavior defined in the code for this page's class.";
var(TribesGui) private EditInline Config GUIMultiColumnListBox    AwardList "A component of this page which has its behavior defined in the code for this page's class.";

var localized string wonString;
var localized string lostString;
var localized string tiedString;

var(TribesGui) private EditInline Config GUIImage	ChatWindowBackground;	// background for chat window
var(TribesGui) private EditInline Config GUIEditBox	ChatEntryBox;			// text edit box for chat entry
var HUDMessageWindow	ChatWindow;											// actual HUD display element for the chat output

function InitComponent(GUIComponent MyOwner)
{
	Super.InitComponent(MyOwner);

    OnActivate=InternalOnActivate;
	OnDeActivate=InternalOnDeActivate;

    ResumeButton.OnClick=InternalOnClick;

	ChatEntryBox.OnEntryCompleted = OnChatEntryCompleted;
}

// Paul: Added PreLevelChange callback for cleanup purposes
function OnPreLevelChange(String DestURL, LevelSummary NewSummary)
{
	super.OnPreLevelChange(DestURL, NewSummary);

	// have to None-ify the chat window reference
	ChatWindow = None;
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

function InternalOnActivate()
{
	// Request stat updates
	tribesReplicationInfo(PlayerOwner().playerReplicationInfo).requestStatInit();
	tribesReplicationInfo(PlayerOwner().playerReplicationInfo).requestStatUpdates();
	Update();
	SetTimer(1, true);
}

function InternalOnDeActivate()
{
	// Stop requesting stat updates
	SetTimer(0, false);
}

function Update()
{
	//Log("GAME SUMMARY UPDATE called");
	UpdateTeamScores();
	UpdatePlayerList();
	UpdateStatList();
	UpdateAwardList();
}

function Timer()
{
	tribesReplicationInfo(PlayerOwner().playerReplicationInfo).requestStatUpdates();
	Update();
}

function UpdateTeamScores()
{
	local Array<int> scoreVals;
	local Array<string> scoreNames;
	local int i;
	local TeamInfo team, ownerTeam;

	// Don't show team stuff if there's only one team
	if (TribesGameReplicationinfo(PlayerOwner().GameReplicationInfo).numTeams < 2)
	{
		TeamOneLabel.Hide();
		TeamTwoLabel.Hide();
		TeamOneScoreLabel.Hide();
		TeamTwoScoreLabel.Hide();
		TitleLabel.Hide();
		return;
	}

	TeamOneLabel.Show();
	TeamTwoLabel.Show();
	TeamOneScoreLabel.Show();
	TeamTwoScoreLabel.Show();
	TitleLabel.Show();

	ownerTeam = TribesReplicationInfo(PlayerOwner().PlayerReplicationInfo).team;

	// Sort teams by score
	ForEach PlayerOwner().Level.AllActors(class'TeamInfo', team)
	{
		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > team.Score )
				i++;

		scoreVals.Insert(i, 1);
		scoreVals[i] = team.Score;
		scoreNames.Insert(i, 1);
		scoreNames[i] = team.localizedName;
	}

	// Hard-coded update for two teams for now
	TeamOneLabel.Caption = scoreNames[0];
	TeamTwoLabel.Caption = scoreNames[1];
	TeamOneScoreLabel.Caption = string(scoreVals[0]);
	TeamTwoScoreLabel.Caption = string(scoreVals[1]);

	// Update title
	if (ownerTeam != None)
	{
		if (scoreVals[0] == scoreVals[1])
			TitleLabel.Caption = tiedString;
		else if (ownerTeam.localizedName == scoreNames[0])
			TitleLabel.Caption = wonString;
		else
			TitleLabel.Caption = lostString;
	}

	for (i = 0; i < scoreVals.Length; i++)
	{
		//if (scoreNames[i] == string(char.team().Label))
		//	C.SetDrawColor(255, 0, 0);
		//else
		//	C.SetDrawColor(255, 255, 255);


		//drawJustifiedShadowedText(C, scoreNames[i], x + (0.8 * C.ClipX * 0.0), y, x + (0.8 * C.ClipX * 0.7), y + 0.03 * C.ClipY, 0);
		//drawJustifiedShadowedText(C, string(scoreVals[i]), x + (0.8 * C.ClipX * 0.22), y, x + (0.8 * C.ClipX * 1.0), y + 0.03 * C.ClipY, 0);

		//y += 0.03 * C.ClipY;
	}
}

function UpdatePlayerList()
{
	local Array<int> scoreVals;
	local Array<TribesReplicationInfo> sortedTRIList;
	local PlayerReplicationInfo P;
	local int i,j;
	local GUIMultiColumnListBox PlayerList;

	// Sort players by score
	for (j = 0; j < PlayerOwner().GameReplicationInfo.PRIArray.Length; j++)
	{
		P = tribesReplicationInfo(PlayerOwner().GameReplicationInfo.PRIArray[j]);
		if (P == None || P.playerName == "" || tribesReplicationInfo(P).team == None)
			continue;

		i = 0;
		if ( scoreVals.length > 0 )
			while ( i < scoreVals.length && scoreVals[i] > P.Score )
				i++;

		sortedTRIList.Insert(i, 1);
		sortedTRIList[i] = tribesReplicationInfo(P);
		scoreVals.Insert(i, 1);
		scoreVals[i] = P.Score;
	}

	// Update the tables
	TeamOnePlayerList.Clear();
	TeamTwoPlayerList.Clear();
	for (i=0; i<sortedTRIList.Length; i++)
	{
		if (sortedTRIList[i].team.localizedName == teamOneLabel.Caption)
			PlayerList = TeamOnePlayerList;
		else
			PlayerList = TeamTwoPlayerList;

	    PlayerList.AddNewRowElement( "Name",,  TribesGUIController(Controller).EncodePlayerName(self, sortedTRIList[i]) );
		PlayerList.AddNewRowElement( "Score",, string(int(sortedTRIList[i].Score)) );
		PlayerList.AddNewRowElement( "O",, string(sortedTRIList[i].offenseScore) );
		PlayerList.AddNewRowElement( "D",, string(sortedTRIList[i].defenseScore) );
		PlayerList.AddNewRowElement( "S",, string(sortedTRIList[i].styleScore) );
		PlayerList.PopulateRow( "Name" );
	}

	TeamOnePlayerList.SetIndex(-1);
	TeamTwoPlayerList.SetIndex(-1);
}

function UpdateStatList()
{
	local tribesReplicationInfo TRI;
	local int i;

	TRI = tribesReplicationInfo(PlayerOwner().playerReplicationInfo);

	if (TRI == None)
		return;


	StatList.Clear();

	for (i=0; i < TRI.statDataList.Length; i++)
	{
		if (TRI.statDataList[i].statClass.default.Description != "")
			StatList.AddNewRowElement( "Stat",, TRI.statDataList[i].statClass.default.Description);
		else
			continue;
		//	StatList.AddNewRowElement( "Stat",, TRI.statDataList[i].statClass.default.acronym);
		StatList.AddNewRowElement( "Value",, string(TRI.statDataList[i].amount));
		StatList.PopulateRow( "Stat");
	}

	StatList.SetIndex(-1);
}

function UpdateAwardList()
{
	local tribesReplicationInfo TRI;
	local tribesReplicationInfo awardWinnerTRI;
	local int i;

	// Use own TRI to cycle through stats and find award winners
	TRI = tribesReplicationInfo(PlayerOwner().playerReplicationInfo);

	if (TRI == None)
		return;

	AwardList.Clear();

	for (i=0; i < TRI.statDataList.Length; i++)
	{
		if (TRI.statDataList[i].statClass.default.awardDescription != "")
		{
			awardWinnerTRI = getAwardWinnerTRI(i);
			AwardList.AddNewRowElement("Award",,TRI.statDataList[i].statClass.default.awardDescription);
			
			if (awardWinnerTRI != None)
			{
				//Log("Awarding "$awardWinnerTRI.PlayerName$" for "$TRI.statDataList[i]);
				AwardList.AddNewRowElement("Winner",,TribesGUIController(Controller).EncodePlayerName(self, awardWinnerTRI));
				AwardList.AddNewRowElement("Value",,string(awardWinnerTRI.statDataList[i].amount));
			}
			else
			{
				AwardList.AddNewRowElement("Winner",,"-");
				AwardList.AddNewRowElement("Value",,"-");
			}
			AwardList.PopulateRow( "Award");
		}
	}

	AwardList.SetIndex(-1);
}

function TribesReplicationInfo getAwardWinnerTRI(int statDataIndex)
{
	local TribesReplicationInfo TRI;
	local TribesReplicationInfo highestTRI;

	ForEach PlayerOwner().Level.DynamicActors(class'TribesReplicationInfo', TRI)
	{
		if (highestTRI == None)
			highestTRI = TRI;
		else if (TRI.statDataList[statDataIndex].amount > highestTRI.statDataList[statDataIndex].amount)
			highestTRI = TRI;
	}

	// Don't give an award if amount was 0
	if (highestTRI.statDataList[statDataIndex].amount == 0)
		return None;

	return highestTRI;
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

function string getColoredPlayerName(TribesReplicationInfo TRI)
{
	local string PlayerName, TeamTag;

	// Team tag
	if (TRI.teamTag != "")
	{
		TeamTag = MakeColorCode(TRI.team.TeamHighlightColor) $ TRI.teamTag;
	}

	PlayerName = stripCodes(TRI.PlayerName);
	// Highlight own name
	if (PlayerOwner().PlayerReplicationInfo == TRI)
		PlayerName = MakeColorCode(TRI.team.TeamHighlightColor) $ PlayerName;
	else
		PlayerName = MakeColorCode(TRI.team.TeamColor) $ PlayerName;

	// Simply add it to front of name for now
	// TODO:  Use delimeter to control how tag looks
	return TeamTag $ PlayerName;
}

//
//
//
function OnChatEntryCompleted(GUIComponent edit)
{
	local PlayerCharacterController CharacterController;

	CharacterController = PlayerCharacterController(PlayerOwner());
	CharacterController.Say(ChatEntryBox.GetText());
	ChatEntryBox.SetText("");
}

//
// Override OnDraw in order to render the chat window text 
// into the area we have supplied for it
//
function OnClientDraw(Canvas canvas)
{
	local PlayerCharacterController CharacterController;

	// initialise the chat window
	if(ChatWindow == None)
		ChatWindow = HUDMessageWindow(class'HUDElement'.static.StaticCreateHUDElement(class'HUDMessageWindow', "default_MessageWindow"));

	CharacterController = PlayerCharacterController(PlayerOwner());

	if(CharacterController != None)
	{
		ChatWindow.ForcedMaxVisibleLines = (ChatWindowBackground.ActualHeight() / ChatWindow.GetLineHeight(canvas));
		ChatWindow.DoLayout(canvas);
		ChatWindow.PosX = ChatWindowBackground.ActualLeft();
		ChatWindow.PosY = ChatWindowBackground.ActualTop();
		ChatWindow.Width = ChatWindowBackground.ActualWidth();
		ChatWindow.Height = ChatWindowBackground.ActualHeight();

		canvas.SetOrigin(ChatWindow.PosX, ChatWindow.PosY);
		canvas.SetClip(ChatWindow.Width, ChatWindow.Height);
		ChatWindow.UpdateData(CharacterController.clientSideChar);
		ChatWindow.Render(canvas);
	}
}

defaultproperties
{
    OnKeyEvent=InternalOnKeyEvent;
	wonString = "Your team won!"
	lostString = "Your team lost..."
	tiedString = "The match ended in a tie!"
}
