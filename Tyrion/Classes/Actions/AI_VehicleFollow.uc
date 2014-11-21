//=====================================================================
// AI_VehicleFollow
// Follows an arbitrary pawn on the map
//=====================================================================

class AI_VehicleFollow extends AI_DriverAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight "How high to end up over the target - 0 means 'DONT_CARE'";
var(Parameters) float desiredSpeed	"Preferred travel speed";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;

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

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	followFunction = None;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(vehicle().findByLabel( class'Engine.Pawn', targetName, true ));

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ resource.pawn().name @ "is following" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	waitForAction( class'NS_Follow'.static.startAction( AI_Controller(vehicle().controller),
					self, target, proximity, followFunction, positionIndex,
					, terminalVelocity, terminalHeight, desiredSpeed ) );

	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") stopped with errorCode" @ errorCode );

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleFollowGoal'
}