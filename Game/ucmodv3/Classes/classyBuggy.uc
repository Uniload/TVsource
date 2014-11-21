class classyBuggy extends VehicleClasses.VehicleBuggy;


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
     gunnerWeaponClass=None
     GearRatios(0)=1.000000
     ChassisMass=15000.000000
     EngineTorque=6000.000000
     EngineMinRPM=650.000000
     EngineOptRPM=4600.000000
     EngineMaxRPM=5500.000000
     EngineTorqueFactorAtMinRPM=2.800000
     EngineTorqueFactorAtMaxRPM=0.550000
     GearDownshiftRPM=2200.000000
     GearUpshiftRPM=4870.000000
     GearReverseRatio=2.700000
     positions(0)=(thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen",ManifestXPosition=50,ManifestYPosition=20,occupantConnection="Character",occupantAnimation="Buggy_Stand")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting",ManifestXPosition=30,ManifestYPosition=20)
     positions(2)=(Type=VP_INVENTORY_STATION_ONE,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(3)=(Type=VP_INVENTORY_STATION_TWO,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=67,bNotLabelledInManifest=True)
     positions(4)=(Type=VP_INVENTORY_STATION_THREE,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(5)=(Type=VP_INVENTORY_STATION_FOUR,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=67,bNotLabelledInManifest=True)
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     flipTriggers(0)=(Radius=400.000000,Height=400.000000)
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     flipRotationStrength=52.500000
     flipPushUpImpulse=15000000.000000
}
