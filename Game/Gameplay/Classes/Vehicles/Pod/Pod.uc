// Pod

class Pod extends JointControlledAircraft
	native;

cppText
{
	void CleanupDestroyed();
}

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

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'Vehicles.Pod'

	Health=800

	TPCameraDistance=800

	strafeThrustForce = 500
	strafeForce = 250
	forwardThrustForce = 500
	forwardForce = 250
	upThrustForce = 500
	reverseForce = 150
	reverseThrustForce = 250
	diveThrustForce = 500

	bDrawDriverInTP = true

	HavokDataClass=class'PodHavokData'

	rootBone="Pod"

	positions(0)=(type=VP_DRIVER,hideOccupant=false,occupantControllerState=TribesPlayerDriving,thirdPersonCamera=true,lookAtInheritPitch=true,occupantAnimation=Pod_Stand,occupantConnection=character)

	driverWeaponClass=class'PodWeapon'

	muzzleSockets(0)=muzzle1
	muzzleSockets(1)=muzzle2
	muzzleSockets(2)=muzzle3
	muzzleSockets(3)=muzzle4

	motorClass = class'PodMotor'
	
	idleAnimation = idle
	leftAnimation = strafeLeft
	rightAnimation = strafeRight
	forwardAnimation = throttleForward
	backAnimation = throttleBack
	upAnimation = thrust
	downAnimation = dive
	
	blendTime = 0.2

	engineDustTraceLength = 750
	engineDustGroundOffset = 100

	angularBankScale = 0.3
	linearBankScale = 0.05

	waterDamagePerSecond = 0

	navigationTurnRate = 10000
	throttleScale = 0.002

	thrustThresholdPitch = 12000

	driveYawCoefficient = 25
	drivePitchCoefficient = 25

	navigationMaximumPitch = 12000

	cornerSlowDownSpeedCoefficient = 10

	localizedName = "fighter"
}