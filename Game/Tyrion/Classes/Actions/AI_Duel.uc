//=====================================================================
// AI_Duel
// Duels with the target.
//
// Notes:
// Duel decides whether to be aggressive or defensive
// 1. Aggressive ("Chase"): Fly towards opponent on a diagonal - try to land on high terrain if possible
// 2. Defensive ("Lure"): Move around, hide behind cover - gain height if possible
//	
// Option 1: Duel action runs concurrently and posts/unposts lure/chase goals
// Option 2: Lure/Chase pre-conditions figure out their own activation
//
// I like Option 1 better because it's hard for lure to know when a chase is more appropriate.
// It also enables Duel to interrupt GainHeight should the target be spotted
// The only disadvantage is having parent and child actions running at the same time. Given the number of
// Duel actions active at the same time (not a lot) that's probaby a minor thing.
//=====================================================================

class AI_Duel extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

const MAX_TAKECOVER_DIST = 3000.0f;			// duelist doesn't try to take cover unless at least *this* close
const JETPACK_BEHIND_DIST = 2000.0f;		// don't jetpack behind unless at least *this* close

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the duelist (1, 2, or 3)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

var() float maxSpinfusorRange "maximum distance at which the Duelist uses the spinfusor";
var() float maxBucklerRange "maximum distance at which the Duelist uses the buckler";
var() float maxEnergyBladeRange "Maximum distance at which to use the energy blade";

var() float idealSpinfusorRange "preferred distance for using the spinfusor";
var() float idealGrenadeLauncherRange "preferred distance for using the grenade launcher";
var() float idealBucklerRange "preferred distance for using the buckler";

var BaseAICharacter ai;
var AI_Goal takeCoverGoal;
var AI_Goal gainHeightGoal;
var AI_TargetMemorySensor targetMemorySensor;
var Character targetCharacter;
var vector destination;
var float jetpackBehindDistance;	// max distance at which to try to jetpack behind target

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a duelist
}

//---------------------------------------------------------------------
// callbacks from subGoals

function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	super.goalAchievedCB( goal, child );
	clearGoals( goal );
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	super.goalNotAchievedCB( goal, child, errorCode );
	clearGoals( goal );
}

final function clearGoals( AI_Goal goal )
{
	if ( goal == takeCoverGoal && takeCoverGoal != None )
	{
		takeCoverGoal.unPostGoal( self );
		takeCoverGoal.Release();
		takeCoverGoal = None;
	}

	if ( goal == gainHeightGoal && gainHeightGoal != None )
	{
		gainHeightGoal.unPostGoal( self );
		gainHeightGoal.Release();
		gainHeightGoal = None;
	}
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;
	local Vector hitLocation;
	local float timeToHit;
	local Character targetCharacter;

	w = Weapon( ai.nextEquipment( None, class'Buckler' ));
	if ( w != None && w.hasAmmo() &&
		( preferredWeaponClass == class'Buckler' ||
		  VDistSquared( ai.Location, target.Location ) < maxBucklerRange * maxBucklerRange ) && 
		w.aimClass.static.obstacleInPath( hitLocation,
										  timeToHit,
										  target,
										  w,
										  w.aimClass.static.getAimLocation( w, target )) == None )
		return w;

	w = Weapon( ai.nextEquipment( None, class'EnergyBlade' ));
	if ( w != None && VDistSquared( ai.Location, target.Location ) <= maxEnergyBladeRange * maxEnergyBladeRange )
		return w;

	targetCharacter = Character(target);

	w = Weapon( ai.nextEquipment( None, class'Spinfusor' ));
	if ( w != None && w.hasAmmo() && 
		( preferredWeaponClass == class'Spinfusor' ||
		  VDistSquared( ai.Location, target.Location ) < maxSpinfusorRange * maxSpinfusorRange ||
		  (targetCharacter != None && targetCharacter.isInAir() && target.Velocity.Z > 0)) &&	// target airborne and going up: use spinfusor
		w.aimClass.static.obstacleInPath( hitLocation,
										  timeToHit,
										  target,
										  w,
										  w.aimClass.static.getAimLocation( w, target )) == None &&
  		!w.aimClass.static.willHurt( w, ai, hitLocation, timeToHit ))
		return w;

	w = Weapon( ai.nextEquipment( None, class'GrenadeLauncher' ));
	if ( w != None && w.hasAmmo() )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	// always try to back up to the ideal spinfusor range unless holding the energy blade
	if ( ClassIsChildOf( weaponClass, class'EnergyBlade' ))
		return 0.8f * (class'EnergyBlade'.default.range + target.CollisionRadius);	// energy blade
	else
		return idealSpinfusorRange;
}

//---------------------------------------------------------------------
// are conditions met for firing this weapon?

function bool bShouldFire( BaseAICharacter ai, Weapon weapon )
{
	return true;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	weaponSelection = None;
	followFunction = None;

	// when Duel deactivates, AI keeps on moving with his last direction
	// (maybe there should be a default low-pri action that lands the AI?)
	if ( class'Pawn'.static.checkAlive( pawn ) )
		AI_Controller(pawn.controller).stopMove();

	if ( targetMemorySensor != None )
	{
		targetMemorySensor.deactivateSensor( self );
		targetMemorySensor = None;
	}

	if ( takeCoverGoal != None )
	{
		takeCoverGoal.Release();
		takeCoverGoal = None;
	}

	if ( gainHeightGoal != None )
	{
		gainHeightGoal.Release();
		gainHeightGoal = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rank != 1 && rank != 2 && rank != 3 )
	{
		log( "AI ERROR: invalid rank" @ rank @ "given to duelist" @ Pawn.name );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started." @ pawn.name @ "is dueling" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS );
	}

	targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', characterResource() ) );
	targetMemorySensor.setParameters( target, rook().visionMemory );
	ai = baseAICharacter();
	targetCharacter = Character(target);
	jetpackBehindDistance = FMax( JETPACK_BEHIND_DIST, 1.2f * idealSpinfusorRange );	// so AI jetpacks even when backed up to spinfusor range

	(new class'AI_DirectAttackGoal'( characterResource(), achievingGoal.priority-1, target, self, preferredWeaponClass, followFunction )).postGoal( self );

	while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) )
	{
		// decide whether to be aggressive
		if ( ( targetCharacter == None || targetCharacter.energy > ai.energy || !targetCharacter.isInAir() ) &&
			targetMemorySensor.queryObjectValue() != None &&
			VSizeSquared2D( target.Location - ai.Location ) < jetpackBehindDistance * jetpackBehindDistance &&
			class'AI_JetpackBehind'.static.getJetpackBehindPoint( destination, ai, target ))
		{
			if ( ai.logTyrion )
				log( name @ "(" @ ai.name @ ") aggressively attacking (jetpacking behind)" );

			if ( takeCoverGoal != None )
			{
				takeCoverGoal.unPostGoal( self );
				takeCoverGoal.Release();
				takeCoverGoal = None;
			}

			if ( gainHeightGoal != None )
			{
				gainHeightGoal.unPostGoal( self );
				gainHeightGoal.Release();
				gainHeightGoal = None;
			}

			WaitForGoal( (new class'AI_JetpackBehindGoal'( movementResource(), achievingGoal.priority, target, destination, 
															1.2f * jetpackBehindDistance, followFunction )).postGoal( self ), true );
		}
		else
		{
			/*if ( takeCoverGoal == None && gainHeightGoal == None )
			{
				if ( VDistSquared( target.Location, ai.Location ) < MAX_TAKECOVER_DIST * MAX_TAKECOVER_DIST )
				{
					if ( true || ai.logTyrion )
						log( name @ "(" @ ai.name @ ") taking cover" );

					takeCoverGoal = (new class'AI_TakeCoverGoal'( movementResource(), achievingGoal.priority, target, 75 )).postGoal( self ).myAddRef();
				}
				else
				{
					if ( true || ai.logTyrion )
						log( name @ "(" @ ai.name @ ") gaining height" );

					gainHeightGoal = (new class'AI_GainHeightGoal'( movementResource(), achievingGoal.priority, target, 75 )).postGoal( self ).myAddRef();
				}
			}*/
		}

		//log( takeCoverGoal @ gainHeightGoal );
		yield();
	}

	if ( class'Pawn'.static.checkDead( target ) )
	{
		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") stopped. TARGET DEAD!" );
		succeed();
	}
	else
		fail( ACT_GENERAL_FAILURE );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_AttackGoal'

	maxSpinfusorRange			= 3000
	maxBucklerRange				= 1800
	maxEnergyBladeRange			= 750

	idealSpinfusorRange			= 2000
	idealGrenadelauncherRange	= 3000
	idealBucklerRange			= 1200
}