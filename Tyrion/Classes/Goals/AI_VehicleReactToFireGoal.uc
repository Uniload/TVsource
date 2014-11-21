//=====================================================================
// AI_VehicleReactToFireGoal
//=====================================================================

class AI_VehicleReactToFireGoal extends AI_VehicleGoal
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) float nearHitDistance "Max distance to react to near hit";
var(Parameters) float allyShotDistance "Max distance to react to an ally getting shot";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, float aNearHitDistance, float aAllyShotDistance )
{
	priority = pri;
	nearHitDistance = aNearHitDistance;
	allyShotDistance = aAllyShotDistance;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_ReactToFireSensor', resource, 1, 1, self );
	// goal is not deactivated - AI_ReactToFire action runs its course
}

//=====================================================================

defaultproperties
{
	priority = 35
	bInactive = true
	bPermanent = true

	nearHitDistance = 1000
	allyShotDistance = 2000
}

