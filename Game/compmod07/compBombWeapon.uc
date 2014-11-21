class compBombWeapon extends EquipmentClasses.WeaponVehicleAssaultShipBomb;

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

defaultproperties
{
     maxAmmo=5
     reloadTimer=1.000000
     reloadTime=1.500000
     ammoCount=5
     ammoUsage=1
     roundsPerSecond=5.000000
     projectileClass=Class'compBomb'
     projectileVelocity=1.000000
     projectileInheritedVelFactor=1.000000
}
