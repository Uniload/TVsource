//=====================================================================
// NS_DoElevatorMove
//
// Moves a character through an elevator.
//=====================================================================

class NS_DoElevatorMove extends NS_Action;

//=====================================================================
// Variables

var ZeroGravityVolume zeroGravityVolume;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Character is assumed to be adjacent to the zero gravity volume

static function NS_DoElevatorMove startAction(AI_Controller c, ActionBase parent,
		ZeroGravityVolume zeroGravityVolume)
{
	local NS_DoElevatorMove action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_DoElevatorMove'( c, parent );

	// set action parameters
	action.zeroGravityVolume = zeroGravityVolume;

	action.runAction();
	return action;
}

state Running
{
Begin:

	
}