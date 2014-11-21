//=====================================================================
// AI_PodAttack
//=====================================================================

class AI_PodAttack extends AI_VehicleAction
	editinlinenew;

import enum VehiclePositionType from Vehicle;

//=====================================================================
// Constants

const CLOSING_RANGE = 3000.0f;			// how close to get to target before starting fancy combat maneuvers
const ATTACK_SPEED = 1500.0f;			// attack speed
const HEIGHT_ABOVE_TARGET = 1000.0f;	// how high do you want to be above target when you attack?
const DIAGONAL_ROTATION = -0.7853981f;	// (PI/4) = 45 deg
const DIAGONAL_DISTANCE = 2000;

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

var Vehicle v;
var VehiclePositionType driverPosition;
var Vector destination;

var AI_Goal fireAtGoal;
var AI_Goal followGoal;
var ACT_Errorcodes errorCode;
var AI_TargetMemorySensor targetMemorySensor;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from sub-goals;
// they are only used to stop the action when any success/failure message
// comes up that isn't an interruption
// todo: automate this process? A new flag on goals/waitForGoals?

function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	super.goalAchievedCB( goal, child );

	errorCode = ACT_SUCCESS;
	runAction();
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes anErrorCode ) 
{
	super.goalNotAchievedCB( goal, child, anErrorCode );

	errorCode = anErrorCode;

	if ( errorCode != ACT_INTERRUPTED )
		runAction();
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	followFunction = None;

	if ( targetMemorySensor != None )
	{
		targetMemorySensor.deactivateSensor( self );
		targetMemorySensor = None;
	}

	if ( followGoal != None )
	{
		followGoal.Release();
		followGoal = None;
	}

	if (fireAtGoal != None )
	{
		fireAtGoal.Release();
		fireAtGoal = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	v = vehicle();

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(v.findByLabel( class'Pawn', targetName, true ));

	if ( v.logTyrion )
		log( name @ "started." @ v.name @ "is attacking" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// set up purely for VehiclePursue: memory function won't work on this sensor if it's always started from scratch
	targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', vehicleResource() ) );
	targetMemorySensor.setParameters( target, v.visionMemory );

	//waitForResourcesAvailable( achievingGoal.priority, achievingGoal.priority );

	// start shooting at target
	driverPosition = VP_DRIVER;		// stupid assignment necessary or Unreal doesn't recognize the enum
	fireAtGoal = (new class'AI_GunnerFireAtGoal'( gunnerResource(driverPosition), achievingGoal.priority,
					target, driverPosition, false )).postGoal( self ).myAddRef();

	while ( class'Pawn'.static.checkAlive( v ) && class'Pawn'.static.checkAlive( target ) && (followGoal == None || !followGoal.wasNotAchieved() ))
	{
		// 1. post followGoal - interrupt it if close to target
		if ( VSizeSquared2D( target.Location - v.Location ) > CLOSING_RANGE * CLOSING_RANGE )
		{
			if ( followGoal != None )
			{
				followGoal.Release();
				followGoal = None;
			}

			// move towards target
			followGoal = (new class'AI_VehiclePursueGoal'( driverResource(), achievingGoal.priority, target,
							 CLOSING_RANGE,,,, HEIGHT_ABOVE_TARGET, ATTACK_SPEED )).postGoal( self ).myAddRef();

			while ( class'Pawn'.static.checkAlive( v ) &&
					class'Pawn'.static.checkAlive( target ) &&
					VSizeSquared2D( target.Location - v.Location ) > CLOSING_RANGE * CLOSING_RANGE &&
					!followGoal.wasNotAchieved() )
				yield();

			followGoal.unPostGoal( self );
		}

		// 2. move to a point behind target (offset a bit) - call doLocalMove with target flag on
		if ( class'Pawn'.static.checkAlive( v ) && class'Pawn'.static.checkAlive( target ) && (followGoal == None || !followGoal.wasNotAchieved() ))
		{
			destination = rotateZ( target.Location - v.Location, DIAGONAL_ROTATION );
			destination.Z = 0;
			destination *= DIAGONAL_DISTANCE / VSize2D( destination );
			destination += target.Location;
			destination.Z += HEIGHT_ABOVE_TARGET;
	
			if ( followFunction == None || followFunction.validDestination( destination ) )
			{
				waitForGoal( (new class'AI_VehicleLocalAttackGoal'( driverResource(), achievingGoal.priority, 
									destination, 750, ATTACK_SPEED, Rook(target) )).postGoal( self ), true );
			}
		}
	}

	if ( v.logTyrion )
		log( name @ "(" @ v.name @ ") stopped with errorCode" @ errorCode );

	if ( class'Pawn'.static.checkDead( target ) )
		succeed();
	else 
		fail( errorCode );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleAttackGoal'
}