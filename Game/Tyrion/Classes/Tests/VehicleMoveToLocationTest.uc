class VehicleMoveToLocationTest extends TyrionUnitTest;

var (VehicleMoveToLocationTest) Character driver;
var (VehicleMoveToLocationTest) Vehicle vehicle;
var (VehicleMoveToLocationTest) float desiredSpeed;
var (VehicleMoveToLocationTest) bool attack;
var (VehicleMoveToLocationTest) array<vector> attackRoute;

var vector destination;

var NS_Action action;

var AI_Controller workController;

var Rook attackTarget;

var int index;

state UnitTestState
{
	function BeginState()
	{
		destination = location;

		// get AI controller
		workController = AI_Controller(driver.Controller);
		if (workController == None)
		{
			signalFailed(string(driver.name) $ " does not have an AI_Controller.");
			return;
		}
	}

Begin:

	// have AI enter vehicle
	if (!(vehicle.tryToDrive(driver)))
	{
		signalFailed("AI driver was not able to enter vehicle.");
		goto('End');
	}

	if (!attack)
	{
		log("BuggyMoveToLocation started");
		if (Buggy(vehicle) != None)
		{
			log("Car");
			action = class'CarMoveToLocation'.static.startAction(workController, None, destination, desiredSpeed).myAddRef();
		}
		else if (JointCOntrolledAircraft(vehicle) != None)
		{
			log("Aircraft");
			action = class'AircraftMoveToLocation'.static.startAction(workController, None, destination, true, 1500).myAddRef();
		}
		else
			assert(false);

ActionWait:
		if (!action.hasCompleted())
		{
			Sleep(1.0);
			goto 'ActionWait';
		}
	}
	else
	{
		// get attack target
		attackTarget = Rook(level.getLocalPlayerController().Pawn);
		if (attackTarget == None)
			signalFailed("failed to get attack target");

		if (attackRoute.length < 2)
			signalFailed("attack route length less than 2");

		index = 0;

AttackStart:
		if ( action != None )
		{
			action.Release();
			action = None;
		}

		action = class'AircraftDoLocalMove'.static.startAction(workController, None,
				attackRoute[index], 750, 1500, attackTarget, false, vect(0,0,0)).myAddRef();

AttackActionWait:
		if (!action.hasCompleted())
		{
			Sleep(1.0);
			goto 'AttackActionWait';
		}

		++index;
		if (index == attackRoute.length)
			index = 0;

		if (workController == None || Vehicle(workController.Pawn) == None)
			goto('End');

		goto('AttackStart');

	}

	signalPassed();

End:
	if ( action != None )
	{
		action.Release();
		action = None;
	}
}

defaultProperties
{
	desiredSpeed = 2250
	attack = false
}