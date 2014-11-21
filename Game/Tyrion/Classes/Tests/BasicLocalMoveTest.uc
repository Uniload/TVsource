class BasicLocalMoveTest extends TyrionUnitTest;

var() name pawnName;
var() vector destination;

var vector workVectorA;
var NS_DoLocalMove dlm;

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

	logTest("doLocalMove started");

	dlm = new( workController ) class'NS_DoLocalMove'( workController, None );
	dlm.destination = destination;
	dlm.skiCompetency = SC_None;
	dlm.jetCompetency = JC_None;
	workController.doLocalMove( dlm );

	logTest("doLocalMove finished");

	Sleep(2);
	workVectorA = workPawn.Location - destination;
	logTest(string(pawnName) $ " is within " $ VSize(workVectorA) $ " units of destination.");

	if (VSize(workVectorA) < PASS_THRESHOLD_PROXIMITY)
		signalPassed();
	else
		signalFailed(string(pawnName) $ " is not within " $ PASS_THRESHOLD_PROXIMITY $
				" units of destination.");
}