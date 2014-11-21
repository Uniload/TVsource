class ConcreteNavigationTest extends Gameplay.NavigationTestHarness;

var NS_Action action;

var vector destination;

function markPoint()
{
	local vector X;
	local vector Y;
	local vector Z;
	local vector startTrace;
	local vector hitNormal;
	local vector endTrace;

	if (!enabled)
		return;

	if (!started)
		return;

	// determine point
	GetAxes(selfHUD.playerOwner.getViewRotation(), X, Y, Z);
	startTrace = selfHUD.playerOwner.viewTarget.location;
//	startTrace.Z += selfHUD.playerOwner.baseEyeHeight;
	endTrace = startTrace + X * 30000;
	if (Trace(destination, hitNormal, endTrace, startTrace, True) == None)
	{
		Log("WARNING: trace failed");
		return;
	}

	GotoState('DoMove');
}

state DoMove
{
Begin:

	Log("Starting Move");
	action = class'NS_MoveToLocation'.static.startAction(AI_Controller(workController), None, destination).myAddRef();

ActionWait:
	if (!action.hasCompleted())
	{
		Sleep(1.0);
		goto 'ActionWait';
	}

	action.Release();
	action = None;

	log("move finished");

	//Sleep(2);
	//workVector = workRook.Location - destination;
	//logTest(string(rookName) $ " is within " $ VSize(workVector) $ " units of destination.");

	//if (VSize(workVector) < PASS_THRESHOLD_PROXIMITY)
	//	signalPassed();
	//else
	//	signalFailed(string(rookName) $ " is not within " $ PASS_THRESHOLD_PROXIMITY $
	//			" units of destination.");
}