class BasicMoveToLocationTest extends TyrionUnitTest;

var() name pawnName;
var() vector destination;
var() float terminalHeight;

var NS_MoveToLocation.TerminalConditions terminalConditions;

var vector workVector;

var NS_Action action;

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
		if (workPawn.Physics != PHYS_Movement)
		{
			signalFailed(string(pawnName) $ " is not in PHYS_Movement state.");
			return;
		}

		// get AI controller
		workController = AI_Controller(workPawn.Controller);
		if (workController == None)
		{
			signalFailed(string(pawnName) $ " does not have an AI_Controller.");
			return;
		}
	}

Begin:

	terminalConditions.height = terminalHeight;
	terminalConditions.distanceXY = 100;
	terminalConditions.distanceZ = 100;

	Log("NS_MoveToLocation started");
	action = class'NS_MoveToLocation'.static.startAction(workController, None,
			destination, None, , , , , terminalConditions).myAddRef();

ActionWait:
	if (!action.hasCompleted())
	{
		Sleep(1.0);
		goto 'ActionWait';
	}

	action.Release();
	action = None;

	Log("NS_MoveToLocation finished");

	Sleep(2);
	workVector = workPawn.Location - destination;
	logTest(string(pawnName) $ " is within " $ VSize(workVector) $ " units of destination.");

	if (VSize(workVector) < PASS_THRESHOLD_PROXIMITY)
		signalPassed();
	else
		signalFailed(string(pawnName) $ " is not within " $ PASS_THRESHOLD_PROXIMITY $
				" units of destination.");
}