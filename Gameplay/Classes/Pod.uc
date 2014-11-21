// Pod

class Pod extends JointControlledAircraft
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var array<name> muzzleSockets;

var int currentMuzzleIndex;

var int engineDustEffectIndex;
var vector engineDustEffectLocation;

var (Pod) float engineDustTraceLength;
var (Pod) float engineDustGroundOffset;

var VehicleEffectObserver muzzleFlashObserver;

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		currentMuzzleIndex;
}

simulated function Material getTeamSkin()
{
	if (m_team != None)
		return m_team.podSkin;

	return None;
}

simulated event postNetBeginPlay()
{
	super.postNetBeginPlay();

	// set team skin
	if (m_team != None)
	{
		skins[0] = m_team.podSkin;
		if (Level.NetMode != NM_Client)
			RepSkin = m_team.podSkin;
	}

	muzzleFlashObserver = new class'VehicleEffectObserver'();
	
	TriggerEffectEvent('Spawn');
}

function vector getProjectileSpawnLocation()
{
	return getBoneCoords(muzzleSockets[currentMuzzleIndex], true).origin;
}

function onShotFiredNotification()
{
	// cycle location
	++currentMuzzleIndex;
	if (currentMuzzleIndex == muzzleSockets.length)
		currentMuzzleIndex = 0;
}

simulated function vector getFirstPersonEquippableLocation(Equippable subject)
{
	warn("not implemented");
	return location;
}

simulated function rotator getFirstPersonEquippableRotation(Equippable subject)
{
	warn("not implemented");
	return rotation;
}

simulated function vector getControlJointAttachLocation()
{
	return getBoneCoords('Pod').origin;
}

simulated function Actor getEffectsBaseActor()
{
	return self;
}

simulated function initialiseEffects()
{
	super.initialiseEffects();

	addEffect('engineDust', true, engineDustEffectIndex);
}

simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	local vector traceStart;
	local vector traceEnd;

	local vector dummy;

	switch (effectCauserIndex)
	{
	case engineDustEffectIndex:

		// trace from engine to ground
		if (positions[driverIndex].occupant == None)
			return false;
		traceStart = location;
		traceEnd = traceStart + (vect(0, 0, -1) >> Rotation) * engineDustTraceLength;

		// The Trace simply ignores all Actors. Ideally it would only ignore Actors to do with the Pod like the occupant and the Pod
		// itself.

		return Trace(engineDustEffectLocation, dummy, traceEnd, traceStart, false) != None;
	}

	return super.isEffectCauserActive(effectCauserIndex);
}

simulated function updateDynamicEffectStates()
{	
	local vector groundOffset;

	super.updateDynamicEffectStates();

	groundOffset.Z = engineDustGroundOffset;

	// move engine dust effect

	// I am assuming that the location is valid if the effect is playing.

	if (effects[engineDustEffectIndex].observer.emitter != None && effects[engineDustEffectIndex].flag)
		effects[engineDustEffectIndex].observer.emitter.setLocation(engineDustEffectLocation + groundOffset);
}

function bool aimAdjustViewRotation()
{
	return true;
}

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart)
{
	newAimAdjustStart = getCameraLookAt(cameraRotation, driverIndex);
}

simulated function bool customFiredEffectProcessing()
{
	return true;
}

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
			if (currentMuzzleIndex == 4)
				currentMuzzleIndex = 0;
		}

		previousMuzzleIndex = currentMuzzleIndex - 1;
		if (previousMuzzleIndex == -1)
			previousMuzzleIndex = 3;
		if (muzzleFlashObserver.emitter != None)
		{
			muzzleFlashObserver.emitter.setLocation(getBoneCoords(muzzleSockets[previousMuzzleIndex], true).origin);
			muzzleFlashObserver.emitter.bHardAttach = true;
			muzzleFlashObserver.emitter.setBase(self);
		}
	}
}

simulated function destroyed()
{
	muzzleFlashObserver.cleanup();
	muzzleFlashObserver.delete();
	muzzleFlashObserver = None;

	super.destroyed();
}

cpptext
{
	void CleanupDestroyed();

}


defaultproperties
{
     muzzleSockets(0)="Muzzle1"
     muzzleSockets(1)="Muzzle2"
     muzzleSockets(2)="muzzle3"
     muzzleSockets(3)="Muzzle4"
     engineDustTraceLength=750.000000
     engineDustGroundOffset=100.000000
     idleAnimation="Idle"
     leftAnimation="strafeLeft"
     rightAnimation="strafeRight"
     forwardAnimation="throttleForward"
     backAnimation="throttleBack"
     upAnimation="thrust"
     downAnimation="dive"
     strafeThrustForce=500.000000
     strafeForce=250.000000
     forwardThrustForce=500.000000
     forwardForce=250.000000
     upThrustForce=500.000000
     reverseForce=150.000000
     reverseThrustForce=250.000000
     diveThrustForce=500.000000
     angularBankScale=0.300000
     linearBankScale=0.050000
     navigationMaximumPitch=12000.000000
     navigationTurnRate=10000.000000
     thrustThresholdPitch=12000.000000
     throttleScale=0.002000
     positions(0)=(thirdPersonCamera=True,lookAtInheritPitch=True,occupantControllerState="TribesPlayerDriving",occupantConnection="Character",occupantAnimation="Pod_Stand")
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     motorClass=Class'PodMotor'
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     driveYawCoefficient=25.000000
     drivePitchCoefficient=25.000000
     TPCameraDistance=800.000000
     bDrawDriverInTP=True
     rootBone="Pod"
     driverWeaponClass=Class'PodWeapon'
     waterDamagePerSecond=0.000000
     localizedName="fighter"
     Mesh=SkeletalMesh'Vehicles.Pod'
     havokDataClass=Class'PodHavokData'
}
