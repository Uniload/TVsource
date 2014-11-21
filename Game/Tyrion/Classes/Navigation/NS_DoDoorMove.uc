//=====================================================================
// NS_DoDoorMove
//
// Moves a character through a door.
//=====================================================================

class NS_DoDoorMove extends NS_Action;

//=====================================================================
// Variables

var vector beforeDoorLocation;
var Door door;
var vector afterDoorLocation;
var bool nextLocationValid;
var vector nextLocation;

var float waitStartTime;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// It is assumed that when this action is called the character is sufficiently close to "beforeDoorLocation"
// to trigger the door.

static function NS_DoDoorMove startAction(AI_Controller c, ActionBase parent, vector beforeDoorLocation,
		Door door, vector afterDoorLocation, bool nextLocationValid, vector nextLocation)
{
	local NS_DoDoorMove action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_DoDoorMove'( c, parent );

	// set action parameters
	action.beforeDoorLocation = beforeDoorLocation;
	action.door = door;
	action.afterDoorLocation = afterDoorLocation;
	action.nextLocationValid = nextLocationValid;
	action.nextLocation = nextLocation;

	action.runAction();
	return action;
}

state Running
{
Begin:

	// wait for door to open (no more than 5 seconds)
	waitStartTime = door.level.timeSeconds;

	// ... stop if closed
	if (door.bClosed)
		Character(controller.pawn).motor.moveCharacter();

	while (door.bClosed)
	{
		if ((door.level.timeSeconds - waitStartTime) > 7)
		{
			warn("door failed to open");
			break;
		}
		else
			sleep(0);
	}

	waitForAction(class'NS_DoLocalMove'.static.startAction(controller, self, afterDoorLocation,
			nextLocationValid, nextLocation));

	// propagate error if doLocalMove failed
	if (errorCode != ACT_SUCCESS)
	{
		fail(errorCode);
	}
	else
	{
		succeed();
	}
}