class BuggyMotor extends CarMotor
	native
	dependsOn(CarMotor);

cpptext
{
	virtual void driveVehicle(const FVector& steering, const FVector& direction);
}