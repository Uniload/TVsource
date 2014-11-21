class VehicleMotor extends Motor
	native;

var Vehicle vehicle;

var vector currentSteering;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// construct
overloaded simulated function construct(actor Owner, optional optional name Tag, optional vector Location, optional rotator Rotation)
{
	super.construct(owner, tag, location, rotation);

	vehicle = Vehicle(Owner);
	if (vehicle == None)
	{
		warn("VehicleMotor's owner is not a vehicle");
	}
}

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

function displayWorldSpaceDebug(HUD displayHUD)
{
	local color workColor;
	workColor.R = 255;
	workColor.G = 0;
	workColor.B = 0;

	// steering
	if (currentSteering != vect(0,0,0))
		displayHud.draw3DLine(vehicle.location, vehicle.location + currentSteering * 3, workColor);
}

cpptext
{
	static const float RADIANS_TO_UNREAL;
	virtual void driveVehicle(const FVector& steering, const FVector& direction);
	virtual void stop();
	virtual void rotateToward(const FVector& target);

}


defaultproperties
{
}
