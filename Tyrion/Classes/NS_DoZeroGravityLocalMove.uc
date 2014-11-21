//=====================================================================
// NS_DoZeroGravityLocalMove
//
// Encapsulates the native latent function doZeroGravityLocalMove
// within a Navigation System action.
//=====================================================================

class NS_DoZeroGravityLocalMove extends NS_Action
	native
	threaded
	dependson(AI_Controller);

//=====================================================================
// Constants

//=====================================================================
// Variables

var vector destination;
var ElevatorVolume elevator;
var float terminalDistanceXY;
var float terminalDistanceZ;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Character is assumed to be within a zero gravity volume when this
// function is called.

static function NS_DoZeroGravityLocalMove startAction( AI_Controller c, ActionBase parent, vector destination, ElevatorVolume elevator,
		float terminalDistanceXY, float terminalDistanceZ)
{
	local NS_DoZeroGravityLocalMove action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_DoZeroGravityLocalMove'( c, parent );

	// set action parameters
	action.destination = destination;
	action.elevator = elevator;
	action.terminalDistanceXY = terminalDistanceXY;
	action.terminalDistanceZ = terminalDistanceZ;

	action.runAction();
	return action;
}

function cleanup()
{
	super.cleanup();

	controller.zeroGravityMoveAction = None;
}

//=====================================================================
// States

state Running
{
Begin:

	if (controller.Pawn.logNavigationSystem)
		log( name $ ": zero gravity move to " @ destination @ "started" );

	controller.doZeroGravityLocalMove(self);

	switch(controller.zeroGravityMoveResult)
	{
	case DZGLM_SUCCESS:		
		succeed();
		break;
	}

	warn("unknown zero gravity move result");
}

defaultproperties
{
}
