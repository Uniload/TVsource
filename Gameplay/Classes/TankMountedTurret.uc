class TankMountedTurret extends VehicleMountedTurret;

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = ownerVehicle;
	boneName = 'gunner';
}

defaultproperties
{
     pivotBone="GunTower"
     pitchPivotBone="JTGun"
     positionType=VP_GUNNER
     thirdPersonRotationType=2
}
