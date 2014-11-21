class FailWeaponBurner extends EquipmentClasses.WeaponBurner;

simulated protected function FireWeapon()
{
	local Vector fireLoc;

	fireLoc = rookMotor.getProjectileSpawnLocation();
	makeProjectile(getAimRotation(fireLoc), fireLoc);

	lastFireTime = Level.TimeSeconds;

	if (rookMotor == None)
		initialiseRookMotor();

	firedEffectProcessing();

	bFiredWeapon = true;

	playCharacterFireAnim();
	animClass.static.playEquippableAnim(self, fireAnimation, speedPackScale * roundsPerSecond);

	demoFireCount++;
	
	if (demoFireCount==0)
	    demoFireCount = 1;
}

defaultproperties
{
     roundsPerSecond=0.670000
     projectileClass=Class'FailProjectileBurner'
}
