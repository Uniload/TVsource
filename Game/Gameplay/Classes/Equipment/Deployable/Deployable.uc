// Deployable
// Base class for deployables. The deployable object represents a piece of equipment that can be carried
// by the player and then deployed somewhere. Once deployed, the object cannot be picked up again.
//
// Generally this class has no need to be used, instead used the derived BaseDeviceDeployable class. Objects
// that can be deployed themselves should be a type of BaseDevice, but this class remains in case the deployable 
// system needs to be extended in another direction.
class Deployable extends Equippable
	native
	abstract;

var() float			deployRange				"The maximum range from the player at which the object can be deployed";
var() bool			bCanDeployOnWall		"If true, the object can be spawned on a wall, else the object must be spawned on the floor";
var() float			exclusiveRange			"The minimum distance that deployables of the same type can be deployed from each other. 0 to disable.";
var() bool			bCanBeStolen			"If false, the enemy cannot take the deployable until it has been previously held by a member of the friendly team.";

var bool			bDeployed;
var bool			bIsInStation;
var TeamInfo		team;
var bool			bDeploying;

var() Material		hudReticuleOk			"Reticule shown when deployable can be placed successfully";
var() float			hudReticuleOkWidth		"Width of the reticule texture";
var() float			hudReticuleOkHeight		"Height of the reticule texture";
var() float			hudReticuleOkCenterX	"X co-ord on the texture of the hud center";
var() float			hudReticuleOkCenterY	"Y co-ord on the texture of the hud center";

var() Material		hudReticuleBad			"Reticule shown when deployable cannot be placed successfully";
var() float			hudReticuleBadWidth		"Width of the reticule texture";
var() float			hudReticuleBadHeight	"Height of the reticule texture";
var() float			hudReticuleBadCenterX	"X co-ord on the texture of the hud center";
var() float			hudReticuleBadCenterY	"Y co-ord on the texture of the hud center";

var() Rotator		deployRotOffset			"Rotation applied to the deployable after it is deployed";

var() Name			thirdPersonInventoryAttachmentBone		"Attachment bone used when the deployable is not selected, but held in the inventory";
var() Vector		thirdPersonInventoryAttachmentOffset	"Offset from attachment point for 3rd person mesh, while the deployable is not selected";
var Name			originalAttachmentBone;

var() Name			deployedQuickChatTag					"Quick chat tag to announce when deployed";

enum eDeployableInfo
{
	DeployableInfo_Ok,
	DeployableInfo_TooFar,
	DeployableInfo_NoSurface,
	DeployableInfo_Blocked,
	DeployableInfo_SameTypeTooNear,
	DeployableInfo_InvalidTargetObject,
	DeployableInfo_BadState
};

var eDeployableInfo lastTestResult;

replication
{
	reliable if (Role == ROLE_Authority)
		bDeployed, bIsInStation;
	
	reliable if (Role == ROLE_Authority && bNetOwner)
		lastTestResult;
}


simulated function PostNetReceive()
{
	if (bIsInStation)
		GotoState('DeployableStation');
	else
		super.PostNetReceive();
}

// PostNetBeginPlay
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Mesh != None)
		PlayAnim('Closed');
}

simulated function bool armsFirstPersonStatus(bool bNewIsFirstPerson)
{
	return false;
}

// canPickup
function bool canPickup(Character potentialOwner)
{
	local Deployable existing;

	if (!bCanBeStolen && team != None && potentialOwner.team() != None && potentialOwner.team() != team)
		return false;

	if (!potentialOwner.armorClass.static.isDeployableAllowed(class))
	{
//		potentialOwner.ClientMessage("Your armor does not allow you to pick up this deployable.");
		return false;
	}

	existing = Deployable(potentialOwner.nextEquipment(None, class'Deployable'));
	if (existing != None)
	{
//		potentialOwner.ClientMessage("You can only carry one deployable at a time.");
		return false;
	}

	return true;
}

function eDeployableInfo testDeploy()
{
	lastTestResult = doDeploy(true);
	return lastTestResult;
}

simulated function bool EncroachingOn(Actor Other)
{
	return bDeploying;
}

simulated private function eDeployableInfo doDeploy(optional bool bTest)
{
	local bool bOldColActors;
	local bool bOldColWorld;
	local bool bOldBlockActors;
	local bool bOldBlockPlayers;
	local bool bOldUseCylinderCollision;
	local vector startTrace, hitNormal, endTrace;
	local vector loc;
	local rotator newRotation;
	local Actor a;
	local eDeployableInfo result;
	local Character charOwner;
	local Actor allD;

	bDeploying = true;

	bOldColWorld = bCollideWorld;
	bOldColActors = bCollideActors;
	bOldBlockActors = bBlockActors;
	bOldBlockPlayers = bOldBlockPlayers;
	bOldUseCylinderCollision = bUseCylinderCollision;

	charOwner = Character(Owner);

	startTrace = charOwner.Location + charOwner.EyePosition();
	endTrace = startTrace + Vector(charOwner.motor.getViewRotation()) * deployRange;

	bCollideWorld = false;
	SetCollision(false, false, false);

	result = DeployableInfo_Ok;

	// test for deployment range
	a = charOwner.Trace(loc, hitNormal, endTrace, startTrace, true, Vect(0.1,0.1,0.1));
	loc += hitNormal * (CollisionHeight * 0.5);
	if (a == None || VSize(loc - startTrace) > deployRange)
	{
		result = DeployableInfo_TooFar;
	}

	// make sure we don't deploy onto vehicles or havok objects
	if (DynamicObject(a) != None || Vehicle(a) != None || VehicleSpawnPoint(a) != None ||
		BaseDevice(a) != None || MPActor(a) != None)
		result = DeployableInfo_InvalidTargetObject;

	bUseCylinderCollision = true;
	bCollideWorld = true;
	SetCollision(true, true, true);

	// check if we can deploy onto a wall
	if (result == DeployableInfo_Ok && !bCanDeployOnWall)
	{
		if (Vect(0, 0, 1) Dot hitNormal < 0.5)
		{
			result = DeployableInfo_NoSurface;
		}
	}

	// check if we can deploy near other deployables
	if (result == DeployableInfo_Ok && exclusiveRange > 0)
	{
		ForEach DynamicActors(class, allD)
		{
			if (allD != self && VSize(allD.Location - loc) < exclusiveRange && Deployable(allD).bDeployed)
			{
				result = DeployableInfo_SameTypeTooNear;
				break;
			}
		}
	}

	if (result == DeployableInfo_Ok)
	{
		newRotation.Yaw = charOwner.Rotation.Yaw;
		newRotation += deployRotOffset;

		if (bTest)
		{
			if (!TestMove(loc, newRotation))
			{
				result = DeployableInfo_Blocked;
			}
		}
		else
		{
			if (!SetLocation(loc))
			{
				result = DeployableInfo_Blocked;
			}
			else
			{
				if (!SetRotation(newRotation))
				{
					result = DeployableInfo_Blocked;
				}
				else
				{
					team = charOwner.team();
				}
			}
		}
	}

	bCollideWorld = bOldColWorld;
	bUseCylinderCollision = bOldUseCylinderCollision;
	SetCollision(bOldColActors, bOldBlockActors, bOldBlockPlayers);

	bDeploying = false;

	return result;
}

// FireReleased state
state FireReleased
{
	function eDeployableInfo deploy()
	{
		local Character charOwner;
		local eDeployableInfo testResult;

		if (bDeployed)
			return DeployableInfo_BadState;

		charOwner = Character(Owner);
		if (charOwner == None)
		{
			log("Deployable used without owner");
			return DeployableInfo_BadState;
		}

		if (charOwner.motor == None)
		{
			log("Deployable character owner has no motor");
			return DeployableInfo_BadState;
		}

		testResult = doDeploy();
		return testResult;
	}

	simulated function BeginState()
	{
		Super.BeginState();

		if (Level.NetMode != NM_Client)
		{
			if (deploy() == DeployableInfo_Ok)
			{
				bDeployed = true;

				// trigger a quickchat to tell the team its deployed
				if(	deployedQuickChatTag != '' && Character(Owner) != None && 
					PlayerCharacterController(Character(Owner).Controller) != None && 
					! PlayerCharacterController(Character(Owner).Controller).IsSinglePlayer())
						PlayerCharacterController(Character(Owner).Controller).TeamQuickChat("", String(deployedQuickChatTag));
			}
			else
				GotoState('Idle');
		}
	}
}

// needPrompt
function bool needPrompt(Character potentialOwner)
{
	return false;
}

// Tick
simulated function Tick(float Delta)
{
	if (bDeployed && !IsInState('Deployed'))
	{
		GotoState('Deployed');
	}
	else
		Super.Tick(Delta);
}

simulated function updateAttachmentStatus(optional bool bForce)
{
	if (!firstPersonStatus())
	{
		bHidden = false;
		selectMesh(bForce);
		SetRelativeLocation(thirdPersonInventoryAttachmentOffset);
	}
	else
	{
		bHidden = true;
	}
}

function simulated bool fire(optional bool _fireOnce)
{
	local Character charOwner;

	// client-side scripting specific code
	charOwner = Character(Owner);
	if (charOwner != None)
	{
		if (PlayerCharacterController(charOwner.controller) != None)
		{
			PlayerCharacterController(charOwner.controller).clientSideChar.deployableUseTime = Level.TimeSeconds;
		}
	}

	return super.fire(_fireOnce);
}

// State Idle
simulated state Idle
{
	simulated function BeginState()
	{
		Super.BeginState();
		Instigator = None;
		SetRelativeRotation(Rot(0,0,0));
	}

	simulated function Tick(float Delta)
	{
		Super.Tick(Delta);

		testDeploy();
	}
}

// State Held
// Overridden to show the deployable on the character's back
simulated state Held
{
	simulated function BeginState()
	{
		super.BeginState();
		bMeshChangeOk = false;
		Instigator = None;
		originalAttachmentBone = thirdPersonAttachmentBone;
		thirdPersonAttachmentBone = thirdPersonInventoryAttachmentBone;

		updateAttachmentStatus(true);

		SetRelativeRotation(Rot(0,0,0));
	}

	simulated function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);

		updateAttachmentStatus();
	}

	simulated function EndState()
	{
		super.EndState();
		thirdPersonAttachmentBone = originalAttachmentBone;
	}
}

// State Dropped
simulated state Dropped
{
	simulated function BeginState()
	{
		Super.BeginState();
		bCanBeStolen = true;
	}
}

// State Deployed
simulated state Deployed extends Dropped
{
	function setupDropped()
	{
		Character(rookOwner).removeEquipment(self);
		Character(rookOwner).deployable = None;
		Super.setupDropped();
		bDropped = false;
	}

	simulated function BeginState()
	{
		setupDropped();
	}

	// called to see if the object can expire due to timeout, max dropped equipment etc.
	simulated function bool canExpire()
	{
		return false;
	}

Begin:
	if (Mesh != None)
	{
		PlayAnim('Deploy');
		FinishAnim();
		LoopAnim('Deployed');
	}
}

simulated state DeployableStation extends AwaitingPickup
{
	simulated function setup()
	{
		bCanPickup = false;
		SetCollision(false, false, false);
		bCollideWorld = false;
		bHidden = false;
	}

	simulated function BeginState()
	{
		super.BeginState();
		bIsInStation = true;
	}

	simulated function EndState()
	{
		super.EndState();
		bIsInStation = false;
	}

Begin:
	bPlayPickupSound = true;
	setup();
}


defaultproperties
{
	bCanDrop				= true
	bCanBeStolen			= false
	animClass				= class'CharacterEquippableAnimator'
	deployRange				= 1000
	exclusiveRange			= 1000

	hudReticuleOk			= texture'HUD.ReticuleScatter'
	hudReticuleOkWidth		= 128
	hudReticuleOkHeight		= 128
	hudReticuleOkCenterX	= 64
	hudReticuleOkCenterY	= 64

	hudReticuleBad			= texture'HUD.ReticuleDirect'
	hudReticuleBadWidth		= 128
	hudReticuleBadHeight	= 128
	hudReticuleBadCenterX	= 64
	hudReticuleBadCenterY	= 64
	
	thirdPersonInventoryAttachmentBone = "deployable"
}