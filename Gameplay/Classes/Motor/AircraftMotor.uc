class AircraftMotor extends VehicleMotor
	native;

var JointControlledAircraft aircraft;

cpptext
{
	virtual void driveVehicle(const FVector& steering, const FVector& direction);
	virtual void rotateToward(const FVector& target);
	virtual void steerAircraft(const FRotator& steering);
}

event preBeginPlay()
{
	super.preBeginPlay();

	// store reference to aircraft
	aircraft = JointControlledAircraft(owner);

	if (aircraft == None)
		warn("aircraft motor owner is not an aircraft");
}