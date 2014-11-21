class MPRabbitFlag extends MPCarryable;
var() int	timerInterval			"The number of seconds that pass between scoring of points for the flag carrier";
var() int	pointsPerInterval		"The number of points awarded each interval";

var(Stats) class<Stat>	timeHeldStat		"The stat that is used to track longest time held";
var(Stats) class<Stat>	rabidRabbitStat		"The stat awarded when the rabbit kills a chaser";

var int timeHeld;
var TeamInfo oldTeam;
var TeamInfo enemyTeam;

function registerStats(StatTracker tracker)
{
	local ModeInfo mode;

	Super.registerStats(tracker);
	tracker.registerStat(timeHeldStat);
	tracker.registerStat(rabidRabbitStat);

	mode = ModeInfo(Level.Game);

	if (mode != None && rabidRabbitStat != None)
	{
		mode.registerPlayerKillListener(self);
	}
}

function onPickedUp(Character c)
{
	if (c == None)
		return;

	// Put the carrier on a new, temporary enemy team
	enemyTeam = spawn(c.team().Class);
	oldTeam = c.team();
	c.setTeam(enemyTeam);

	// Start a scoring timer here
	SetTimer(timerInterval, true);
}

function onDropped(Controller c)
{
	// Put dropping player back on old team
	enemyTeam.destroy();
	if (c.Pawn != None)
	{
		Character(c.Pawn).setTeam(oldTeam);
	}
	else
		TribesReplicationInfo(c.PlayerReplicationInfo).team = oldTeam;

	// Stop scoring timer
	SetTimer(0, false);
	timeHeld = 0;
}

function onPlayerKilled(Controller Killer, Controller Target)
{
	Super.onPlayerKilled(Killer, Target);

	if (Killer == carrierController && rabidRabbitStat != None)
		awardStat(rabidRabbitStat, Character(Killer.Pawn), Target);
}

state Held
{
	function Timer()
	{
		timeHeld += timerInterval;

		// Track time held
		if (timeHeldStat != None && timeHeld > TribesReplicationInfo(carrierController.PlayerReplicationInfo).getStatData(timeHeldStat).amount)
			ModeInfo(Level.Game).Tracker.setStat(carrierController, timeHeldStat, timeHeld);

		scoreIndividual(carrier, pointsPerInterval);
	}
}

defaultproperties
{
	CollisionRadius			= 45
	CollisionHeight			= 100
	returnTime				= 30
	elasticity				= 0.05	

	timerInterval			= 1
	pointsPerInterval		= 1
}