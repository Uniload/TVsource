class EquipmentSpawnPoint extends Engine.Actor
	placeable;

var() editinlineuse class<Equipment> equipmentClass;
var() float respawnTime;
var() Vector respawnOffset;

var Equipment spawnedEquipment;

function PostBeginPlay()
{
	spawnEquipment();
}

simulated function destroyed()
{
	Super.destroyed();

	if (spawnedEquipment != None)
		spawnedEquipment.destroy();
}

function Timer()
{
	spawnEquipment();
}

function spawnEquipment()
{
	spawnedEquipment = Spawn(equipmentClass,,, Location + respawnOffset);

	if (spawnedEquipment != None)
	{
		spawnedEquipment.awaitingPickupPhysics = PHYS_None;
		spawnedEquipment.spawnPoint = self;
	}
	else
		Log("Warning:  equipment spawn point "$self$" failed to spawn object of class "$equipmentClass);
}

function equipmentTaken()
{
	if (spawnedEquipment != None)
	{
		spawnedEquipment.awaitingPickupPhysics = spawnedEquipment.default.awaitingPickupPhysics;
		spawnedEquipment.onTakenFromSpawnPoint();
		spawnedEquipment = None;
	}
	SetTimer(respawnTime, false);
}

defaultproperties
{
	//RemoteRole = ROLE_None
	respawnOffset=(X=0,Y=0,Z=100)
}