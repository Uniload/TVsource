//=====================================================================
// AI_GuardAttackGoal
// Engages any enemies within a specified area
// Doesn't require movement resource
//=====================================================================

class AI_GuardAttackGoal extends AI_CharacterGoal;

//=====================================================================
// Variables

var(InternalParameters) float engagementAreaRadius "Radius of engagement area";
var(InternalParameters) float movementAreaRadius "Radius of movement area";
var(InternalParameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri,
							  Vector _engagementAreaCenter, Actor _engagementAreaTarget, float _engagementAreaRadius,
							  optional Vector _movementAreaCenter, optional Actor _movementAreaTarget, optional float _movementAreaRadius,						  
							  optional IWeaponSelectionFunction _weaponSelection,
							  optional class<Weapon> _preferredWeaponClass, optional IFollowFunction _followFunction )
{
	priority = pri;

	engagementAreaCenter = _engagementAreaCenter;
	engagementAreaTarget = _engagementAreaTarget;
	engagementAreaRadius = _EngagementAreaRadius;
	movementAreaCenter = _movementAreaCenter;
	movementAreaTarget = _movementAreaTarget;
	movementAreaRadius = _movementAreaRadius;
	weaponSelection = _weaponSelection;
	preferredWeaponClass = _preferredWeaponClass;
	followFunction = _followFunction;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called when a goal is removed

function cleanup()
{
	super.cleanup();

	followFunction = None;
	weaponSelection = None;
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_GuardSensor', r,, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
	AI_GuardSensor(activationSentinel.sensor).setParameters( engagementAreaRadius, engagementAreaCenter, engagementAreaTarget );
}

//---------------------------------------------------------------------
// Setup deactivation sentinel

function setUpDeactivationSentinel()
{
	deactivationSentinel.activateSentinel( self, class'AI_GuardSensor', resource,, class'AI_Sensor'.const.ONLY_NONE_VALUE, None ); 
}

//---------------------------------------------------------------------
// returns the priority of this goal

event int priorityFn()
{
	local float distanceSquared;

	// lower goal priority if outside movementArea
	if ( resource != None )
	{						
		if ( movementAreaTarget == None )
			distanceSquared = VDistSquared( movementAreaCenter, resource.pawn().Location );
		else
			distanceSquared = VDistSquared( movementAreaTarget.Location, resource.pawn().Location );
		
		if ( distanceSquared > movementAreaRadius * movementAreaRadius )
		{
			//log( "goal priority debumped!" );
			return priority-2;
		}
	}

	return priority;
}

//=====================================================================

defaultproperties
{
	engagementAreaRadius = 5000
	movementAreaRadius = 4000

	bInactive = true
	bPermanent = true
	priority = 40
}

