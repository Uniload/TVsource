class MPGameAnnouncerMessages extends TribesLocalMessage;

defaultproperties
{
	announcements(0)=(effectEvent=WonMatch,speechTag="WINMATCH",debugString="%1 win the match.")
	announcements(1)=(effectEvent=WonRound,speechTag="WINROUND",debugString="%1 win the round.")
	announcements(2)=(effectEvent=TieMatch,speechTag="MATCHTIE",debugString="")
	announcements(3)=(effectEvent=,speechTag="TIME60",debugString="")
	announcements(4)=(effectEvent=,speechTag="TIME10",debugString="")
	announcements(5)=(effectEvent=,speechTag="GAMEON",debugString="")
}
