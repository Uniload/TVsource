//=====================================================================
// AI_GetOutOfWaySensor
// Is this AI blocking someone?
// Value (object): person being blocked
//=====================================================================

class AI_GetOutOfWaySensor extends AI_Sensor;

//=====================================================================
// Variables

var Vector aimLocation;	// where the avoidee (stored in value.objectData) is aiming

//=====================================================================
// Functions

//---------------------------------------------------------------------
// convenience function to set all the variables (and the sensor value itself)

function setValue( Object rook, Vector aimLocation )
{
	self.aimLocation = aimLocation;
	setObjectValue( rook );
}

//=====================================================================

defaultproperties
{
}
