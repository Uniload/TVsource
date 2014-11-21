class promodWeaponPlasma extends EquipmentClasses.WeaponBurner config(promod);

var config float	projectileVelocity;
var config float	projectileInheritedVelFactor;

function int getMaxAmmo(){
 	return Character(rookOwner).getModifiedAmmo(Character(rookOwner).armorClass.static.maxAmmo(class'EquipmentClasses.WeaponBurner'));
}                        

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

function useAmmo()
{
	if (ammoCount <= 0)
		return;

	ammoCount -= ammoUsage;

	if (ammoCount <= 0)
		setOutOfAmmo();
}

simulated function bool hasAmmo()
{
	return ammoCount >= ammoUsage;
}

simulated function bool canFire()
{
	return hasAmmo();
}

defaultproperties
{
     energyUsage=0.000000
     ammoUsage=1
     roundsPerSecond=1.500000
     projectileClass=Class'promodProjectilePlasma'
     projectileVelocity=120000.000000
     projectileInheritedVelFactor=0.400000
}
