//=====================================================================
// AI_GunnerGoal
// Goals for the Gunner Resource
//=====================================================================

class AI_GunnerGoal extends AI_Goal
	abstract;

//=====================================================================
// Variables

var(Parameters) Vehicle.VehiclePositionType position;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Accessor function for resource

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
// Return the resource class for this goal

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_GunnerResource';
}

//---------------------------------------------------------------------
// Depending on the type of goal, find the resource the goal should be
// attached to (if you happen to have an instance of the goal pass it in)

static function Tyrion_ResourceBase findResource( Pawn p, optional Tyrion_GoalBase goal )
{
	local Vehicle vehicle;
	local Turret turret;

	vehicle = Vehicle(p);
	turret = Turret(p);

	if ( vehicle != None && goal != None )
	{
		// There's no way of identifying gunner resources uniquely with just the pawn - so return None if no
		// goal instance is specified.
		// (Vehicles get their goals attached to every position in InitVehicleAI() anyway)
		return vehicle.positions[vehicle.getPositionIndex( AI_GunnerGoal(goal).position )].toBePossessed.mountAI;
	}

	if ( turret != None )
		return turret.mountAI;

	return None;
}


