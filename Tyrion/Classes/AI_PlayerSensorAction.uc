//=====================================================================
// AI_PlayerSensorAction
// Updates sensors regarding the player's state relative to this AI
//=====================================================================

class AI_PlayerSensorAction extends AI_SensorCharacterAction;

//=====================================================================
// Variables.

var AI_PlayerProximitySensor playerProximitySensor;

var Pawn player;
var float distanceSquared;

//=====================================================================
// Functions.

//---------------------------------------------------------------------
// set up the sensors this action may update

function setupSensors( AI_Resource resource )
{
	//log( self.name @ "called" );

	// construct all sensors, add them to resource's sensor list
	playerProximitySensor = AI_PlayerProximitySensor(addSensorClass( class'AI_PlayerProximitySensor' ));

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------

state Running
{
Begin:
	player = rook().Level.GetLocalPlayerController().Pawn;
	assert( player != None );

	while ( true )
	{
		if ( playerProximitySensor.queryUsage() > 0 )
		{
			distanceSquared = VDistSquared( player.Location, rook().Location );
			playerProximitySensor.setFloatValue( distanceSquared );
		}

		// log( self.name $ ":" @ playerProximitySentinel.value.floatData );
		sleep(0.5);
	}
}

//=====================================================================

defaultproperties
{
}
