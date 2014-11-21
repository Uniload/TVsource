//=====================================================================
// AI_BucklerDeflectGoal
//=====================================================================

class AI_BucklerDeflectGoal extends AI_WeaponGoal
	editinlinenew;

//=====================================================================
// Constants

const DEACTIVATION_DELAY = 5;			// goal deactivates after this many seconds

//=====================================================================
// Variables

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri )
{
	super.construct( r );

	priority = pri;
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_DodgeSensor', characterResource(),, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
	// goal is deactivated after a fixed amount of time
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
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true
	priority = 99
}

