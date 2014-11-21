class x2Tank extends VehicleClasses.VehicleTank;

simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}

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
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving",ManifestXPosition=40,ManifestYPosition=30)
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting",ManifestXPosition=40,ManifestYPosition=50)
     Entries(0)=(Radius=200.000000,Height=125.000000,Offset=(X=250.000000,Y=250.000000,Z=150.000000),secondaryPositions=(VP_GUNNER))
     Entries(1)=(Radius=200.000000,Height=125.000000,Offset=(Y=-250.000000,Z=200.000000),primaryPosition=VP_GUNNER,secondaryPositions=(VP_DRIVER))
     Entries(2)=(Radius=200.000000,Height=125.000000,Offset=(Y=220.000000),secondaryPositions=(VP_GUNNER))
     Entries(3)=(Radius=200.000000,Height=125.000000,Offset=(Y=-220.000000),secondaryPositions=(VP_GUNNER))
     Entries(4)=(Radius=200.000000,Height=125.000000,Offset=(X=-250.000000),secondaryPositions=(VP_GUNNER))
     flipTriggers(0)=(Radius=600.000000,Height=600.000000)
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     exits(2)=(Offset=(Z=300.000000),Position=VP_NULL)
     exits(3)=(Offset=(Z=-300.000000),Position=VP_NULL)
     damageComponents(0)=(objectType=Class'Vehicles.DynTankPannelA',attachmentPoint="Pannel00")
     damageComponents(1)=(objectType=Class'Vehicles.DynTankPannelB',attachmentPoint="Pannel01")
     damageComponents(2)=(objectType=Class'Vehicles.DynTankPannelC',attachmentPoint="pannel02")
     Health=600.000000
}
