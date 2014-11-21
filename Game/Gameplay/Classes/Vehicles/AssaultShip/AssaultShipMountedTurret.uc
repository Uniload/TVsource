class AssaultShipMountedTurret extends VehicleMountedTurret;

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = ownerVehicle;

	// specify attachment bone dependent on left or right position
	switch (positionType)
	{
	case VP_LEFT_GUNNER:
		boneName = class'AssaultShip'.default.leftTurretBone;
		break;
	case VP_RIGHT_GUNNER:
		boneName = class'AssaultShip'.default.rightTurretBone;
		break;
	default:
		warn("unknown assault ship gun position");
	}
}

defaultProperties
{
	DrawType = DT_None

	pivotBone = ashipgunright

	thirdPersonRotationType = 1
}