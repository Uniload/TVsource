class NavigationStressTest extends TyrionUnitTest;

var() array<name> names;
var() array<vector> destinations;

var array<pawn> rooks;

var array<AI_Controller> controllers;

var array<NS_Action> actions;

var array<vector> startLocations;

var array<int> goingTo;

var vector workVectorA;

var int workIndex;

var NS_MoveToLocation.TerminalConditions terminalConditions;

state UnitTestState
{
	function BeginState()
	{
		local int rookIndex;
		local int controllerIndex;

		if (names.Length != destinations.Length)
		{
			signalFailed("Number of pawns does not match number of destinations.");
			return;
		}

		// get specified pawns
		rooks.Length = destinations.Length;
		for (rookIndex = 0; rookIndex < rooks.Length; ++rookIndex)
		{
			rooks[rookIndex] = getPawn(string(names[rookIndex]));
			if ((rooks[rookIndex] == None) || ((rookIndex != 0) && rooks[rookIndex] == rooks[rookIndex - 1]))
			{
				signalFailed("Failed to find Pawn named " $ string(names[rookIndex]) $ ".");
				return;
			}
		}

		// get AI controllers
		controllers.Length = rooks.Length;
		for (controllerIndex = 0; controllerIndex < controllers.Length; ++controllerIndex)
		{
			controllers[controllerIndex] = AI_Controller(rooks[controllerIndex].controller);
			if (controllers[controllerIndex] == None)
			{
				signalFailed("Rook without an AI_Controller.");
				return;
			}
		}

		// get start locations
		startLocations.Length = rooks.Length;
		for (controllerIndex = 0; controllerIndex < controllers.Length; ++controllerIndex)
		{
			startLocations[controllerIndex] = rooks[controllerIndex].Location;
		}

		goingTo.Length = rooks.Length;
	}

Begin:

	logTest("Stress Test Started");

	// start move actions
	actions.Length = controllers.Length;
	for (workIndex = 0; workIndex < controllers.Length; ++workIndex)
	{
		assert(controllers[workIndex] != None);
//		log("Starting move for " $ string(rooks[workIndex].name) $ " who has controller " $
//				controllers[workIndex].name $ ".");
		terminalConditions.distanceXY = 1000;
		terminalConditions.distanceZ = 1000;
		actions[workIndex] = class'NS_MoveToLocation'.static.startAction(controllers[workIndex], None,
				destinations[workIndex], None, , , , , terminalConditions).myAddRef();
		goingTo[workIndex] = 1;
	}

	// restart any actions that are finished
	workIndex = 0;
ActionWait:
	for (workIndex = 0; workIndex < controllers.Length; ++workIndex)
	{
		assert(controllers[workIndex] != None);

		if (!actions[workIndex].hasCompleted())
			continue;

		terminalConditions.distanceXY = 1000;
		terminalConditions.distanceZ = 1000;

		if ( actions[workIndex] != None )
		{
			actions[workIndex].Release();
			actions[workIndex] = None;
		}

		if (goingTo[workIndex] == 0)
		{
//			Log("Starting move to destination for " $ string(rooks[workIndex].name) $ " who has controller " $
//					controllers[workIndex].name $ ".");
			actions[workIndex] = class'NS_MoveToLocation'.static.startAction(controllers[workIndex], None,
					destinations[workIndex], None, , , , , terminalConditions).myAddRef();

			goingTo[workIndex] = 1;
		}
		else
		{
//			Log("Starting move to start for " $ string(rooks[workIndex].name) $ " who has controller " $
//					controllers[workIndex].name $ ".");
			actions[workIndex] = class'NS_MoveToLocation'.static.startAction(controllers[workIndex], None,
					startLocations[workIndex], None, , , , , terminalConditions).myAddRef();

			goingTo[workIndex] = 0;
		}
	}

	//if (!actions[workIndex].hasCompleted())
	//{
		Sleep(1.0);
		goto 'ActionWait';
	//}
	//else if ((workIndex + 1) < controllers.Length)
	//{
	//	++workIndex;
	//	goto 'ActionWait';
	//}

	for ( workIndex = 0; workIndex < controllers.Length; ++workIndex )
	{
		if ( actions[workIndex] != None )
		{
			actions[workIndex].Release();
			actions[workIndex] = None;
		}
	}

	//logTest("Stress Test Finished");

	//signalPassed();
}