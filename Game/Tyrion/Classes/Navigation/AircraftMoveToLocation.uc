class AircraftMoveToLocation extends NS_Action;

var vector destination;
var bool skipIntermediateNodes;
var float desiredSpeed;
var Rook attackTarget;

var Controller.FindPathAIProperties workAIProperties;

var array<Actor> ignore;

// Sets action parameters and starts action.
static function AircraftMoveToLocation startAction(AI_Controller c, ActionBase parent, vector destination, bool skipIntermediateNodes,
		float desiredSpeed, optional Rook attackTarget)
{
	local AircraftMoveToLocation action;

	// create new object
	action = new(c.level.Outer) class'AircraftMoveToLocation'(c, parent);

	// set action parameters
	action.destination = destination;
	action.skipIntermediateNodes = skipIntermediateNodes;
	action.desiredSpeed = desiredSpeed;
	action.attackTarget = attackTarget;

	action.runAction();
	return action;
}

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started (dist:" @ VDist( destination, controller.Pawn.Location ) @ ")");

	workAIProperties.airborne = true;

	controller.findPath(controller.Pawn.Location, destination, workAIProperties, ignore, controller.Pawn.logNavigationSystem);

	// wait for find path to complete
	while (class'Pawn'.static.checkAlive(controller.pawn) && !controller.isFindPathComplete())
	{
		sleep(0.0);
	}

	// handle case of death while waiting
	if (class'Pawn'.static.checkDead(controller.pawn))
		fail(ACT_ALL_RESOURCES_DIED);

	controller.getFindPathResult();
	controller.discardFindPath();

	// move along wapoints
	waitForAction(class'AircraftMoveAlongWaypoints'.static.startAction(controller, self, skipIntermediateNodes, desiredSpeed, attackTarget));

	// fail and propagate error if failure
	if (errorCode != ACT_SUCCESS)
	{
		fail(errorCode);
	}

	succeed();
}