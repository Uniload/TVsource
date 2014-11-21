//=====================================================================
// AI_GunnerSensorAction
// Updates sensors related to hunnerResources
//=====================================================================

class AI_GunnerSensorAction extends AI_SensorAction;

//=====================================================================
// Constants

//=====================================================================
// Variables

var AI_GuardSensor			guardSensor;		// this one gets updated by callbacks on the sensor
var AI_EnemySensor			enemySensor;		// this one gets updated by callbacks on the sensor
var AI_TargetSensor			targetSensor;		// this one gets updated by callbacks on the sensor

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

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_GunnerResource';
}

//=====================================================================
// State Code

state Running
{
Begin:
	log( self.name @ "!!! SHOULD NEVER BE CALLED !!!" );
	assert( false );
}

//=====================================================================

defaultproperties
{
}