//=====================================================================
// AI_GuardSensor
// Notifies AI if an enemy is inside guard area
// Value (object): target for guard action
//=====================================================================

class AI_GuardSensor extends AI_Sensor;

//=====================================================================
// COnstants

const NO_SHOT_TIMEOUT = 3.0f;	// time after which a new target is chosen because old target couldn't be shot at (multiplier on weapon refire rate)

//=====================================================================
// Variables

// Parameters
var Vector engagementAreaCenter;
var Actor engagementAreaTarget;
var float engagementAreaRadius;

// Internal
var AI_EnemySensor enemySensor;
var AI_Sensor timerSensor;
var Rook rook;							// the character/vehicle/turret this sensor is running on
var VehicleMountedTurret mountedTurret;	// the rook this sensor is running on (or None)
var Turret turret;						// the turret this sensor is running on (or None)
var Vehicle vehicle;					// the vehicle this sensor is running on (or None)
var int nEnemies;						// number of seen enemies on last sensor callback

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Sensor callback (from enemySensor or timerSensor)

function onSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	local Pawn target;
	local Pawn newTarget;

	//log( name @ "(" @ rook.name @ ") sensorMessage called by" @ sensor.name @ "with value" @ value.integerData );

	if ( sensor == enemySensor ) 
	{
		if ( value.integerData == 0 && timerSensor != None )		// no enemies seen
		{
			timerSensor.deactivateSensor( self );
			timerSensor = None;
		}
		if ( value.integerData > 0 && timerSensor == None )			// an enemy in my field of view
		{
			timerSensor = class'AI_Sensor'.static.activateSensor( self, class'AI_TimerSensor', None, 0, 99999999999999 );
			timerSensor.sendMessageOnNextValueUpdate( self );

			// new enemy seen
			if ( value.integerData > nEnemies && !rook.IsA( 'AICivilian' ) )
				rook.level.speechManager.PlayDynamicSpeech( rook, 'Detect', None, enemySensor.lastSeen );
		}
		nEnemies = value.integerData;
	}

	if ( timerSensor != None && sensor == timerSensor )
	{
		//log( "== setting bNotify" );
		timerSensor.sendMessageOnNextValueUpdate( self );	// receive timer message next tick - regardless of value
	}

	target = Pawn(queryObjectValue());

	// sanityCheck( target );

	// already attacking something
	if ( target != None )
	{
		// continue checking if target is within engagement range
		// (doesn't do LOS checks - GuardAttack decides if target should be abandoned because of LOS)
		// (stops attacking if player becomes a target)

		if ( isGuardTarget( target ) &&
			 ( enemySensor.player == target || !noShotTimeout( rook, target ) ) &&
			 ( enemySensor.player == target || enemySensor.player == None || !isGuardTarget( enemySensor.player )))
		{
			//log( name @ "(" @ rook.name @ "): continuing to attack" @ target.name @ "(" @ enemySensor.player @ ")" );
			return;
		}
		else
		{
			newTarget = findGuardTarget();
			if ( newTarget != target )
			{
				setObjectValue( None );			// deactivate the old action
				if ( rook.logTyrion )
					log( name @ "(" @ rook.name @ "):" @ target.name @ "no longer valid target; isGuardTarget:" @
							isGuardTarget( target ) @ "!timout:" @ !noShotTimeout( rook, target ) );
				target = None;
			}
		}
	}

	// not attacking anything
	if ( target == None )
	{
		if ( newTarget == None )
			target = findGuardTarget();	// find a new target
		else
			target = newTarget;
		if ( target != None )
		{
			if ( rook.logTyrion )
				log( name @ "(" @ rook.name @ ") engaging" @ target.name );
			setObjectValue( target );
		}
	}
}

//---------------------------------------------------------------------
// find a suitable enemy to attack in the engagement area

private final function Pawn findGuardTarget()
{
	local int i;
	local int n;

	// player always considered first
	if ( enemySensor.player != None && isGuardTarget( enemySensor.player ) )
		return enemySensor.player;

	n = enemySensor.enemies.length;
	i = Rand( n );

	// now look at other enemies
	while ( n > 0 )
	{
		if ( isGuardTarget( enemySensor.enemies[i] ) )
		{
			return enemySensor.enemies[i];
			break;
		}
		i = (i+1) % enemySensor.enemies.length;
		--n;
	}

	return None;
}

//---------------------------------------------------------------------
// is the specified pawn a valid target for this guard action?

private final function bool isGuardTarget( Pawn target )
{
	local Vector centerLocation;
	local Rook rookTarget;

	rookTarget = Rook(target);

	if ( rookTarget == None )
	{
		log( "AI ERROR: invalid target" @ target @ "in" @ rook.name $"'s 'isGuardTarget'" );
		return false;
	}

	// Is the target something AI's should shoot at? 
	if ( !rookTarget.bAIThreat || rook.isFriendly( rookTarget ))
		return false;

	// if guarder is a turret and turret cannot be pointed at target, don't pick this target
	// (shot leading is not taken into consideration here)
	if ( turret != None && !turret.canTargetPoint( target.Location ) )
		return false;

	if ( vehicle != None && !vehicle.canTargetPoint( target.Location ) )
		return false;

	if ( mountedTurret != None && !mountedTurret.canTargetPoint( target.Location ) )
		return false;

	// add turret type specific checks (if any)....

	if ( engagementAreaTarget == None )
		centerLocation = engagementAreaCenter;
	else
		centerLocation = engagementAreaTarget.Location;

	//log( target.name @ VDist( target.Location, centerLocation ) @ "/" @ engagementAreaRadius);

	return VDistSquared( target.Location, centerLocation ) <= engagementAreaRadius * engagementAreaRadius;
}

//---------------------------------------------------------------------
// sanity check: Guard sensor shouldn't have a value if GuardAttackGoal is inactive

private final function sanityCheck( Pawn target )
{
	local int i;

	if ( target != None && rook.characterAI != None )
	{
		for ( i = 0; i < rook.characterAI.goals.length; ++i )
			if ( AI_Goal(rook.characterAI.goals[i]).activationSentinel.sensor == self && AI_Goal(rook.characterAI.goals[i]).bInActive )
			{
				log( "AI ERROR:" @ rook.name @ "(" $ rook.label $ ")" @ rook.characterAI.goals[i].name @ "is inActive yet sensor is set to" @ target.label );
				assert( false );
			}
	}
}

//---------------------------------------------------------------------
// returns true of GuardAttack should time out because no shot was fired

private final function bool noShotTimeOut( Rook rook, Pawn target )
{
	local Weapon weapon;
	local float maxRange;

	weapon = rook.firingMotor().getWeapon();
	if ( weapon == None )
		return false;

	// if target is out of range of the weapon, give attacker a chance to close in
	maxRange = class'AimFunctions'.static.getMaxEffectiveRange( weapon.class );
	if ( maxRange >= 0 && VDistSquared( rook.Location, target.Location ) > maxRange * maxRange )
		return false;

	return (rook.lastShotFiredTime < rook.level.timeSeconds - NO_SHOT_TIMEOUT / weapon.roundsPerSecond);
}

//---------------------------------------------------------------------
// perform sensor-specific startup initializations when sensor is activated

function begin()
{
	rook = sensorAction.resource.localRook();
	mountedTurret = VehicleMountedTurret(rook);
	turret = Turret(rook);
	vehicle = Vehicle(rook);
	enemySensor = AI_EnemySensor(class'AI_Sensor'.static.activateSensor( self, class'AI_EnemySensor', sensorAction.resource, 0, 1000000 ));
	enemySensor.setParameters();
}

//---------------------------------------------------------------------
// perform sensor-specific cleanup when sensor is deactivated

function cleanup()
{
	if ( enemySensor != None )
	{
		enemySensor.deactivateSensor( self );
		enemySensor = None;
	}

	if ( timerSensor != None )
	{
		timerSensor.deactivateSensor( self );
		timerSensor = None;
	}
}

//---------------------------------------------------------------------
// Initialize set the sensor's parameters
// engagementAreaCenter
// engagementAreaTarget
// engagementAreaRadius

function setParameters( float aEngagementAreaRadius, Vector aEngagementAreaCenter, optional Actor aEngagementAreaTarget )
{
	engagementAreaRadius = aEngagementAreaRadius;
	engagementAreaCenter = aEngagementAreaCenter;
	engagementAreaTarget = aEngagementAreaTarget;

	//log( name @ "(" @ sensorAction.resource.localRook().name @ ") initializing" @ findGuardTarget() );

	setObjectValue( findGuardTarget() ); 
}

//=====================================================================

defaultproperties
{
	bNotifyOnValueChange = true
}