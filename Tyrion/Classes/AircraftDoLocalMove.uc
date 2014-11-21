class AircraftDoLocalMove extends NS_Action
	native;

var vector destination;
var float terminalDistance;
var float speed;
var bool nextDestinationValid;
var vector nextDestination;
var Rook target;

// Sets action parameters and starts action.
static function AircraftDoLocalMove startAction(AI_Controller c, ActionBase parent, vector destination,
		float terminalDistance, float speed, Rook target, bool nextDestinationValid, vector nextDestination)
{
	local AircraftDoLocalMove action;

	// create new object
	action = new(c.level.Outer) class'AircraftDoLocalMove'(c, parent);

	// set action parameters
	action.destination = destination;
	action.terminalDistance = terminalDistance;
	action.speed = speed;
	action.nextDestinationValid = nextDestinationValid;
	action.nextDestination = nextDestination;
	action.target = target;

	action.runAction();
	return action;
}

function cleanup()
{
	super.cleanup();

	controller.aircraftLocalMoveAction = None;

	controller.aircraftAttacking = false;

	// tells low level navigation that there is nothing running
	controller.vehicleNavigationFunctionIndex = 0;
}

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started" );

	controller.aircraftDoLocalMove(self);

	// propagate error if failure
	switch(controller.vehicleDoLocalMoveResult)
	{
	case VDLM_SUCCESS:		
		succeed();
		break;
	case VDLM_TIMED_OUT:
		fail(ACT_ErrorCodes.ACT_TIME_LIMIT_EXCEEDED);
		break;
	}

	assert(false);
}

defaultproperties
{
}
