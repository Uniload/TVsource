//=============================================================================
// GameReplicationInfo.
//=============================================================================
class TribesGameReplicationInfo extends Engine.GameReplicationInfo;

var bool bAwaitingTournamentStart;
var int numTeams;

replication
{
	reliable if (Role == ROLE_Authority)
		bAwaitingTournamentStart, numTeams;
}