//=====================================================================
// AI_SquadPatrolGoal
//=====================================================================

class AI_SquadGuardGoal extends AI_SquadGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name engagementAreaCenterName "Label of the Actorthat defines the center of the area to be guarded - any enemy within this area will be attacked; an empty label is taken to mean the AI itself";
var(Parameters) float engagementAreaRadius "Radius of engagement area";
var(Parameters) Name movementAreaCenterName "Label of the Actor that defines the center of the area the AI can move around in to defend; an empty label is taken to mean the AI's spawn location";
var(Parameters) float movementAreaRadius "Radius of movement area (0 is taken to mean infinite/no restrictions)";
var(Parameters) bool removeDefaultGuardGoals "Remove squad members' already existing default guard goals?";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri,
							  Vector _engagementAreaCenter, Actor _engagementAreaTarget, float _engagementAreaRadius,
							  optional Vector _movementAreaCenter, optional Actor _movementAreaTarget, optional float _movementAreaRadius,
							  optional bool _removeDefaultGuardGoals )
{
	priority = pri;

	engagementAreaCenter = _engagementAreaCenter;
	engagementAreaTarget = _engagementAreaTarget;
	engagementAreaRadius = _engagementAreaRadius;
	movementAreaCenter = _movementAreaCenter;
	movementAreaTarget = _movementAreaTarget;
	movementAreaRadius = _movementAreaRadius;
	removeDefaultGuardGoals = _removeDefaultGuardGoals;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	engagementAreaRadius = 5000
	movementAreaRadius = 4000

	bRemoveGoalOfSameType = true

	bInactive = false
	bPermanent = false
	priority = 52
	removeDefaultGuardGoals = true
}

