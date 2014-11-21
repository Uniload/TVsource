//=====================================================================
// AI_GunnerGuardGoal
// Engages any enemies within a specified area around a gunnerResource
//=====================================================================

class AI_GunnerGuardGoal extends AI_GunnerGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float engagementAreaRadius "Radius of engagement area";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vehicle.VehiclePositionType aPosition, float aEngagementAreaRadius )
{
	priority = pri;

	position = aPosition;
	engagementAreaRadius = aEngagementAreaRadius;

	super.construct( r );	// "init" called from this function so "position" has to be set
}

//---------------------------------------------------------------------

function init( AI_Resource r )
{
	local Vehicle v;

	super.init( r );

	v = Vehicle(r.pawn());
	// only activate goal if position matches this resource
	if ( v == None || v.getPositionIndex( position ) == AI_MountResource(r).index )
	{
		//log( "Setting up GuardSensor for on" @ r.localRook().name @ "on" @ v.name );
		// userData is always 'None' for deactivation sensors, and != None for activation sensors
		activationSentinel.activateSentinel( self, class'AI_GuardSensor', r,, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
		AI_GuardSensor(activationSentinel.sensor).setParameters( engagementAreaRadius, r.localRook().Location, r.localRook() );
	}
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

	bInactive = true
	bPermanent = true
	priority = 50
}

