class GameSpyStatSerializer extends StatSerializer;

var int nextPlayerStatIndex;

function resetNextPlayerStatIndex()
{
	nextPlayerStatIndex = 0;
}

function int getNextPlayerStatIndex()
{
	return nextPlayerStatIndex++;
}

function gsStatLog(coerce String msg)
{
	Log("    GAMESPY STAT: " $ msg);
}

function onMapStart()
{
}

function onClientConnect(TribesReplicationInfo TRI)
{
}

function onClientDisconnect(TribesReplicationInfo TRI)
{
}

function serializeStat(TribesReplicationInfo TRI, StatData sd)
{
	// We only need to do snapshots for GameSpy stat tracking, so we don't need to serialize individual stats
}

private function sendSnapshot(bool finalSnapshot)
{
	local Array<TribesReplicationInfo> statTrackedPlayers;
	local int j;
	local int i;
	local TribesReplicationInfo TRI;
	local GameSpyManager gsm;

	gsm = Level.GetGameSpyManager();

	ForEach DynamicActors(class'TribesReplicationInfo', TRI)
		if (TRI.playerStatIndex == -1 && TRI.Owner != None && gsm.StatsHasPIDAndResponse(PlayerController(TRI.Owner)))
			statTrackedPlayers[statTrackedPlayers.Length] = TRI;

	if (statTrackedPlayers.Length == 0)
		return;

	gsm.StatsNewGameStarted();
	resetNextPlayerStatIndex();

	gsStatLog("Serializing snapshot");

	gsm.SetServerStat("Mapname", Level.Title);

	gsm.SetServerStat("TeamOne", GameInfo(Level.Game).GetTeamFromIndex(0).localizedName);
	gsm.SetServerStat("TeamTwo", GameInfo(Level.Game).GetTeamFromIndex(1).localizedName);

	gsm.SetServerStat("TeamOneScore", String(GameInfo(Level.Game).GetTeamFromIndex(0).score));
	gsm.SetServerStat("TeamTwoScore", String(GameInfo(Level.Game).GetTeamFromIndex(1).score));

	// Log the player specific stats
	for (j = 0; j < statTrackedPlayers.Length; ++j)
	{
		TRI = statTrackedPlayers[j];

		TRI.playerStatIndex = getNextPlayerStatIndex();

		if (TRI.playerStatIndex != -1) // If stats were tracked for this player
		{
			gsStatLog("    Serializing stats for player " $ TRI.PlayerName);

			Level.GetGameSpyManager().StatsNewPlayer(TRI.playerStatIndex, TRI.PlayerName);

			gsm.SetPlayerStat("pid", gsm.StatsGetPID(PlayerController(TRI.Owner)), TRI.playerStatIndex);
			gsm.SetPlayerStat("auth", gsm.StatsGetStatResponse(PlayerController(TRI.Owner)), TRI.playerStatIndex);

			gsm.SetPlayerStat("team", TRI.team.localizedName, TRI.playerStatIndex);

			gsm.SetPlayerStat("OffenseScore", TRI.offenseScore, TRI.playerStatIndex);
			gsm.SetPlayerStat("DefenseScore", TRI.defenseScore, TRI.playerStatIndex);
			gsm.SetPlayerStat("StyleScore", TRI.styleScore, TRI.playerStatIndex);

			for (i = 0; i < TRI.statDataList.Length; ++i)
			{
				gsm.SetPlayerStat(TRI.statDataList[i].statClass.Name, TRI.statDataList[i].amount, TRI.playerStatIndex);
			}
		}
	}

	gsStatLog("Sending snapshot");
	gsm.SendStatSnapshot(finalSnapshot);
}

function serializeSnapshot()
{
}

function onMapEnd()
{
	if (GetUrlOption("GameStats") ~= "true")
		sendSnapshot(true);
}

defaultproperties
{
}
