class CarMotor extends VehicleMotor
	native;

var Car car;

cpptext
{
	virtual void driveVehicle(const FVector& steering, const FVector& direction);
}

event preBeginPlay()
{
	super.preBeginPlay();

	// store reference to car
	car = Car(owner);

	if (car == None)
		warn("car motor owner is not a car");
}