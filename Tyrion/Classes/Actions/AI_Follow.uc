//=====================================================================
// AI_Follow
// Follows an arbitrary pawn on the map using walking/jetting/skiing
//=====================================================================

class AI_Follow extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "An actor to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;
var(Parameters) Character.GroundMovementLevels preferredGroundMovement;

var(InternalParameters) editconst Actor target;
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
// how close do you want to get?

private final function float proximityFunction()
{
	if ( followFunction != None )
		return followFunction.proximityFunction();
	else
		return proximity;
}

//---------------------------------------------------------------------
// return pertinent information about an action for debugging

function string actionDebuggingString()
{
	if ( target == None )
		return String(name) @ "None," $ proximityFunction();
	else
		return String(name) @ target.label $ "," $ proximityFunction();
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
		target = Pawn(resource.pawn().findByLabel( class'Engine.Pawn', targetName, true ));

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ resource.pawn().name @ "is following" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	waitForAction( class'NS_Follow'.static.startAction( AI_Controller(resource.pawn().controller),
					self, target, proximity, followFunction, positionIndex,
					energyUsage, terminalVelocity, terminalHeight, preferredGroundMovement ) );	// terminalVelocity used to be DON'T_CARE...

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
	satisfiesGoal = class'AI_FollowGoal'
}