//=====================================================================
// AI_DodgeGoal
//
// This goal is activated by the dodgeSensor. The dodgeSensor sets the AI_Controller's "dodgeDisplacement"
// as a side effect. This is a weird thing for a sensor to do, but it's more efficient than having the
// AI_controller request dodgeDisplacement values regardless of whether the character can dodge or not.
//
// The bottom line is that every character who can dodge should have a dodge goal so that the activation
// sensor keeps dodgeDisplacement updated.
//=====================================================================

class AI_DodgeGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Constants

const DEACTIVATION_DELAY = 5;			// goal deactivates after this many seconds

//=====================================================================
// Variables

var() Rook protectee "The object to be protected by the AI running the DodgeGoal (None: protect yourself)";
var() float shieldPackTime "use shield pack if impact in less than this many seconds (-1: disables shield pack)";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, optional Rook _protectee, optional float _shieldPackTime )
{
	super.construct( r );

	priority = pri;

	protectee = _protectee;

	if ( _shieldPackTime == 0 )
		shieldPackTime = default.shieldPackTime;
	else
		shieldPackTime = _shieldPackTime;
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_DodgeSensor', characterResource(),, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
	AI_DodgeSensor(activationSentinel.sensor).setParameters( protectee, shieldPackTime );
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

//---------------------------------------------------------------------
// returns the priority of this goal

event int priorityFn()
{
	// bump up goal priority if AI not moving...
	if ( achievingAction != None ||								// action has started: keep priority stable
		(resource != None && AI_Controller(resource.pawn().controller).dlm == None ))	// no doLocalMove running
	{
		// the AI is not being moved by Tyrion
		//log( "goal priority bumped!" );
		return 99;
	}
	else
		return priority;
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true
	priority = 10

	protectee		= None
	shieldPackTime	= 0.5f
}

