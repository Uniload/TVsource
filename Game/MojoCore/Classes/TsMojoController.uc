class TsMojoController extends Engine.Controller
	native;

const LOCAL_VIEW_FOCUS_EXTENSION = 10000;

// the controller is ref counted, incase multiple scenes cause it to be created. the last scene to finish
// will dec the ref count to 0, and cause the old controller to kick in
var int scene_ref_count;

var Controller original_controller;
var vector point;
var bool localShouldWalk;

var	TsViewFocus targetViewFocus;
var	Actor moveViewFocus;

event TakeControlOf(Pawn P)
{
	original_controller = P.Controller;
	if (original_controller != None)
		original_controller.Pawn = None;

	P.PossessedBy(Self);
	Pawn = P;

	scene_ref_count = 1;

	// initialise target view focus
	targetViewFocus = spawn(class'TsViewFocus');
}

event Destroyed()
{
	// revert old controller
	if ((original_controller != None) && (!Pawn.IsInState('Dying')))
	{
		Pawn.PossessedBy(original_controller);
		original_controller.Pawn = Pawn;
	}

	// dont need this anymore
	if (targetViewFocus != None)
		targetViewFocus.Destroy();

	Super.Destroyed();
}

event AddRef()
{
	++scene_ref_count;
}

event DecRef()
{
	--scene_ref_count;

	if (scene_ref_count <= 0)
	{
		scene_ref_count = 0;
		Destroy();
	}
}

function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	if (Pawn.PressingFire())
	{
//		Pawn.Weapon.BotFire(bFinishedFire);
		return true;
	}
	// DLB Controller clean pass: removed AI logic StopFiring();
	return false;
}

function BeginMoveToPoint(vector p, rotator r, Actor actorVF, vector pointVF, bool nullPointVF,
						  bool shouldWalk)
{
	local vector viewLocWork;

	Log("BeginMoveToPoint");

	point = p;
	localShouldWalk = shouldWalk;

	// set up the target view focus

	if ((actorVF == None) && (nullPointVF))
	{
		// ... no view focus case
		viewLocWork = vect(0, 0, 0);
		viewLocWork.X = LOCAL_VIEW_FOCUS_EXTENSION;
		viewLocWork = viewLocWork >> r;
		viewLocWork = viewLocWork + point;
		targetViewFocus.SetLocation(viewLocWork);
		moveViewFocus = targetViewFocus;
	}
	else if (!nullPointVF)
	{
		// ... point view focus case
		targetViewFocus.SetLocation(pointVF);
		moveViewFocus = targetViewFocus;
	}
	else
	{
		// ... actor view focus case
		moveViewFocus = actorVF;
	}

	GotoState('MoveToPoint');
}

function bool FinishedState()
{
	return false;
}

event ResetState()
{
	GotoState('');
}

state MoveToPoint
{
Begin:
	Pawn.SetPhysics(PHYS_Walking);
	// DLB Controller clean pass: removed AI logic WaitForLanding();
//	MoveTo(point, moveViewFocus, , localShouldWalk);
//	Pawn.SetWalking(false); necessary when using WarCogPlasmaTrooper (?)
//	FinishRotation();
	GotoState('Finished');
}

state Finished
{
	function bool FinishedState()
	{
		return true;
	}
}