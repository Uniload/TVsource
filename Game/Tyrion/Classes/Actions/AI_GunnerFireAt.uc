//=====================================================================
// AI_GunnerFireAt
//
// FireAt action for vehicle mounted turrets and turret/vehicle weapons
//=====================================================================

class AI_GunnerFireAt extends AI_GunnerAction
	editinlinenew;

//=====================================================================
// Constants

// maximum allowable angular deviation between where you shooting and where your target is
const MAX_DEVIATION_POD = 25;			// ...for pods
const MAX_DEVIATION_POD_ATTACKING = 40;	// ...for pods doing attack runs 
const MAX_DEVIATION_ASSAULTSHIP = 60;	// ...for assault ships
const MAX_DEVIATION_NORMAL = 10;		// ...for everything else (i.e. turrets of all shapes and sizes)

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) bool bGiveUpIfTargetLost "Terminate action if target lost?";
var(Parameters) bool bFireWithoutLOS "Fire even if you have no LOS on the target";

var(InternalParameters) editconst Pawn target;

var Weapon weapon;
var Vector aimLocation;
var Vector inaccurateAimLocation;	// where the projectile will actually go
var Rotator aimRotation;
var int yawDiff;
var int pitchDiff;
var int rollDiff;
var int maxDeviation;
var Vector hitLocation;
var float timeToHit;
var Actor obstacle;			// possible obstacle in my shot line
var Rook rookObstacle;
var AI_TargetSensor targetSensor;
var Rook mount;
var IFiringMotor firingMotor;
var Rotator viewRotation;	// where the weapon is pointing
var bool bAssaultShip;		// true if running on the assault ship main gun
var bool bPod;				// true if running on the pod gun
var bool bChainGun;			// true if firing a chaingun weapon
var class<ExplosiveProjectile> projectileClass;

var String debugString;		// indicates what caused the AI to not fire

//=====================================================================
// Functions

//---------------------------------------------------------------------
// sensor callback (from TargetSensor)

function OnSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	if ( value.objectData == None )
	{
		if ( rook().logTyrion )
			log( name @ "target lost" );

		localRook().firingMotor().releaseFire();

		if ( class'Pawn'.static.checkAlive( target ) )
		{
			if ( bGiveUpIfTargetLost )
				instantFail( ACT_LOST_TARGET );
			else
				pauseAction();
		}
	}
	else
	{
		if ( rook().logTyrion )
			log( name @ "target acquired" );

		runAction();
	}
}

//---------------------------------------------------------------------
// compute inaccuracy that will be added to shot

private final function Rotator computeAIspread()
{
	local Rotator r;
	local float deviation;

	deviation = rook().shotAngularDeviation * ( 65536 / 360 );

	r.Yaw = FRand() * 2.f * deviation - deviation;
	r.Pitch = FRand() * 2.f * deviation - deviation;

	return r;
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

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	localRook().firingMotor().releaseFire();

	if ( targetSensor != None )
	{
		targetSensor.deactivateSensor( self );
		targetSensor = None;
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	mount = localRook();
	firingMotor = mount.firingMotor();

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(mount.findByLabel( class'Pawn', targetName, true ));

	if ( rook().logTyrion )
		log( name @ "started." @ mount.name @ "is firing at" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" @ targetName );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( !bFireWithoutLOS )
	{
		targetSensor = AI_TargetSensor( class'AI_Sensor'.static.activateSensor( self, class'AI_TargetSensor', resource ));
		targetSensor.setParameters( target );
	}

	// play that funky music, white boy!
	if ( rook().level.MusicMgr != None )
		rook().level.MusicMgr.TriggerDynamicMusic( MT_Combat );

	mount.lastShotFiredTime = mount.level.timeSeconds;	// give a new FireAt a chance to shoot at target
	mount.PlayEffect( "DetectedEnemy" );

	weapon = firingMotor.getWeapon();
	bAssaultShip = mount.IsA( 'AssaultShip' );
	bPod = mount.IsA( 'Pod' );
	bChainGun = weapon.IsA( 'ChainGun' );
	//projectileClass = class<ExplosiveProjectile>(weapon.projectileClass); //(hurtCheck disabled for now)

	if ( mount.reactionDelay > 0 )
	{
		if ( rook().logTyrion )
			log( name $ ":" @ mount.name @ "detected enemy; waiting" @ mount.reactionDelay @ "before firing" );
		Sleep( mount.reactionDelay );
	}

	while( class'Pawn'.static.checkAlive( rook() ) && class'Pawn'.static.checkAlive( target ) )	// (in range checks are done in GuardSensor)
	{
		aimLocation = weapon.aimClass.static.getAimLocation( weapon, target );
		aimRotation = Rotator(aimLocation - mount.Location);

		firingMotor.setViewRotation( aimRotation );		// aim...

		if ( bPod || bAssaultShip )
			viewRotation = rook().Rotation;				// use move rotation
		else
			viewRotation = firingMotor.getViewRotation();

		yawDiff = ( aimRotation.Yaw - viewRotation.Yaw ) & 65535;
		if ( yawDiff > 32768 )
			yawDiff = 65536 - yawDiff;

		pitchDiff = ( aimRotation.Pitch - viewRotation.Pitch ) & 65535;
		if ( pitchDiff > 32768 )
			pitchDiff = 65536 - pitchDiff;

		//rollDiff = ( aimRotation.Roll - viewRotation.Roll ) & 65535;
		//if ( rollDiff > 32768 )
		//	rollDiff = 65536 - rollDiff;

		if ( bAssaultShip )
		{
			maxDeviation = MAX_DEVIATION_ASSAULTSHIP*65536/360;
			pitchDiff = 0;
		}
		else if ( bPod )
		{
			if ( AI_Controller(mount.controller).aircraftAttacking )
				maxDeviation = MAX_DEVIATION_POD_ATTACKING*65536/360;
			else
				maxDeviation = MAX_DEVIATION_POD*65536/360;
		}
		else
			maxDeviation = MAX_DEVIATION_NORMAL*65536/360;

		debugString = "not pointing at target (" $ yawDiff * 360 / 65536 $ "," $ pitchDiff * 360 / 65536 $ "," $ rollDiff * 360 / 65536 $ "," $ maxDeviation * 360 / 65536 $ ")";

		if ( yawDiff < maxDeviation && pitchDiff < maxDeviation  )	// AI is pointing weapon within maxDeviation degrees of target and ready to fire
		{
			debugString = "weapon not ready";

			if ( weapon.fireRatePassed() || bChainGun )		// releaseFire is *not* called when this is false: prevents chainguns from going into idle state
			{
				// add inaccuracy to the aimRotation;
				weapon.AIspread = computeAIspread();
				weapon.AIAccelerationModifier = 0.0;
				inaccurateAimLocation = VSize(aimLocation - mount.Location) * Vector(aimRotation + weapon.AIspread) + mount.Location;
				obstacle = weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, weapon, inaccurateAimLocation );

				// if target's center is occluded, check if I can hit the head
				// (simple aimLocation adjustment won't work for arced projectiles so this is skipped for them)
				if ( obstacle != None && !bFireWithoutLOS && weapon.aimClass != class'AimArcWeapons' )
				{
					//log( "Adjusting" @ rook().name @ "aim upward to hit" @ target.name $ "'s head" );
					inaccurateAimLocation.Z += 0.9f * target.CollisionHeight;
					firingMotor.setViewRotation( Rotator( inaccurateAimLocation - mount.Location ));
					obstacle = weapon.aimClass.static.obstacleInPath( hitLocation, timeToHit, target, weapon, inaccurateAimLocation );
				}

				// if the obstacle is an enemy, shoot anyway!
				if ( obstacle != None )
				{
					rookObstacle = Rook(obstacle);
					if ( rookObstacle != None && !rook().isFriendly( rookObstacle ) && rookObstacle.Health > 0 )
						obstacle = None;
				}

				// debug display
				if ( mount.bShowTyrionWeaponDebug )
				{
					if ( bFireWithoutLOS )
						debugString = "FIREWITHOUTLOS";
					else if (obstacle == None )
						debugString = "obst:None";
					else
						debugString = "obst:" $ obstacle;

					if ( projectileClass != None &&
						VDistSquared( target.Location, mount.Location ) <= projectileClass.default.radiusDamageSize * projectileClass.default.radiusDamageSize )
						debugString = "TARGET TOO CLOSE";
				}

				if ( (obstacle == None || bFireWithoutLOS) &&				// projectile has clear path
					(projectileClass == None ||								// will damage itself?
					VDistSquared( target.Location, mount.Location ) > projectileClass.default.radiusDamageSize * projectileClass.default.radiusDamageSize ))
				{
					if ( bChainGun )
					{
						if ( Chaingun(weapon).overheated )
							firingMotor.releaseFire();
						else
						{
							mount.lastShotFiredTime = mount.level.timeSeconds;
							firingMotor.fire(false);	// ... and shoot!
						}
					}
					else
					{
						mount.lastShotFiredTime = mount.level.timeSeconds;
						firingMotor.fire(true);			// ... and shoot!
					}
				}
				else
				{
					firingMotor.releaseFire();
				}
			}
		}
		else
		{
			firingMotor.releaseFire();
		}

		yield();
	}

	if ( rook().logTyrion )
		log( name @ "(" @ mount.name @ ") stopped" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GunnerFireAtGoal'