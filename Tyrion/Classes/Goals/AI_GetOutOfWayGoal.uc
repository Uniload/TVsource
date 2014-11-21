//=====================================================================
// AI_GetOutOfWayGoal
//=====================================================================

class AI_GetOutOfWayGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Constants

const DEACTIVATION_DELAY = 5;			// goal deactivates after this many seconds

//=====================================================================
// Variables

var(Parameters) Rook avoidee;			// rook I'm avoiding
var(Parameters) Vector aimLocation;		// where the avoidee is shooting

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Rook avoidee, Vector aimLocation )
{
	priority = pri;

	self.avoidee = avoidee;
	self.aimLocation = aimLocation;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_GetOutOfWaySensor', characterResource(),,, self );
}

//---------------------------------------------------------------------
// Setup deactivation sentinel

function setUpDeactivationSentinel()
{
	local int timerValue;

	// deactivate after a specified amount of time
	timerValue = DEACTIVATION_DELAY +
		AI_SensorResource( class'Setup'.static.GetStaticSensorResource() ).globalSensorAction.timer.queryIntegerValue();
	deactivationSentinel.activateSentinel( self, class'AI_TimerSensor', None, timerValue, timerValue, None );

	avoidee = Rook(AI_GetOutOfWaySensor(activationSentinel.sensor).value.objectData);
	aimLocation = AI_GetOutOfWaySensor(activationSentinel.sensor).aimLocation;
	//log( "====" @ resource.pawn().name @ "sticking avoidee into goal:" @ avoidee.name @ class'Pawn'.static.checkAlive(avoidee) $ ". Switch off at" @ timerValue );
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true
	priority = 60
}


