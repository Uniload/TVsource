//=====================================================================
// NS_Turn
//
// Turns to a specified facing
//=====================================================================

class NS_Turn extends NS_Action;

//=====================================================================
// Constants

const TURN_INCREMENT = 4096;

enum TurnDirections
{
	TD_DONT_CARE,		// turns in direction that takes less time
	TD_CLOCKWISE,
	TD_COUNTERCLOCKWISE
};

//=====================================================================
// Variables

var Rotator facing;
var TurnDirections turnDirection;

var Character character;
var Rotator r;

//=====================================================================
// Functions

//---------------------------------------------------------------------

static function NS_Turn startAction(AI_Controller c, ActionBase parent, Rotator facing,
									optional TurnDirections turnDirection)
{
	local NS_Turn action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_Turn'( c, parent );

	// set action parameters
	action.facing = facing;
	action.turnDirection = turnDirection;

	action.runAction();
	return action;
}

//---------------------------------------------------------------------
// Turn the character to "r" and wait for the turn to complete

latent function turn( Rotator r )
{
	character.motor.setViewRotation( r );
	character.motor.setAIMoveRotation( r );

	// wait for turn to complete
	while ( Abs(character.motor.getMoveYawDelta()) > 100 && class'Pawn'.static.checkAlive( character ) )
		yield();
}

//---------------------------------------------------------------------
// determine the yaw increment for this character if it should turn in
// a specific direction, limited by TURN_INCREMENT

function int getIncrement()
{
	local int delta;

	delta = facing.Yaw - r.Yaw;

	if ( delta < 0 )
		delta += 65536;

	if ( turnDirection == TD_CLOCKWISE )
		delta = min(delta,TURN_INCREMENT);
	else
		delta = max(delta-65536,-TURN_INCREMENT);

	return delta;
}

//=====================================================================
// States

state Running
{
Begin:
	character = Character(controller.Pawn);

	if ( character.logNavigationSystem )
		log( name @ "(" @ controller.Pawn.name @ ") started turning" );

	if ( turnDirection != TD_DONT_CARE )
	{
		r = character.motor.getMoveRotation();

		if ( character.logNavigationSystem )
			log( name @ "turning from" @ r.Yaw @ "to" @ facing.Yaw );

		while ( facing.Yaw != r.Yaw && class'Pawn'.static.checkAlive( character ) ) 
		{
			//log( "Increment:" @ getIncrement() @ facing.Yaw @ r.Yaw );
			r.Yaw = ( r.Yaw + getIncrement() ) & 65535;
			turn( r );
		}
	}
	else
	{
		turn( facing );
	}

	if ( class'Pawn'.static.checkDead( character ) )
		fail( ACT_ALL_RESOURCES_DIED );
	else
		succeed();
}