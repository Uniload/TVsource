//=====================================================================
// AI_CommonSenseSensorAction
// Updates sensors related to common sense actions/goals
//=====================================================================

class AI_CommonSenseSensorAction extends AI_SensorCharacterAction;

//=====================================================================
// Constants

//=====================================================================
// Variables

var AI_GetOutOfWaySensor	getOutOfWaySensor;	// gets updated by setValue calls, not in a sensor action
var AI_PainSensor			painSensor;			// this one, too
var AI_EnemySensor			enemySensor;		// this one gets updated by callbacks on the sensor
var AI_DodgeSensor			dodgeSensor;		// ditto
var AI_TargetSensor			targetSensor;		// and ditto
var AI_TargetMemorySensor	targetMemorySensor;	// (a targetSensor that remembers a lost target for a while...)
var AI_ReactToFireSensor	reactToFireSensor;	// and double ditto
var AI_NearMissSensor		nearMissSensor;		// this one gets updated by setValue calls again (Touch function in NearMissCollisionVolume); however, it requires periodic update of the nearMissCollisionVolume
var AI_GuardSensor			guardSensor;		// this one gets updated by callbacks on the sensor

var NearMissCollisionVolume fatVolume;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// set up the sensors this action may update

function setupSensors( AI_Resource resource )
{
	// construct all sensors, add them to resource's sensor list
	getOutOfWaySensor = AI_GetOutOfWaySensor(addSensorClass( class'AI_GetOutOfWaySensor' ));
	painSensor        = AI_PainSensor(addSensorClass( class'AI_PainSensor' ));
	enemySensor		  = AI_EnemySensor(addSensorClass( class'AI_EnemySensor' ));
	dodgeSensor		  = AI_DodgeSensor(addSensorClass( class'AI_DodgeSensor' ));
	targetSensor      = AI_TargetSensor(addSensorClass( class'AI_TargetSensor' ));
	targetMemorySensor= AI_TargetMemorySensor(addSensorClass( class'AI_TargetMemorySensor' ));
	reactToFireSensor = AI_ReactToFireSensor(addSensorClass( class'AI_ReactToFireSensor' ));
	nearMissSensor	  = AI_NearMissSensor(addSensorClass( class'AI_NearMissSensor' ));
	guardSensor		  = AI_GuardSensor(addSensorClass( class'AI_GuardSensor' ));

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------

function begin()
{
	// Create a larger collision volume around the character to detect near misses
	if ( fatVolume == None )
		fatVolume = rook().Spawn( class'NearMissCollisionVolume' );
	fatVolume.pawn = rook();
	fatVolume.nearMissSensor = nearMissSensor;
	fatVolume.Move( rook().Location - fatVolume.Location );
}

function cleanup()
{
	super.cleanup();

	if ( fatVolume != None )
	{
		fatVolume.Destroy();
		fatVolume = None;
	}
}

//=====================================================================
// State Code

state Running
{
Begin:
	while ( true )
	{
		// update fatVolume location
		if ( nearMissSensor.queryUsage() > 0 && rook().Location != fatVolume.Location )
			fatVolume.Move( rook().Location - fatVolume.Location );
		yield();
	}
}

//=====================================================================

defaultproperties
{
}