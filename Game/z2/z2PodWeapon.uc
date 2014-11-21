class z2PodWeapon extends EquipmentClasses.WeaponVehicleFighterRocket;



var int maxAmmo;
var float reloadTimer;
var float reloadTime;

simulated function tick(float deltaSeconds)
{
	if(reloadTimer <= 0)
	{
		if(ammoCount < maxAmmo)
		{
			increaseAmmo(1);
			reloadTimer = reloadTime;
		}
	}
	else
	{
		reloadTimer -= deltaSeconds;
	}
	
	super.tick(deltaSeconds);
}

//AssaultShipWeapon sticks this true, so override
simulated function bool canFire()
{
	return hasAmmo();
}

//simulated protected function FireWeapon()
//{
//	local Vector fireLoc;
//	local int i;
//	for( i = 0; i < 2; i ++)
//	{

//		fireLoc = rookMotor.getProjectileSpawnLocation();
//		makeProjectile(getAimRotation(fireLoc), fireLoc);
//
//		lastFireTime = Level.TimeSeconds;
//
//		if (rookMotor == None)
//			initialiseRookMotor();
//
//		firedEffectProcessing();
//	}

//	bFiredWeapon = true;

//	playCharacterFireAnim();
//	animClass.static.playEquippableAnim(self, fireAnimation, speedPackScale);

//	demoFireCount++;
	
//	if (demoFireCount==0)
//	    demoFireCount = 1;
//}

defaultproperties
{
     maxAmmo=8
     reloadTimer=0.900000
     reloadTime=0.900000
     ammoCount=8
     ammoUsage=1
}
