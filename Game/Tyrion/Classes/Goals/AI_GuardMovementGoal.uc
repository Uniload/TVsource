//=====================================================================
// AI_GuardMovementGoal
// Handles non-attack related movement for Guard 
//=====================================================================

class AI_GuardMovementGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(InternalParameters) editconst Vector movementAreaCenter;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector aMovementAreaCenter )
{
	priority = pri;

	movementAreaCenter = aMovementAreaCenter;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_EnemySensor', characterResource(), 0, 0, self );
	AI_EnemySensor(activationSentinel.sensor).setParameters();
}

//---------------------------------------------------------------------
// Setup deactivation sentinel

function setUpDeactivationSentinel()
{
	deactivationSentinel.activateSentinel( self, class'AI_EnemySensor', characterResource(), 1, 9999999, None ); 
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true
	priority = 39
}

