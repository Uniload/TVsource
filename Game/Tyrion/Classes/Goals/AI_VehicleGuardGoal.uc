//=====================================================================
// AI_VehicleGuardGoal
// Engages any enemies within a specified area around a turret
//=====================================================================

class AI_VehicleGuardGoal extends AI_VehicleGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float engagementAreaRadius "Radius of engagement area";

//=====================================================================
// Functions

//---------------------------------------------------------------------

overloaded function construct( AI_Resource r, int pri, float _engagementAreaRadius )
{
	priority = pri;

	engagementAreaRadius = _engagementAreaRadius;

	super.construct( r );
}

//---------------------------------------------------------------------

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_GuardSensor', r,, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
	AI_GuardSensor(activationSentinel.sensor).setParameters( engagementAreaRadius, r.pawn().Location, r.pawn() );
}

//---------------------------------------------------------------------
// Setup deactivation sentinel

function setUpDeactivationSentinel()
{
	deactivationSentinel.activateSentinel( self, class'AI_GuardSensor', resource,, class'AI_Sensor'.const.ONLY_NONE_VALUE, None ); 
}

//=====================================================================

defaultproperties
{
	engagementAreaRadius = 10000

	bRemoveGoalOfSameType = true

	bInactive = true
	bPermanent = true
	priority = 40
}

