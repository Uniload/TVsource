//=====================================================================
// AI_FireAt
// Shoots at a target
// Succeeds if target is dead
//=====================================================================

class AI_FireAt extends AI_WeaponAction
	editinlinenew;

import enum GrenadeUseCategories from BaseAICharacter;
import enum SpeedPackUseCategories from BaseAICharacter;

//=====================================================================
// Constants
 
const MAX_DEVIATION = 10;						// maximum allowable yaw deviation between where you shooting and where your target is
const MIN_TIME_BETWEEN_WEAPON_CHANGE = 5;		// (in seconds)
const MIN_TIME_BETWEEN_GRENADE_THROWS = 4;		// (in seconds)
const INACCURACY_INCREASE_WHEN_MOVING = 2.0f;	// factor by which inaccuracy of moving AI's is increased

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";
var(Parameters) bool bGiveUpIfTargetLost "Terminate action if target lost?";
var(Parameters) bool bFireWithoutLOS "Fire even if you have no LOS on the target";

var(InternalParameters) editconst Rook target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;

var BaseAICharacter ai;
var AI_Controller c;
var Vector projectileSpawnLocation;	// where the projectile spawns
var Vector aimLocation;				// spot I'm aiming for
var Vector inaccurateAimLocation;	// where the projectile will actually go
var Rotator aimRotation;			// rotator to turn character to "aimLocation"
var int yawDiff;
var Actor obstacle;			// possible obstacle in my shot line
var Rook rookObstacle;
var Character obstacleChar;	// possible character in my shot line
var Weapon newWeapon;
var Weapon weapon;
var Vector hitLocation;
var float timeToHit;
var AI_TargetSensor targetSensor;
var AI_TargetMemorySensor targetMemorySensor;
var float lastWeaponChange;	// time at which weapon was last changed
var float lastGrenadeThrow;	// time at which hand grenade was last thrown
var float effectiveRange;	// max effective range of weapon

var String debugString;		// indicates what caused the AI to not fire

//=====================================================================
// Functions

//---------------------------------------------------------------------
// sensor callback (from TargetSensor)

function OnSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	if ( sensor == targetSensor && value.objectData == None )
	{
		if ( ai.logTyrion )
			log( name @ "target lost" );

		character().motor.releaseFire();

		if ( class'Pawn'.static.checkAlive( target ) && bGiveUpIfTargetLost )
		{
			instantFail( ACT_LOST_TARGET );
		}
	}

	if ( sensor == targetMemorySensor )
	{
		if ( value.objectData == None )
		{
			c.bAiming = false;

			if ( class'Pawn'.static.checkAlive( target ) )
			{
				pauseAction();
			}
		}
		else
		{
			if ( ai.logTyrion )
				log( name @ "(" @ ai.name @ ") target acquired" @ target );

			runAction();
		}
	}
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	rook().bUnobstructedLOF = true;
	weaponSelection = None;

	if ( character().weapon != None )
		character().motor.releaseFire();

	if ( rook().controller != None )
		AI_Controller(rook().controller).bAiming = false;

	if ( targetSensor != None )
	{
		targetSensor.deactivateSensor( self );
		targetSensor = None;
	}

	if ( targetMemorySensor != None )
	{
		targetMemorySensor.deactivateSensor( self );
		targetMemorySensor = None;
	}
}

//---------------------------------------------------------------------
// Decides whether to switch the character's weapon;
// Returns weapon equipped after switch

private final function Weapon chooseWeapon()
{
	local Weapon newWeapon;

	if ( target.level.TimeSeconds > lastWeaponChange + MIN_TIME_BETWEEN_WEAPON_CHANGE &&
			(weaponSelection != None || preferredWeaponClass != None ))
	{
		if ( weaponSelection != None )
			newWeapon = weaponSelection.bestWeapon( ai, target, preferredWeaponClass );
		else
			newWeapon = Weapon( ai.nextEquipment( None, preferredWeaponClass ));

		if ( newWeapon != None && ai.weapon != newWeapon )
		{
			if ( ai.motor.setWeapon( newWeapon ) )
			{
				// weapon change succeeded
				lastWeaponChange = target.level.TimeSeconds;

				// check for speed pack use
				if ( ai.pack != None && ai.bUsePackActiveEffect && ai.speedPackUseCategory == SP_WHEN_CLOSE &&
					ai.pack.IsInState( 'Charged' ) &&
					VDistSquared( target.Location, ai.Location ) <= class'BaseAICharacter'.const.SPEEDPACK_DISTANCE * class'BaseAICharacter'.const.SPEEDPACK_DISTANCE &&
					ClassIsChildOf( ai.pack.class, class'SpeedPack' ) )
				{
					ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackSpeed' );
					ai.pack.activate();
				}

				if ( ai.logTyrion )
					log( name @ "picked" @ newWeapon.name );
			}
		}
	}
	return ai.weapon;
}

//---------------------------------------------------------------------
// compute inaccuracy that will be added to shot

private final function Rotator computeAIspread()
{
	local Rotator r;
	local float deviation;

	deviation = ai.shotAngularDeviation * ( 65536 / 360 );

	if ( ai.firingWhileMovingState != FWM_GOOD && !IsNearlyZero( ai.Velocity ) )
		deviation *= INACCURACY_INCREASE_WHEN_MOVING;

	r.Yaw = FRand() * 2.f * deviation - deviation;
	r.Pitch = FRand() * 2.f * deviation - deviation;

	//log( r.Yaw @ VSize( aimVector - (aimVector << r )));
	return r;
}

//---------------------------------------------------------------------
// keep rotated towards target?

private final function bool bTrackTarget()
{
	return ai.firingWhileMovingState >= FWM_POOR || IsNearlyZero( ai.Velocity );
}

//---------------------------------------------------------------------
// return pertinent information about an action for debugging

function string actionDebuggingString()
{
	if ( target == None )
		return String(name) @ "NOTARGET" @ debugString;
	else
		return String(name) @ target.Name @ debugString;
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

	ai = BaseAICharacter();

	if ( target == None )
		target = Rook(ai.findByLabel( class'Rook', targetName, true ));

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is firing at" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	c = AI_Controller(ai.controller);

	if ( !bFireWithoutLOS )
	{
		targetSensor = AI_TargetSensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetSensor', characterResource() ) );
		targetSensor.setParameters( target );

		targetMemorySensor = AI_TargetMemorySensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetMemorySensor', characterResource() ) );
		targetMemorySensor.setParameters( target, ai.visionMemory );
	}

	// play that funky music, white boy!
	if ( ai.level.MusicMgr != None )
		ai.level.MusicMgr.TriggerDynamicMusic( MT_Combat );

	ai.lastShotFiredtIme = ai.level.timeSeconds;	// give a new FireAt a chance to shoot at target

	// reaction time
	if ( ai.reactionDelay > 0 && ai.getAlertnessLevel() == ALERTNESS_Neutral )
	{
		// <-- yell out stuff here
		if ( ai.logTyrion )
			log( name $ ":" @ ai.name @ "is startled; waiting" @ ai.reactionDelay @ "before firing" );
		Sleep( ai.reactionDelay );
	}

	while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ))
	{
		// miss speech events
		if ( target.attacker != None && target.expectedImpactTime < ai.level.TimeSeconds &&
			ai.level.TimeSeconds - target.expectedImpactTime <= 1.0 )
		{
			//log( "SHAZBOT!" @ target.attacker.name @ "missed" @ target.name @ "(" $ ai.weapon $ ")" );
			ai.level.speechManager.PlayDynamicSpeech( target.attacker, 'Miss' );
			target.attacker = None;
		}

		// pain reaction
		while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) &&
				ai.noAttackUntil > ai.level.timeSeconds )
		{
			//log( ai.name @ "not firing!" );
			if ( ai.weapon != None )
				ai.motor.releaseFire();
			yield();
		}

		if ( class'Pawn'.static.checkDead( ai ) || class'Pawn'.static.checkDead( target ) )
			continue;

		weapon = chooseWeapon();	// possibly choose new weapon (can be None if weapon is being switched)

		// compute place to aim to
		if ( weapon == None )
		{
			aimLocation = target.Location;
			projectileSpawnLocation = ai.Location;
		}
		else
		{
			aimLocation = weapon.aimClass.static.getAimLocation( weapon, target );
			//projectileSpawnLocation = ai.motor.getFirstPersonEquippableLocation( weapon ); possibly less accurate
			if ( VDistSquared( ai.Location, target.Location ) <= 400.0f * 400.0f )
				projectileSpawnLocation = ai.Location;
			else
				projectileSpawnLocation = weapon.rookMotor.getProjectileSpawnLocation();
		}

		// track target while moving?
		c.bAiming = true;			//was: bTrackTarget();

		// stay pointed towards target
		aimRotation = Rotator(aimLocation - projectileSpawnLocation);
		if ( c.bAiming )
		{
			ai.motor.setAIMoveRotation( aimRotation );
			ai.motor.setViewRotation( aimRotation );	// target needs to kept in view
		}

		if ( weapon != None && (ai.firingWhileMovingState != FWM_NEVER || IsNearlyZero( ai.Velocity )) && !weapon.IsA( 'Grappler' ) )
		{
			yawDiff = ( aimRotation.Yaw - ai.motor.getMoveRotation().Yaw ) & 65535;
			if ( yawDiff > 32768 )
				yawDiff = 65536 - yawDiff;

			if ( yawDiff >= MAX_DEVIATION*65536/360 )
				debugString = "not pointing at target (" $ yawDiff * 360 / 65536 $ "/" $ MAX_DEVIATION $ ")";
			else
				debugString = "bShouldFire is false";

			// AI is pointing weapon within 10 degrees of target and ready to fire
			if ( yawDiff < MAX_DEVIATION*65536/360 && weapon.canFire() && ( weaponSelection == None || weaponSelection.bShouldfire( ai, weapon ) ))
			{
				debugString = "weapon not ready";

				if ( weapon.fireRatePassed() || weapon.IsA( 'ChainGun' ))	// releaseFire is *not* called when this is false: prevents chainguns from going into idle state
				{
					c.setAlertnessLevel(ALERTNESS_Combat);

					// add inaccuracy to the aimRotation;
					weapon.AIspread = computeAIspread();
					weapon.AIAccelerationModifier = 0.0;
					inaccurateAimLocation = VSize(aimLocation - projectileSpawnLocation) * Vector(aimRotation + weapon.AIspread) + projectileSpawnLocation;

					// set hitLocation/timeToHit to sensible values in case nothing is hit
					hitLocation = target.Location;
					timeToHit = weapon.aimClass.static.getTimeToHitTarget( weapon, target );

					// main obstacle check
					obstacle = weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, weapon, inaccurateAimLocation );

					// use hand grenade?
					// (decision to use could easily be moved to "chooseWeapon()" function if need be)
					if ( obstacle != None && ai.grenadeUseCategory == GU_USE && ai.altWeapon != None &&
						ai.level.TimeSeconds > lastGrenadeThrow + MIN_TIME_BETWEEN_GRENADE_THROWS &&
						ai.altWeapon.IsA( 'HandGrenade' ) && ai.altWeapon.hasAmmo() ) 
					{
						weapon = ai.altWeapon;
						lastGrenadeThrow = ai.level.TimeSeconds;
						obstacle = weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, weapon, inaccurateAimLocation );
					}

					// if target's center is occluded, check if I can hit the head
					// (simple aimLocation adjustment won't work for arced projectiles so this is skipped for them)
					if ( obstacle != None && !bFireWithoutLOS && weapon.aimClass != class'AimArcWeapons' )
					{
						//log( "Adjusting" @ ai.name @ "aim upward to hit" @ target.name @ "head" );
						inaccurateAimLocation.Z += 0.9f * target.CollisionHeight;
						ai.motor.setViewRotation( Rotator( inaccurateAimLocation - projectileSpawnLocation ));
						obstacle = weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, weapon, inaccurateAimLocation );
					}

					effectiveRange = weapon.aimClass.static.getMaxEffectiveRange( weapon.class );

					// debug display
					if ( ai.bShowTyrionWeaponDebug )
					{
						if ( bFireWithoutLOS )
							debugString = "FIREWITHOUTLOS";
						else if (obstacle == None )
							debugString = "obst:None";
						else
							debugString = "obst:" $ obstacle;

						if ( weapon.aimClass.static.willHurt( weapon, ai, hitLocation, timeToHit ) )
							debugString $= " WILLHURTME";
						if ( weapon.willHurtFriendly( hitLocation, timeToHit, hitLocation != target.Location ) )
							debugString $= " WILLHURTFRIENDLY";
						if ( !(effectiveRange < 0 || ai.combatRangeCategory == CR_STAND_GROUND ||
							VDistSquared( ai.Location, target.Location ) <= effectiveRange * effectiveRange))
							debugString $= " OUTOFRANGE";
					}	

					// if the obstacle is an enemy, shoot anyway!
					if ( obstacle != None )
					{
						rookObstacle = Rook(obstacle);
						if ( rookObstacle != None && !ai.isFriendly( rookObstacle ) && rookObstacle.Health > 0 )
							obstacle = None;
					}

					ai.bUnobstructedLOF = (obstacle == None || bFireWithoutLOS);

					// check that projectile has clear path and won't hurt me or a friendly
					if ( ai.bUnobstructedLOF &&
						!weapon.aimClass.static.willHurt( weapon, ai, hitLocation, timeToHit ) &&
						!weapon.willHurtFriendly( hitLocation, timeToHit, hitLocation != target.Location ) &&
						(effectiveRange < 0 || ai.combatRangeCategory == CR_STAND_GROUND ||
							VDistSquared( ai.Location, target.Location ) <= effectiveRange * effectiveRange) )
					{
						//ai.motor.setViewRotation( Rotator( aimLocation - projectileSpawnLocation ));

						if ( weapon.bGenerateMissSpeechEvents )
							class'Setup'.static.setTarget( ai, target, timeToHit );		// for miss speech events

						if ( weapon.IsA( 'Chaingun' ) )
						{
							// special case code for the chaingun (which spins up and overheats)
							if ( Chaingun(weapon).overheated )
							{
								debugString = "overheated";
								ai.motor.releaseFire();
							}
							else
							{
								ai.lastShotFiredTime = ai.level.timeSeconds;
								ai.motor.fire(false);
							}
						}
						else if ( weapon.IsA( 'HandGrenade' ) )
						{
							ai.motor.altFire(true);
						}
						else
						{
							//log( ai.name @ "firing!" );
							ai.lastShotFiredTime = ai.level.timeSeconds;
							ai.motor.fire(true);
						}
				    }
				    else
				    {
					    obstacleChar = Character(obstacle);
					    if ( class'Pawn'.static.checkAlive( obstacleChar ) &&
						    obstacleChar.isFriendly( ai ) &&
						    !obstacleChar.isHumanControlled() )
					    {
						    // tell character (if he's friendly) to get out of the damn way
						    //log( "MOVE IT OR LOSE IT!" @ ai.name @ "is being blocked by" @ obstacleChar.name @ class'pawn'.static.checkAlive( obstacleChar ) );
							ai.level.speechManager.PlayDynamicSpeech( ai, 'AllyBlock' );
							AI_CharacterResource(obstacleChar.characterAI).commonSenseSensorAction.getOutOfWaySensor.setValue( ai, aimLocation );
					    }
					    ai.motor.releaseFire();
				    }
				}
			}
			else
			{
				ai.motor.releaseFire();
			}
		}
		yield();
	}

	if ( ai.logTyrion )
		if ( class'Pawn'.static.checkDead( target ) )
			log( name @ "stopped. TARGET DEAD!" );
		else
			log( name @ "stopped." );

	if ( class'Pawn'.static.checkAlive( ai ) )
		succeed();
	else
		fail( ACT_RESOURCE_INACTIVE );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_FireAtGoal'
}