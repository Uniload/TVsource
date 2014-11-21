//
// SpawnArray class.
//
// Triggers an effect event when a player spawns.
//
class SpawnArray extends BaseDevice;

var() Name spawnAnimation						"The name of the animation to play when a player spawns.";
var(Effectevents) Name spawnedEffectEvent		"The name of the effect event to trigger when a player spawns.";
var() float useableObjectCollisionHeight;
var() float useableObjectCollisionRadius;
var() class<SpawnArrayUseableObject>	accessClass		"Access class to use";
var() float minimumTimeBetweenSpawnEffects		"The number of seconds that must pass before repeated spawn effects will play.";

var bool bSpawnEffect;
var bool bLocalSpawnEffect;
var SpawnArrayUseableObject access;
var localized string cantUseSpawnTowerMessage;
var float lastSpawnEffectTime;

replication
{
	reliable if (Role == ROLE_Authority)
		bSpawnEffect;
}

function PostBeginPlay()
{
	access = Spawn(accessClass, self,, Location, Rotation);

	access.SetCollisionSize(useableObjectCollisionRadius, useableObjectCollisionHeight);

	// Update useable points array
	UseablePoints[0] = access.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

function Destroyed()
{
	Super.Destroyed();

	if (access != None)
		access.Destroy();
}

//
// Called when a player spawns
//
function PlayerSpawned()
{
	bSpawnEffect = !bSpawnEffect;
	playSpawnEffects();
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	if (bLocalSpawnEffect != bSpawnEffect)
	{
		bLocalSpawnEffect = bSpawnEffect;
		playSpawnEffects();
	}
}

simulated function playSpawnEffects()
{
	PlayAnim(spawnAnimation);
	TriggerEffectEvent(spawnedEffectEvent,,,,,,,,team().Class.Name);
}

function use(Pawn user)
{
	// Allow user to teleport to any other spawn array
	// Eventually this should allow you to keep your equipment.  For now, just display the
	// respawn screen.
	// Don't allow players who are carrying carryables to use the spawn array
	if (Character(user) != None && Character(user).numDroppableCarryables() == 0)
	{
		PlayerCharacterController(user.Controller).SelectTeleport();
	}
	else
	{
		// Should display a prompt message if the player can't use it.  This should be implemented the
		// same way as all other prompts (which aren't yet implemented?)
		// For now just send a message
		user.ClientMessage(cantUseSpawnTowerMessage);
	}
}

defaultproperties
{
	Mesh			= SkeletalMesh'BaseObjects.SpawnTower'
	DrawType		= DT_Mesh
	bNetNotify		= true
	useableObjectCollisionHeight	= 150
	useableObjectCollisionRadius	= 300
	accessClass	= class'Gameplay.SpawnArrayUseableObject'
	cantUseSpawnTowerMessage = "You can't use a spawn tower while carrying a game object."
	bAlwaysRelevant = true
	NetPriority		= 0.5

	spawnAnimation	 = SpawnTower
	spawnedEffectEvent = PlayerSpawned
	bCanBeDamaged	= false
}