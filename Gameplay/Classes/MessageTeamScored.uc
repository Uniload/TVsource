class MessageTeamScored extends Engine.Message
	editinlinenew;

var() TeamInfo team;

// construct
overloaded function construct(TeamInfo _team)
{
	team = _team;

	SLog("Team "$_team$" scored");
}

// editorDisplay
static function string editorDisplay(Name triggeredBy, Message filter)
{
	return "A team scored";
}

defaultproperties
{
     specificTo=Class'MPActor'
}
