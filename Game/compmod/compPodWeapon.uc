class compPodWeapon extends EquipmentClasses.WeaponVehicleFighterRocket;




simulated protected function FireWeapon()
{
	local Vector fireLoc;
	local int i;
	for( i = 0; i < 4; i ++)
	{

		fireLoc = rookMotor.getProjectileSpawnLocation();
		makeProjectile(getAimRotation(fireLoc), fireLoc);

		lastFireTime = Level.TimeSeconds;

		if (rookMotor == None)
			initialiseRookMotor();

		firedEffectProcessing();
	}

	bFiredWeapon = true;

	playCharacterFireAnim();
	animClass.static.playEquippableAnim(self, fireAnimation, speedPackScale);

	demoFireCount++;
	
	if (demoFireCount==0)
	    demoFireCount = 1;
}

defaultproperties
{
     roundsPerSecond=0.800000
     projectileClass=Class'compPodRocket'
     projectileVelocity=7000.000000
     projectileInheritedVelFactor=0.400000
}
