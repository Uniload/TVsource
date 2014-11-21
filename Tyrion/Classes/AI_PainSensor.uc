//=====================================================================
// AI_PainSensor
// Was this AI hurt?
// Value (int): damage amount
//=====================================================================

class AI_PainSensor extends AI_Sensor;

//=====================================================================
// Variables

var Pawn instigatedBy;		// who did the damage (damage amount is in value.integerData); can be None
var Vector hitLocation;
var class<DamageType> damageType;
var int tickStamp;			// tick at which pawn got hit

//=====================================================================
// Functions

//---------------------------------------------------------------------
// convenience function to set all the variables (and the sensor value itself)

function setValue( int damage, Pawn instigatedBy, Vector hitLocation, class<DamageType> damageType, int tick )
{
	self.instigatedBy = instigatedBy;
	self.hitLocation = hitLocation;
	self.damageType = damageType;
	tickStamp = tick;
	setIntegerValue( damage );
}

//=====================================================================

defaultproperties
{
}
