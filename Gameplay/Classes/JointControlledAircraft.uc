// JointControlledAircraft

class JointControlledAircraft extends Vehicle
	abstract
	dependsOn(PlayerCharacterController)
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

const JCA_LINEAR_VELOCITY_ACCURACY_FACTOR = 100;
const JCA_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.01;

var (Animation) name idleAnimation;
var (Animation) name leftAnimation;
var (Animation) name rightAnimation;
var (Animation) name forwardAnimation;
var (Animation) name backAnimation;
var (Animation) name upAnimation;
var (Animation) name downAnimation;
var (Animation) name spawningAnimation;
var (Animation) name gearUpAnimation;
var (Animation) float spawningBlendTime;
var (Animation) float blendTime;
var (Animation) float gearTraceLength;
var (Animation) float gearUpBlendTime;

// control forces
var (JointControlledAircraft) float strafeThrustForce;
var (JointControlledAircraft) float strafeForce;
var (JointControlledAircraft) float forwardThrustForce;
var (JointControlledAircraft) float forwardForce;
var (JointControlledAircraft) float upThrustForce;
var (JointControlledAircraft) float reverseForce;
var (JointControlledAircraft) float reverseThrustForce;
var (JointControlledAircraft) float strafeCombinedReduction;
var (JointControlledAircraft) float forwardCombinedReduction;
var (JointControlledAircraft) float diveThrustForce;
var (JointControlledAircraft) float diveCombinedReduction;
var (JointControlledAircraft) float thrustCombinedReduction;
var (JointControlledAircraft) float downDiveForceScale;
var (JointControlledAircraft) float aheadDiveForceScale;
var (JointControlledAircraft) float forceScale;

var (JointControlledAircraft) float clientControlJointStrength;
var (JointControlledAircraft) float controlJointStrength;
var (JointControlledAircraft) float clientDriverControlJointStrength;

var (JointControlledAircraft) float flightControlDamping;

var (JointControlledAircraft) float diveCounterGravityForceScale;
var (JointControlledAircraft) float coastingCounterGravityForceScale;

var (JointControlledAircraft) float coastingDamping;

var (JointControlledAircraft) float angularBankScale;
var (JointControlledAircraft) float linearBankScale;

var int turningRightEffectIndex;
var int turningLeftEffectIndex;
var int divingEffectIndex;

var (JointControlledAircraft) float flightRotationEffectMagnitude;

var rotator viewRotationAI;

enum AccelerationEffectStateEnum
{
	AES_ACCELERATING,
	AES_DECELERATING,
	AES_NONE
};

// effect states
var bool ThrustingEffectState;
var AccelerationEffectStateEnum AccelerationEffectState;

// unlike thrusting diving is not always applied directly corresponding to input so this flag is used
var bool divingForceApplied;

// force applied to aircraft due to controls
var vector outputControlForce;
var float outputFlightYawAngle;
var float outputFlightPitchAngle;

var (JointControlledAircraft) float counterGravityForceScale;

// animation states
var bool strafeLeft;
var bool strafeRight;
var bool strafeForward;
var bool strafeBack;
var bool strafeUp;
var bool strafeDown;
var bool LandingGearUp;

var rotator currentCameraRotation;

struct native AircraftState
{
	var vector position;
	var vector velocity;

	// packed pitch and yaw
	var int flightAngles;

	var bool serverThrusting;
	var bool serverDiving;
	var PlayerCharacterController.EDigitalAxisInput serverStrafe;
	var PlayerCharacterController.EDigitalAxisInput serverThrottle;
};
var vector replicatedControlForce;

var AircraftState replicationAircraftState;
var AircraftState oldReplicationAircraftState;

var (JointControlledAircraft) bool constrainAircraftPitch;
var (JointControlledAircraft) float minimumAircraftPitch;
var (JointControlledAircraft) float maximumAircraftPitch;

// unlike the above this is a physically hard constraint
var (JointControlledAircraft) bool hardConstrainAircraftPitch;
var (JointControlledAircraft) float hardAircraftPitchRange;

// indicates the currect z axis rotation being applied by the low level flight physics
var const float zAxisFlightRotation;

////////// NAVIGATION //////////

var float navigationMaximumPitch;
var float navigationMinimumPitch;
var float navigationTurnRate;
var float rotateMinimumPitch;
var float rotateMaximumPitch;
var float thrustThresholdPitch;
var float throttleScale;

// padding
var transient noexport private const int padding[2];

native function vector calculateOutputControlForce(rotator referenceRotation, float currentThrottleInput, float currentStrafeInput,
		float currentThrustInput, bool currentDiveInput);

native function setFlightForce(vector force);
native function setFlightRotation(int yawAngle, int pitchAngle);

native function setFlightControlStrength(float strength);

native function setCounterGravityForceScale(float scale);

replication
{
	reliable if (Role == ROLE_Authority)
		replicationAircraftState;
}

simulated function postNetBeginPlay()
{
	super.postNetBeginPlay();

	VehicleUpdateParams();
}

simulated function rotator getViewRotation()
{
	if (controller != None && !controller.bIsPlayer)
		return viewRotationAI;

	return rotationInput;
}

function setViewRotation(rotator r)
{
	viewRotationAI = r;
}

simulated event updateCameraRotation(float deltaSeconds)
{
	local float maxRotationDelta;
	local rotator requiredRotationDelta;
	local rotator actualrotationDelta;
	local rotator rotationNormal;
	local rotator currentCameraRotationNormal;

	rotationNormal = rotation;
	if (rotationNormal.Pitch > 16384)
		rotationNormal.Yaw += 32768;
	rotationNormal = Normalize(rotationNormal);
	if (rotationNormal.Yaw < 0)
		rotationNormal.Yaw += 65536;
	if (rotationNormal.Pitch < 0)
		rotationNormal.Pitch += 65536;

	currentCameraRotationNormal = Normalize(currentCameraRotation);
	if (currentCameraRotationNormal.Yaw < 0)
		currentCameraRotationNormal.Yaw += 65536;
	if (currentCameraRotationNormal.Pitch < 0)
		currentCameraRotationNormal.Pitch += 65536;

	maxRotationDelta = deltaSeconds * 70000;

	requiredRotationDelta = rotationNormal - currentCameraRotationNormal;

	if (requiredRotationDelta.Pitch > 32768)
		requiredRotationDelta.Pitch -= 65536;
	else if (requiredRotationDelta.Pitch < -32768)
		requiredRotationDelta.Pitch += 65536;

	if (requiredRotationDelta.Yaw > 32768)
		requiredRotationDelta.Yaw -= 65536;
	else if (requiredRotationDelta.Yaw < -32768)
		requiredRotationDelta.Yaw += 65536;

	if (requiredRotationDelta.Yaw < 0)
		actualrotationDelta.Yaw = max(-maxRotationDelta, requiredRotationDelta.Yaw);
	else
		actualrotationDelta.Yaw = min(maxRotationDelta, requiredRotationDelta.Yaw);

	if (requiredRotationDelta.Pitch < 0)
		actualrotationDelta.Pitch = max(-maxRotationDelta, requiredRotationDelta.Pitch);
	else
		actualrotationDelta.Pitch = min(maxRotationDelta, requiredRotationDelta.Pitch);

	currentCameraRotation.Pitch += actualrotationDelta.Pitch;
	currentCameraRotation.Yaw += actualrotationDelta.Yaw;
}

function processInput()
{
	local rotator normalRotationInput;

	// do nothing if no driver
	if (positions[driverIndex].occupant == None)
	{
		outputControlForce = vect(0, 0, 0);
		normalRotationInput = Normalize(Rotation);
		outputFlightYawAngle = normalRotationInput.Yaw;
		outputFlightPitchAngle = normalRotationInput.Pitch;

		return;
	}

	outputControlForce = calculateOutputControlForce(rotationInput, ThrottleInput, StrafeInput, ThrustInput, DiveInput);
	
	normalRotationInput = Normalize(rotationInput);

	outputFlightYawAngle = normalRotationInput.Yaw;
	outputFlightPitchAngle = normalRotationInput.Pitch;
}

function bool needToPushStateToClient()
{
	return true;
}

function pushStateToClient()
{
	local HavokRigidBodyState currentState;
	local rotator workFlightRotation;

	HavokGetState(currentState);

	replicationAircraftState.velocity = currentState.LinVel * JCA_LINEAR_VELOCITY_ACCURACY_FACTOR;
	replicationAircraftState.position = HavokGetCenterOfMass();

	// pack flight angles
	workFlightRotation.Pitch = outputFlightPitchAngle;
	workFlightRotation.Yaw = outputFlightYawAngle;
	replicationAircraftState.flightAngles = packPitchAndYaw(workFlightRotation);

	// effects
	replicationAircraftState.serverThrusting = (ThrustInput > 0);
	replicationAircraftState.serverDiving = divingForceApplied;
	replicationAircraftState.serverStrafe = class'PlayerCharacterController'.static.analogueToDigital(StrafeInput, 1);
	replicationAircraftState.serverThrottle = class'PlayerCharacterController'.static.analogueToDigital(ThrottleInput, 1);

	forceNetDirty();
}

simulated function applyOutput()
{
	local float constrainedPitch;

	setFlightForce(outputControlForce * forceScale);

	// apply pitch constraint
	constrainedPitch = outputFlightPitchAngle;
	if (constrainAircraftPitch)
		constrainedPitch = clamp(constrainedPitch, minimumAircraftPitch, maximumAircraftPitch);

	setFlightRotation(outputFlightYawAngle, constrainedPitch);

	// set counter gravity force scale dependent on dive and driver state
	if (DiveInput && positions[driverIndex].occupant == None)
		warn("diving with no driver");
	if (DiveInput)
		setCounterGravityForceScale(diveCounterGravityForceScale);
	else if (positions[driverIndex].occupant == None)
		setCounterGravityForceScale(coastingCounterGravityForceScale);
	else
		setCounterGravityForceScale(counterGravityForceScale);
}

simulated function vector getControlJointAttachLocation()
{
	return location;
}

simulated event VehicleStateReceived()
{
	local rotator referenceRotation;
	local float receivedThrustInput;
	local rotator flightRotation;

	// should never occur on server but just in case
	if (Role == ROLE_Authority)
		return;

	super.vehicleStateReceived();

	// retrieve packed flight angles
	flightRotation = unpackPitchAndYaw(replicationAircraftState.flightAngles);
	outputFlightPitchAngle = flightRotation.pitch;
	outputFlightYawAngle = flightRotation.yaw;

	// update desired state
	currentDesiredHavokState.position = replicationAircraftState.position;
	currentDesiredHavokState.velocity = replicationAircraftState.velocity * JCA_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.newState = true;

	// calculate output control force
	referenceRotation.Pitch = outputFlightPitchAngle;
	referenceRotation.Yaw = outputFlightYawAngle;
	if (replicationAircraftState.serverThrusting)
		receivedThrustInput = 0;
	replicatedControlForce = calculateOutputControlForce(referenceRotation,
			class'PlayerCharacterController'.static.digitalToAnalogue(replicationAircraftState.serverThrottle, 1),
			class'PlayerCharacterController'.static.digitalToAnalogue(replicationAircraftState.serverStrafe, 1),
			receivedThrustInput, replicationAircraftState.serverDiving);
}

simulated function updateEffectsStates()
{
	local AccelerationEffectStateEnum tickAccelerationState;
	local vector normalVelocity;
	local vector normalForce;
	local float dotForceVelocity;

	super.updateEffectsStates();

	// thrusting
	if (!ThrustingEffectState && (
			((Role == ROLE_Authority) && (ThrustInput > 0)) ||
			((Role < ROLE_Authority) && (replicationAircraftState.serverThrusting))
			))
	{
		ThrustingEffectState = true;
		TriggerEffectEvent('ThrustBegun');
	}
	else if (ThrustingEffectState && (
			((Role == ROLE_Authority) && (ThrustInput == 0)) ||
			((Role < ROLE_Authority) && (!replicationAircraftState.serverThrusting))
			))
	{
		ThrustingEffectState = false;
		TriggerEffectEvent('ThrustEnded');
	}

	// acceleration

	// ... determine acceleration state this tick
	if (outputControlForce != vect(0,0,0))
	{
		if (Velocity == vect(0,0,0))
		{
			tickAccelerationState = AES_ACCELERATING;
		}
		else
		{
			normalVelocity = normal(velocity);
			normalForce = normal(outputControlForce);
			dotForceVelocity = normalVelocity dot normalForce;
			if (dotForceVelocity > 0)
			{
				tickAccelerationState = AES_ACCELERATING;
			}
			else
			{
				tickAccelerationState = AES_DECELERATING;
			}
		}
	}
	else
	{
		tickAccelerationState = AES_NONE;
	}

	// ... update acceleration state based on tick accelration state
	if (tickAccelerationState != accelerationEffectState)
	{
		switch (accelerationEffectState)
		{
		case AES_ACCELERATING:
			UnTriggerEffectEvent('EngineAccelerating');
			break;
		case AES_DECELERATING:
			UnTriggerEffectEvent('EngineDecelerating');
			break;
		}

		accelerationEffectState = tickAccelerationState;

		switch (accelerationEffectState)
		{
		case AES_ACCELERATING:
			TriggerEffectEvent('EngineAccelerating');
			break;
		case AES_DECELERATING:
			TriggerEffectEvent('EngineDecelerating');
			break;
		}
	}
	
	// set animation effect flgas
	if (Role < ROLE_Authority)
	{
		strafeUp =  replicationAircraftState.serverThrusting;
		strafeDown = replicationAircraftState.serverDiving;
		strafeForward = replicationAircraftState.serverThrottle == DAI_Positive;
		strafeBack = replicationAircraftState.serverThrottle == DAI_Negative;
		strafeLeft = replicationAircraftState.serverStrafe == DAI_Positive;
		strafeRight = replicationAircraftState.serverStrafe == DAI_Negative;
	}
	else
	{
		strafeUp = thrustInput>0;
		strafeDown = diveInput;
		strafeForward = ThrottleInput>0;
		strafeBack = ThrottleInput<0;
		strafeLeft = StrafeInput>0;
		strafeRight = StrafeInput<0;
	}
}

simulated function initialiseEffects()
{
	super.initialiseEffects();

	addEffect('turningForceRight', false, turningRightEffectIndex);
	addEffect('turningForceLeft', false, turningLeftEffectIndex);
	addEffect('Diving', false, divingEffectIndex);
}

simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	// clients use replicated information for basic effects
	if (Role < ROLE_Authority)
	{
		switch (effectCauserIndex)
		{
		case throttleForwardEffectIndex:
			return replicationAircraftState.serverThrottle == DAI_Positive;
		case throttleBackEffectIndex:
			return replicationAircraftState.serverThrottle == DAI_Negative;
		case strafeLeftEffectIndex:
			return replicationAircraftState.serverStrafe == DAI_Positive;
		case strafeRightEffectIndex:
			return replicationAircraftState.serverStrafe == DAI_Negative;
		case thrustingEffectIndex:
			return replicationAircraftState.serverThrusting;
		case throttleForwardOrThrustEffectIndex:
			return replicationAircraftState.serverThrottle == DAI_Positive || replicationAircraftState.serverThrusting;
		case strafeLeftOrThrustEffectIndex:
			return replicationAircraftState.serverStrafe == DAI_Positive || replicationAircraftState.serverThrusting;
		case strafeRightOrThrustEffectIndex:
			return replicationAircraftState.serverStrafe == DAI_Negative || replicationAircraftState.serverThrusting;
		case divingEffectIndex:
			return replicationAircraftState.serverDiving;
		}
	}

	switch (effectCauserIndex)
	{
	case turningRightEffectIndex:
		return zAxisFlightRotation > flightRotationEffectMagnitude;
	case turningLeftEffectIndex:
		return zAxisFlightRotation < -flightRotationEffectMagnitude;
	case divingEffectIndex:
		return divingForceApplied;
	}

	return super.isEffectCauserActive(effectCauserIndex);
}

simulated function clientOccupantEnter(ClientOccupantEnterData data)
{
	super.clientOccupantEnter(data);

	// reset control joint strength
	if (Level.NetMode == NM_Client)
	{
		setFlightControlStrength(clientDriverControlJointStrength);
	}
}

simulated function clientDriverLeave(Controller c, Character oldDriver)
{
	Super.clientDriverLeave(c, oldDriver);

	// reset control joint strength
	if (Level.NetMode == NM_Client)
	{
		setFlightControlStrength(clientControlJointStrength);
	}

	// turn off all effects
	if (ThrustingEffectState)
	{
		UnTriggerEffectEvent('Thrusting');
		ThrustingEffectState = false;
	}
	switch (accelerationEffectState)
	{
	case AES_ACCELERATING:
		UnTriggerEffectEvent('EngineAccelerating');
		break;
	case AES_DECELERATING:
		UnTriggerEffectEvent('EngineDecelerating');
		break;
	}
	accelerationEffectState = AES_NONE;
}

simulated function Destroyed()
{
	UnTriggerEffectEvent('EngineAccelerating');
	UnTriggerEffectEvent('EngineDecelerating');
	UnTriggerEffectEvent('Thrusting');
	UnTriggerEffectEvent('Diving');

	super.Destroyed();
}

simulated function bool specialCalcViewProcessing(out actor viewActor, out vector cameraLocation,
		out rotator cameraRotation, int positionIndex)
{
//	cameraRotation = currentCameraRotation;

	return super.specialCalcViewProcessing(viewActor, cameraLocation, cameraRotation, positionIndex);
}

simulated function tick(float deltaSeconds)
{
	local vector traceStart;
	local vector traceEnd;
	local vector dummy;

	// apply replicated output force
	if (Level.NetMode == NM_Client)
	{
		outputControlForce = replicatedControlForce;
	}

	super.tick(deltaSeconds);

	// update landing gear state
	if (gearUpAnimation != 'None')
	{
		traceStart = location;
		traceEnd = traceStart + vect(0, 0, -1) * gearTraceLength;
		LandingGearUp = Trace(dummy, dummy, traceEnd, traceStart) == None;
	}

	// coasting damping
	if (positions[driverIndex].occupant == None)
	{
		dampingPlusEnabled = true;
		dampingPlusXY = coastingDamping;
		dampingPlusPositiveZ = coastingDamping;
		dampingPlusNegativeZ = 0;
	}
	else
	{
		dampingPlusEnabled = false;
	}

	// not diving if no driver
	if (clientPositions[driverIndex].occupant == None)
		divingForceApplied = false;
}

cpptext
{
	virtual void HavokPreStepCallback(FLOAT deltaTime);

	virtual bool HavokInitActor();
	virtual void HavokQuitActor();

	virtual void PostEditChange();

	void PostNetReceive();

	bool isHavokInitialised();

	// movement animation override
	void UpdateMovementAnimation(FLOAT DeltaSeconds);

	virtual void TickAuthoritative(float deltaSeconds);

	class HkSimpleFlightAction* m_flightAction;

	class hkGenericConstraint* m_hardPitchConstraint;

}


defaultproperties
{
     spawningBlendTime=0.600000
     blendTime=0.200000
     gearTraceLength=600.000000
     gearUpBlendTime=1.200000
     strafeThrustForce=50.000000
     strafeForce=25.000000
     forwardThrustForce=50.000000
     forwardForce=25.000000
     upThrustForce=50.000000
     reverseForce=15.000000
     reverseThrustForce=25.000000
     strafeCombinedReduction=0.500000
     forwardCombinedReduction=0.500000
     diveThrustForce=50.000000
     diveCombinedReduction=0.500000
     thrustCombinedReduction=0.500000
     downDiveForceScale=1.200000
     aheadDiveForceScale=0.200000
     ForceScale=250.000000
     clientControlJointStrength=1.000000
     controlJointStrength=2.500000
     clientDriverControlJointStrength=1.500000
     flightControlDamping=0.250000
     coastingCounterGravityForceScale=0.200000
     coastingDamping=0.400000
     angularBankScale=0.350000
     linearBankScale=0.400000
     flightRotationEffectMagnitude=650.000000
     AccelerationEffectState=AES_NONE
     counterGravityForceScale=0.500000
     hardConstrainAircraftPitch=True
     hardAircraftPitchRange=22500.000000
     navigationMaximumPitch=7000.000000
     navigationMinimumPitch=-8000.000000
     navigationTurnRate=4000.000000
     rotateMinimumPitch=-10000.000000
     rotateMaximumPitch=10000.000000
     thrustThresholdPitch=500.000000
     throttleScale=0.000500
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     currentDesiredHavokState=(ignoreRotation=True)
     AirSpeed=5000.000000
     Health=800.000000
     bPhysicsAnimUpdate=True
}
