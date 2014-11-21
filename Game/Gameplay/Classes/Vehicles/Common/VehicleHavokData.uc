class VehicleHavokData extends Engine.HavokRigidBody
	native;

cpptext
{
	virtual void PostEditChange();
}

var Vehicle ownerVehicle;