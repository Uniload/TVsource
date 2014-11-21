class promodBuggyWithoutGun extends VehicleClasses.VehicleBuggy config(promod);

var config bool EnableRoverGun;

simulated function bool canArmorOccupy(VehiclePositionType position, Character character)
{
	if (character.armorClass == None)
	{
		warn(character.name $ "'s armor class is none");
		return true;
	}
	if((character.ArmorClass == class'EquipmentClasses.ArmorHeavy') && (position == VP_DRIVER))
		return false;
	else
		return true;
	
}

simulated function bool canCharacterRespawnAt()
{
	// cannot respawn if there is a driver
	if (clientPositions[0].occupant != None)
		return false;

	return super.canCharacterRespawnAt();
}

function int canOccupy(Character character, VehiclePositionType position, array<VehiclePositionType> secondaryPositions, out byte promptIndex)
{
	local int returnCode;

	returnCode = super.canOccupy(character, position, secondaryPositions, promptIndex);

	if(returnCode != -1 && team() != character.team()){
		
		team().removeVehicleRespawn(self);
		setTeam(character.team());
		team().addVehicleRespawn(self);
	}
	return returnCode;
}

function enableAbandonmentDestruction(float periodSeconds)
{
}

//replace actors
//function Actor ReplaceActor(Actor Other)
//{
//	if(Other.IsA('Buggy')
//		{
//			if(EnableRoverGun == true)
//			{
	//		Gameplay.Buggy(Other).gunnerWeaponClass = class'Gameplay.AntiAircraftWeapon';
//			} else {
//			Gameplay.Buggy(Other).gunnerWeaponClass = None;
//			}
//		}
//	return Super.ReplaceActor(Other);	
//}		
	
//function ModifyRover()
//	{
//	if(EnableRoverGun == true)
//		{
//		gunnerWeaponClass=Class'AntiAircraftWeapon';
	//	} else {
//		gunnerWeaponClass=None;
//		}
//	}	
	
	

defaultproperties
{
     gunnerWeaponClass=None
     spawnDefaultWeapons(0)=Class'EquipmentClasses.WeaponSpinfusor'
     spawnDefaultWeapons(1)=Class'EquipmentClasses.WeaponChaingun'
     spawnDefaultWeapons(2)=Class'EquipmentClasses.WeaponBlaster'
     wheelClasses(0)=Class'VehicleClasses.BuggyFrontLeftWheel'
     wheelClasses(1)=Class'VehicleClasses.BuggyFrontRightWheel'
     wheelClasses(2)=Class'VehicleClasses.BuggyRearLeftWheel'
     wheelClasses(3)=Class'VehicleClasses.BuggyRearRightWheel'
     GearRatios(0)=3.600000
     GearRatios(1)=2.700000
     GearRatios(2)=1.250000
     GearRatios(3)=1.000000
     GearRatios(4)=0.780000
     positions(0)=(thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen",ManifestXPosition=50,ManifestYPosition=20,occupantConnection="Character",occupantAnimation="Buggy_Stand")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting",ManifestXPosition=30,ManifestYPosition=20)
     positions(2)=(Type=VP_INVENTORY_STATION_ONE,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(3)=(Type=VP_INVENTORY_STATION_TWO,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=67,bNotLabelledInManifest=True)
     positions(4)=(Type=VP_INVENTORY_STATION_THREE,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(5)=(Type=VP_INVENTORY_STATION_FOUR,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=67,bNotLabelledInManifest=True)
     Entries(0)=(Radius=150.000000,Height=125.000000,Offset=(Y=-125.000000),primaryPosition=VP_GUNNER,secondaryPositions=(VP_DRIVER))
     Entries(1)=(Radius=100.000000,Height=125.000000,Offset=(Y=125.000000),secondaryPositions=(VP_GUNNER))
     Entries(2)=(Radius=150.000000,Height=125.000000,Offset=(X=200.000000),secondaryPositions=(VP_GUNNER))
     Entries(3)=(Radius=150.000000,Offset=(X=-200.000000),primaryPosition=VP_INVENTORY_STATION_ONE,secondaryPositions=(VP_INVENTORY_STATION_TWO,VP_INVENTORY_STATION_THREE,VP_INVENTORY_STATION_FOUR))
     flipTriggers(0)=(Radius=400.000000,Height=400.000000)
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000),Position=VP_GUNNER)
     exits(2)=(Offset=(X=-350.000000,Z=50.000000),Position=VP_INVENTORY_STATION_ONE)
     exits(3)=(Offset=(X=-350.000000,Z=50.000000),Position=VP_INVENTORY_STATION_TWO)
     exits(4)=(Offset=(X=-350.000000,Z=50.000000),Position=VP_INVENTORY_STATION_THREE)
     exits(5)=(Offset=(X=-350.000000,Z=50.000000),Position=VP_INVENTORY_STATION_FOUR)
     exits(6)=(Offset=(Z=300.000000),Position=VP_NULL)
     exits(7)=(Offset=(Z=-300.000000),Position=VP_NULL)
     damageComponents(0)=(objectType=Class'Vehicles.DynBuggyPANELA',attachmentPoint="Pannela")
     damageComponents(1)=(objectType=Class'Vehicles.DynBuggyPANELB',attachmentPoint="pannelb")
     damageComponents(2)=(objectType=Class'Vehicles.DynBuggyPANELC',attachmentPoint="pannelc")
     goals(0)=Class'VehicleClasses.VehicleBuggy.AI_GunnerGuardGoal'
     abilities(0)=Class'VehicleClasses.VehicleBuggy.AI_VehicleExpellOccupant'
     abilities(1)=Class'VehicleClasses.VehicleBuggy.AI_VehicleMoveTo'
     abilities(2)=Class'VehicleClasses.VehicleBuggy.AI_VehiclePatrol'
     abilities(3)=Class'VehicleClasses.VehicleBuggy.AI_VehicleFollow'
     abilities(4)=Class'VehicleClasses.VehicleBuggy.AI_VehiclePursue'
     abilities(5)=Class'VehicleClasses.VehicleBuggy.AI_GunnerFireAt'
     abilities(6)=Class'VehicleClasses.VehicleBuggy.AI_GunnerGuard'
     Health=2000.000000
}
