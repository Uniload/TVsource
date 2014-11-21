class compTank extends VehicleClasses.VehicleTank;

//This is where compmod decides what class can pilot each vehicle. Not clean...but there is no nice way to edit the armorclasses allowed vehicles						
// Returns true if the armour of the specified character can occupy the specified position. 
simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}
	//else if (position == VP_DRIVER)
	//	return canArmourBeDriver(character.armorClass);
	//else
	//	return canArmourBePassenger(character.armorClass);
	if(character.ArmorClass == class'EquipmentClasses.ArmorHeavy')
		return false;
	else
		return true;
	
}

defaultproperties
{
     boostStrength=16000000.000000
     treadLength=230.000000
     throttleToVelocityFactor=35.000000
     treadGainFactor=0.090000
     treadVehicleGravityScale=2.000000
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     Health=600.000000
}
