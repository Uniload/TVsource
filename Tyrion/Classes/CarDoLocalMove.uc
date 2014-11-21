class CarDoLocalMove extends NS_Action
	native;

var vector destination;
var float terminalDistance;
var float speed;
var bool nextDestinationValid;
var vector nextDestination;

// Sets action parameters and starts action.
static function CarDoLocalMove startAction(AI_Controller c, ActionBase parent, vector destination,
		float terminalDistance, float speed, bool nextDestinationValid, vector nextDestination)
{
	local CarDoLocalMove action;

	// create new object
	action = new(c.level.Outer) class'CarDoLocalMove'(c, parent);

	// set action parameters
	action.destination = destination;
	action.terminalDistance = terminalDistance;
	action.speed = speed;
	action.nextDestinationValid = nextDestinationValid;
	action.nextDestination = nextDestination;

	action.runAction();
	return action;
}

function cleanUp()
{
	super.cleanUp();

	controller.carLocalMoveAction = None;

	// tells low level navigation that there is nothing running
	controller.vehicleNavigationFunctionIndex = 0;
}

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started" );

	controller.carDoLocalMove(self);

	// propagate error if failure
	switch(controller.vehicleDoLocalMoveResult)
	{
	case VDLM_SUCCESS:		
		succeed();
		break;
	}

	assert(false);
}

defaultproperties
{
}
