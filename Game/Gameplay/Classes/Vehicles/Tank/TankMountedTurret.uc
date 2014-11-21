class TankMountedTurret extends VehicleMountedTurret;

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = ownerVehicle;
	boneName = 'gunner';
}

defaultProperties
{
	DrawType = DT_None

	positionType = VP_GUNNER

	pivotBone = guntower

	pitchPivotBone = jtgun

	thirdPersonRotationType = 2
}