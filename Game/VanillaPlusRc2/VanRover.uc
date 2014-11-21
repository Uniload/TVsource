class VanRover extends VehicleClasses.VehicleBuggy;

//This is where compmod decides what class can pilot each vehicle. Not clean...but there is no nice way to edit the armorclasses allowed vehicles						
//Returns true if the armour of the specified character can occupy the specified position. 
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

/* (debugging code)
function updateRespawnState()
{
	 Log("updateRespawnState");
	if (isRegisteredRespawnVehicle)
	{
		Log("server: reg'ed respawn veh");
		if (!canCharacterRespawnAt())
		{
			Log("server: remove respawn vehicle");
		}
	}
	else
	{
		Log("server: NOT a reg'ed respawn veh");
		if (canCharacterRespawnAt())
		{
			Log("server: add respawn vehicle");
		}
	}
	super.updateRespawnState();
}
//called on client and server everytime someone switches position or enters vehicle
simulated function clientOccupantEnter(ClientOccupantEnterData data)
{
	Log("clientOccupantEnter");
	super.clientOccupantEnter(data);
	//clientUpdateRespawnState();
}
function switchPosition(int currentPositionIndex, byte selectedPosition)
{
	Log("switchPosition");
	super.switchPosition(currentPositionIndex, selectedPosition);
}
*/
// Called on all machines when an occupant leaves this vehicle.
simulated function otherClientOccupantLeave(int positionI, Character oldOccupant)
{
	Log("otherClientOccupantLeave");
	super.otherClientOccupantLeave(positionI, oldOccupant);
	if (Role == ROLE_Authority)
		updateRespawnState();
}

function occupantEnter(Character p, int positionIndex)
{
	Log("occupantEnter...");
	super.occupantEnter(p, positionIndex);
	//if driver enters, check again to see if this is a valid spawnpoint
	if (positionIndex == driverIndex)
	{
		Log("...entered to driver, updating respawn");
		updateRespawnState();
	}
	
}


simulated function bool canCharacterRespawnAt()
{
	local int inventoryStationI;
	local TeamInfo occupantTeam;

	Log("can character respawn at rover?");
	if (!isAlive())
		{Log("not alive");
		return false;
		}
	
	if (Role < ROLE_Authority)
	{
		//no spawning with a driver in the seat
		if( clientPositions[driverIndex].occupant != None)
		{
			Log("client driver in the seat");
			return false;
		}
	}
	else
	{
		//no spawning with a driver in the seat
		if(positions[driverIndex].occupant != None)
		{
			Log("server driver in the seat");
			return false;
		}
	}

	// unneeded with above code
	// cannot respawn if being driven by an enemy
	//occupantTeam = getOccupantTeam();
	//if (occupantTeam != None && occupantTeam != m_team)
	//	return false;

	// cannot respawn if all inventory station slots are occupied
	for (inventoryStationI = 2; inventoryStationI < 2 + numberInventoryStationPositions; ++inventoryStationI)
		if (clientPositions[inventoryStationI].occupant == None)
			break;
	if (inventoryStationI == 2 + numberInventoryStationPositions)
		{
		Log("slots full");
		return false;
		}

	// cannot respawn if settled upside down
	if (bSettledUpsideDown)
	{
	Log("rover flipped");
		return false;
		}

	// cannot respawn if yet to be driven
	if (!bHasBeenOccupied)
	{
	Log("not yet occ'ed");
		return false;
		}

	Log("...yes");
	return true;
}

defaultproperties
{
     gunnerWeaponClass=Class'WeaponVehicleBuggy'
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
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     bDisablePositionSwitching=True
     Health=300.000000
}
