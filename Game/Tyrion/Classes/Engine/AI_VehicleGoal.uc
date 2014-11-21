//=====================================================================
// AI_VehicleGoal
// Goals for the vehicle (or turret) as a whole
//=====================================================================

class AI_VehicleGoal extends AI_Goal
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Return the resource class for this goal

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_VehicleResource';
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

	if ( vehicle != None )
		return vehicle.vehicleAI;
	
	if ( turret != None )
		return turret.vehicleAI;

	return None;
}

