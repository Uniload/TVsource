//=====================================================================
// AI_VehiclePursue
// Move towards a target, look for it if you lose sight
//=====================================================================

class AI_VehiclePursue extends AI_DriverAction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight "How high to end up over the target - 0 means 'DONT_CARE'";
var(Parameters) float desiredSpeed	"Preferred travel speed";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;	// index of this pawn in a formation (starts at 0)

var ACT_ErrorCodes errorCode;		// errorcode from child action
var AI_TargetMemorySensor targetMemorySensor;
var NS_Action follow;
var AI_Goal moveToGoal;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// sensor callback

function OnSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	if ( resource.pawn().logTyrion )
		log( name @ "receiving message from" @ sensor.name @ value.objectData );
	runAction();
}

//---------------------------------------------------------------------
// callbacks from moveToGoal

function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	if ( resource.pawn().logTyrion )
		log( name @ "receiving goal achieved message from" @ goal.name );
	super.goalAchievedCB( goal, child );
	runAction();
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	if ( resource.pawn().logTyrion )
		log( name @ "receiving goal failed message from" @ goal.name );
	super.goalNotAchievedCB( goal, child, errorCode );
	runAction();
}

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	if ( resource.pawn().logTyrion )
		log( name @ "receiving action succeeded message from" @ child.name );
	super.actionSucceededCB( child );
	errorCode = ACT_SUCCESS;
	runAction();
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	if ( resource.pawn().logTyrion )
		log( name @ "receiving action failed message from" @ child.name );
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
	runAction();
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	followFunction = None;

	if ( class'Pawn'.static.checkAlive( vehicle() ) )
		AI_Controller(vehicle().controller).stopMove();

	if ( targetMemorySensor != None )
	{
		targetMemorySensor.deactivateSensor( self );
		targetMemorySensor = None;
	}

	if ( moveToGoal != None )
	{
		moveToGoal.Release();
		moveToGoal = None;
	}

	if ( follow != None )
	{
		follow.Release();
		follow = None;
	}
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
		target = Pawn(vehicle().findByLabel( class'Engine.Pawn', targetName ));

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ resource.pawn().name @ "is pursuing" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', vehicleResource() ) );
	targetMemorySensor.setParameters( target, vehicle().visionMemory );

	while ( targetMemorySensor.queryObjectValue() != None )
	{
		if ( resource.pawn().logTyrion )
			log( name @ "starting to follow" );

		if ( follow != None )
		{
			follow.Release();
			follow = None;
		}

		follow = class'NS_Follow'.static.startAction( AI_Controller(vehicle().controller), self, target, proximity,
					followFunction, positionIndex,, terminalVelocity, terminalHeight, desiredSpeed ).myAddRef();
		pause();

		// if action is woken up it's because target was lost or follow failed
		if ( follow.hasCompleted() )
		{
			if ( errorCode != ACT_SUCCESS )
			{
				if ( resource.pawn().logTyrion )
					log( name @ "stopped because follow failed" );
				fail( errorCode );
			}
		}
		else
		{
			follow.interruptAction();
		}

		/*if ( followFunction == None || followFunction.validDestination( targetMemorySensor.lastPlaceSeen ))
		{
			if ( resource.pawn().logTyrion )
				log( name @ "moving to at target's last known location" );
			
			// target must have been lost
			moveToGoal = (new class'AI_VehicleMoveToGoal'( resource, achievingGoal.priority, targetMemorySensor.lastPlaceSeen, desiredSpeed, true )).postGoal( self ).myAddRef();
			pause();

			if ( !moveToGoal.wasAchieved() )
			{
				moveToGoal.unPostGoal( self );
				moveToGoal.Release();			// must be done here as well as cleanup because moveToGoal could be overwritten
				moveToGoal = None;
			}
		}*/
	}

	if ( resource.pawn().logTyrion )
		log( name @ "stopped because target can't be found" );
	fail( ACT_LOST_TARGET );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehiclePursueGoal'
}