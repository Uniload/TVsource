class AircraftMoveAlongWaypoints extends NS_Action;

var int index;

var bool skipIntermediateNodes;
var float desiredSpeed;
var Rook attackTarget;

// Sets action parameters and starts action.
static function AircraftMoveAlongWaypoints startAction(AI_Controller c, ActionBase parent, bool skipIntermediateNodes,
													   float desiredSpeed, optional Rook attackTarget)
{
	local AircraftMoveAlongWaypoints action;

	// create new object
	action = new(c.level.Outer) class'AircraftMoveAlongWaypoints'(c, parent);

	// set action parameters
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
		log( name @ "(" @ controller.Pawn.name @ "): started" );

	for (index = 0; index < controller.routeCache.length; ++index)
	{
		if (skipIntermediateNodes)
			index = lookAhead(index);

		// do local move
		if ((index + 1) < controller.routeCache.length)
			waitForAction(class'AircraftDoLocalMove'.static.startAction(controller, self,
					controller.routeCache[index].location, 750, desiredSpeed, attackTarget, true,
					controller.routeCache[index + 1].location));
		else
			waitForAction(class'AircraftDoLocalMove'.static.startAction(controller, self,
					controller.routeCache[index].location, 750, desiredSpeed, attackTarget, false, vect(0,0,0)));

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

// Returns the largest index after the current index that corresponds to a point that can be reached directly
// from the current index.
function int lookAhead(int currentRouteCacheIndex)
{
	local int workIndex;
	workIndex = currentRouteCacheIndex + 1;
	while (workIndex < controller.routeCache.length &&
			controller.canPointBeReachedUsingAircraft(controller.routeCache[currentRouteCacheIndex].location,
			controller.routeCache[workIndex].location, controller.pawn))
	{
		++workIndex;
	}
	return workIndex - 1;
}