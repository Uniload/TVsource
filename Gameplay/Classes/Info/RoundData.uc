class RoundData extends Core.Object
	editinlinenew
	hidecategories(Object);

var() float		duration					"The length of time in minutes that this round will last (-1 to ignore)";
var() float		countdownDuration			"The length of time in seconds that players must wait before the round starts (-1 to ignore)";
var() int		scoreLimit					"The number of points a team must accumulate in order to end this round (-1 to disable)";
var() int		maxLives					"The maximum number of lives allowed per player in this round (-1 to ignore)";
var() bool		bAllowNewPlayers			"Determines whether players can join a round in progress";
var() bool		bKeepEquipmentDuringRound	"Determines whether players keep their equipment between respawns NOT IMPLEMENTED";
var() bool		bKeepEquipmentAfterRound	"Determines whether players keep their equipment for the next round if they are alive at the end of the round NOT IMPLEMENTED";
var() bool		bAllowEquipOnRespawn		"Determines whether the player is presented with an inventory screen every time they spawn";
var() float		respawnDelay				"The length of time in seconds that players must wait before respawning in the round (0 to ignore)";
var() float		respawnWaveInterval			"If set, bypasses respawnDelay and causes players to respawn in waves at this interval (0 to ignore)";
var() int		roundWinPoints				"The number of team points awarded for winning this round by killing the other team.  Only applies when maxLives is used.";
var() float		overtimeDuration			"In the event of a tie in a game that uses maxLives, use an overtime of this duration (in minutes)";

var float		startTime;
var float		playStartTime;
var TeamInfo	winningTeam;
var float		currentWaveTime;

// start
// call this when the round starts
function start(float levelTime)
{
	startTime = levelTime;
	playStartTime = levelTime + countdownDuration;
}

function end()
{
}

// isCountdown
// returns true if the round is in the countdown phase
function bool isCountdown(float levelTime)
{
	return countdownDuration != -1 && (levelTime - startTime) <= countdownDuration - 1;
}

function float timeLeft(Engine.LevelInfo level)
{
	return (duration * 60) - (level.TimeSeconds - playStartTime);
}

// isFinished
// returns true if the round is finished
function bool isFinished(Engine.LevelInfo level)
{
	local TeamInfo team, winningTeam;

	if (duration != -1)
	{
		// Check time limit if this round has a duration
		if (timeLeft(level) <= 0)
		{
			Log("Round finished due to time limit");

			// If maxLives is set and time has run out, make the team with the most number of remaining players
			// alive the winners.  If it's a tie, add a minute and don't end yet.
			if (maxLives >= 0)
			{
				ForEach Level.AllActors(class'TeamInfo', team)
				{
					if (winningTeam == None)
						winningTeam = team;
	
					else
					{
						if (team.numTotalLives() > winningTeam.numTotalLives())
							winningTeam = team;
						else if (team.numTotalLives() == winningTeam.numTotalLives())
						{
							// Tie game; add 1 minute overtime
							duration += overtimeDuration;
							return false;
						}
					}
				}
				winningTeam.Score += roundWinPoints;
				MultiplayerGameInfo(Level.Game).postTeamScored(winningTeam, roundWinPoints);
				setWinningTeam(level, winningTeam);
			}
			return true;
		}
	}

	return false;
}

function bool shouldEndAfterTeamScored(LevelInfo Level, TeamInfo t)
{
	if (scoreLimit > 0)
	{
		// Check the team to see if they've reached the score limit, if applicable
		if (t.score >= scoreLimit)
		{
			Log("Round finished due to scoreLimit");
			setWinningTeam(Level, t);
			return true;
		}
	}

	return false;
}

function bool shouldEndAfterDeathOf(LevelInfo Level, PlayerCharacterController c)
{
	local bool bFinished;
	local TeamInfo team;
	local array<TeamInfo> teamArray;
	local int numTeamsLeft;
	local int i, teamWithPlayersLeftIndex;

	// If the dying player is the last player left on his team, and that team has no more carryables
	// left for respawning, the round should end
	team = tribesReplicationInfo(c.playerReplicationInfo).team;
	if (team.numActivePlayers() == 0 && team.bNoMoreCarryables)
	{
		//Log("Round "$self$" finished due to no more players and carryables on team "$team);
		return true;
	}

	// Otherwise the round can only end after a death if maxLives is used
	if (maxLives == -1)
		return false;

	// Store teams so we know how many there are, but only store a team if it actually has
	// any members
	ForEach Level.AllActors(class'TeamInfo', team)
	{
		if (team.numPlayers() > 0)
			teamArray[teamArray.Length] = team;
	}

	if (teamArray.Length == 0)
	{
		Log("Error:  character died but there are no teams");
		return false;
	}

	// If there is only one team, then the round is finished if that team has no active players left with respawns
	if (teamArray.Length == 1)
	{
		if (teamArray[0].numActivePlayers() <= 0 && teamArray[0].numTotalLives() == 0)
		{
			Log("Round "$self$" finished due to solo team running out of respawns");
			return true;
		}
		else
		{
			Log("Solo team death detected, active = "$teamArray[0].numActivePlayers()$", totalRespawns = "$teamArray[0].numTotalLives());
		}
	}
	else
	{
		// Otherwise, assume the round is finished, but if any two teams are left,
		// then mark the round as not finished (this should handle n teams)
		bFinished = true;
		for (i=0; i<teamArray.Length; i++)
		{
			// Probably need a better way than numActivePlayers() to determine if a team
			// still has players left in the current round
			if (teamArray[i].numActivePlayers() > 0 || teamArray[i].numTotalLives() > 0)
			{
				//Log("Team "$teamArray[i]$" was found to have players and/or lives left");
				teamWithPlayersLeftIndex = i;
				numTeamsLeft++;
			}
			else
			{
				//Log("Team "$teamArray[i]$" has NO players and/or respawns left!");	
			}

			if (numTeamsLeft >= 2)
			{
				bFinished = false;
				break;
			}
		}
		if (bFinished)
		{
			//Log("Round "$self$" finished due to only one team having players left"); 
			teamArray[teamWithPlayersLeftIndex].Score += roundWinPoints;
			MultiplayerGameInfo(Level.Game).postTeamScored(teamArray[teamWithPlayersLeftIndex], roundWinPoints);
			setWinningTeam(Level, teamArray[teamWithPlayersLeftIndex]);
		}
	}

	return bFinished;
}

function setWinningTeam(LevelInfo Level, TeamInfo winningTeam)
{
	local TeamInfo team;

	self.winningTeam = winningTeam;

	ForEach Level.AllActors(class'TeamInfo', team)
	{
		if (team == winningTeam)
			team.bWonLastRound = true;
		else
			team.bWonLastRound = false;
	}
}

function float getRespawnDelay()
{
	if (respawnWaveInterval > 0)
		return respawnWaveInterval - currentWaveTime;

	return respawnDelay;
}

function cleanup()
{
	// Satisfy the garbage collector
	winningTeam = None;
}

function advanceWaveTime(float Delta)
{
	currentWaveTime += Delta;

	if (currentWaveTime >= respawnWaveInterval)
	{
		currentWaveTime = 0;
	}
}

defaultproperties
{
	duration					= 20
	countdownDuration			= 5
	scoreLimit					= -1
	maxLives					= -1
	bAllowNewPlayers			= true
	bKeepEquipmentDuringRound	= false
	bKeepEquipmentAfterRound	= false
	bAllowEquipOnRespawn		= false
	respawnDelay				= 2
	roundWinPoints				= 0
	overtimeDuration			= 1
}