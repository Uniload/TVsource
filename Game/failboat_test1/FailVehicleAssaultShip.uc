class FailVehicleAssaultShip extends VehicleClasses.VehicleAssaultShip;

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

function enableAbandonmentDestruction(float periodSeconds)
{
}

defaultproperties
{
     turretWeaponClass=Class'FailWeaponVehicleTurretSentry'
     coastingCounterGravityForceScale=0.250000
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen")
     positions(1)=(Type=VP_LEFT_GUNNER,occupantControllerState="PlayerVehicleTurreting",occupantConnection="gunnerleft",occupantAnimation="AShipGunner_Stand")
     positions(2)=(Type=VP_RIGHT_GUNNER,occupantControllerState="PlayerVehicleTurreting",occupantConnection="gunnerright",occupantAnimation="AShipGunner_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     driverWeaponClass=None
     localizedName="Mile High Club"
     Health=1400.000000
}
