//=====================================================================
// AI_VehicleAction
// Actions that involve the vehicle (or turret) as a whole
//=====================================================================

class AI_VehicleAction extends AI_Action
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Accessor functions

final function Rook rook()
{
	return Rook(AI_VehicleResource(resource).m_pawn);
}

final function Vehicle vehicle()
{
	return Vehicle(AI_VehicleResource(resource).m_pawn);
}

final function Turret turret()
{
	return Turret(AI_VehicleResource(resource).m_pawn);
}

final function AI_VehicleResource vehicleResource()
{
	return AI_VehicleResource(resource);
}

final function AI_DriverResource driverResource()
{
	return AI_DriverResource(Vehicle(AI_VehicleResource(resource).m_pawn).mountAI);
}

final function AI_GunnerResource gunnerResource( Vehicle.VehiclePositionType position )
{
	local Vehicle v;

	v = Vehicle(AI_VehicleResource(resource).m_pawn);
	return AI_GunnerResource(v.positions[v.getPositionIndex(position)].toBePossessed.mountAI);
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_VehicleResource';
}

//---------------------------------------------------------------------
// Depending on the type of action, find the resource the action should
// be attached to

static function Tyrion_ResourceBase findResource( Pawn p )
{
	local Vehicle vehicle;
	local Turret turret;

	vehicle = Vehicle(p);
	turret = Turret(p);

	if ( vehicle != None )
		return vehicle.vehicleAI;
	
	if ( turret != None )
		return turret.vehicleAI;

	return None;
}

//=======================================================================

function classConstruct()
{
	resourceUsage = 0;
}

defaultproperties
{
}