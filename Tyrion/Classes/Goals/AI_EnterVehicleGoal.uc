//=====================================================================
// AI_EnterVehicleGoal
//=====================================================================

class AI_EnterVehicleGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name vehicleOrTurretName "Name of vehicle or turret to enter";
var(Parameters) Vehicle.VehiclePositionType vehiclePosition "Preferred vehicle position to enter; if position is taken AI will enter any free position";
var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn vehicleOrTurret;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn _vehicleOrTurret, Vehicle.VehiclePositionType _vehiclePosition,
							  optional float _energyUsage )
{
	priority = pri;
	vehicleOrTurret = _vehicleOrTurret;
	vehiclePosition = _vehiclePosition;
	energyUsage = _energyUsage;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	super.init( r );

	if ( vehicleOrTurret == None && vehicleOrTurretName != '' )
		vehicleOrTurret = Pawn(resource.pawn().findByLabel( class'Pawn', vehicleOrTurretName, true ));

	if ( vehicleOrTurret == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" @ vehicleOrTurretName );

		// goal needs to be matched so it can be cleaned up by the action:
		bInActive = false;
	}
	else
	{
		// userData is always 'None' for deactivation sensors, and != None for activation sensors
		activationSentinel.activateSentinel( self, class'AI_EnterVehicleSensor', characterResource(),, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
		AI_EnterVehicleSensor(activationSentinel.sensor).setParameters( vehicleOrTurret, vehiclePosition );
	}
}

//---------------------------------------------------------------------
// Setup deactivation sentinel

function setUpDeactivationSentinel()
{
	deactivationSentinel.activateSentinel( self, class'AI_EnterVehicleSensor', characterResource(),, class'AI_Sensor'.const.ONLY_NONE_VALUE, None ); 
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true	// goal is made non-permanent if it succeeds
}

