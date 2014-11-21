class TsActionMoveTo extends TsPawnAction;

var(Action) MojoKeyframe target;
var(Action) enum EViewFocusType
{
	VIEW_FOCUS_Actor,
	VIEW_FOCUS_Point,
	VIEW_FOCUS_None
} viewFocusType;
var(Action) MojoActorRef viewFocusActor;
var(Action) MojoKeyframe viewFocusPoint;
var(Action) enum EMoveType
{
	MOVE_TYPE_Run,
	MOVE_TYPE_Walk,
} move_type;

var transient TsMojoController MojoController;

function bool OnStart()
{
	local bool shouldWalk;
	local vector viewFcsPntPstn;
	local bool nullViewFcsPntPstn;

	// do move type specific action
	switch(move_type)
	{
	case MOVE_TYPE_Run:
		shouldWalk = false;
		break;

	case MOVE_TYPE_Walk:
		shouldWalk = true;
		break;
	}

	MojoController = TsMojoController(Pawn.Controller);
	if (MojoController == None)
	{
		Log("TsActionMoveTo, failed to find MojoController");
		return false;
	}

	viewFocusActor.actor = None;

	// get specifed view focus
	switch (viewFocusType)
	{
	case VIEW_FOCUS_Actor:
		nullViewFcsPntPstn = true;

		viewFocusActor = ResolveActorRef(viewFocusActor);
		if (viewFocusActor.actor == None)
			Log("TsActionMoveTo, Failed to find view focus actor "$viewFocusActor.name);

		break;

	case VIEW_FOCUS_Point:
		viewFcsPntPstn = viewFocusPoint.position;
		nullViewFcsPntPstn = false;
		break;

	case VIEW_FOCUS_None:
		nullViewFcsPntPstn = true;
		break;
	}

	// put mojo controller in appropriate move state
	MojoController.BeginMoveToPoint(target.position, target.rotation, viewFocusActor.actor, viewFcsPntPstn,
			nullViewFcsPntPstn, shouldWalk);

	return true;
}

function bool OnTick(float delta)
{
	return !MojoController.FinishedState();
}

function OnFinish()
{
	Log("Finished Move To");
}

defaultproperties
{
	DName			="Move To"
	Track			="Position"
	Help			="Move to a vector location"
	ModifiesLocation = true

	viewFocusType	=VIEW_FOCUS_None
}