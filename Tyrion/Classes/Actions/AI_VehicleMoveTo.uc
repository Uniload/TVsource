//=====================================================================
// AI_VehicleMoveTo
// Moves a vehicle to a location on the map
//=====================================================================

class AI_VehicleMoveTo extends AI_DriverAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) editinline float desiredSpeed;
var(Parameters) bool skipIntermediateNodes;
var(Parameters) editinline Name attackTargetName "keep oriented towards this rook to be able to shoot at it (currently only used by the Pod)";

var(InternalParameters) editconst Vector destination;
var(InternalParameters) editconst Rook attackTarget;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;

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
	if ( destinationName != '' )
	{
		node = vehicle().findStaticByLabel( class'Pathfinding.PlacedNode', destinationName );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ vehicle().name @ ") can't find specified path node" @ destinationName );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		destination = node.Location;
	}

	if ( attackTargetName != '' )
		attackTarget = Rook(vehicle().findStaticByLabel( class'Gameplay.Rook', attackTargetName ));

	if ( vehicle().logTyrion )
		log( name @ "started." @ vehicle().name @ "is moving to" @ destination @ "(dist:" @ VDist( destination, vehicle().Location ) @ ")");

	if ( vehicle().isA( 'Car' ) )
		waitForAction( class'CarMoveToLocation'.static.startAction( AI_Controller(vehicle().controller),
						self, destination, desiredSpeed ));
	else
		waitForAction( class'AircraftMoveToLocation'.static.startAction( AI_Controller(vehicle().controller),
						self, destination, skipIntermediateNodes, desiredSpeed, attackTarget ));

	if ( vehicle().logTyrion )
		log( name @ "(" @ vehicle().name @ ") stopped with errorCode" @ errorCode );

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleMoveToGoal'