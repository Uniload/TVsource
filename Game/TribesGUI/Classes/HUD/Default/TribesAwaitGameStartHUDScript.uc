class TribesAwaitGameStartHUDScript extends TribesEditableHUDScript;

var LabelElement WaitGameStartPromptLabel;

var localized string WaitForMorePlayersText;
var localized string WaitForTournamentText;


overloaded function Construct()
{
	super.Construct();

	WaitGameStartPromptLabel = LabelElement(AddElement("TribesGUI.LabelElement", "default_WaitGameStartPromptLabel"));
	WaitGameStartPromptLabel.SetText(WaitForMorePlayersText);
}

simulated function UpdateData(ClientSideCharacter c)
{
	Super.UpdateData(c);

	if (c.bAwaitingTournamentStart)
		WaitGameStartPromptLabel.SetText(WaitForTournamentText);
	else
		WaitGameStartPromptLabel.SetText(WaitForMorePlayersText);
}

defaultproperties
{
	WaitForMorePlayersText			= "The game will not start until more players have joined."
	WaitForTournamentText			= "The server is in tournament mode."
}