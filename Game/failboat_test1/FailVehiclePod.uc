class FailVehiclePod extends VehicleClasses.VehiclePod;



var name passengerSeat;
var Character passenger;

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
	if((character.ArmorClass != class'EquipmentClasses.ArmorLight'))
		return false;
	else
		return true;
}

defaultproperties
{
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     positions(0)=(thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",occupantConnection="Character",occupantAnimation="Pod_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     motorClass=Class'FailPodMotor'
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
}
