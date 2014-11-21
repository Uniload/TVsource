class BasicWaypointMoveTest extends TyrionUnitTest;

var() name pawnName;
var() vector destination;

var vector workVector;

var NS_Action action;

var Controller.FindPathAIProperties workAIProperties;

var array<Actor> ignore;

state UnitTestState
{
	function BeginState()
	{
		workPawn = getPawn(string(pawnName));

		// get specified pawn
		if (workPawn == None)
		{
			signalFailed("Failed to find Pawn named " $ string(pawnName) $ ".");
			return;
		}

		// confirm correct physics mode
//		if (workPawn.Physics != PHYS_Movement)
//		{
//			signalFailed(string(pawnName) $ " is not in PHYS_Movement state.");
//			return;
//		}

		// get AI controller
		workController = AI_Controller(workPawn.Controller);
		if (workController == None)
		{
			signalFailed(string(pawnName) $ " does not have an AI_Controller.");
			return;
		}
	}

Begin:

	workAIProperties.jetpack = false;
	workAIProperties.upCostFactor = 0;
	workAIProperties.upCostFactor = 0;

	workController.findPath(workPawn.Location, destination, workAIProperties, ignore, true);

	Log("NS_MoveAlongWaypoints started");
	action = class'NS_MoveAlongWaypoints'.static.startAction(workController, None, 0,
			workController.routeCache.length - 1 ).myAddRef();

ActionWait:
	if (!action.hasCompleted())
	{
		Sleep(1.0);
		goto 'ActionWait';
	}

	action.Release();
	action = None;

	Log("NS_MoveAlongWaypoints finished");

	Sleep(2);
	workVector = workPawn.Location - destination;
	logTest(string(pawnName) $ " is within " $ VSize(workVector) $ " units of destination.");

	if (VSize(workVector) < PASS_THRESHOLD_PROXIMITY)
		signalPassed();
	else
		signalFailed(string(pawnName) $ " is not within " $ PASS_THRESHOLD_PROXIMITY $
				" units of destination.");
}