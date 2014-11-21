class Trigger extends Engine.Actor
	hidecategories(Events)
	hidecategories(Force)
	hidecategories(Karma)
	hidecategories(Lighting)
	hidecategories(LightColor)
	hidecategories(Movement)
	hidecategories(Sound)
	abstract;

var() string debugLogString;
var() array<name> triggeredByFilter;
var() bool bCanDeadTrigger				"Dead characters will not cause a trigger unless this variable is set to true.";
var() bool bCanDeadTriggerExit			"Dead characters will not cause a trigger on exiting unless this variable is set to true.";

function bool canTrigger(Actor testActor, optional bool exiting)
{
	local int index;
	local bool bDeadTrigger;

	if (exiting)
		bDeadTrigger = bCanDeadTriggerExit;
	else
		bDeadTrigger = bCanDeadTrigger;

	// dead rooks will not trigger unless otherwise specified
	if (!bDeadTrigger && Rook(testActor) != None && !Rook(testActor).isAlive())
		return false;

	// if no actor is specified then all actors can trigger
	if (triggeredByFilter.length == 0)
		return true;

	for (index = 0; index < triggeredByFilter.length; ++index)
	{
		if (triggeredByFilter[index] == testActor.label)
			return true;
	}
	return false;
}

// dispatchMessage
function dispatchMessage(Message msg)
{
	log(self$".dispatchMessage: Use the 'dispatchTrigger' function to send messages from trigger classes.");
}

// dispatchTrigger
function bool dispatchTrigger(Actor instigator, MessageTrigger msg)
{
	local Pawn P;
	local PlayerController C;

	// debug log
	if (debugLogString != "")
	{
		P = Pawn(instigator);
		if (P != None)
		{
			C = PlayerController(P.Controller);
			if (C != None)
				C.ClientMessage("TRIGGER "$label$": "$debugLogString);
		}
	}

	super.dispatchMessage(msg);

	return true;
}

defaultproperties
{
    bHidden=True
    bCollideActors=True
	Texture=Texture'Engine_res.S_Trigger'
	bProjTarget = false
}
