//=====================================================================
// AI_DriverResource
// Specialized AI_Resource for driver positions in vehicles
//=====================================================================

class AI_DriverResource extends AI_GunnerResource;

//=====================================================================
// Variables

//=====================================================================
// Functions

//----------------------------------------------------------------------
// Return the corresponding action class for this type of resource

function class<AI_RunnableAction> getActionClass()
{
	return class'AI_DriverAction';
}

//=====================================================================

defaultproperties
{
}
