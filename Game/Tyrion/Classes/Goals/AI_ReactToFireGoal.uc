//=====================================================================
// AI_ReactToFireGoal
//=====================================================================

class AI_ReactToFireGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters)	float panicChance "chance of panicking when being shot at by an unseen assailant";
var(Parameters) float nearHitDistance "Max distance to react to near hit";
var(Parameters) float allyShotDistance "Max distance to react to an ally getting shot";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, float _panicChance, float _nearHitDistance, float _allyShotDistance )
{
	priority = pri;

	panicChance = _panicChance;
	nearHitDistance = _nearHitDistance;
	allyShotDistance = _allyShotDistance;

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

	panicChance = 0.0f
	nearHitDistance = 1000
	allyShotDistance = 2000
}

