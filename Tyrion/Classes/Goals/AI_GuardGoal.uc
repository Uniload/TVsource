//=====================================================================
// AI_GuardGoal
// Engages any enemies within a specified area
// Doesn't require movement resource
//=====================================================================

class AI_GuardGoal extends AI_CharacterGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Name engagementAreaCenterName "Label of the Actor that defines the center of the area to be guarded - any enemy within this area will be attacked; On Protectors this denotes the thing to be protected; an empty label is taken to mean the AI itself";
var(Parameters) float engagementAreaRadius "Radius of engagement area";
var(Parameters) Name movementAreaCenterName "Label of the Actor that defines the center of the area the AI can move around in to defend; an empty label is taken to mean the AI's spawn location";
var(Parameters) float movementAreaRadius "Radius of movement area (0 is taken to mean infinite/no restrictions)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Vector engagementAreaCenter;
var(InternalParameters) editconst Actor engagementAreaTarget;
var(InternalParameters) editconst Vector movementAreaCenter;
var(InternalParameters) editconst Actor movementAreaTarget;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri,
							  Vector _EngagementAreaCenter, Actor _engagementAreaTarget, float _engagementAreaRadius,
							  optional Vector _movementAreaCenter, optional Actor _movementAreaTarget, optional float _movementAreaRadius,						  
							  optional IWeaponSelectionFunction _weaponSelection,
							  optional class<Weapon> _preferredWeaponClass )
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
	priority = 51
}

