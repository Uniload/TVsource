//=====================================================================
// AI_Turn
// Turns to a specified facing
//=====================================================================

class AI_Turn extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) Rotator facing;
var(Parameters) NS_Turn.TurnDirections turnDirection;

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	if ( resource.pawn().logTyrion)
		log( self.name @ "started." @ rook().name @ "is turning" );

	waitForAction( class'NS_Turn'.static.startAction( AI_Controller(rook().controller), self, facing, turnDirection ));

	if ( rook().logTyrion )
		log( self.name @ "(" @ rook().name @ ") stopped" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_TurnGoal'
}