class CarMoveAlongWaypoints extends NS_Action;

var int index;

var float desiredSpeed;

// Sets action parameters and starts action.
static function CarMoveAlongWaypoints startAction(AI_Controller c, ActionBase parent, float desiredSpeed)
{
	local CarMoveAlongWaypoints action;

	// create new object
	action = new(c.level.Outer) class'CarMoveAlongWaypoints'(c, parent);

	// set action parameters
	action.desiredSpeed = desiredSpeed;

	action.runAction();
	return action;
}

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): started" );

	for (index = 0; index < controller.routeCache.length; ++index)
	{
		// do local move
		if ((index + 1) < controller.routeCache.length)
			waitForAction(class'CarDoLocalMove'.static.startAction(controller, self,
					controller.routeCache[index].location, 1000, desiredSpeed, true,
					controller.routeCache[index + 1].location));
		else
			waitForAction(class'CarDoLocalMove'.static.startAction(controller, self,
					controller.routeCache[index].location, 1000, desiredSpeed, false, vect(0,0,0)));

		// fail and propagate error if failure
		if (errorCode != ACT_SUCCESS)
		{
			fail(errorCode);
		}
	}

	// fail and propagate error if failure
	if (errorCode != ACT_SUCCESS)
	{
		fail(errorCode);
	}

	succeed();
}