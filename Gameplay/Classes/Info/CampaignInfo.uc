// Defaults defined in Campaign.ini
// A new object with default values is saved in TribesGUIConfig when a new campaign is started.
// Reference the object in TribesGUIConfig for the current state of the campaign.
class CampaignInfo extends Core.Object
	PerObjectConfig
	config(Campaign);

struct MissionInfo
{
	var() string startCutsceneMap;
	var() string startCutsceneName;
	var() string endCutsceneMap;
	var() string endCutsceneName;
	var() string mapName;
	var() bool bPersist;
};

// !!! remember to add any variables to the 'copy' function
var() config Array<MissionInfo> missions; // defines the campaign structure
var() config int	progressIdx				"The index of the current campaign mission";
var() config int	highestProgressIdx		"The furthest the player has gotten in the game.";

var() config int	selectedDifficulty;


// Given a mapname, returns an index into the campaign. Returns -1 if no such mission exists in the campaign.
function int findMission(coerce string mapName)
{
	local int i;

	for (i = 0; i < missions.Length; i++)
	{
		if (Caps(mapName) == Caps(missions[i].mapName))
		{
			return i;
		}
	}

	return -1;
}

// duplicates the object
function copy(CampaignInfo dest)
{
	local int i;

	if (dest == None)
		return;

	dest.progressIdx = progressIdx;
	dest.highestProgressIdx = highestProgressIdx;
	dest.selectedDifficulty = selectedDifficulty;

	dest.missions.Length = 0;

	for (i = 0; i < missions.Length; i++)
	{
		dest.missions.Length = i + 1;
		dest.missions[dest.missions.Length - 1].startCutsceneMap = missions[i].startCutsceneMap;
		dest.missions[dest.missions.Length - 1].startCutsceneName = missions[i].startCutsceneName;
		dest.missions[dest.missions.Length - 1].endCutsceneMap = missions[i].endCutsceneMap;
		dest.missions[dest.missions.Length - 1].endCutsceneName = missions[i].endCutsceneName;
		dest.missions[dest.missions.Length - 1].mapName = missions[i].mapName;
		dest.missions[dest.missions.Length - 1].bPersist = missions[i].bPersist;
	}
}


defaultproperties
{
	selectedDifficulty = 1
}