//=====================================================================
// AI_GunnerResource
// Specialized AI_Resource for gunner positions in vehicles and
// the gunner position in a turret
//=====================================================================

class AI_GunnerResource extends AI_MountResource;

//=====================================================================
// Variables

var AI_GunnerSensorAction gunnerSensorAction;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

event init()
{
	gunnerSensorAction = AI_GunnerSensorAction(addSensorActionClass( class'AI_GunnerSensorAction' ));

	super.init();
}

//---------------------------------------------------------------------
// perform resource-specific cleanup before resource is deleted

function cleanup()
{
	// Set sensorActions to None
	gunnerSensorAction = None;

	super.cleanup();
}

//----------------------------------------------------------------------
// Return the corresponding action class for this type of resource

function class<AI_RunnableAction> getActionClass()
{
	return class'AI_GunnerAction';
}
