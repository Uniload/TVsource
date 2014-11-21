//=====================================================================
// AI_ReactToFireSensor
// Trigger the ReactToFire goal?
// Value (int): on/off?
//=====================================================================

class AI_ReactToFireSensor extends AI_Sensor implements IHearingNotification;

//=====================================================================
// Constants

enum TriggerCategories
{
	RTF_PAIN,
	RTF_NEAR_MISS,
	RTF_MOVEMENT_SOUND,
	RTF_COMBAT_SOUND
};

//=====================================================================
// Variables

var Pawn attacker;						// who was responsible for triggering this sensor?
var TriggerCategories triggerCategory;	// what triggered the ReactToFireSensor?

var AI_PainSensor painSensor;			// sub-sensor
var AI_NearMissSensor nearMissSensor;	// another sub-sensor
var Rook rook;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// convenience function to set all the variables (and the sensor value itself)

function setValue( Pawn anAttacker, TriggerCategories trigger )
{
	attacker = anAttacker;
	triggerCategory = trigger;
	setIntegerValue( 1 );	// trigger goal activation
}

//---------------------------------------------------------------------
// Sensor callback (from painSensor)

function onSensorMessage( AI_Sensor sensor, AI_SensorData value, Object userData )
{
	local Rook shooter;
	//log( name @ "sensorMessage called by" @ sensor.name @ "with value" @ value.integerData @ value.objectData );
	//log( name @ "Alertness:" @ rook.getAlertnessLevel() );

	if ( sensor.IsA( 'AI_PainSensor' ) &&
		painSensor.InstigatedBy != None &&
		painSensor.InstigatedBy != rook )						// pain caused by another rook
	{
		setValue( painSensor.InstigatedBy, RTF_PAIN );
	}

	if ( sensor.IsA( 'AI_NearMissSensor' ) )
	{
		shooter = Projectile(value.objectData).rookAttacker;
		if ( !rook.isFriendly( shooter ) )						// ignore near misses by friendlies
		{
			setValue( shooter, RTF_NEAR_MISS );
		}
	}
}

//---------------------------------------------------------------------
// sound callback

function OnListenerHeardNoise(Pawn Listener, Actor SoundMaker, vector SoundOrigin, Name SoundCategory )
{
	local Rook r;
	local bool bCombatSound;

	// try to determine the pawn responsible for the sound
	r = Rook(SoundMaker);
	if ( r == None && SoundMaker.isA( 'Projectile' ))
	{
		r = Projectile(SoundMaker).rookAttacker;
		bCombatSound = true;
	}
	if ( r == None && SoundMaker.isA( 'Weapon' ))
	{
		r = Weapon(SoundMaker).rookOwner;
		bCombatSound = true;
	}

	if ( r != None && !rook.isFriendly( r ) && !rook.vision.isVisible( r ) )
	{
		//log( "!!!" @ Listener.name @ SoundMaker.name @ SoundCategory @ SoundOrigin @ bCombatSound );
		if ( bCombatSound )
			setValue( r, RTF_COMBAT_SOUND );
		else
			setValue( r, RTF_MOVEMENT_SOUND );
	}
}

//---------------------------------------------------------------------
// perform sensor-specific startup initializations when sensor is activated

function begin()
{
	rook = sensorAction.resource.localRook();

	rook.RegisterHearingNotification( self );
	painSensor = AI_PainSensor(class'AI_Sensor'.static.activateSensor( self, class'AI_PainSensor', sensorAction.resource, 1, 1000, ));
	nearMissSensor = AI_NearMissSensor(class'AI_Sensor'.static.activateSensor( self, class'AI_NearMissSensor', sensorAction.resource,, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, ));
}

//---------------------------------------------------------------------
// perform sensor-specific cleanup when sensor is deactivated

function cleanup()
{
	sensorAction.resource.localRook().UnregisterHearingNotification( self );

	if ( painSensor != None )
	{
		painSensor.deactivateSensor( self );
		painSensor = None;
	}

	if ( nearMissSensor != None )
	{
		nearMissSensor.deactivateSensor( self );
		nearMissSensor = None;
	}
}

//=====================================================================

defaultproperties
{
}
