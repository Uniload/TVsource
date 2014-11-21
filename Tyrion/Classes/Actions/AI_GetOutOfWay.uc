//=====================================================================
// AI_GetOutOfWay
// Tries to get out of the way of another pawn
// Triggered when the pawn A's shot is being blocked by pawn B or
// when pawn A runs into pawn B
//=====================================================================

class AI_GetOutOfWay extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Constants

const DISPLACEMENT_DISTANCE = 200.0f;	// how far the AI moves to get out of the way

//=====================================================================
// Variables

var(Parameters) Rook avoidee;			// rook I'm avoiding
var(Parameters) Vector aimLocation;		// where the avoidee is shooting / trying to go

var ACT_ErrorCodes errorCode;			// errorcode from child action
var Vector destination;					// tentative location to move out of the way to
var Vector rotatedAimLine;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	errorCode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( rook().controller != None )
		AI_Controller(rook().controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rook().logTyrion )
		log( self.name @ "started on" @ rook().name $ ". Avoideee:" @ avoidee.name );

	if ( rook().controller == None )
	{
		log( "AI WARNING:" @ self.name @ "doesn't have a controller. This shouldn't be" );
		fail( ACT_GENERAL_FAILURE );
	}

	// find a destination somewhat orthogonal to line of fire
	aimLocation = aimLocation - avoidee.Location;	// line from shooter to target

	// rotate line by 90 deg
	if ( FRand() < 0.5 )
	{
		// rotate to the right ...
		rotatedAimLine.X = -aimLocation.Y;
		rotatedAimLine.Y = aimLocation.X;
	}
	else
	{
		// ... or to the left
		rotatedAimLine.X = aimLocation.Y;
		rotatedAimLine.Y = -aimLocation.X;
	}
	rotatedAimLine.Z = 0;

	destination = rook().Location + DISPLACEMENT_DISTANCE * rotatedAimLine / VSize( rotatedAimLine );
	destination = AI_Controller(rook().controller).getRandomLocation( rook(), destination, DISPLACEMENT_DISTANCE/4, 0 );

	// suitable location found?
	if ( destination == rook().Location )
	{
		if ( rook().logTyrion )
			log( self.name @ "couldn't find a suitable location." );

		fail( ACT_GENERAL_FAILURE );
	}

	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(rook().controller),
					self, destination
					/*, skiCompetency, jetCompetency, groundMovement, energyUsage */));

	if ( errorCode != ACT_SUCCESS )
		fail( ACT_CANT_REACH_DESTINATION );
	else
		succeed();

}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GetOutOfWayGoal'
}