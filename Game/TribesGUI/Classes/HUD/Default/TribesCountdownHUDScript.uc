class TribesCountdownHUDScript extends TribesEditableHUDScript;

var LabelElement CountdownLabel;

var localized string CountdownText;
var localized string TournamentText;
var Gameplay.ClientSideCharacter CSC;


overloaded function Construct()
{
	super.Construct();

	CountdownLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_CountdownLabel"));
	CountdownLabel.SetText(CountdownText);
}

simulated function UpdateData(ClientSideCharacter c)
{
	Super.UpdateData(c);

	CSC = c;

	//if (roundInfo == None)
	//	ForEach AllActors(class'RoundInfo', roundInfo)
	//		break;

	if (CSC.bAwaitingTournamentStart)
		CountdownLabel.SetText(TournamentText);
	else if (CSC.countdown >= 0)
		CountdownLabel.SetText(string(int(CSC.countdown)) $ CountdownText);
}

defaultproperties
{
	CountdownText		= " seconds until round starts"
	TournamentText		= "The server is in tournament mode.  Press fire to ready and unready yourself."
}