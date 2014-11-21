//=====================================================================
// AI_DriverGoal
// Goals for the Driver Resource
//=====================================================================

class AI_DriverGoal extends AI_Goal
	abstract;

//=====================================================================
// Variables

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Return the resource class for this goal

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_DriverResource';
}

//---------------------------------------------------------------------
// Depending on the type of goal, find the resource the goal should be
// attached to (if you happen to have an instance of the goal pass it in)

static function Tyrion_ResourceBase findResource( Pawn p, optional Tyrion_GoalBase goal )
{
	local Vehicle vehicle;

	vehicle = Vehicle(p);

	if ( vehicle != None )
		return vehicle.positions[vehicle.driverIndex].toBePossessed.mountAI;

	return None;
}

