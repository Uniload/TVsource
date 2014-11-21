//=====================================================================
// AI_VehicleLocalAttack
//
// Attack when target is close;
// Call appropriate vehicle DoLocalMove with target set
//=====================================================================

class AI_VehicleLocalAttack extends AI_DriverAction
	editinlinenew;

//=====================================================================
// Variables

var(InternalParameters) editconst Vector destination;
var(InternalParameters) editconst float terminalDistance;
var(InternalParameters) editconst float speed;
var(InternalParameters) editconst Rook target;

var ACT_ErrorCodes errorCode;		// errorcode from child action

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

//=====================================================================
// State code

state Running
{
Begin:
	if ( vehicle().logTyrion )
		log( self.name @ "(" @ vehicle().name @ ") doing attack run" );

	waitForAction( class'AircraftDoLocalMove'.static.startAction( AI_Controller(vehicle().controller), self,
					destination, terminalDistance, speed, target, false, vect(0,0,0) ));

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleLocalAttackGoal'