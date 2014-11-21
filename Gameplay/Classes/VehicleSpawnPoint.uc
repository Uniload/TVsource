class VehicleSpawnPoint extends BaseDevice
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var () class<Vehicle> vehicleClass;
var () float spawnDuration;
var () float abandonmentDesturctionStartRadius;
var () float abandonmentDesturctionPeriod;
var () float spawnOffsetHeight;

var () bool bAllowSpawnedVehicleStealing;

var Vehicle spawnedVehicle;

var float spawnStartTime;

var int index;

var vector direction;

var float spawnAnimationLength;

var name animationName;

var float dummy;

var vector spawnOffset;

var name localAnimationName;

var bool bTearOffAnimation;

replication
{
	reliable if (Role == ROLE_Authority)
		spawnedVehicle;
}

native function Vehicle spawnVehicle(vector spawnLocation, rotator spawnRotation);

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	GetAnimParams(0, localAnimationName, dummy, dummy);
}

simulated function postBeginPlay()
{
	super.postBeginPlay();

	spawnOffset.z = spawnOffsetHeight;
}

simulated function postNetBeginPlay()
{
	super.postNetBeginPlay();
}

simulated function postNetReceive()
{
	local name currentAnimationName;

	super.postNetReceive();

	// assuming between last tick and now replicated animation has been applied

	GetAnimParams(0, currentAnimationName, dummy, dummy);

	// check for spawn animation event
	if (localAnimationName != currentAnimationName && currentAnimationName == 'SpawnEnd')
		GotoState('Active', 'Spawn');

	// check for bake animation event
	if (localAnimationName != currentAnimationName && currentAnimationName == 'SpawnStart')
		GotoState('Active', 'NewSpawn');
}

simulated event onTeamChange()
{
	super.onTeamChange();

	// destroy spawned vehicle if it is not the same team and is yet to be driven
	if (Role == ROLE_Authority && spawnedVehicle != None && !spawnedVehicle.bHasBeenOccupied && team() != spawnedVehicle.team())
	{
		spawnedVehicle.TakeDamage(spawnedVehicle.health + 10, self, spawnedVehicle.Location, vect(0,0,0), class'DamageType');
	}
}

simulated state Active
{

	simulated function endState()
	{
		super.endState();

		// handle case we are powering down while vehicle is spawning
		GetAnimParams(0, animationName, dummy, dummy);
		if (animationName == 'SpawnEnd' && IsAnimating())
		{
			bTearOffAnimation = false;

			// snap to final spot
			if (spawnedVehicle != None)
				spawnedVehicle.move(getBoneCoords('VehicleSpawn', true).origin + spawnOffset - spawnedVehicle.Location);

			postSpawnVehicle();
		}
	}

Begin:

	// case a client is recieving spawn point mid spawn
	GetAnimParams(0, animationName, dummy, dummy);
	if (animationName == 'SpawnEnd' && IsAnimating())
		goto('Spawning');

	// client waiting for new spawn
	if (Role != ROLE_Authority)
		goto('End');

	// case of server waiting for new spawn
	if (m_team == None || spawnedVehicle != None)
		goto('WaitForNewSpawnEvent');

Spawn:

	// make sure channel 1 blending is off
	AnimBlendParams(1, 0);

	if (Role == ROLE_Authority)
	{
		PlayAnim('SpawnEnd');
		preSpawnVehicle();
	}

Spawning:

	// clients might get here even though the vehicle is not spawning
	if (Role != ROLE_Authority && spawnedVehicle != None && !spawnedVehicle.spawning)
		goto('End');

	// wait for animation to finish
	GetAnimParams(0, animationName, dummy, dummy);
	if (animationName == 'SpawnEnd' && IsAnimating())
	{
		// on clients tear off this animation to avoid snapping at end
		if (Role < ROLE_Authority)
			bTearOffAnimation = true;

		// manual move vehicle with vehicle bone - using a bone attachment was problematic
		if (spawnedVehicle != None)
			spawnedVehicle.move(getBoneCoords('Vehicle', true).origin + spawnOffset - spawnedVehicle.Location);

		sleep(0);
		Goto('Spawning');
	}

	// snap to final spot for sake of robustness
	if (spawnedVehicle != None)
		spawnedVehicle.move(getBoneCoords('VehicleSpawn', true).origin + spawnOffset - spawnedVehicle.Location);

	if (Role < ROLE_Authority)
		bTearOffAnimation = false;

	postSpawnVehicle();

	// clients stop now and wait for event from server in PostNetReceive
	if (Role != ROLE_Authority)
		goto('End');

WaitForNewSpawnEvent:

	// keep on waiting if we do not have a team
	if (m_team == None)
	{
		sleep(0);
		goto('WaitForNewSpawnEvent');
	}

	// wait for vehicle to die
	if (spawnedVehicle == None || spawnedVehicle.health <= 0 || spawnedVehicle.bDeleteMe)
		goto('NewSpawn');

	// start abandonment destruction if necessary
	if (!spawnedVehicle.abandonmentDestruction && VSize(Location - spawnedVehicle.Location) > abandonmentDesturctionStartRadius)
		spawnedVehicle.enableAbandonmentDestruction(abandonmentDesturctionPeriod);

	sleep(0);
	goto('WaitForNewSpawnEvent');

NewSpawn:

	spawnedVehicle = None;

	spawnStartTime = Level.TimeSeconds;

	bTearOffAnimation = false;

	if (Role == ROLE_Authority)
		PlayAnim('SpawnStart');

SpawnStarting:

	// wait for animation to finish
	GetAnimParams(0, animationName, dummy, dummy);
	if (animationName == 'SpawnStart' && IsAnimating())
	{
		sleep(0);
		goto('SpawnStarting');
	}

	// blend the posts going down
	AnimBlendParams(1, 1);
	PlayAnim('Spawning', GetAnimLength('Spawning') / spawnDuration, , 1);

	while ((Level.TimeSeconds - spawnStartTime) < spawnDuration)
		sleep(0);

	if (Role == ROLE_Authority)
		goto('Spawn');

End:

}

// Spawns actual vehicle instance and puts vehicle in the spawn state.
function preSpawnVehicle()
{
	if (vehicleClass == None)
	{
		warn("vehicle class is none");
		return;
	}

	spawnedVehicle = spawnVehicle(getBoneCoords('Vehicle', true).origin + spawnOffset, getBoneRotation('Vehicle'));
	spawnedVehicle.bCanBeStolen = bAllowSpawnedVehicleStealing;

	spawnedVehicle.startedSpawnFromVehicleSpawnPoint();

	if (spawnedVehicle == None)
	{
		warn("failed to spawn vehicle");
		return;
	}

	if (team() == None)
		warn("vehicle spawn point does not have a team");

	spawnedVehicle.Label = Name(Label $ "Vehicle");
	spawnedVehicle.setTeam(team());
}

// Puts spanwed vehicle in normal vehicle state.
simulated function postSpawnVehicle()
{
	// getting crash in detachFromBone
	if (spawnedVehicle != None)
	{
		spawnedVehicle.spawning = false;

		spawnedVehicle.finishedSpawnFromVehicleSpawnPoint();
	}
}

cpptext
{
	virtual void PlayReplicatedAnim();

}


defaultproperties
{
     spawnDuration=10.000000
     abandonmentDesturctionStartRadius=3000.000000
     abandonmentDesturctionPeriod=5.000000
     spawnOffsetHeight=40.000000
     bAllowSpawnedVehicleStealing=True
     bWorldGeometry=True
     bAlwaysRelevant=True
     bReplicateAnimations=True
     Mesh=SkeletalMesh'BaseObjects.VehicleSpawnPod'
     bNetNotify=True
}
