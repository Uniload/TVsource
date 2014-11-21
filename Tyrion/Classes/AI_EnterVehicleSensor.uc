//=====================================================================
// AI_EnterVehicleSensor
// Activates when the vehcieOrtUrret becomes unoccupied
// Value (object): pointer to the unoccupied target or None
//=====================================================================

class AI_EnterVehicleSensor extends AI_PeriodicSensor;

//=====================================================================
// Variables

// Parameters
var Pawn vehicleOrTurret;
var Vehicle.VehiclePositionType vehiclePosition;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// does this vehicle or turret have a free position at "vehiclePosition"?

final static function bool isEnterable( Pawn vehicleOrTurret, Vehicle.VehiclePositionType vehiclePosition )
{
	local Turret turret;
	local Vehicle vehicle;

	turret = Turret(vehicleOrTurret);
	vehicle = Vehicle(vehicleOrTurret);

	if ( turret != None )
	{
		return (turret.driver == None);
	}

	if ( vehicle != None )
	{
		return (vehicle.positions[vehicle.getPositionIndex(vehiclePosition)].occupant == None);
	}

	return false;
}

//---------------------------------------------------------------------
// Initialize set the sensor's parameters

function setParameters( Pawn _vehicleOrTurret, Vehicle.VehiclePositionType _vehiclePosition )
{
	vehicleOrTurret = _vehicleOrTurret;
	vehiclePosition = _vehiclePosition;

	//log( vehicleOrTurret.name @ "enterable?" @ isEnterable( vehicleOrTurret, vehiclePosition ) );
	if ( isEnterable( vehicleOrTurret, vehiclePosition ) )
		setObjectValue( vehicleOrTurret );
	else
		setObjectValue( None );
}

//=====================================================================

defaultproperties
{
}
