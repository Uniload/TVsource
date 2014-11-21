//=====================================================================
// AI_DriverAction
// Actions that involve a vehicle's driver position
//=====================================================================

class AI_DriverAction extends AI_Action
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Accessor function for resources

final function Rook rook()
{
	return Rook(AI_DriverResource(resource).m_pawn);
}

final function Vehicle vehicle()
{
	return Vehicle(AI_DriverResource(resource).m_pawn);
}

final function AI_VehicleResource vehicleResource()
{
	return AI_VehicleResource(Vehicle(AI_DriverResource(resource).m_pawn).vehicleAI);
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_DriverResource';
}

//---------------------------------------------------------------------
// Depending on the type of action, find the resource the action should
// be attached to

static function Tyrion_ResourceBase findResource( Pawn p )
{
	local Vehicle vehicle;

	vehicle = Vehicle(p);

	if ( vehicle != None )
		return vehicle.positions[vehicle.driverIndex].toBePossessed.mountAI;

	return None;
}

//---------------------------------------------------------------------
// Run an action
// Typically called by the resource

function runAction()
{
	Super.runAction();

	//log( "==" @ self.name $ ":" @ resource.isActive() @ resourceUsage @ resource.usedByAction.name );

	if ( resource.isActive() && (resourceUsage & class'AI_Resource'.const.RU_MOUNT) != 0 && resource.usedByAction == None )
		resource.usedByAction = self;
}

//=======================================================================

function classConstruct()
{
	resourceUsage = class'AI_Resource'.const.RU_MOUNT;
}

defaultproperties
{
}