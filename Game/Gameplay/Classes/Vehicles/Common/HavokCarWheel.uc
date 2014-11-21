class HavokCarWheel extends Engine.HavokVehicleWheel
	native;

cppText
{
	virtual void PostEditChange();
}

var HavokCar car;

// not a vector so as class hierarchy can be leveraged
var (HavokCarWheel) float manualWheelPositionX;
var (HavokCarWheel) float manualWheelPositionY;
var (HavokCarWheel) float manualWheelPositionZ;