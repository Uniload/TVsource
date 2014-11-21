//=====================================================================
// AI_CombatMovement
// Does AI's positioning movement while it's attacking something
//
// never succeeds; fails when pursue fails
//=====================================================================

class AI_CombatMovement extends AI_MovementAction implements IBooleanGoalCondition
	editinlinenew;

import enum CombatRangeCategories from BaseAICharacter;
import enum CombatMovementCategories from BaseAICharacter;
import enum SpeedPackUseCategories from BaseAICharacter;

//=====================================================================
// Constants

const PROXIMITY_HYSTERESIS_STAY_AT_RANGE = 0.5f;	// percentage of "ideal firing range distance" proximity can fall to before AI backs up
const PROXIMITY_HYSTERESIS_DRAW_OUT = 0.9f;
const DRAW_OUT_DISTANCE = 2000.0f;					// how far to draw out the opponent
const FLANKING_UPDATE_PERIOD = 2.0f;				// look for flanking positions every this many seconds
const COVER_UPDATE_PERIOD = 4.0f;					// look for cover positions every this many seconds
const SIDESTEP_RADIUS = 800.0f;						// how far AI's side step

//=====================================================================
// Variables

var(Parameters) float proximity;
var(Parameters) float energyUsage;
var(Parameters) float sideStepInterval "how frequently AI's side steps when in CM_SIDE_STEP";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

var BaseAICharacter ai;			// pointer to the AI this action is running on
var CombatRangeCategories combatRange;
var CombatMovementCategories combatMovement;
var float proximityHysteresis;
var AI_Goal followGoal;
var AI_Goal moveGoal;
var Vector movePoint;			// good point to flank from or to back up to
var bool bCover;				// does "movePoint" offer cover? (bot used)
var float lastFlankingUpdateTime;	// last time AI checked for flanking positions
var float lastCoverUpdateTime;		// last time AI checked for cover positions
var float lastMovementTime;			// last time AI adjusted position
var ACT_Errorcodes errorCode;
var AI_TargetMemorySensor targetMemorySensor;
var Character.GroundMovementLevels moveSpeed;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from pursueGoal

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes anErrorCode ) 
{
	super.goalNotAchievedCB( goal, child, anErrorCode );

	errorCode = anErrorCode;
}

//---------------------------------------------------------------------
// function to interrupt follow if attacker gets too close

static function bool goalTest( AI_Goal goal )
{
	local AI_CombatMovement cm;
	local Pawn pawn;

	cm = AI_CombatMovement(goal.parentAction);
	pawn = goal.resource.pawn();
	cm.movePoint = pawn.Location;
	cm.bCover = false;

	// interrupt action when target dies
	if ( class'Pawn'.static.checkDead( pawn ) || class'Pawn'.static.checkDead( cm.target ) )
		return true;

	// decide whether to check for a flanking spot
	if ( cm.combatRange == CR_FLANKING &&
		pawn.level.timeSeconds - cm.lastFlankingUpdateTime >= FLANKING_UPDATE_PERIOD &&	// don't look for flanking spots too often
		VDist( pawn.Location, cm.target.Location ) < cm.proximityFunction() + 500.0f )	// don't try to flank if far away from target
	{
		if ( cm.ai.logTyrion )
			log( cm.name $ ":" @ pawn.name @ "looking for flanking point!" );

		cm.lastFlankingUpdateTime = pawn.level.timeSeconds;
		cm.movePoint = cm.getFlankPoint();
		cm.moveSpeed = GM_SPRINT;
	}

	// decide whether to check for a backup spot
	if ( cm.combatRange >= CR_STAY_AT_RANGE &&
		cm.movePoint == pawn.Location &&
		VDist( cm.target.Location, pawn.Location ) < cm.proximityHysteresis * cm.proximityFunction() )
	{
		if ( cm.ai.logTyrion )
			log( cm.name $ ":" @ pawn.name @ "looking for back up point!" );

		cm.movePoint = cm.getBackupPoint();
		cm.moveSpeed = GM_RUN;
	}

	// look for cover
	if ( cm.combatMovement == CM_SEEK_COVER &&
		cm.movePoint == pawn.Location &&
		pawn.level.timeSeconds - cm.lastMovementTime >= COVER_UPDATE_PERIOD &&	// don't seek cover if you've just moved
		pawn.level.timeSeconds - cm.lastCoverUpdateTime >= COVER_UPDATE_PERIOD )// don't look for cover too often
	{
		if ( cm.ai.logTyrion )
			log( cm.name $ ":" @ pawn.name @ "looking for cover!" );

		cm.lastCoverUpdateTime = pawn.level.timeSeconds;
		cm.movePoint = cm.getCoverPoint();
		cm.moveSpeed = GM_RUN;
	}

	// look for place to side-step to
	if ( (cm.combatMovement == CM_SIDE_STEP || cm.combatMovement == CM_SEEK_COVER) &&
		cm.movePoint == pawn.Location &&
		IsNearlyZero( pawn.Velocity ) &&
		pawn.level.timeSeconds - cm.lastMovementTime >= cm.sideStepInterval &&	// don't side step if you've just moved
		cm.proximityFunction() > SIDESTEP_RADIUS )		// don't sidestep if you need to be close to your target to attack
	{
		if ( cm.ai.logTyrion )
			log( cm.name $ ":" @ pawn.name @ "doing a side step!" );

		cm.movePoint = cm.getSidestepPoint();
		cm.moveSpeed = GM_RUN;
	}

	return cm.movePoint != pawn.Location;
}

//---------------------------------------------------------------------
// if too close to target, get point to back up to

private final function Vector getBackupPoint()
{
	local Vector targetVector;				// vector from AI to target
	local float targetVectorSize;			// length
	local float backupDistance;				// how far AI needs to backup by
	local Vector backupPoint;				// location to back up to

	targetVector = target.Location - ai.Location;
	targetVectorSize = VSize( targetVector );
	if ( combatRange == CR_DRAW_OUT )
		backupDistance = DRAW_OUT_DISTANCE;
	else
		backupDistance = proximityFunction() - targetVectorSize;

	targetVector *= backupDistance / targetVectorSize;

	backupPoint = AI_Controller(ai.controller).getRandomLocation( ai, ai.Location - targetVector, backupDistance, 0 );

	if ( bValidLocation( backupPoint ) )
		return backupPoint;
	else
		return ai.Location;
}

//---------------------------------------------------------------------
// get point on flank of target

private final function Vector getFlankPoint()
{
	local Vector targetVector;
	local Vector flankPoint;
	local float prox;

	prox = proximityFunction();
	targetVector = target.Location - ai.Location;
	targetVector *= prox / VSize( targetVector );
	targetVector = rotateZ( targetVector, PI/2 );

	flankPoint = AI_Controller(ai.controller).getRandomLocation( ai, target.Location - targetVector, FMin(prox, 500.0f), 0 );

	if ( bValidLocation( flankPoint ) )
		return flankPoint;
	else
		return ai.Location;
}

//---------------------------------------------------------------------
// get nearby point that offers cover

private final function Vector getCoverPoint()
{
	local Vector coverPoint;

	if ( class'AI_TakeCover'.static.findCover( coverPoint, resource.pawn(), target ) )
	{
		bCover = true;
		return coverPoint;
	}
	else
		return ai.location;		// no cover found
}

//---------------------------------------------------------------------
// get nearby point to side step to

private final function Vector getSidestepPoint()
{
	local Vector sideStepPoint;

	sidestepPoint = AI_Controller(ai.controller).getRandomLocation( ai, ai.Location, SIDESTEP_RADIUS, 100 );

	if ( bValidLocation( sidestepPoint ) )
		return sidestepPoint;
	else
		return ai.Location;
}

//---------------------------------------------------------------------
// Is "loc" a valid location to move to?

private final function bool bValidLocation( Vector loc )
{
	local Actor hitActor;

	if ( loc == ai.Location || (followFunction != None && !followFunction.validDestination( loc )))
		return false;

	// check that backup point has LOS to target
	hitActor = ai.AITrace( target.Location, loc, Vect(1, 1, 1) );
	if ( hitActor == None || hitActor == target )
	{
		return true;
	}
	else
	{
		//log( name @ "candidate position occluded" );
		return false;
	}
}

//---------------------------------------------------------------------
// what's your preferred weapon range?

private final function float proximityFunction()
{
	if ( followFunction != None )
		return followFunction.proximityFunction();
	else
		return proximity;
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
	if ( moveGoal != None )
	{
		moveGoal.Release();
		moveGoal = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is maneuvering to attack" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// set up purely for Pursue: memory function won't work on this sensor if it's always started from scratch
	targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', characterResource() ) );
	targetMemorySensor.setParameters( target, ai.visionMemory );

	// if you got a speed pack, use it on first approach!
	if ( ai.pack != None && ai.bUsePackActiveEffect && ai.speedPackUseCategory == SP_ON_FIRST_ATTACK &&
		ai.pack.IsInState( 'Charged' ) && ClassIsChildOf( ai.pack.class, class'SpeedPack' ) )
	{
		ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackSpeed' );
		ai.pack.activate();
	}

	combatRange = ai.combatRangeCategory;
	combatMovement = ai.combatMovementCategory;

	if ( combatRange == CR_DRAW_OUT )
		proximityHysteresis = PROXIMITY_HYSTERESIS_DRAW_OUT;
	else
		proximityHysteresis = PROXIMITY_HYSTERESIS_STAY_AT_RANGE;

	// keep pursuing the target unless goalTest interrupts to do a special move (backing up, flanking, look for cover)
	while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) && (followGoal == None || !followGoal.wasNotAchieved() ))
	{
		if ( followGoal != None )
		{
			followGoal.unPostGoal( self );	// "interruptGoalIf" unposts goal when interrupted but not when goal fails
			followGoal.Release();			// must be done here as well as cleanup because followGoal could be overwritten
			followGoal = None;
		}

		//log( name $ ":" @ ai.name @ "pursuing!" );
		followGoal = (new class'AI_PursueGoal'( movementResource(), achievingGoal.priority, target, proximity, followFunction,, energyUsage )).postGoal( self ).myAddRef();
		interruptGoalIf( followGoal, class'AI_CombatMovement' );

		if ( class'Pawn'.static.checkAlive( target ) && !followGoal.wasNotAchieved() )	// only continue if pursue didn't fail
		{
			if ( movePoint != ai.Location )
			{
				moveGoal = (new class'AI_MoveToGoal'( movementResource(), achievingGoal.priority, movePoint, ,,moveSpeed, energyUsage )).postGoal( self ).myAddRef();
				waitForGoal( moveGoal );
				lastMovementTime = ai.level.timeSeconds;

				// unpost if goal failed (unnecessary if there was a flag on the goal to do this...)
				moveGoal.unPostGoal( self );
				moveGoal.Release();
				moveGoal = None;

				if ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) )
				{
					waitForAction( class'NS_Turn'.static.startAction( AI_Controller(ai.controller), self,
						Rotator(target.Location - ai.Location) ));	// cheat: accessing target's location
				}
			}
			else
				yield();
		}
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") stopped with errorCode" @ errorCode );

	if ( class'Pawn'.static.checkDead( target ) )
		succeed();
	else
		fail( errorCode );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_CombatMovementGoal'
}