class FailPodMotor extends Gameplay.PodMotor;

/*
function driveVehicle(float inForward, float inStrafe, rotator directionRotation, bool inThrust, bool inDive)
{
	// apply input to vehicle input parameters
	
	// ... throttle
	if (InForward > 1)
		vehicle.ThrottleInput = 1;
	else if(InForward < -1)
		vehicle.ThrottleInput = -1;
	else
		vehicle.ThrottleInput = 0;

	// ... strafe
	if (InStrafe < -1)
		vehicle.StrafeInput = 1;
	else if(InStrafe > 1)
		vehicle.StrafeInput = -1;
	else
		vehicle.StrafeInput = 0;

	// ... rotation
	vehicle.RotationInput = directionRotation;
	vehicle.RotationInput = normalize(vehicle.RotationInput);
	vehicle.RotationInput.Pitch = clamp(vehicle.RotationInput.Pitch, vehicle.driverMinimumPitch, vehicle.driverMaximumPitch);
	vehicle.controller.setRotation(vehicle.RotationInput);

	// ... thrust
	if (inThrust)
		vehicle.ThrustInput = 1;
	else
		vehicle.ThrustInput = 0;

	// ... dive
	vehicle.DiveInput = inDive;
}
*/

function driveVehicle(float inForward, float inStrafe, rotator directionRotation, bool inThrust, bool inDive)
{
	// apply input to vehicle input parameters

	vehicle.ThrottleInput = 1;
	vehicle.StrafeInput = 0;

	// ... rotation
	//vehicle.RotationInput = directionRotation;
	//vehicle.RotationInput = normalize(vehicle.RotationInput);
	vehicle.RotationInput.Pitch = clamp(vehicle.RotationInput.Pitch, vehicle.driverMinimumPitch, vehicle.driverMaximumPitch);

	//vehicle.controller.setRotation(vehicle.RotationInput);

	//vehicle.setRotation(vehicle.RotationInput);
	vehicle.setRotation(normalize(directionRotation));

	// ... thrust
	if (inThrust)
		vehicle.ThrustInput = 1;
	else
		vehicle.ThrustInput = 0;

	// ... dive
	vehicle.DiveInput = inDive;
}

defaultproperties
{
}
