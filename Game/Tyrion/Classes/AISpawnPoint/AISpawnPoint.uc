class AISpawnPoint extends Engine.Actor
	placeable;

var() class<BaseAICharacter> spawnAICharacterClass;
var() Name aiCharacterLabel;
var() bool bDisallowEquipmentDropOnDeath;

var() editdisplay(displayActorLabel)
	  editcombotype(enumTeamInfo)
	  Gameplay.TeamInfo team;

var() editdisplay(displayActorLabel)
	  editcombotype(enumSquadInfo)
	  SquadInfo squad;

var() editinline array< class<AI_Goal> > goals;

var int numSpawns;
var() int maxNumSpawns "The maximum number of AIs allowed to spawn (-1 for infinite)";
var() float deathDelay "The delay before respawning after receiving the death message";
var() float deathDelayMax "If set, will use the deathDelay as a min and generate a random death delay between deathDelay and deathDelayMax";
var() float spawnAttemptRate "The rate at which subsequent spawn attempts will be made if a spawn fails";
var() private bool enabled;

var(AI)	float SightRadius "maximum distance at which non-player characters can be seen";
var(AI) float SightRadiusToPlayer "maximum distance at which player characters can be seen";

function PreBeginPlay()
{
	super.PreBeginPlay();

	registerMessage(class'MessageDeath', aiCharacterLabel);
	registerMessage(class'MessageLevelStart', "GameInfo");
}

simulated function PrecacheSpeech(SpeechManager Manager)
{
	if (spawnAICharacterClass != None)
		Manager.PrecacheAIVoiceSet(spawnAICharacterClass.default.VoiceSetPackageName);
}

function onMessage(Message msg)
{
	if (msg.IsA('MessageDeath'))
	{
		if (deathDelayMax != 0.0)
			SetTimer(FRand() * (deathDelayMax - deathDelay) + deathDelay, false);
		else if (deathDelay > 0.0)
			SetTimer(deathDelay, false);
		else
			doSpawn();
	}
	else
	{
		doSpawn();
	}
}

function Timer()
{
	doSpawn();
}

function enableSpawning()
{
	enabled = true;
	numSpawns = 0;
	doSpawn();
}

function disableSpawning()
{
	enabled = false;
}

function doSpawn()
{
	local BaseAICharacter c;
	local int i;
	local AI_Goal goal;

	if (enabled)
	{
		c = Spawn(spawnAICharacterClass,,, Location, Rotation);

		if (c != None)
		{
			++numSpawns;

			c.Label = aiCharacterLabel;
			c.bDisallowEquipmentDropOnDeath = bDisallowEquipmentDropOnDeath;

			c.SetTeam(team);
			c.SetSquad(squad);

			c.SightRadius = SightRadius;
			c.SightRadiusToPlayer = SightRadiusToPlayer;

			// If there are any default goals with the same name as a goal in the goal list, we want
			// the default goal to be removed so set its priority to zero so it will get removed in
			// the resources init function
			for (i = 0; i < goals.length; ++i)
			{
				goal = class'AI_Goal'.static.findGoalByName(c, goals[i].default.goalName);

				if (goal != None)
					goal.priority = 0;
			}

			// Add the goals from the goal list to the newly spawned character
			for (i = 0; i < goals.length; i++)
			{
				if (goals[i] != None)
					goals[i].static.findResource(c).assignGoal(goals[i]);
			}

			dispatchMessage(new class'MessageAISpawned'(Label, aiCharacterLabel));
		}
		else
		{
			SetTimer(spawnAttemptRate, false);
		}

		if (numSpawns == maxNumSpawns)
			disableSpawning();
	}
}

function string displayActorLabel(Actor t)
{
	return string(t.label);
}

function enumTeamInfo(Engine.LevelInfo l, out Array<TeamInfo> s)
{
	local TeamInfo t;

	ForEach l.AllActors(class'TeamInfo', t)
	{
		s[s.Length] = t;
	}
}

function enumSquadInfo(Engine.LevelInfo l, out Array<SquadInfo> s)
{
	local SquadInfo t;

	ForEach l.AllActors(class'SquadInfo', t)
	{
		s[s.Length] = t;
	}
}

defaultproperties
{
	bDirectional = true
	Texture = Texture'Engine_res.S_Teleport'
	RemoteRole = ROLE_None
	bHidden = true
	enabled = true
	spawnAttemptRate = 1.0
	maxNumSpawns = -1

	SightRadius					= 6000.0
	SightRadiusToPlayer			= 12000.0
}