// Pod
// Tweaked version

class classyPod extends VehicleClasses.VehiclePod;


var array<name> muzzleSockets;

var int currentMuzzleIndex;

var int engineDustEffectIndex;
var vector engineDustEffectLocation;

var (Pod) float engineDustTraceLength;
var (Pod) float engineDustGroundOffset;

var VehicleEffectObserver muzzleFlashObserver;
var string CModArmorClassName;
var class<Armor> CModArmorClass;



simulated function doCustomFiredEffectProcessing()
{
	local int previousMuzzleIndex;
	if (Level.NetMode != NM_DedicatedServer && muzzleFlashObserver != None)
	{
		TriggerEffectEvent('Fired', , , , , , , muzzleFlashObserver);

		// update current muzzle index if we are client
		if (Level.NetMode == NM_Client)
		{
			++currentMuzzleIndex;
			if (currentMuzzleIndex == 2)
				currentMuzzleIndex = 0;
		}

		previousMuzzleIndex = currentMuzzleIndex - 1;
		if (previousMuzzleIndex == -1)
			previousMuzzleIndex = 1;
		if (muzzleFlashObserver.emitter != None)
		{
			muzzleFlashObserver.emitter.setLocation(getBoneCoords(muzzleSockets[previousMuzzleIndex], true).origin);
			muzzleFlashObserver.emitter.bHardAttach = true;
			muzzleFlashObserver.emitter.setBase(self);
		}
	}
}



/*
NOTE Da_Wrecka: This entire function is unnecessary; we can just specify the class to use in DefaultProperties
function PostBeginPlay(){
super.PostBeginPlay();
cmodarmorclass = class<ArmorDefault>(DynamicLoadObject("EquipmentClasses.ArmorHeavy", class'class'));
}*/

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
    if(character.ArmorClass == cmodarmorclass)
        return false;
    else
        return true;
    
}


function bool aimAdjustViewRotation()
{
    return true;
}

defaultproperties
{
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     engineDustTraceLength=750.000000
     engineDustGroundOffset=100.000000
     CModArmorClass=Class'EquipmentClasses.ArmorHeavy'
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     strafeThrustForce=100.000000
     strafeForce=750.000000
     forwardThrustForce=11000.000000
     forwardForce=9500.000000
     upThrustForce=4000.000000
     reverseThrustForce=100.000000
     diveThrustForce=5500.000000
     positions(0)=(thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",occupantConnection="Character",occupantAnimation="Pod_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     collisionDamageMagnitudeScale=0.000800
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     TopSpeed=100000.000000
     driverWeaponClass=Class'classyPodWeapon'
     velocityInheritOnExitScale=0.500000
     AirSpeed=9500.000000
     Health=100.000000
}
