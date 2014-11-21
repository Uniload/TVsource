//=====================================================================
// AI_GlobalSensorAction
// Sensor for non squad or character specific sensors -
// attached to sensorResource in Tyrion_Setup
//=====================================================================

class AI_GlobalSensorAction extends AI_SensorAction;

//=====================================================================
// Variables.

var AI_TimerSensor timer;
var int i;

//=====================================================================
// Functions.

//---------------------------------------------------------------------
// set up the sensors this action may update
// (can't do this in constructor because this class isn't known at
// compile time when AI_Resource postBeginPlay new's sensorActions)

function setupSensors( AI_Resource resource )
{
	// construct all sensors, add them to resource's sensor list
	timer = AI_TimerSensor(addSensorClass( class'AI_TimerSensor' ));

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_Resource';
}

//---------------------------------------------------------------------

state Running
{
Begin:
	timer.setIntegerValue( 0 );

	while ( true )
	{
		if ( timer.queryUsage() > 0 )
		{
			//log( timer.value.integerData + 1 );
			timer.setIntegerValue( timer.value.integerData + 1 );

			//for ( i = 0; i < timer.recipients.length; i++ )
			//	log( i @ timer.recipients[i] );
		}
		Sleep(1.0);
	}
}

//=====================================================================

defaultproperties
{
}