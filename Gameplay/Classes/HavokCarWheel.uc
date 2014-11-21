class HavokCarWheel extends Engine.HavokVehicleWheel
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var HavokCar car;

// not a vector so as class hierarchy can be leveraged
var (HavokCarWheel) float manualWheelPositionX;
var (HavokCarWheel) float manualWheelPositionY;
var (HavokCarWheel) float manualWheelPositionZ;

cpptext
{
	virtual void PostEditChange();

}


defaultproperties
{
}
