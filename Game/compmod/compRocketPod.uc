class compRocketPod extends EquipmentClasses.WeaponRocketPod;


simulated protected function FireWeapon()
{
log("fired rocketpod at " $ launchDelay);

super.FireWeapon();
}

defaultproperties
{
     launchDelay=0.080000
}
