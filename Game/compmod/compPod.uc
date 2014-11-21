class compPod extends VehicleClasses.VehiclePod;

var () float Energy;
var () float EnergyMax;
var () float EnergyRegenPerSec;

//simulated event postNetBeginPlay()
//{

	//driverWeapon.projectileClass = class'compMod.compPodRocket';
	//super.postNetBeginPlay();

//}

function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation,  Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	if(Energy > Damage)
	{
		Energy -= Damage;//subtract damage from energy
		Health += Damage;//undo damage taken
	}
	else
	{
		Health += Energy;//Since energy < damage, just heal what we can
		Energy = 0;//we used all our shields
		
	}
	
	//super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	super.PostTakeDamage(Damage, instigatedBy, hitlocation, momentum,  damageType,  projectileFactor);
}

simulated function tick(float deltaSeconds)
{
	if(Energy < EnergyMax)
		{
			Energy += EnergyRegenPerSec * deltaSeconds;
			if(Energy > EnergyMax)
				Energy = EnergyMax;
		}
	super.tick(deltaSeconds);

}
							

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

function bool aimAdjustViewRotation()
{
	return true;
}

simulated event updateCameraRotation(float deltaSeconds)
{
	local float maxRotationDelta;
	local rotator requiredRotationDelta;
	local rotator actualrotationDelta;
	local rotator rotationNormal;
	local rotator currentCameraRotationNormal;

	rotationNormal = rotation;
	if (rotationNormal.Pitch > 16384)
		rotationNormal.Yaw += 32768;
	rotationNormal = Normalize(rotationNormal);
	if (rotationNormal.Yaw < 0)
		rotationNormal.Yaw += 65536;
	if (rotationNormal.Pitch < 0)
		rotationNormal.Pitch += 65536;

	currentCameraRotationNormal = Normalize(currentCameraRotation);
	if (currentCameraRotationNormal.Yaw < 0)
		currentCameraRotationNormal.Yaw += 65536;
	if (currentCameraRotationNormal.Pitch < 0)
		currentCameraRotationNormal.Pitch += 65536;

	maxRotationDelta = deltaSeconds * 70000;

	requiredRotationDelta = rotationNormal - currentCameraRotationNormal;

	if (requiredRotationDelta.Pitch > 32768)
		requiredRotationDelta.Pitch -= 65536;
	else if (requiredRotationDelta.Pitch < -32768)
		requiredRotationDelta.Pitch += 65536;

	if (requiredRotationDelta.Yaw > 32768)
		requiredRotationDelta.Yaw -= 65536;
	else if (requiredRotationDelta.Yaw < -32768)
		requiredRotationDelta.Yaw += 65536;

	if (requiredRotationDelta.Yaw < 0)
		actualrotationDelta.Yaw = max(-maxRotationDelta, requiredRotationDelta.Yaw);
	else
		actualrotationDelta.Yaw = min(maxRotationDelta, requiredRotationDelta.Yaw);

	if (requiredRotationDelta.Pitch < 0)
		actualrotationDelta.Pitch = max(-maxRotationDelta, requiredRotationDelta.Pitch);
	else
		actualrotationDelta.Pitch = min(maxRotationDelta, requiredRotationDelta.Pitch);

	currentCameraRotation.Pitch += actualrotationDelta.Pitch;
	currentCameraRotation.Yaw += actualrotationDelta.Yaw;
}

defaultproperties
{
     energy=15.000000
     EnergyMax=15.000000
     EnergyRegenPerSec=3.000000
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     strafeThrustForce=2000.000000
     strafeForce=5000.000000
     forwardThrustForce=6500.000000
     forwardForce=3000.000000
     upThrustForce=4500.000000
     reverseForce=1200.000000
     reverseThrustForce=1200.000000
     diveThrustForce=7500.000000
     thrustCombinedReduction=0.400000
     coastingDamping=-0.500000
     angularBankScale=0.500000
     linearBankScale=0.400000
     positions(0)=(thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",occupantConnection="Character",occupantAnimation="Pod_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     TopSpeed=120000.000000
     cornerSlowDownSpeedCoefficient=1.000000
     driverWeaponClass=Class'compPodWeapon'
     AirSpeed=10000.000000
     Health=100.000000
}
