class InventoryStation extends BaseDevice implements InventoryStationAccessControl
	native;

struct native QueueElement
{
	var Character character;
	var InventoryStationAccess access;
	var int accessIndex;
	var int extensionIndex;
	var bool accessible;
};

// 1 to 4 inclusive
var (InventoryStation) int numberAccessPoints;

var (InventoryStation) name baseSocketName;

var InventoryStationPlatform accessPointOne;
var InventoryStationPlatform accessPointTwo;
var InventoryStationPlatform accessPointThree;
var InventoryStationPlatform accessPointFour;
var InventoryStationPlatform localAccessPoints[4];

var array<InventoryStationAccess> accesses;

var array<Name> accessPoses;
var array<Name> extensionPoses;

var (InventoryStation) class<InventoryStationAccess> accessClass;

var (InventoryStation) float accessRadius;
var (InventoryStation) float accessHeight;

// used when turning
var int targetAccessIndex;
var int targetExtensionIndex;

// first digit is access index, second digit in extension index
var int packedIndices;
var int localPackedIndices;
var bool repeatSwitch;
var bool localRepeatSwitch;

var int loadoutChangeIndex;
var int localLoadoutChangeIndex;
var bool loadoutChangeSwitch;
var bool localLoadoutChangeSwitch;

var bool bDamaged;

var (InventoryStation) float receiveDamageRadius;

var (InventoryStation) float delaySeconds;

// should add to 1
var (InventoryStation) float armRetractDelayFraction;
var (InventoryStation) float armTurnDelayFraction;
var (InventoryStation) float armExtendDelayFraction;

var array<QueueElement> accessQueue;

cpptext
{
	virtual void Spawned();
}

replication
{
	reliable if (Role == ROLE_Authority)
		packedIndices, repeatSwitch, loadoutChangeIndex, loadoutChangeSwitch, accessPointOne,
				accessPointTwo, accessPointThree, accessPointFour;
}

function PostBeginPlay()
{
	local int accessI;
	local Vector accessSpawnLocation;
	local Rotator accessSpawnRotation;

	Super.PostBeginPlay();

	for (accessI = 0; accessI < numberAccessPoints; ++accessI)
	{
		accessSpawnLocation = getAccessPoint(accessI).location;
		accessSpawnRotation = getAccessPoint(accessI).rotation;
		accessSpawnLocation.Z += accessHeight;

		accesses[accessI] = spawn(accessClass, self, , accessSpawnLocation, accessSpawnRotation);
		accesses[accessI].setCollision(true, false, false);
		accesses[accessI].setCollisionSize(accessRadius, accessHeight);

		// set self as access control
		accesses[accessI].initialise(self);

		// Update useable points array
		UseablePoints[accessI] = accesses[accessI].GetUseablePoint();
		UseablePointsValid[accessI] = UP_Valid;
	}
}

simulated function PostNetReceive()
{
	local InventoryStationPlatform workAccessPoint;
	local int index;

	Super.PostNetReceive();

	// handle arm changes
	if (packedIndices != localPackedIndices)
	{
		localPackedIndices = packedIndices;
		targetAccessIndex = packedIndices / 10;
		targetExtensionIndex = packedIndices % 10;
		GotoState('Active', 'Positioning');
	}
	else if (repeatSwitch != localRepeatSwitch)
	{
		localRepeatSwitch = repeatSwitch;
		GotoState('Active', 'Positioning');
	}

	// handle loadout changed triggers
	if (loadoutChangeIndex != localLoadoutChangeIndex)
	{
		localLoadoutChangeIndex = loadoutChangeIndex;
		workAccessPoint = getAccessPoint(localLoadoutChangeIndex);
		workAccessPoint.TriggerEffectEvent('LoadoutChanged');
	}
	else if (loadoutChangeSwitch != localLoadoutChangeSwitch)
	{
		localLoadoutChangeSwitch = loadoutChangeSwitch;
		workAccessPoint = getAccessPoint(localLoadoutChangeIndex);
		workAccessPoint.TriggerEffectEvent('LoadoutChanged');
	}

	// update platform references to us
	for (index = 0; index < 4; ++index)
	{
		if (localAccessPoints[index] != getAccessPoint(index))
		{
			localAccessPoints[index] = getAccessPoint(index);
			if (localAccessPoints[index] != None)
				localAccessPoints[index].ownerInventoryStation = self;
		}
	}
}

function int getAccessIndex(InventoryStationAccess access)
{
	local int result;

	for (result = 0; result < numberAccessPoints; ++result)
	{
		if (access == accesses[result])
			return result;
	}
	assert(false);
}

function accessRequired(Character accessor, InventoryStationAccess access, int armorIndex)
{
	local int desiredAccessIndex;
	local bool onlyQueueMember;
	local int index;

	desiredAccessIndex = getAccessIndex(access);

	// add to queue
	accessQueue.length = accessQueue.length + 1;
	accessQueue[accessQueue.length - 1].character = accessor;
	accessQueue[accessQueue.length - 1].access = access;
	accessQueue[accessQueue.length - 1].accessIndex = desiredAccessIndex;
	accessQueue[accessQueue.length - 1].extensionIndex = armorIndex;
	accessQueue[accessQueue.length - 1].accessible = false;

	// get into desired position if only inaccessible member in queue
	onlyQueueMember = true;
	for (index = 0; index < accessQueue.length - 1; ++index)
	{
		if (!accessQueue[index].accessible)
		{
			onlyQueueMember = false;
			break;
		}
	}
	if (onlyQueueMember)
		proceedToNextQueueMember();
}

function accessNoLongerRequired(Character accessor)
{
	local int index;
	local int oldLength;

	// remove character from queue
	oldLength = accessQueue.length;
	for (index = 0; index < accessQueue.length; ++index)
	{
		if (accessQueue[index].character == accessor)
		{
			accessQueue.remove(index, 1);
			break;
		}
	}
	if (index == oldLength)
		warn("removed " $ accessor $ " from access queue who was not actually in it");
}

function proceedToNextQueueMember()
{
	local int index;
	local int workPackedIndices;

	// get index of first inaccessible queue member
	for (index = 0; index < accessQueue.length; ++index)
	{
		if (!accessQueue[index].accessible)
			break;
	}

	// do nothing if no one left in queue
	if (accessQueue.length == index)
		return;

	targetAccessIndex = accessQueue[index].accessIndex;
	targetExtensionIndex = accessQueue[index].extensionIndex;
	GotoState('Active', 'Positioning');
						 
	workPackedIndices = targetAccessIndex * 10;
	workPackedIndices += targetExtensionIndex;

	// flip repeat switch if packed indices did not change
	if (workPackedIndices == packedIndices)
		repeatSwitch = !repeatSwitch;
	else
		packedIndices = workPackedIndices;
}

function bool isAccessible(Character accessor)
{
	local int index;

	// find queue member
	for (index = 0; index < accessQueue.length; ++index)
	{
		if (accessQueue[index].character == accessor)
			break;
	}
	if (index == accessQueue.length)
	{
		warn(accessor @ "not in queue");
		return false;
	}

	// remove from queue if accessible
	if (accessQueue[index].accessible)
	{
		accessQueue.Remove(index, 1);
		return true;
	}

	return false;
}

simulated function InventoryStationPlatform getAccessPoint(int accessPointIndex)
{
	local InventoryStationPlatform result;

	switch (accessPointIndex)
	{
	case 0:
		result = accessPointOne;
		break;
	case 1:
		result = accessPointTwo;
		break;
	case 2:
		result = accessPointThree;
		break;
	case 3:
		result = accessPointFour;
		break;
	default:
		warn(accessPointIndex @ "is beyond the maximum access point index");
	}

	// result could be None due to replication

	return result;
}

function changeApplied(InventoryStationAccess access)
{
	local int accessIndex;
	accessIndex = getAccessIndex(access);
	getAccessPoint(accessIndex).TriggerEffectEvent('LoadoutChanged');

	// update replicated variables
	if (accessIndex == loadoutChangeIndex)
	{
		loadoutChangeSwitch = !loadoutChangeSwitch;
	}
	else
	{
		loadoutChangeIndex = accessIndex;
	}
}

simulated state Active
{
	//
	// Overridden to avoid ever going to the damaged state
	//
	simulated function CheckChangeState()
	{
		// check if we need to go to Destructed or unpowered states
		if(Health <= 0)
			GotoState('Destructed', 'Degenerating');
		else if(!isPowered() && !bWasDeployed)
			GotoState('UnPowered');
		else if(isDisabled())
			GotoState('Destructed', 'Degenerating');
		else if(isDamaged() && ! bDamaged)
		{
			bDamaged = true;
			PlayDamagedDegeneratingEffects();
			PlayDamagedEnteredEffects();
		}
		else if(! isDamaged() && bDamaged)
		{
			bDamaged = false;
			PlayDamagedExitedEffects();
		}
	}

Begin:

	if (!bInitialization)
		PlayAnim(accessPoses[0], , 2.0, 0);
	Goto('End');

Positioning:

	// put arm into target position

	TriggerEffectEvent('InventoryStationActivating');

	// ... turn
	PlayAnim(accessPoses[targetAccessIndex], , delaySeconds * armTurnDelayFraction, 0);
	FinishAnim(0);

	// ... extend
	AnimBlendParams(1, 1);
	PlayAnim(extensionPoses[targetExtensionIndex], , delaySeconds * armExtendDelayFraction, 1);
	FinishAnim(1);

	if (Level.NetMode != NM_Client)
		positioningFinished();

	if (Level.NetMode != NM_Client)
		proceedToNextQueueMember();

	// ... retract
	PlayAnim('Fold', , delaySeconds * armRetractDelayFraction, 1);
	FinishAnim(1);

	UnTriggerEffectEvent('InventoryStationActivating');

End:
	// nothing
}

function positioningFinished()
{
	local int index;

	// flag queue member as being accessible
	for (index = 0; index < accessQueue.length; ++index)
	{
		if (accessQueue[index].accessIndex == targetAccessIndex)
		{
			if (accessQueue[index].accessible)
				warn("queue memeber already accessible");
			accessQueue[index].accessible = true;
			break;
		}
	}

	// may get to this point if a queue member was removed while waiting
}

function bool isOnCharactersTeam(Character testCharacter)
{
	return isFriendly(testCharacter);
}

function bool directUsage()
{
	return true;
}

function accessFinished(Character user, bool returnToUsualMovment);

simulated event destroyed()
{
	local int accessI;

	super.destroyed();

	for (accessI = 0; accessI < accesses.length; ++accessI)
		if (accesses[accessI] != None)
			accesses[accessI].destroy();
}

simulated function Actor getHurtRadiusParent()
{
	return self;
}

simulated function float getReceiveDamageRadius()
{
	return CollisionRadius;
}

simulated function bool getCurrentLoadoutWeapons(out InventoryStationAccess.InventoryStationLoadout weaponLoadout, Character user)
{
	return false;
}

defaultProperties
{
	Mesh			= SkeletalMesh'BaseObjects.InventoryStationArm'
	DrawType		= DT_Mesh

	numberAccessPoints	= 4

	baseSocketName	= "Base"

	accessRadius	= 50
	accessHeight	= 80

	accessClass		= class'Gameplay.InventoryStationAccess'

	accessPoses(0)	= Front
	accessPoses(1)	= Right
	accessPoses(2)	= Back
	accessPoses(3)	= Left

	extensionPoses(0)	= ScreenLight
	extensionPoses(1)	= ScreenMedium
	extensionPoses(2)	= ScreenHeavy

	bNetInitialRotation	= true

	bNetNotify			= true

	delaySeconds			= 2
	armRetractDelayFraction	= 0.3
	armTurnDelayFraction	= 0.4
	armExtendDelayFraction	= 0.3

	localLoadOutChangeIndex	= 0

	RemoteRole				= ROLE_SimulatedProxy

	bDisableEditorCopying	= true

	// base functionality is required inside UnrealEd
	bWorldGeometry			= false

	receiveDamageRadius		= 300
}