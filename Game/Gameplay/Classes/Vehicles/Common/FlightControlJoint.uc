// Flight Control Joint

// Used by flying vehicles to implement a basic flying model.
class FlightControlJoint extends Engine.Havok6DOFConstraint
	native;

function setTargetRotation(Quat newTargetRotation)
{
	AutoComputeLocals = HKC_DontAutoCompute;
	LocalAxisB = QuatRotateVector(newTargetRotation, vect(1,0,0));
	LocalPerpAxisB = QuatRotateVector(newTargetRotation, vect(0,1,0));
	UpdateConstraintDetails();
}

defaultProperties
{
	RemoteRole = ROLE_None

	bConstrainLinear = false
}