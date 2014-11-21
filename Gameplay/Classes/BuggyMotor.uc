class BuggyMotor extends CarMotor
	native
	dependsOn(CarMotor);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

cpptext
{
	virtual void driveVehicle(const FVector& steering, const FVector& direction);

}


defaultproperties
{
}
