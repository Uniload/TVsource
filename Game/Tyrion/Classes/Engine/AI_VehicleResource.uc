//=====================================================================
// AI_VehicleResource
// Resource for the vehicle (or turret) as a whole -
// corresponds to CharacterResource for characters
//
// Class Hierarchy:
// - Resource
//	  +- VehicleResource				(the whole vehicle/turret)
//	  +- MountResource					(occupyable positions in a vehicle/turret)
//        +- GunnerResource				(vehicle gunner positions/turret position)
//             +- DriverResource		(vehicle driver positions)
//=====================================================================

class AI_VehicleResource extends AI_Resource;

//=====================================================================
// Variables

var Pawn m_pawn;	// contains pointer to vehicle or turret
var AI_VehicleSensorAction vehicleSensorAction;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Store a back pointer to the actor (vehicle) that this resource is attached to

function setResourceOwner( Engine.Actor aVehicle )
{
	m_pawn = Pawn(aVehicle);
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

event init()
{
	vehicleSensorAction = AI_VehicleSensorAction(addSensorActionClass( class'AI_VehicleSensorAction' ));

	super.init();
}

//---------------------------------------------------------------------
// perform resource-specific cleanup before resource is deleted

function cleanup()
{
	// Set sensorActions to None
	vehicleSensorAction = None;

	super.cleanup();

	m_pawn = None;
}

//---------------------------------------------------------------------
// Accessor function

function Pawn pawn()
{
	return m_pawn;
}

//---------------------------------------------------------------------
// Does the resource have the sub-resources available to run an action?
// legspriority:  priority of the sub-goal that will be posted on the legs (0 if no goal)
// armsPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)
// headPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)

function bool requiredResourcesAvailable( int legsPriority, int armsPriority, optional int headPriority )
{
	return true;	// for now
}

//---------------------------------------------------------------------
// Should this resource be trying to satisfy goals?

event bool isActive()
{
	local Vehicle v;
	local Turret t;

	v = vehicle();
	t = turret();

	return class'Pawn'.static.checkAlive( m_pawn ) && m_pawn.AI_LOD_Level >= AILOD_NORMAL &&
		// turret active when not occupied or occupied by an AI
		( t == None || ( t.IsInState('Active') && ( class'Pawn'.static.checkAlive( t.driver ) || t.IsA( 'DeployedTurret' )) && !t.isHumanControlled() )) &&
		// vehicle active when occupied by an AI 
		( v == None || ( class'Pawn'.static.checkAlive( v.getDriver() ) && !v.isHumanControlled() ));
}

//---------------------------------------------------------------------
// Accessor functions

function Vehicle vehicle()
{
	return Vehicle(m_pawn);
}

//---------------------------------------------------------------------
// Accessor functions

function Turret turret()
{
	return Turret(m_pawn);
}

//----------------------------------------------------------------------
// Return the corresponding action class for this type of resource

function class<AI_RunnableAction> getActionClass()
{
	return class'AI_VehicleAction';
}

//=====================================================================

defaultproperties
{
}
