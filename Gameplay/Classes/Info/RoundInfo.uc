// RoundInfo
// Holds a list of RoundData objects that define the rounds in the level.
// If a RoundData actor is not placed by the user in UnrealEd, one will be spawned on level load for
// multiplayer maps.
class RoundInfo extends Engine.Info
	editinlinenew
	placeable;

var() deepcopy editinline Array<RoundData>	rounds;

var int			currentRoundIdx;
var float		replicatedRemainingDuration;	// for net clients. It would be good to find a lower-bandwidth alternative.
var float		replicatedRemainingCountdown;	// for net clients

replication
{
	reliable if (Role == ROLE_Authority)
		replicatedRemainingDuration, replicatedRemainingCountdown;
}


function bool moreRoundsToPlay()
{
	return currentRoundIdx < rounds.Length - 1;
}

// Call this to start the next round
function startNextRound()
{
	local PlayerCharacterController c;

	// End current round if applicable

	if (currentRoundIdx >= 0 && currentRoundIdx < rounds.Length)
		rounds[currentRoundIdx].end();

	currentRoundIdx++;

	// Reset some variables on all players
	ForEach Level.AllControllers(class'PlayerCharacterController', c)
	{
		if (c.Pawn == None)
			c.bWaitingForRoundEnd = false;

		// Reset livesLeft
		if(currentRound().maxLives > 0)
		{
			c.livesLeft = currentRound().maxLives;
		}
		else
			// Otherwise ensure respawns are disabled for this player
			c.livesLeft = -1;
	}

	cleanupEquipment();

	Log("Starting round "$rounds[currentRoundIdx]);
	rounds[currentRoundIdx].start(Level.TimeSeconds);
}

// needsCountdown
// returns true if the current round requires a warmup
function bool needsCountdown()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
		return false;

	return rounds[currentRoundIdx].countdownDuration > 0;
}

// isCountdown
// returns true if the current round is in the warmup phase
function bool isCountdown()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
		return false;

	return rounds[currentRoundIdx].isCountdown(Level.TimeSeconds);
}

// remainingCountdown
// returns the number of seconds remaining in the warmup phase
function float remainingCountdown()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
		return 0;

	return rounds[currentRoundIdx].playStartTime - Level.TimeSeconds;
}

// isFinished
// returns true if the current round is finished
function bool isFinished()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
	{
		Log("Round finished (no more rounds left)");
		return true;
	}

	return rounds[currentRoundIdx].isFinished(Level);
}

// remainingRoundTime
// returns the number of seconds remaining in the round
function float remainingRoundTime()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
		return 0;

	return (rounds[currentRoundIdx].playStartTime + rounds[currentRoundIdx].duration * 60) - Level.TimeSeconds;
}

// tick
function Tick(float delta)
{
	if (isCountdown())
		replicatedRemainingCountdown = remainingCountdown();
	else
		replicatedRemainingDuration = remainingRoundTime();
}

function RoundData currentRound()
{
	if (currentRoundIdx < 0 || currentRoundIdx >= rounds.Length)
		return None;

	return rounds[currentRoundIdx];
}

function restart()
{
	currentRoundIdx = -1;
	startNextRound();
}

function cleanup()
{
	local int i;

	for (i=0; i<rounds.Length; i++)
	{
		rounds[i].cleanup();
	}
}

// Destroy all dropped equipment and reset equipment spawn points
function cleanupEquipment()
{
	local Equipment e;
	local EquipmentSpawnPoint esp;

	// Destroy dropped equipment, but not deployables
	ForEach DynamicActors(class'Equipment', e)
	{
		if (e.IsInState('AwaitingPickup') && !ClassIsChildOf(e.Class, class'Deployable'))
			e.destroy();
	}

	// Make sure every equipment spawn point spawns its equipment
	ForEach AllActors(class'EquipmentSpawnPoint', esp)
	{
		// Don't check to see if the spawn point has already spawned equipment because even if it had,
		// it would've been deleted in the previous operation
		esp.spawnEquipment();
	}
}

defaultproperties
{
	RemoteRole				= ROLE_DumbProxy
	bAlwaysRelevant			= true
	NetUpdateFrequency		= 1
	currentRoundIdx			= -1
}
