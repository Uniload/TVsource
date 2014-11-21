class CarMoveToLocation extends NS_Action;

var vector destination;
var float desiredSpeed;

var Controller.FindPathAIProperties workAIProperties;

var array<Actor> ignore;

// Sets action parameters and starts action.
static function CarMoveToLocation startAction(AI_Controller c, ActionBase parent, vector destination, float desiredSpeed)
{
	local CarMoveToLocation action;

	// create new object
	action = new(c.level.Outer) class'CarMoveToLocation'(c, parent);

	// set action parameters
	action.destination = destination;
	action.desiredSpeed = desiredSpeed;

	action.runAction();
	return action;
}

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started" );

	workAIProperties.roadBased = true;

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
	waitForAction(class'CarMoveAlongWaypoints'.static.startAction(controller, self, desiredSpeed));

	// put hand brake on
	if (Buggy(controller.pawn) != None)
		Buggy(controller.pawn).diveInput = true;

	// fail and propagate error if failure
	if (errorCode != ACT_SUCCESS)
	{
		fail(errorCode);
	}

	succeed();
}