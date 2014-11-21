//=====================================================================
// AI_Pursue
// Move towards a target, look for it if you lose sight
//=====================================================================

class AI_Pursue extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Constants

const SEARCH_TIME = 6.0f;			// max time spent looking for lost target

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

// todo: add parameter for walk in a slinky fashion (for combat movement category)

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;
var(InternalParameters) editconst int positionIndex;	// index of this pawn in a formation (starts at 0)

var BaseAICharacter ai;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var AI_TargetMemorySensor targetMemorySensor;
var NS_Action follow;
var AI_Goal investigateGoal;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// sensor callback

function OnSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	if ( ai.logTyrion )
		log( name @ "receiving message from" @ sensor.name @ value.objectData );
	runAction();
}

//---------------------------------------------------------------------
// callbacks from investigateGoal

function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	if ( ai.logTyrion )
		log( name @ "receiving goal achieved message from" @ goal.name );
	super.goalAchievedCB( goal, child );
	runAction();
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	if ( ai.logTyrion )
		log( name @ "receiving goal failed message from" @ goal.name );
	super.goalNotAchievedCB( goal, child, errorCode );
	runAction();
}

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	if ( ai.logTyrion )
		log( name @ "receiving action succeeded message from" @ child.name );
	super.actionSucceededCB( child );
	errorCode = ACT_SUCCESS;
	runAction();
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	if ( ai.logTyrion )
		log( name @ "receiving action failed message from" @ child.name );
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
	runAction();
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

	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		AI_Controller(resource.pawn().controller).stopMove();

	if ( targetMemorySensor != None )
	{
		targetMemorySensor.deactivateSensor( self );
		targetMemorySensor = None;
	}

	if ( investigateGoal != None )
	{
		investigateGoal.Release();
		investigateGoal = None;
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
	ai = BaseAICharacter(resource.pawn());

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(ai.findByLabel( class'Engine.Pawn', targetName, true ));

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is pursuing" @ target.name @ achievingGoal.bTryOnlyOnce );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', characterResource() ) );
	targetMemorySensor.setParameters( target, ai.visionMemory );

	while ( targetMemorySensor.queryObjectValue() != None )
	{
		if ( ai.logTyrion )
			log( name @ "starting to follow" );

		if ( follow != None )
		{
			follow.Release();
			follow = None;
		}

		follow = class'NS_Follow'.static.startAction( AI_Controller(ai.controller), self, target, proximity, followFunction, positionIndex, energyUsage, terminalVelocity, terminalHeight ).myAddRef();
		pause();
		if ( class'Pawn'.static.checkDead( ai ) || class'Pawn'.static.checkDead( target ) )
			goto 'exit';

		// if action is woken up it's because target was lost or follow failed
		if ( follow.hasCompleted() )
		{
			if (  errorCode != ACT_SUCCESS )
			{
				if ( ai.logTyrion )
					log( name @ "stopped because follow failed" );
				fail( errorCode );
			}
		}
		else
		{
			follow.interruptAction();
		}

		if ( followFunction == None || followFunction.validDestination( targetMemorySensor.lastPlaceSeen ))
		{
			if ( ai.logTyrion )
				log( name @ "going to investigate at target's last known location" );
			
			//ai.level.speechManager.PlayDynamicSpeech( ai, 'CombatLose', None, None, "You" );

			// target must have been lost
			investigateGoal = (new class'AI_InvestigateGoal'( movementResource(), achievingGoal.priority, targetMemorySensor.lastPlaceSeen, SEARCH_TIME, target )).postGoal( self ).myAddRef();
			pause();
			if ( class'Pawn'.static.checkDead( ai ) || class'Pawn'.static.checkDead( target ) )
				goto 'exit';

			if ( !investigateGoal.wasAchieved() )
			{
				investigateGoal.unPostGoal( self );
				investigateGoal.Release();			// must be done here as well as cleanup because investigateGoal could be overwritten
				investigateGoal = None;
			}

			//if ( targetMemorySensor.queryObjectValue() != None )
			//	ai.level.speechManager.PlayDynamicSpeech( ai, 'CombatLose', None, None, "Find" );
		}
	}

	//ai.level.speechManager.PlayDynamicSpeech( ai, 'CombatLose', None, None, "GiveUp" );

exit:
	if ( ai.logTyrion )
		log( name @ "stopped because target can't be found" );
	fail( ACT_LOST_TARGET );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_PursueGoal'
}