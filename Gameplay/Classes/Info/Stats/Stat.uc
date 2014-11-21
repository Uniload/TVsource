class Stat extends Core.Object;

var() int offensePointsPerStat	"The number of offense points awarded when this stat is incremented";
var() int defensePointsPerStat	"The number of defense points awarded when this stat is incremented";
var() int stylePointsPerStat	"The number of style points awarded when this stat is incremented";
var() int logLevel;
var() localized string acronym			"The acronym for this stat";
var() localized string description		"The description for this stat";
var() localized string awardDescription "If provided, an award with this description will be given to the player with the highest stat";
var() localized string personalMessage	"If provided, sends this personal message when the stat is awarded";
var(LocalMessage) class<MPPersonalMessage> PersonalMessageClass "Personal message class to use when stat is awarded";

defaultproperties
{
	offensePointsPerStat	= 0
	defensePointsPerStat	= 0
	stylePointsPerStat		= 0
	logLevel				= 1
	acronym					= "N/A"
}