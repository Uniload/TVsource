//=====================================================================
// AI_DodgeSensor
// Keeps tracks of this pawn's enemies
// Value (object): pointer to the shooter that triggered dodge
//=====================================================================

class AI_DodgeSensor extends AI_Sensor implements IShotNotification;

//=====================================================================
// Constants

const DODGE_DURATION = 2.0f;		// how many seconds will the dodge displacement be valid for
const DEFAULT_DODGE_DISTANCE = 250;			// how far the pawn dodges
const MIN_DODGE_BY_JETPACKING_TIME = 0.3f;	// min. time needed to dodge by jetpacking
const MAX_DODGE_BY_JETPACKING_TIME = 0.8f;	// max. time needed to dodge by jetpacking
const MAX_COLLISION_PREDICTION_ITERATIONS = 100;
//const RUN_SPEED = 555.0f;			// 25km/h / 3.6f * 80.0f

//=====================================================================
// Variables

var Rook protectee;					// thing being protected; set if this AI is trying to block shots (None otherwise)
var float shieldPackTime;			// use shield pack if impact in less than this many seconds

var AI_EnemySensor enemySensor;
var BaseAICharacter ai;				// the character this sensor is running on

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Sensor callback (from enemySensor)

function onSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	//log( name @ "sensorMessage called by" @ sensor.name @ "with value" @ value.integerData );

	if ( enemySensor.lastSeen != None )
		enemySensor.lastSeen.RegisterShotNotification( self );

	if ( enemySensor.lastLost != None )
		enemySensor.lastLost.UnRegisterShotNotification( self );
}

//---------------------------------------------------------------------
// shot callbacks

function OnShooterFiredShot( Pawn shooter, Actor projectile )
{
	local Weapon weapon;
	local Vector hitLocation;
	local float timeToHit;		// estimate of when projectile will hit me
	local Vector dodgeDisplacement;
	local bool bHitProtectee;		// will this projectile do damage to 'protectee'?
	local bool bHitMe;				// will this projectile do damage to me
	local AI_Controller controller;
	local Vector lastValidLocation;
	//local float timeToDodge;

	local array<Actor> ignore; // passed to canPointBe Reached

	assert( ai != None );
	if ( ai.Controller == None )
		return;					// ai is in a vehicle

	if ( ai.Physics != PHYS_Movement )
	{
		log( "AI WARNING: OnShooterFiredShot called on" @ ai.name @ "but AI is is physics mode" @ ai.Physics );
		return;
	}

	weapon = Rook(shooter).firingMotor().getWeapon();
	controller = AI_Controller(ai.controller);

	//log( "---->" @ ai.name @ "sez:" @ shooter.name @ "fired" @ projectile.name );

	if ( projectile.IsA( 'MortarProjectile' ) || projectile.IsA( 'GrenadeLauncherProjectile' ) || projectile.IsA( 'SniperRifleProjectile' ))
		ai.level.speechManager.PlayDynamicSpeech( ai, 'Detect', None, projectile );

	if ( protectee != None )
		bHitProtectee = willHurt( hitLocation, timeToHit, protectee, weapon, projectile );

	if ( !bHitProtectee )
		bHitMe = willHurt( hitLocation, timeToHit, ai, weapon, projectile );	// todo: take account of projectiles still en route

	if ( bHitMe || bHitProtectee )
	{
		// "dodgeDirection" will contain a displacement vector that has to be reduced to 0
		if ( bHitProtectee )
		{
			// dodge to block shots /////////////////////////////

			dodgeDisplacement = class'ActionBase'.static.closestPointOnALine( ai.Location, shooter.Location, projectile.Velocity ) - ai.Location;

			if ( ai.jetCompetency == JC_NONE )
				dodgeDisplacement.Z = 0;

			//log( ai.name @ "Dodging to protect" @ protectee.name $ ". Displacement:" @ dodgeDisplacement @ "( length:" @ VSize( dodgeDisplacement ) @ ")" );
		}
		else
		{
			// dodge to protect yourself ////////////////////////

			if ( ai.jetCompetency == JC_NONE || ai.Energy < 10 ||
				timeToHit < MIN_DODGE_BY_JETPACKING_TIME || timeToHit > MAX_DODGE_BY_JETPACKING_TIME ||
				!projectile.IsA( 'ExplosiveProjectile' ) )
			{
				//log( "dodging by walking" );
				// dodging by walking: dodge direction is orthogonal to projectile direction
				dodgeDisplacement.X = -projectile.Velocity.Y;
				dodgeDisplacement.Y = projectile.Velocity.X;
				dodgeDisplacement.Z = 0;

				// scale
				if ( projectile.IsA( 'ExplosiveProjectile' ) )
					dodgeDisplacement *= weapon.aimClass.static.getProjectileDamageRadius( weapon.projectileClass ) / VSize( dodgeDisplacement );
				else
					dodgeDisplacement *= DEFAULT_DODGE_DISTANCE / VSize( dodgeDisplacement ); 
			}
			else
			{
				//log( "dodging by jetpacking" );
				// dodging by jetpacking
				dodgeDisplacement.X = 0;
				dodgeDisplacement.Y = 0;
				dodgeDisplacement.Z = 100 + weapon.aimClass.static.getProjectileDamageRadius( weapon.projectileClass );

				// if you've got an energy pack, use it to boost your jump!
				if ( ai.pack != None && ai.bUsePackActiveEffect && ai.pack.IsInState( 'Charged' ) &&
					ClassIsChildOf( ai.pack.class, class'EnergyPack' ) )
				{
					ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackEnergy' );
					ai.pack.activate();
				}
			}
			
			// flip dodge direction if projectile is heading towards the side you would move to
			if ( ((hitLocation - ai.Location) Dot dodgeDisplacement) > 0 )
			{
				dodgeDisplacement.X = -dodgeDisplacement.X;
				dodgeDisplacement.Y = -dodgeDisplacement.Y;
			}

			//timeToDodge = VSize( dodgeDisplacement ) / max( VSize(ai.Velocity), RUN_SPEED );
			//if ( !controller.canPointBeReached( ai.Location, ai.predictedLocation( timeToDodge ) - dodgeDisplacement, ai, lastValidLocation ) )
			if ( !controller.canPointBeReached( ai.Location, ai.Location + dodgeDisplacement, ai, ignore, lastValidLocation ) )
			{
				//log( "Ledge! Dodge displacement reduced from" @ VSize(dodgeDisplacement) @ "to" @ VSize2D(lastValidLocation - ai.Location));
				dodgeDisplacement.X = 0.9f*(lastValidLocation.X - ai.Location.X);
				dodgeDisplacement.Y = 0.9f*(lastValidLocation.Y - ai.Location.Y);
			}

			if ( ai.dodgingCategory == DODGING_POOR &&
				// not already dodging
				(ai.level.TimeSeconds >= controller.dodgeExpirationTime ||
				IsZero( controller.dodgeDisplacement )) )
			{
				controller.dodgeStartTime = ai.level.TimeSeconds + class'BaseAICharacter'.const.DODGING_DELAY_TIME;
			}

			if ( weapon.bGenerateMissSpeechEvents )
				class'Setup'.static.setTarget( shooter, ai, timeToHit );	// for taunt miss speech events
		}

		controller.dodgeDisplacement = dodgeDisplacement;
		controller.dodgeExpirationTime = ai.level.TimeSeconds + DODGE_DURATION;

		// if you've got a shield pack and can't avoid projectile, use it!
		if ( ai.pack != None && ai.bUsePackActiveEffect && (timeToHit < shieldPackTime || bHitProtectee) && 
				ai.pack.IsInState( 'Charged' ) && ClassIsChildOf( ai.pack.class, class'ShieldPack' ) )
		{
			ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackShield' );
			ai.pack.activate();
		}

		setObjectValue( shooter );

		//ai.health = 1000;
	}
}

//---------------------------------------------------------------------
// Will 'projectile', fired by 'weapon', damage 'rook'?

private final function bool willHurt( out Vector hitLocation, out float timeToHit, Rook rook, Weapon weapon, Actor projectile )
{
	local Actor thingHit; 

	// will splash damage projectile impact within its damage radius? 
	if ( projectile.IsA( 'ExplosiveProjectile' ) )
	{
		thingHit = weapon.aimClass.static.getThingHit( hitLocation, timeToHit, weapon, projectile.Velocity );
		if ( thingHit == rook ||				// projectile will hit me!
			(thingHit != None &&
				weapon.aimClass.static.willHurt( weapon, rook, hitLocation, timeToHit )))	// splash damage will hurt me!
		{
			//log( "splash damage:" @ timeToHit );
			return true;
		}
	}

	// will other projectiles pass close to me? (Problem: there might be an obstacle on path (energy barrier for example) that will prevent impact
	if ( class'ActionBase'.static.minDistBetweenTrajectories( timeToHit, projectile.Location, projectile.Velocity, rook.Location, rook.averageVelocity() )
			< ai.CollisionHeight + projectile.CollisionHeight )
	{
		hitLocation = projectile.Location + timeToHit * projectile.Velocity;
		//log( "direct hit:" @ timeToHit );
		return true;
	}

	return false;
}

//---------------------------------------------------------------------
// perform sensor-specific startup initializations when sensor is activated

function begin()
{
	local int i;

	ai = BaseAICharacter(sensorAction.resource.pawn());
	enemySensor = AI_EnemySensor(class'AI_Sensor'.static.activateSensor( self, class'AI_EnemySensor', sensorAction.resource, 0, 1000000 ));
	enemySensor.setParameters();

	for( i = 0; i < enemySensor.enemies.length; i++ )
		Rook(enemySensor.enemies[i]).RegisterShotNotification( self );
}

//---------------------------------------------------------------------
// perform sensor-specific cleanup when sensor is deactivated

function cleanup()
{
	local int i;

	//if ( rook().controller != None )
	//	AI_Controller(rook().controller).bDodging = false;

	if ( enemySensor != None )
	{
		for( i = 0; i < enemySensor.enemies.length; i++ )
			if ( enemySensor.enemies[i] != None )
				Rook(enemySensor.enemies[i]).UnRegisterShotNotification( self );

		enemySensor.deactivateSensor( self );
		enemySensor = None;
	}
}

//---------------------------------------------------------------------
// Initialize set the sensor's parameters
// 'protectee': the Rook to be protected from incoming shots
// 'shieldPackTime': use shield pack if impact in less than this many seconds

function setParameters( Rook _protectee, optional float _shieldPackTime )
{
	protectee = _protectee;

	if ( _shieldPackTime != 0 )
		shieldPackTime = _shieldPackTime;
}

//=====================================================================
