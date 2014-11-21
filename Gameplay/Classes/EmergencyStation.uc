///////////////////////////////////////////////////////////////////////////////
//
// Emergency Station
//
class EmergencyStation extends BaseDevice
	native;

//
// Access point variables
//
var(EmergencyStation) float				accessPointOffset	"Offset of the access area from the Emergency station";
var(EmergencyStation) float				accessRadius		"Radius of the access area in front of the Emergency station";
var(EmergencyStation) float				accessHeight		"Height of the access area in front of the Emergency station";
var(EmergencyStation) Material			activeLightSkin		"The active light skin texture";
var(EmergencyStation) int				activeLightSkinSlot	"skin slot for the flashing light skin";
var(EmergencyStation) class<RepairPack>	repairPackClass		"class of repair pack to give";
var(EmergencyStation) class<EmergencyStationAccess>	accessClass	"Access Class to spawn";
var(EmergencyStation) float				respawnDelay		"Duration of repair pack respawn";

var EmergencyStationAccess access;
var bool bForceIconVisible;	// used to turn on icon in radar

enum eBakeAnimationState
{
	BAS_End,
	BAS_Start,
	BAS_Baking
};
var eBakeAnimationState animationState;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	local Vector accessPointLocation;
	local Vector xAxis, zAxis;

	Super.PostBeginPlay();

	// Place the access point in front of the emergency station (along the y axis)
	GetAxes(rotation, xAxis, accessPointLocation, zAxis);
	accessPointLocation *= accessPointOffset;
	accessPointLocation += location;

	// create the access point
	access = spawn(accessClass, None, , accessPointLocation, Rotation);
	access.setCollision(true, false, false);
	access.setCollisionSize(accessRadius, accessHeight);

	// set self as access control
	access.initialise(self);

	// Update the useable points array
	UseablePoints[0] = access.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	// animation processing
	if (Role == ROLE_Authority)
	{
		switch (animationState)
		{
		case BAS_Start:
			if (!isAnimating())
			{
				// start bake animation
				savedAnim = 'Bake';
				bLoopSavedAnim = false;
				PlayAnim('Bake', GetAnimLength('Bake') / respawnDelay);
				animationState = BAS_Baking;
			}
			break;
		case BAS_Baking:
			if (!isAnimating())
			{
				// start end animation
				PlayBDAnim('End');
				animationState = BAS_End;
			}
			break;
		}
	}
}

function bool isRepairPackAvailable()
{
	return animationState == BAS_End;
}

simulated function Destroyed()
{
	// Delete spawned access class
	if (access != None)
		access.Destroy();

	Super.Destroyed();
}

// State Unpowered
simulated state Unpowered
{
	simulated function BeginState()
	{
		// Play flashing light animation 
		Skins[ActiveLightSkinSlot] = activeLightSkin;
		// start the alarm
		TriggerEffectEvent('Alarm');
	}
}

// State Active
simulated state Active
{
	simulated function BeginState()
	{
		// Stop flashing light animation 
		Skins[ActiveLightSkinSlot] = None;
		// stop the alarm
		UnTriggerEffectEvent('Alarm');
	}
}

function repairPackTaken()
{
	PlayBDAnim('Start');
	animationState = BAS_Start;
}

function bool isOnCharactersTeam(Character testCharacter)
{
	return isFriendly(testCharacter);
}

function bool canBeSensed()
{
	return bForceIconVisible;
}

// its always functional
function bool isFunctional()
{
	return true;
}

cpptext
{
	virtual UBOOL canBeSeenBy(APawn* pawn) {return false;}	// AI's can't see EmergencyStation's

}


defaultproperties
{
     accessRadius=50.000000
     accessHeight=80.000000
     activeLightSkin=Shader'BaseObjects.VstationLightShader'
     activeLightSkinSlot=3
     repairPackClass=Class'RepairPack'
     accessClass=Class'EmergencyStationAccess'
     respawnDelay=5.000000
     bAIThreat=False
     bReplicateAnimations=True
     Mesh=SkeletalMesh'BaseObjects.RepairStation'
     bCanBeDamaged=False
}
