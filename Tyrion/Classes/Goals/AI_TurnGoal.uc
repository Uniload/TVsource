//=====================================================================
// AI_TurnGoal
//=====================================================================

class AI_TurnGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Rotator facing;
var(Parameters) NS_Turn.TurnDirections turnDirection;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Rotator _facing, optional NS_Turn.TurnDirections _turnDirection )
{
	priority = pri;

	facing = _facing;
	turnDirection = _turnDirection;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false
}

