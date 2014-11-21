class DeployedTurretSentryWeapon extends TurretSentryWeapon;

simulated function Vector calcProjectileSpawnLocation(Rotator fireRot)
{
	if (rookOwner != None)
		return rookOwner.GetBoneCoords(projectileSpawnBone).origin;

	return super.calcProjectileSpawnLocation(fireRot);
}

defaultproperties
{
	ammoUsage = 0
}