class classyAssaultShip extends VehicleClasses.VehicleAssaultShip;

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
     turretWeaponClass=Class'classyWeaponVehicleAssaultShip'
     strafeThrustForce=200.000000
     strafeForce=1000.000000
     forwardThrustForce=25000.000000
     forwardForce=30000.000000
     upThrustForce=18000.000000
     reverseForce=150.000000
     reverseThrustForce=100.000000
     diveThrustForce=35000.000000
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen")
     positions(1)=(Type=VP_LEFT_GUNNER,occupantControllerState="PlayerVehicleTurreting",occupantConnection="gunnerleft",occupantAnimation="AShipGunner_Stand")
     positions(2)=(Type=VP_RIGHT_GUNNER,occupantControllerState="PlayerVehicleTurreting",occupantConnection="gunnerright",occupantAnimation="AShipGunner_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     collisionDamageMagnitudeScale=0.000100
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     TopSpeed=5500.000000
     driverWeaponClass=None
     AirSpeed=6500.000000
     Health=250.000000
}
