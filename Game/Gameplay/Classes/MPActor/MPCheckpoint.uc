class MPCheckpoint extends MPArea;

var() editcombotype(enumCheckpoints) 
	  Name			nextCheckpointLabel	"The next checkpoint";
var() bool			bStartingPoint		"Is this checkpoint the start of a lap?";
var() bool			bFinishingPoint		"Is this checkpoint the end of a lap?";
var() int			numLapsToFinish		"If bFinishingLine is true, specify the number of laps here";
var() int			teamPointsPerLap	"Number of points awarded to your team for each lap passed";
var() Name			passAnimation		"The name of the animation to play when this checkpoint gets passed";
var() bool			bDontResetAfterPass	"If true, the checkpoint won't reset itself after you pass it, so its effects will stay active";
var() bool			bUsePersonalObjectives "If true, the player will automatically receive a personal objective for each checkpoint";

// Effect events
var(EffectEvents) Name	passedEffectEvent	"The name of an effect event that plays once on the checkpoint when passed";
var(EffectEvents) Name	failedEffectEvent	"The name of an effect event that plays once on the checkpoint when failed";

var bool bPassedEffect;
var bool bLocalPassedEffect;

var Array<PlayerCharacterController>		awaitingClientsList;
var float					startingTime;
var MPCheckpoint			nextCheckpoint;

// Stats
var(Stats)	class<Stat>		checkpointPassedStat;
var(Stats)	class<Stat>		lapFinishedStat;
var(Stats)	class<Stat>		raceFinishedStat;

// Objectives
var(Objectives) localized string	selfCheckpointObjectiveDesc		"A description that will show up as a personal objective for your next checkpoint.";

var(LocalMessage) class<Engine.LocalMessage>	CheckpointMessageClass "The class used for displaying messages and playing effects related to carryables.";


struct ClientCheckpointData
{
	var PlayerCharacterController client;
	var int lap;
	var float lastTimePassed;
};

var Array<ClientCheckpointData>		passedClientsList;

replication
{
	reliable if (Role == ROLE_Authority)
		bPassedEffect;
}

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (bStartingPoint)
	{
		startingTime = Level.TimeSeconds;
		// Register interest in connect messages, but only if this is a starting point
		registerMessage(class'MessageClientConnected', "All");
	}

	
	nextCheckpoint = MPCheckpoint(findByLabel(class'MPCheckpoint', nextCheckpointLabel));

	// Register interest in disconnect and team change messages
	// This is needed in order to tidy up client lists
	registerMessage(class'MessageClientDisconnected', "All");
	registerMessage(class'MessageClientChangedTeam', "All");
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	updateCheckpointEffects();
}

simulated function updateCheckpointEffects()
{
	if (bPassedEffect != bLocalPassedEffect)
	{
		bLocalPassedEffect = bPassedEffect;
		if (bPassedEffect)
		{
			TriggerEffectEvent(passedEffectEvent);
			PlayAnim(passAnimation);

			if (!bDontResetAfterPass)
				SetTimer(1, false);
		}
		else
		{
			// The passedEffectEvent wasn't intended to be looping but the artists have used it that way
			// so UnTrigger it here
			UnTriggerEffectEvent(passedEffectEvent);
			PlayAnim('Deactive');
		}
	}
}

simulated event Timer()
{
	// Temporary:  restore checkpoint to its lowered location
	bPassedEffect = false;
	updateCheckpointEffects();
}

function onMessage(Message msg)
{
	if (MessageClientChangedTeam(msg) != None)
	{
		// Do cleanup here
		//Log("Checkpoint:  Team change detected for "$MessageClientChangedTeam(msg).client);
	}
	else if (MessageClientConnected(msg) != None)
	{
		// If this message was received, we know this is a starting point, so
		// automatically advance to the next checkpoint
		advanceCheckpoint(MessageClientConnected(msg).client);
	}
	else if (MessageClientDisconnected(msg) != None)
	{
		// Ensure this client is removed from all client lists
		removeAwaitingClient(MessageClientDisconnected(msg).client);
	}
}

function OnAreaEntered(Character c)
{
	// Use Owner instead of Controller to handle case where player is in a vehicle
	//Log(self$" entered by "$c$" with owner "$c.owner);
	if (isAwaitingClient(PlayerCharacterController(c.Owner)))
		passCheckpoint(PlayerCharacterController(c.Owner), c.team());
	else if (team() == None || c.team() == team())
	{
		failCheckpoint(c);
	}
}

function OnAreaExited(Character c)
{
	// Do nothing
}

// Old approach was to touch the checkpoint
/*function Touch(Actor Other)
{
	local Character c;

	c = Character(Other);
	if (c == None)
		return;

	if (isAwaitingClient(PlayerCharacterController(c.Controller)))
		passCheckpoint(PlayerCharacterController(c.Controller), c.team());
	else
	{
		//c.ClientMessage("This isn't your current checkpoint");
		dispatchMessage(new class'MessageCheckpointFailed'(label, c.label, getTeamLabel() ));
	}
}*/

function failCheckpoint(Character c)
{
	//c.ClientMessage("This isn't your current checkpoint");
	dispatchMessage(new class'MessageCheckpointFailed'(label, c.label, getTeamLabel() ));
	Level.Game.BroadcastLocalized(self, CheckpointMessageClass, 0, c.tribesReplicationInfo, self);
}

function passCheckpoint(PlayerCharacterController c, TeamInfo t)
{
	local int p;

	bPassedEffect = true;
	updateCheckpointEffects();

	//c.ClientMessage("Checkpoint passed!  Proceed to next checkpoint");
	dispatchMessage(new class'MessageCheckpointPassed'(label, c.label, getTeamLabel() ));
	Level.Game.BroadcastLocalized(self, CheckpointMessageClass, 1, c.playerReplicationInfo, self);
	//Log("CHECKPOINT:  Checkpoint passed by "$c);

	// Could display lap time difference here

	p = getClientCheckpointDataIndex(c);
	// If the player hasn't already passed here, create a new entry
	if (p < 0)
		p = addPassedClient(c);

	// Advance the lap counter
	passedClientsList[p].lap = passedClientsList[p].lap + 1;

	// Set a timestamp
	passedClientsList[p].lastTimePassed = Level.TimeSeconds;

	// Advance the passed player's next checkpoint
	advanceCheckpoint(c);

	if (bFinishingPoint)
	{
		// Award a point for finishing the lap
		scoreTeam(teamPointsPerLap, t);

		// Check to see if this is the last lap
		if (passedClientsList[p].lap >= numLapsToFinish)
		{
			lastLapPassed(passedClientsList[p]);
		}
		// If it's not the last lap, inform the player
		else
		{
			//Log("CHECKPOINT:  Lap completed, rank = "$getClientRank(passedClientsList[p])$", plap = "$passedClientsList[p].lap$", finish = "$numLapsToFinish);
			//c.ClientMessage("Lap completed!  "$ (numLapsToFinish - passedClientsList[p].lap) $" laps to go");
			//c.ClientMessage("Your rank:  "$getClientRank(passedClientsList[p]));
		}
	}
}

function advanceCheckpoint(PlayerCharacterController c)
{
	// This checkpoint is no longer awaiting this player
	removeAwaitingClient(c);

	// The next checkpoint is now awaiting this player
	if (nextCheckpoint != None)
	{
		nextCheckpoint.addAwaitingClient(c);
		// Add waypoint here
		if (bUsePersonalObjectives)
			setPersonalObjective(c, selfCheckpointObjectiveDesc, nextCheckpoint);
	}
}

function bool isAwaitingClient(PlayerCharacterController c)
{
	local int i;

	for (i=0; i<awaitingClientsList.Length; i++)
	{
		if (awaitingClientsList[i] == c)
			return true;
	}

	return false;
}

function removeAwaitingClient(PlayerCharacterController c)
{
	local int i;

	for (i=0; i<awaitingClientsList.Length; i++)
	{
		if (awaitingClientsList[i] == c)
			awaitingClientsList.Remove(i, 1);
	}
}

function addAwaitingClient(PlayerCharacterController c)
{
	//Log("CHECKPOINT:  Checkpoint "$self$" is now awaiting client "$c);
	awaitingClientsList[awaitingClientsList.Length] = c;
}

function int getClientCheckpointDataIndex(PlayerCharacterController c)
{
	local int i;

	for (i=0; i<passedClientsList.Length; i++)
	{
		//Log("CHECKPOINT:  "$passedClientsList[i].client$" == "$c$"?");
		if (passedClientsList[i].client == c)
			return i;
	}

	return -1;
}

function int addPassedClient(PlayerCharacterController c)
{
	passedClientsList.Length = passedClientsList.Length + 1;
	passedClientsList[passedClientsList.Length - 1].client = c;

	//Log("CHECKPOINT:  Added passed client "$c);

	return passedClientsList.Length - 1;
}

function lastLapPassed(ClientCheckpointData p)
{
	//p.client.ClientMessage("You finished the race!  Final rank:  "$getClientRank(p));
	//Log("CHECKPOINT: FINISHED, rank = "$getClientRank(p));
	if (bUsePersonalObjectives)
		removePersonalObjective(p.client);

	// Remove the client from the next checkpoint
	nextCheckpoint.removeAwaitingClient(p.client);
}

function int getClientRank(ClientCheckpointData p)
{
	local int i;
	local int rank;
	local ClientCheckpointData compareClient;

	rank = 1;

	for (i=0; i<passedClientsList.Length; i++)
	{
		compareClient = passedClientsList[i];

		if (compareClient == p)
			continue;

		if (compareClient.lap > p.lap)
			rank++;
		else if (compareClient.lap == p.lap)
			if (compareClient.lastTimePassed < p.lastTimePassed)
				rank++;
	}

	return rank;
}

function reset()
{
	awaitingClientsList.Length = 0;

	if (bDontResetAfterPass)
	{
		bPassedEffect = false;
		updateCheckpointEffects();
	}

	// Recurse along the list until the end of the race
	if (nextCheckpoint != None && !bFinishingPoint)
	{
		nextCheckpoint.reset();
	}
}

function restartPlayer(PlayerCharacterController pcc)
{
	advanceCheckpoint(pcc);
}

// enumCheckpoints
function enumCheckpoints(Engine.LevelInfo l, out Array<Name> a)
{
	local MPCheckpoint c;

	ForEach DynamicActors(class'MPCheckpoint', c)
	{
		// Valid next checkpoints need to be the same team, neutral team, or any team if this checkpoint
		// is a neutral checkpoint.  Neutral checkpoints can be shared between teams.
		if (c.isA(Class.Name) && c != self && (c.team() == team() || team() == None || c.team() == None ))
			a[a.Length] = c.Label;
	}
}

defaultProperties
{
	DrawType				= DT_Mesh
	Mesh					= Mesh'MPGameObjects.MPCheckpoint'
	bCollideActors			= true
	bCollideWorld			= true
	bMovable				= false
	//bBlockPlayers			= false
	bNetNotify				= true
	NetUpdateFrequency		= 2

	selfCheckpointObjectiveDesc	= "Proceed to the next Checkpoint."
	CheckpointMessageClass	= class'MPCheckpointMessages'
	passedEffectEvent		= Passed
	failedEffectEvent		= Failed
	passAnimation			= Activate
	teamPointsPerLap		= 1
}