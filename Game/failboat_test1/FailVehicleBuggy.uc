class FailVehicleBuggy extends VehicleClasses.VehicleBuggy;

//Thanks Stryker
//This is where compmod decides what class can pilot each vehicle. Not clean...but there is no nice way to edit the armorclasses allowed vehicles						
//Returns true if the armour of the specified character can occupy the specified position. 
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

defaultproperties
{
     gunnerWeaponClass=Class'FailWeaponVehicleTurretSentry'
     GearRatios(0)=1.000000
     positions(0)=(thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen",ManifestXPosition=50,ManifestYPosition=20,occupantConnection="Character",occupantAnimation="Buggy_Stand")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting",ManifestXPosition=30,ManifestYPosition=20)
     positions(2)=(Type=VP_INVENTORY_STATION_ONE,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(3)=(Type=VP_INVENTORY_STATION_TWO,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=67,bNotLabelledInManifest=True)
     positions(4)=(Type=VP_INVENTORY_STATION_THREE,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(5)=(Type=VP_INVENTORY_STATION_FOUR,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=67,bNotLabelledInManifest=True)
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     flipTriggers(0)=(Radius=400.000000,Height=400.000000)
     collisionDamageMagnitudeScale=0.000035
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     bDisablePositionSwitching=True
     TopSpeed=13250.000000
     localizedName="Party Van"
}
