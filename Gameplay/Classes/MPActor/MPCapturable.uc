class MPCapturable extends MPCarryable;

var bool					bAllowEnemyReturn			"When true, enemies will return this capturable to its home location when they touch it (NOT YET IMPLEMENTED)";

var(Stats) class<Stat>		returnStat					"The stat awarded for returning this capturable";
var(Stats) class<Stat>		captureStat					"The stat awarded for capturing this capturable";
var(Stats) class<Stat>		timelyReturnStat			"The stat awarded for returning a capturable in order for a teammate to capture";
var(Stats) int				timelyReturnSeconds			"The number of seconds between capturing and returning to be considered a timely return";

var MPCapturePoint	homeCapturePoint;	// Automatically set by an MPCapturePoint

function registerStats(StatTracker tracker)
{
	Super.registerStats(tracker);
	tracker.registerStat(captureStat);
	tracker.registerStat(returnStat);
	tracker.registerStat(timelyReturnStat);
	tracker.registerStat(defendStat);
}

function returnToHome(optional bool bForced)
{

	Super.returnToHome(bForced);

	if (homeCapturePoint != None)
		homeCapturePoint.onHomeCapturableReturned();
}

function Vector chooseHomeLocation()
{
	if (homeCapturePoint != None)
		return homeCapturePoint.Location + homeCapturePoint.homeCapturableOffset;
	else
		return Super.chooseHomeLocation();
}

// onCapture
function onCapture(Character c)
{
	awardStat(captureStat, c);
	dispatchMessage(new class'MessageCapturableCaptured'(label, carrier.label, carrier.getTeamLabel() ));
	returnToHome();
}

// scoreReturn
function scoreReturn(Character instigator)
{
	awardStat(returnStat, instigator);
}

function onPickedUp(Character c)
{
	//Level.Game.BroadcastLocalized(self, class'MPCapturableMessages', 1, team());
}

function bool validCarrier(Character c, optional bool ignoreLastCarrierCheck)
{
	// Valid only if collider is neutral or enemy
	if (c.team() == team())
		return false;

	return Super.validCarrier(c, ignoreLastCarrierCheck);
}

// Dropped state
state Dropped
{
	function onCharacterPassedThrough(Character c)
	{
		if (c.team() != team())
			return;

		// Return the flag home if a player passes through his own team's flag while dropped
		// Display a secondary message
		if (SecondaryMessageClass != None)
			Level.Game.BroadcastLocalized(self, SecondaryMessageClass, 2, c.tribesReplicationInfo);

		dispatchMessage(new class'MessageCarryableReturned'(label));
		scoreReturn(c);
		returnToHome(true);
	}

	// return timer
	function Timer()
	{
		//Level.Game.BroadcastLocalized(self, class'MPFlagMessages', 3, team());
		Super.Timer();
	}
}

defaultproperties
{
	CollisionRadius			= 120
	CollisionHeight			= 100
	GravityScale			= 1.0
	
	returnTime				= 20
	elasticity				= 0.05	

	bAllowEnemyReturn		= true
}