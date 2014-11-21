//=====================================================================
// AI_ReactToFire
// Reacts to being shot at:
// - when hit, looks around and take cover if not in combat
// - when nearly hit, look around and take cover if not in combat
// - future: when closeby ally hit, look around and take cover if not in combat
// Note: when the shooter is a friendly, this action will only be activated when hit;
//       sounds only activate this action if soundmaker isn't visible and not a friendly
//=====================================================================

class AI_ReactToFire extends AI_CharacterAction
	editinlinenew
	dependsOn(AI_ReactToFireSensor);

import enum TriggerCategories from AI_ReactToFireSensor;

//=====================================================================
// Constants

const DIRECTDETECT_RADIUS = 1000.0f;	// if attacker is within this distance, his position is always known

//=====================================================================
// Variables

var(Parameters)	float panicChance "chance of panicking when being shot at by an unseen assailant";
var(Parameters) float nearHitDistance "Max distance to react to near hit";
var(Parameters) float allyShotDistance "Max distance to react to an ally getting shot";

var Rook enemy;
var TriggerCategories trigger;	// what triggered ReactToFire?
var bool bFriendly;				// was shooter a friendly?
var bool bVisible;				// is shooter visible?
var bool bPotentiallyVisible;	// is shooter within range to be visible?
var float sightRadius;			// sightRadius to this enemy
var float distSquared;			// squared distance to shooter
var Character.GroundMovementLevels searchSpeed;
var AI_Goal subGoal;			// what you do to react to fire

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 0.1;					// default reaction; character-specific ones have higher score
}

//---------------------------------------------------------------------
// should the target of the targetsensor by the enemy, 
// updates the last known position of said target

private final function updateTargetPosition( AI_TargetSensor sensor, Rook enemy )
{
	if ( sensor != None && sensor.target == enemy && sensor.queryObjectValue() == None )
	{
		// pretend you just caught a glimpse of the target...
		sensor.OnViewerSawPawn( pawn, enemy );
		sensor.OnViewerLostPawn( pawn, enemy );
	}
}

//---------------------------------------------------------------------

private final function float getSightRadius( Rook enemy )
{
	if ( enemy.controller.bIsPlayer )
		return rook().sightRadiusToPlayer;
	else
		return pawn.sightRadius;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( subGoal != None )
	{
		subGoal.Release();
		subGoal = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	// This bit of code assumes that the reactToFire action is started by the reactToFire sensor
	// (and consequently, that the sensor has meaningful values when this action runs). 
	// todo: Think of a way to formalize this dependency? The action could declare its interest in a value even though it doesn't require callbacks?)
	enemy = Rook(characterResource().commonSenseSensorAction.reactToFireSensor.attacker);	// knowing who fired the shot is a bit a cheat, but the AI does have to spot the enemy before reacting

	if ( enemy == None )
	{
		log( "AI WARNING:" @ name $ ":" @ pawn.name @ "has no enemy to react to" );
	}
	else if ( class'Pawn'.static.checkDead( enemy ) )
	{
		;	// enemy is dead
	}
	else
	{
		trigger = characterResource().commonSenseSensorAction.reactToFireSensor.triggerCategory;
		bFriendly = rook().isFriendly( enemy );
		bVisible = rook().vision.isVisible( enemy );

		if ( pawn.logTyrion )
			log( name @ "started." @ panicChance @ enemy.name @ trigger @ bFriendly @ bVisible );

		if ( bFriendly )
		{
			//log( pawn.name $ ": Stop shooting at me," @ enemy.name $ "! You dumbass!" );
			if ( baseAICharacter().scaleByWeaponRefireRate( enemy.firingMotor().getWeapon() ) )
				pawn.level.speechManager.PlayDynamicSpeech( pawn, 'AllyHurtWeapon' );
		}
		else if ( !bVisible )
		{
			// reaction to not visible unfriendlies
			AI_Controller(pawn.controller).setAlertnessLevel( ALERTNESS_Alert );

			switch ( trigger )
			{
			case RTF_PAIN:
			case RTF_NEAR_MISS:
			case RTF_COMBAT_SOUND:
				pawn.level.speechManager.PlayDynamicSpeech( pawn, 'SuspiciousCombat' );
				break;
			case RTF_MOVEMENT_SOUND:
				pawn.level.speechManager.PlayDynamicSpeech( pawn, 'SuspiciousHear' );
				break;
			}

			// Choose a reaction type, any reaction type:
			// 1. Panic
			// 2. Look for shooter
			// 3. If you have some sense where enemy is (or enemy is out of sight range): look for cover

			distSquared = VDistSquared( enemy.Location, pawn.Location );
			sightRadius = getSightRadius( enemy );
			bPotentiallyVisible = (distSquared <= sightRadius * sightRadius );

			// if being attacked by your current target: target's position gets updated!
			updateTargetPosition( characterResource().commonSenseSensorAction.targetSensor, enemy );
			updateTargetPosition( characterResource().commonSenseSensorAction.targetMemorySensor, enemy );

			if ( trigger != RTF_MOVEMENT_SOUND && FRand() < panicChance )
			{
				// Panic
				subGoal = (new class'AI_PanicGoal'( resource, 99 )).postGoal( self ).myAddRef();
			}
			else if ( distSquared < DIRECTDETECT_RADIUS * DIRECTDETECT_RADIUS )
			{
				// Turn to enemy
				subGoal = (new class'AI_TurnGoal'( movementResource(), achievingGoal.priority, Rotator(enemy.Location - pawn.Location) )).postGoal( self ).myAddRef();
			}
			else if ( !bPotentiallyVisible ||
				(trigger == RTF_COMBAT_SOUND && FRand() < 0.5f && enemy.vision != None && enemy.vision.isLocallyVisible( pawn ) ))
			{
				// Take cover
				subGoal = (new class'AI_TakeCoverGoal'( movementResource(), achievingGoal.priority, enemy, true )).postGoal( self ).myAddRef();
			}
			else
			{
				// Look for enemy
				if ( trigger == RTF_MOVEMENT_SOUND )
					searchSpeed = GM_WALK;
				else
					searchSpeed = GM_ANY;

				subGoal = (new class'AI_SearchGoal'( movementResource(), achievingGoal.priority, enemy, searchSpeed )).postGoal( self ).myAddRef();
			}

			// Wait for the subGoal?
			if ( subGoal != None )
			{
				yield();		// wait a tick for goal to get matched

				//log( subGoal.name @ subGoal.matchedN @ subGoal.bGoalFailed @ subGoal.bGoalAchieved );

				// if goal didn't get matched or failed, forget about it!
				if ( subGoal.matchedN == 0 || subGoal.bGoalFailed )
					subGoal.unPostGoal( self );
				else if ( !subGoal.bGoalAchieved )
					WaitForGoal( subGoal, true );
			}
		}
	}

	if ( pawn.logTyrion )
		log( name @ "stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_ReactToFireGoal'
}