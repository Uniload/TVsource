//=====================================================================
// AI_TargetSensor
// Keeps track of a particular pawn
// Value (object): pointer to the target or None
//=====================================================================

class AI_TargetSensor extends AI_Sensor implements IVisionNotification;

//=====================================================================
// Variables

// Parameters
var Pawn target;					// the pawn this sensor is interested in
var float canStillSeePeriod;		// seconds after which a target is lost during which the AI still knows where the target is

// Output
var Vector lastPlaceSeen;			// last known location of target
var float lastTimeSeen;				// time at which target was last seen

var AI_Sensor timerSensor;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// vision callbacks

function OnViewerSawPawn(Pawn Viewer, Pawn Seen)
{
	if ( target == Seen )
	{
		if ( sensorAction.resource.localRook().logTyrion )
			log( sensorAction.resource.localRook().name $ ":" @ target.name @ "acquired" );

		// discontinue countdown to "not seen" if timer present
		if ( timerSensor != None )
		{
			timerSensor.deactivateSensor( self );
			timerSensor = None;
		}

		setObjectValue( Seen );
	}
}

function OnViewerLostPawn(Pawn Viewer, Pawn Seen)
{
	local int timerValue;

	if ( target == Seen )
	{
		lastPlaceSeen = Seen.Location;
		lastTimeSeen = target.level.TimeSeconds;

		if ( canStillSeePeriod <= 0 || class'Pawn'.static.checkDead( target ) )
		{
			if ( sensorAction.resource.localRook().logTyrion )
				log( sensorAction.resource.localRook().name $ ":" @ target.name @ "lost (" @ canStillSeePeriod @ ")" );
			setObjectValue( None );
		}
		else
		{
			timerValue = canStillSeePeriod +
				AI_SensorResource( class'Setup'.static.GetStaticSensorResource() ).globalSensorAction.timer.queryIntegerValue();

			if ( timerSensor != None )
			{
				timerSensor.deactivateSensor( self );
				timerSensor = None;
			}
			timerSensor = class'AI_Sensor'.static.activateSensor( self, class'AI_TimerSensor', None, timerValue, timerValue );
		}	
	}
}

//---------------------------------------------------------------------
// Sensor callback (from timerSensor)

function onSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	//log( name @ "sensorMessage called by" @ sensor.name @ "with value" @ value.integerData );

	timerSensor.deactivateSensor( self );
	timerSensor = None;

	if ( class'Pawn'.static.checkDead( target ) || 
		( !sensorAction.resource.localRook().vision.isVisible( target ) ))
	{
		if ( sensorAction.resource.localRook().logTyrion )
			log( sensorAction.resource.localRook().name $ ":" @ target @ "not seen for" @ canStillSeePeriod @ "seconds (lastTimeSeen:" @ lastTimeSeen $ ")" );
		setObjectValue( None );
	}
}

//---------------------------------------------------------------------
// perform sensor-specific startup initializations when sensor is activated

function begin()
{
	sensorAction.resource.localRook().RegisterVisionNotification( self );
}

//---------------------------------------------------------------------
// perform sensor-specific cleanup when sensor is deactivated

function cleanup()
{
	//log( name @ sensorAction.resource.localRook().name @ "UNREGISTERING VISION" );
	sensorAction.resource.localRook().UnregisterVisionNotification( self );
	target = None;

	if ( timerSensor != None )
	{
		timerSensor.deactivateSensor( self );
		timerSensor = None;
	}
}

//---------------------------------------------------------------------
// Initialize set the sensor's parameters
// 'target': the pawn this sensor is interested in
// 'canStillSeePeriod': seconds after which a target is lost during which the AI still knows where the target is

function setParameters( Pawn _target, optional float _canStillSeePeriod )
{
	if ( sensorAction.resource.localRook().logTyrion && 
		( (target != None && target != _target) ||
		( (canStillSeePeriod != 0 && canStillSeePeriod != _canStillSeePeriod)) ))
		log( name @ "is redefining its target value from" @ target @ canStillSeePeriod @ "to" @ _target @ _canStillSeePeriod );

	target = _target;
	canStillSeePeriod = _canStillSeePeriod;

	if ( sensorAction.resource.localRook().vision.isVisible( target ) ||
		(lastTimeSeen >= 0 && lastTimeSeen >= target.level.TimeSeconds - canStillSeePeriod ))
	{
		//log( name @ "TargetSensor ACTIVATED!" @ target.Level.TimeSeconds - lastTimeSeen @ "(lastTimeSeen:" @ lastTimeSeen $ ")" );
		setObjectValue( target );	// so sensor message is sent when sensor is first activated
	}
	else
	{
		//log( name @ "target not visible" @ target.Level.TimeSeconds @ lastTimeSeen );
		setObjectValue( None ); 
	}
}

//=====================================================================

defaultproperties
{
     lastTimeSeen=-9999999.000000
     bNotifyOnValueChange=True
     bNotifyIfResourceInactive=True
}
