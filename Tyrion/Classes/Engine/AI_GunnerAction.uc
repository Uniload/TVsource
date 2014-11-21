//=====================================================================
// AI_GunnerAction
// Actions that involve a mounts that shoot
//=====================================================================

class AI_GunnerAction extends AI_Action
	abstract;

//=====================================================================
// Variables

var(Parameters) Vehicle.VehiclePositionType position;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Accessor functions for resource

final function Rook rook()
{
	return Rook(AI_GunnerResource(resource).m_pawn);
}

final function Vehicle vehicle()
{
	return Vehicle(AI_GunnerResource(resource).m_pawn);
}

final function Turret turret()
{
	return Turret(AI_GunnerResource(resource).m_pawn);
}

// returns the rook representing the vehicle mounted turret or the vehicle (for drivers) or the turret 
final function Rook localRook()
{
	local AI_GunnerResource gunnerResource;

	gunnerResource = AI_GunnerResource(resource);

	if ( gunnerResource.index < 0 )
		return Turret(gunnerResource.m_pawn);
	else
		return Vehicle(gunnerResource.m_pawn).positions[gunnerResource.index].toBePossessed;
}

function AI_VehicleResource vehicleResource()
{
	local Turret turret;
	local Vehicle vehicle;

	turret = Turret(AI_GunnerResource(resource).m_pawn);
	vehicle = Vehicle(AI_GunnerResource(resource).m_pawn);

	if ( turret != None )
		return AI_VehicleResource(turret.vehicleAI);

	if ( vehicle != None )
		return AI_VehicleResource(vehicle.vehicleAI);

	return None;
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_GunnerResource';
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
	{
		// There's no way of identifying gunner resources uniquely with just the pawn
		// What should really happen is that the caller of findResource attaches a goal to every gunner position
		return vehicle.positions[1].toBePossessed.mountAI;
	}

	if ( turret != None )
		return turret.mountAI;

	return None;
}

//=======================================================================

function classConstruct()
{
	// GunnerActions don't use the resource - because if they did firing actions on the driver would conflict with
	// movement actions on the driver. Without having two separate resources this will allow them to coexist.
	// (just don't ever start up multiple firing actions!)
	resourceUsage = 0;
}

defaultproperties
{
}