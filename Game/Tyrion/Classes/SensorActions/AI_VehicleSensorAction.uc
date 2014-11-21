//=====================================================================
// AI_VehicleSensorAction
// Updates sensors related to vehicles
//=====================================================================

class AI_VehicleSensorAction extends AI_SensorAction;

//=====================================================================
// Constants

//=====================================================================
// Variables

var AI_GuardSensor			guardSensor;		// this one gets updated by callbacks on the sensor
var AI_EnemySensor			enemySensor;		// this one gets updated by callbacks on the sensor
var AI_TargetSensor			targetSensor;		// this one gets updated by callbacks on the sensor
var AI_TargetMemorySensor	targetMemorySensor;	// (a targetSensor that remembers a lost target for a while...)
var AI_ReactToFireSensor	reactToFireSensor;	// this one gets updated by callbacks on the sensor
var AI_PainSensor			painSensor;			// this one, too
var AI_NearMissSensor		nearMissSensor;		// this one gets updated by setValue calls again (Touch function in NearMissCollisionVolume); however, it requires periodic update of the nearMissCollisionVolume

var NearMissCollisionVolume fatVolume;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// set up the sensors this action may update

function setupSensors( AI_Resource resource )
{
	// construct all sensors, add them to resource's sensor list
	guardSensor		  = AI_GuardSensor(addSensorClass( class'AI_GuardSensor' ));
	enemySensor		  = AI_EnemySensor(addSensorClass( class'AI_EnemySensor' ));
	targetSensor	  = AI_TargetSensor(addSensorClass( class'AI_TargetSensor' ));
	targetMemorySensor= AI_TargetMemorySensor(addSensorClass( class'AI_TargetMemorySensor' ));
	reactToFireSensor = AI_ReactToFireSensor(addSensorClass( class'AI_ReactToFireSensor' ));
	painSensor        = AI_PainSensor(addSensorClass( class'AI_PainSensor' ));
	nearMissSensor	  = AI_NearMissSensor(addSensorClass( class'AI_NearMissSensor' ));

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------

function begin()
{
	// Create a larger collision volume around the character to detect near misses
	if ( fatVolume == None )
		fatVolume = resource.pawn().Spawn( class'NearMissCollisionVolume' );
	fatVolume.pawn = resource.pawn();
	fatVolume.nearMissSensor = nearMissSensor;
	fatVolume.Move( resource.pawn().Location - fatVolume.Location );
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

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_VehicleResource';
}

//=====================================================================
// State Code

state Running
{
Begin:
	pause();	// NearMissSensor's fatVolume only used on turrets so doesn't need to be updated
}

//=====================================================================

defaultproperties
{
}