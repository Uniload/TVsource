class classyTank extends VehicleClasses.VehicleTank;

var class<Armor> CModArmorClass;




//compmod's way of telling which armor can use it
simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
    if (character.armorClass == None)
    {
        warn(character.name $ "'s armor class is none");
        return true;
    }
    //else if (position == VP_DRIVER)
    //  return canArmourBeDriver(character.armorClass);
    //else
    //  return canArmourBePassenger(character.armorClass);
    if((character.ArmorClass == cmodarmorclass)&&(position==VP_DRIVER))
        return false;
    else
        return true;
    
}

defaultproperties
{
     CModArmorClass=Class'EquipmentClasses.ArmorHeavy'
     timeBetweenBoosts=15.000000
     boostAngle=0.800000
     boostStrength=10000000.000000
     boostUpStrength=35000000.000000
     boostUpDuration=0.200000
     boostEffectDuration=3.000000
     throttleToVelocityFactor=35.000000
     lowFriction=0.000500
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     driverWeaponClass=Class'classyWeaponVehicleTank'
     Health=550.000000
}
