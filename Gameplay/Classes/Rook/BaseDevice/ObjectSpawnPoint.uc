class ObjectSpawnPoint extends BaseDevice;

var() class<Actor>	objectType				"The type of object spawned at this spawn point";
var() float			respawnDelay			"How long before a new object is made available after the old object is destroyed";
var() Vector		spawnOffset				"Offset from the origin that the object appears at, possibly temporary, will have to be tuned depending on the type of object being spawned";
var() bool			bCanSpawnMultiples		"If false, the spawn point must wait until the previous object taken from it is used up or destroyed before it can spawn a new object. Otherwise, a new object is spawned once the existing object is taken by a character and the respawn delay elapses";
var() Rotator		spawnRotationOffset		"Rotation offset to be applied to the object when spawned";
var() Name			objectAttachBone		"Bone on SpawnPoint that the object is attached to when spawned";
var() float			useableObjectCollisionHeight;
var() float			useableObjectCollisionRadius;
var() Vector		useableObjectOffset;

var Actor						spawnedObject; // use with care on client. prefer signal events.
var ObjectSpawnUseableObject	useableObject;
var float						respawnAnimTime;
var bool						bHoldingObject;
var bool						bWatchingObject;
var bool						bFirstSpawn;
var bool						bWaitingForObject;
var bool						bFinishedDeployEnd;
var bool						bFinishedClosing;

replication
{
	reliable if (Role == ROLE_Authority)
		spawnedObject, respawnAnimTime, bHoldingObject, bWatchingObject,
		bFirstSpawn, bWaitingForObject, bFinishedDeployEnd, bFinishedClosing;
}


function PostBeginPlay()
{
	local vector useableOffset;

	super.PostBeginPlay();

	useableOffset = useableObjectOffset >> rotation;
	useableOffset += Location;

	useableObject = spawn(class'ObjectSpawnUseableObject',self,,useableOffset,Rotation);
	useableObject.SetCollisionSize(useableObjectCollisionRadius, useableObjectCollisionHeight);

	UseablePoints[0] = useableObject.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

simulated function Destroyed()
{
	if (useableObject != None)
		useableObject.Destroy();

	Super.Destroyed();
}

// spawnObject
function spawnObject()
{
	local Vector spawnLocation;
	local Rotator spawnRotation;

	if (objectType == None)
		return;

	spawnLocation = spawnOffset >> rotation;
	spawnLocation += Location;

	spawnRotation = spawnRotationOffset + rotation;

	spawnedObject = spawn(objectType, , , spawnLocation, spawnRotation);
	if (spawnedObject != None)
	{
		spawnedObject.SetPhysics(PHYS_None);
		spawnedObject.Instigator = self;
		if (objectAttachBone != '')
		{
			AttachToBone(spawnedObject, objectAttachBone);
			spawnedObject.bReplicateMovement = true;
		}
		TriggerEffectEvent('SpawnObject');

		if (Rook(spawnedObject) != None)
			Rook(spawnedObject).setTeam(team());
		else if (Deployable(spawnedObject) != None)
		{
			Deployable(spawnedObject).team = team();
			spawnedObject.GotoState('DeployableStation');
		}

		bHoldingObject = true;
	}
	else
	{
		log("ObjectSpawnPoint "$label$" couldn't spawn its object");
		
		bHoldingObject = false;
	}
}

simulated function bool CanBeUsedBy(Character CharacterUser)
{
	return super.CanBeUsedBy(CharacterUser);
}

// OnPlayerUsed
function OnPlayerUsed(Pawn Other)
{
	local Character c;
	local Deployable d;

	c = Character(Other);

	d = Deployable(spawnedObject);

	if (d != None && c != None)
	{
		if (d.canPickup(c))
		{
			d.team = team();
			d.pickup(c);

			// no longer a valid useable point
			UseablePointsValid[0] = UP_NotValid;

			bHoldingObject = false;
		}
	}
}

simulated function bool isOpenedAnimPlaying(Name animName)
{
	return animName == 'Open' || animName == 'DeployStart' || animName == 'DeployEnd';
}

simulated latent function latentExecuteActive()
{
	local float lastTime;

	if (respawnAnimTime != 0)
		Goto RespawnAnimClosing;

	if (bHoldingObject)
		Goto HoldingObject;
	else if (bWatchingObject)
		Goto WatchingObject;
	else if (bWaitingForObject)
		Goto WaitingForRespawn;
	else if (bFinishedDeployEnd)
		Goto FinishedDeployEnd;
	else if (bFinishedClosing)
		Goto FinishedClosing;
	else
	{
		if (!bFirstSpawn)
			Goto WaitingForRespawn;
		else
			bFirstSpawn = false;
	}

SpawnObject:
	PlayBDAnim('DeployStart');
	TriggerEffectEvent('DeployableSpawned');

	bWaitingForObject = false;

	spawnObject(); // server-only call
	while (spawnedObject == None)
		Sleep(0.1);	// may have to wait on client for object reference to replicate
	UseablePointsValid[0] = UP_Valid;

HoldingObject:
	// check if object was collected
	if (!bHoldingObject)
	{
		if (bCanSpawnMultiples)
		{
			bWatchingObject = false;
			StopAnimating();
			goto WaitingForRespawn;	// we don't care about the object's death if we can spawn multiples
		}
		else
		{
			bWatchingObject = true;
			goto WatchingObject;
		}
	}
	Sleep(0.5);
	goto HoldingObject;

WatchingObject: // waiting for the spawned object to die
	if (!bWatchingObject)
	{
		StopAnimating();
		goto WaitingForRespawn;
	}

	if (Role == ROLE_Authority)
	{
		if (spawnedObject == None || spawnedObject.bDeleteMe)
		{
			bWatchingObject = false;
		}
	}

	Sleep(0.5);
	goto WatchingObject;

WaitingForRespawn:
	bFinishedDeployEnd = false;
	bWaitingForObject = true;

	if (!IsAnimating())
	{
		PlayBDAnim('DeployEnd');
	}

	FinishAnim(0);

FinishedDeployEnd:
	bWaitingForObject = false;
	bFinishedDeployEnd = true;

	while (Role != ROLE_Authority && (respawnAnimTime == 0 && HasAnim('Closing')))
	{
		if (spawnedObject != None)
			goto SpawnObject;
		
		Sleep(0);
	}

RespawnAnimClosing:

	// respawnAnimTime is used to sync anim on client only
	if (Role == ROLE_Authority)
		respawnAnimTime = GetAnimLength('Closing') * respawnDelay;

	PlayAnim('Closing', 1.0 / respawnAnimTime,, 0);
	savedAnim = 'Closing';

	lastTime = Level.TimeSeconds;
	while (true)
	{
		Sleep(0);
		respawnAnimTime -= Level.TimeSeconds - lastTime;

		// stop deployable poking through station on client
		if (Level.NetMode == NM_Client && spawnedObject != None)
			spawnedObject.bHidden = true; 

		if (!IsAnimating())
			break;
	}
	
	StopAnimating();

	respawnAnimTime = 0;

FinishedClosing:
	if (spawnedObject != None)
		spawnedObject.bHidden = false; 

	bFinishedDeployEnd = false;
	bFinishedClosing = true;

	if (!IsAnimating())
	{
		PlayBDAnim('Opening');
	}
	FinishAnim(0);

	while (Role != ROLE_Authority && spawnedObject == None)
	{
		Sleep(0);
	}

	bFinishedClosing = false;
	goto SpawnObject;
}

// State Unpowered
simulated state Unpowered
{
	simulated function BeginState()
	{
		super.BeginState();
		destroyHeldObject();
		UseablePointsValid[0] = UP_NotValid;
	}

Begin:
	if (!bInitialization)
	{
		PlayBDAnim('Closing');
		FinishAnim();
	}
	LoopBDAnim('Closed');
}

// State Destructed
simulated state Destructed
{
	simulated function BeginState()
	{
		super.BeginState();
		destroyHeldObject();
		UseablePointsValid[0] = UP_NotValid;
	}
}

function destroyHeldObject()
{
	if (bHoldingObject)
	{
		if (spawnedObject != None)
		{
			spawnedObject.Destroy();
			spawnedObject = None;
		}

		bHoldingObject = false;
		bWatchingObject = false;
		bWaitingForObject = false;
		bFinishedDeployEnd = false;
		bFinishedClosing = false;
	}
}

function onTeamChange()
{
	super.onTeamChange();

	destroyHeldObject();
}

defaultproperties
{
	bReplicateAnimations = false

	bWorldGeometry = false
	objectAttachBone = "deployable"

	useableObjectCollisionHeight = 80
	useableObjectCollisionRadius = 60
	useableObjectOffset = (X=0,Y=40,Z=0)

	bFirstSpawn = true;
}