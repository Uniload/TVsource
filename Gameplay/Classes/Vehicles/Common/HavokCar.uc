class HavokCar extends Car
	placeable
	dependson(PlayerCharacterController)
	native;

cpptext
{
#ifdef UNREAL_HAVOK

	// Actor interface.
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();
	
	virtual void PostNetReceive();
    virtual void PostEditChange();

	virtual void TickAuthoritative(float deltaSeconds);

	virtual void HavokPreStepCallback(FLOAT DeltaTime);
	
	virtual void RemakeVehicle();  // updates the internal Havok Raycast vehicle. Called by default in VehicleUpdateParams event, but you can call it whenever you change suspension params etc. No need to call this if you just chaneg steering + throtle in the UpdateVehicle event.
	virtual void BuildVehicle();    // constructs the vehicle, internal call from PostBeginPlay

	virtual void syncVehicleToBones();

	void havokCarSwitchClass(UClass* havokCarClass);
	void switchWheelClasses(const TArray<UClass*>& newWheelClasses);
#endif

	bool isHavokInitialised();

	virtual void updateHavokCollisionFilter();
}

const HC_LINEAR_VELOCITY_ACCURACY_FACTOR = 100;
const HC_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.01;

const HC_ANGULAR_VELOCITY_ACCURACY_FACTOR = 1000;
const HC_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.001;

// physical output from Havok, corresponds to other wheel arrays
struct native WheelOutput
{
	var float skidEnergyDensity;
	var float suspensionLength;
	var bool groundContact;
};
var array<WheelOutput> wheelsOutput;

// will apply handbrake even if player has not done so
var bool systemHandbrake;

var const transient int hkVehicleDataPtr; //the HavokVehicleData pointer for this vehicle (stores the couple of Havok ptrs required to interface with the Havok SDK)

struct native HavokCarReplicationState
{
	var vector  Position;
	var quat rotation;
	var vector	LinVel;
	var vector	AngVel;

	var PlayerCharacterController.EDigitalAxisInput digitalThrottleInput;

	var PlayerCharacterController.EDigitalAxisInput digitalStrafeInput;

	var	byte serverSteering[2];

	var bool				ServerBoost;
	var bool				ServerHandbrake;
};

var (HavokVehicle) array<class<Engine.HavokVehicleWheel> > wheelClasses;
var array<class<HavokCarWheel> > havokCarWheelClasses;
var editinline array<Engine.HavokVehicleWheel>	Wheels;

var (HavokVehicle) editinline array<float>						GearRatios; //1 per gear, just add another value to get more gears. Gear ratios (3 == low speed, 0.5 == high speed)

//// PHYSICS ////
var (HavokVehicleGeneral) float		ChassisMass; //kg, 750;
var (HavokVehicleGeneral) float		MaxSpeedFullSteeringAngle; //kph  (130.0f * (1.605f / 3.6f)) by default;
var (HavokVehicleGeneral) float		FrictionEqualizer; //0.5f; 
var (HavokVehicleGeneral) float		TorqueRollFactor; //0.25f; 
var (HavokVehicleGeneral) float		TorquePitchFactor; // 0.5f; 
var (HavokVehicleGeneral) float		TorqueYawFactor; //0.35f; 
var (HavokVehicleGeneral) float		TorqueExtraFactor; //-0.5f; 
var (HavokVehicleGeneral) float		ChassisUnitInertiaYaw; //1.0f; 
var (HavokVehicleGeneral) float		ChassisUnitInertiaRoll; //0.4f; 
var (HavokVehicleGeneral) float		ChassisUnitInertiaPitch; //1.0f; 

	// Engine Performance
var (HavokVehicleEngine) float		EngineTorque; //500.0f;
var (HavokVehicleEngine) float		EngineMinRPM; //1000.0f;
var (HavokVehicleEngine) float		EngineOptRPM; // 5500.0f;
var (HavokVehicleEngine) float		EngineMaxRPM; //7500.0f;
var (HavokVehicleEngine) float		EngineTorqueFactorAtMinRPM; // 0.8f;
var (HavokVehicleEngine) float		EngineTorqueFactorAtMaxRPM; // 0.8f;
var (HavokVehicleEngine) float		EngineResistanceFactorAtMinRPM; // 0.05f;
var (HavokVehicleEngine) float		EngineResistanceFactorAtOptRPM; // 0.1f;
var (HavokVehicleEngine) float		EngineResistanceFactorAtMaxRPM; // 0.3f;
var (HavokVehicleEngine) float		GearDownshiftRPM; //3500.0f;
var (HavokVehicleEngine) float		GearUpshiftRPM; // 6500.0f;
var (HavokVehicleEngine) float		GearClutchDelayTime; //0.0f;
var (HavokVehicleEngine) float		GearReverseRatio; //1.0f;
	
	// Aerodynamics
var (HavokVehicleAerodynamics) float	AerodynamicsAirDensity; // 1.3f
var (HavokVehicleAerodynamics) float	AerodynamicsFrontalArea; // 1 (m^2)
var (HavokVehicleAerodynamics) float	AerodynamicsDragCoeff; //0.7f;
var (HavokVehicleAerodynamics) float	AerodynamicsLiftCoeff; //-0.3f;
var (HavokVehicleAerodynamics) vector	ExtraGravity; // 0,0,-5
var (HavokVehicleAerodynamics) float	SpinDamping; //1.0f; 
var (HavokVehicleAerodynamics) float	CollisionSpinDamping; // 0.0f;
var (HavokVehicleAerodynamics) float	CollisionThreshold; //4.0f; 

var (HavokVehicle) float applyHandbrakeSpeed;
var (HavokVehicle) float occupiedApplyHandbrakeSpeed;

var int leftFrontSkiddingEffectIndex;
var int leftRearSkiddingEffectIndex;
var int rightFrontSkiddingEffectIndex;
var int rightRearSkiddingEffectIndex;

var	HavokCarReplicationState ReplicationCarState;
var	HavokCarReplicationState OldReplicationCarState;

// flags indicating whether or not a particular wheel parameter should be common for all wheels, wheel[0] is the authority
var (HavokVehicle) bool commonWheelMass;
var (HavokVehicle) bool commonWheelFriction;
var (HavokVehicle) bool commonWheelViscosityFriction;
var (HavokVehicle) bool commonSuspensionStrength;
var (HavokVehicle) bool commonSuspensionDampingCompression;
var (HavokVehicle) bool commonSuspensionDampingRelaxation;
var (HavokVehicle) bool commonSuspensionTravel;

var (HavokVehicle) int leftFrontWheelIndex;
var (HavokVehicle) int leftRearWheelIndex;
var (HavokVehicle) int rightFrontWheelIndex; 
var (HavokVehicle) int rightRearWheelIndex;

// skid energy at which skid effect is started
var (HavokVehicle) float skidEffectEnergyThreshold;

replication
{
	unreliable if (Role == ROLE_Authority)
		ReplicationCarState;
}

simulated function PreBeginPlay()
{
	local int index;

	super.PreBeginPlay();

	// initialise havok car wheel classes array
	for (index = 0; index < wheelClasses.length; ++index)
	{
		havokCarWheelClasses[index] = class<HavokCarWheel>(wheelClasses[index]);
	}
}

// Vehicles dont get telefragged.
event EncroachedBy( actor Other )
{
	Log("HavokVehicle("$self$") Encroached By: "$Other$".");
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	// Vehicles ignore 'face rotation'.
}

simulated function initialiseEffects()
{
	super.initialiseEffects();

	addEffect('leftFrontSkidding', true, leftFrontSkiddingEffectIndex);
	addEffect('leftRearSkidding', true, leftRearSkiddingEffectIndex);
	addEffect('rightFrontSkidding', true, rightFrontSkiddingEffectIndex);
	addEffect('rightRearSkidding', true, rightRearSkiddingEffectIndex);
}

simulated function tick(float deltaSeconds)
{
	// apply hand brake if no driver and below threshold speed
	if (Role == ROLE_Authority && positions[driverIndex].occupant == None && VSizeSquared(velocity) < applyHandbrakeSpeed *
			applyHandbrakeSpeed)
		DiveInput = true;

	// apply hand brake if driver, no throttle and below threshold speed
	if (Role == ROLE_Authority && positions[driverIndex].occupant != None && ThrottleInput == 0 &&
			VSizeSquared(velocity) < occupiedApplyHandbrakeSpeed * occupiedApplyHandbrakeSpeed)
		systemHandbrake = true;
	else
		systemHandbrake = false;

	super.tick(deltaSeconds);

	// apply replicated throttle if client
	if (Level.NetMode == NM_Client)
	{
		ThrottleInput = class'PlayerCharacterController'.static.digitalToAnalogue(ReplicationCarState.digitalThrottleInput, 1);
	}

	// apply replicated strafe if client
	if (Level.NetMode == NM_Client)
	{
		StrafeInput = class'PlayerCharacterController'.static.digitalToAnalogue(ReplicationCarState.digitalStrafeInput, 1);
	}

	// apply replicated handbrake to client
	if (Level.NetMode == NM_Client)
	{
		DiveInput = ReplicationCarState.serverHandBrake;
	}

	// apply replicated boost to client
	if (Level.NetMode == NM_Client)
	{
		if (ReplicationCarState.serverBoost)
			ThrustInput = 1;
		else
			ThrustInput = 0;
	}
}

// Do script car model stuff here - in the UpdateVehicle you can change steering and throtle., if you change suspension sparams, number of wheels etc, call Remake
simulated event UpdateVehicle( float DeltaTime );

// Redo the vehicle params.. all of them:
native function RemakeVehicle();

native simulated function havokCarSwitchClass(class<HavokCar> havokCarClass);

// should always be called before havokCarSwitchClass because havokCarSwitchClass actually triggers Havok to update
native simulated function switchWheelClasses(out array<class<HavokCarWheel> > newWheelClasses);

// Do any general vehicle set-up when it gets spawned.
simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

	// Make sure params are up to date? Should be anyway.
	// HavokVehicleHasChanged();
}

// Called when a parameter of the overall articulated actor has changed (like PostEditChange)
simulated event HavokVehicleHasChanged()
{
	RemakeVehicle();
}

///////////////////////////////////////////
/////////////// NETWORKING ////////////////
///////////////////////////////////////////

function bool needToPushStateToClient()
{
	local vector oldPos;
	local vector oldLinVel;
	local vector chassisPos, chassisLinVel, chassisAngVel;
	local HavokRigidBodyState chassisState;

	// see if state has changed enough, or enough time has passed, that we 
	// should send out another update by updating the state struct

	// get chassis state
	HavokGetState(ChassisState);

	chassisPos = ChassisState.Position;
	chassisLinVel = ChassisState.LinVel;
	chassisAngVel = ChassisState.AngVel;

	// last position we sent
	oldPos = ReplicationCarState.Position;
	oldLinVel = ReplicationCarState.LinVel;

	if(VSize(oldPos - chassisPos) > 5 ||
			VSize(oldLinVel - chassisLinVel) > 1)// ||
//		Abs(ReplicationCarState.ServerTorque - OutputTorque) > 0.1))// ||
		//			Abs(ReplicationCarState.ServerSteering - StrafeInput) > 0.1))
	{
		return true;
	}

	return false;
}

// Pack current state of whole car into the state struct, to be sent to the client.
// Should only get called on the server.
function pushStateToClient()
{
	local HavokRigidBodyState ChassisState;

	HavokGetState(ChassisState);

	ReplicationCarState.position = HavokGetCenterOfMass();
	ReplicationCarState.linVel = ChassisState.linVel * HC_LINEAR_VELOCITY_ACCURACY_FACTOR;
	ReplicationCarState.rotation = ChassisState.quaternion;
	ReplicationCarState.angVel = ChassisState.angVel * HC_ANGULAR_VELOCITY_ACCURACY_FACTOR;
	ReplicationCarState.serverSteering[0] = getLowByte(outputCarDirection);
	ReplicationCarState.serverSteering[1] = getHighByte(outputCarDirection);
	ReplicationCarState.digitalThrottleInput = class'PlayerCharacterController'.static.analogueToDigital(throttleInput, 1);
	ReplicationCarState.digitalStrafeInput = class'PlayerCharacterController'.static.analogueToDigital(strafeInput, 1);
	if (systemHandbrake)
		ReplicationCarState.serverHandbrake = true;
	else
		ReplicationCarState.serverHandbrake = diveInput;
	ReplicationCarState.serverBoost = ThrustInput > 0.5;
}

simulated event vehicleStateReceived()
{
	// should never occur on server but just in case
	if (Role == ROLE_Authority)
		return;

	super.vehicleStateReceived();

	//// don't do anything if car isn't started up
	//// ...

	// update control inputs
	outputCarDirection = getAngle(ReplicationCarState.serverSteering[0], ReplicationCarState.serverSteering[1]);

	// throttle and handbrake are applied in tick()

	// update desired state
	currentDesiredHavokState.position = ReplicationCarState.position;
	currentDesiredHavokState.velocity = ReplicationCarState.linVel * HC_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.angularVelocity = ReplicationCarState.angVel * HC_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.rotation = ReplicationCarState.rotation;
	currentDesiredHavokState.newState = true;
}

simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	switch (effectCauserIndex)
	{
	case leftFrontSkiddingEffectIndex:
		return wheelsOutput[leftFrontWheelIndex].skidEnergyDensity > skidEffectEnergyThreshold;
	case leftRearSkiddingEffectIndex:
		return wheelsOutput[leftRearWheelIndex].skidEnergyDensity > skidEffectEnergyThreshold;
	case rightFrontSkiddingEffectIndex:
		return wheelsOutput[rightFrontWheelIndex].skidEnergyDensity > skidEffectEnergyThreshold;
	case rightRearSkiddingEffectIndex:
		return wheelsOutput[rightRearWheelIndex].skidEnergyDensity > skidEffectEnergyThreshold;
	}

	return super.isEffectCauserActive(effectCauserIndex);
}

simulated function updateDynamicEffectStates()
{	
	super.updateDynamicEffectStates();

	// update skidding effects
	updateSkidEffect(leftFrontWheelIndex, leftFrontSkiddingEffectIndex);
	updateSkidEffect(leftRearWheelIndex, leftRearSkiddingEffectIndex);
	updateSkidEffect(rightFrontWheelIndex, rightFrontSkiddingEffectIndex);
	updateSkidEffect(rightRearWheelIndex, rightRearSkiddingEffectIndex);
}

simulated function updateSkidEffect(int wheelIndex, int effectIndex)
{
	local float particlesPerSecondScale;

	if (!effects[effectIndex].flag)
		return;

//	assert(effects[effectIndex].observer.emitter != None);

	// update particle system
	particlesPerSecondScale = clamp((wheelsOutput[wheelIndex].skidEnergyDensity - skidEffectEnergyThreshold) / 50, 0, 10) + 1;
	//effects[effectIndex].observer.emitter.emitters[0].particlesPerSecond = particlesPerSecondScale *
	//		effects[effectIndex].observer.originalParticlesPerSecond;
	//effects[effectIndex].observer.emitter.emitters[0].InitialParticlesPerSecond =
	//		effects[effectIndex].observer.emitter.emitters[0].particlesPerSecond;
	//effects[effectIndex].observer.emitter.emitters[0].allParticlesDead = false;
}

simulated function switchClass(class<Vehicle> switchClass)
{
	local class<HavokCar> havokCarSwitchClassTarget;

	super.switchClass(switchClass);

	// initialise actual switch class
	havokCarSwitchClassTarget = class<HavokCar>(switchClass);
	
	if (havokCarSwitchClassTarget == None)
	{
		warn("bad switch class");
		return;
	}

	// do switch
	havokCarSwitchClass(havokCarSwitchClassTarget);
}

simulated function bool isSettledUpsideDown()
{
	local int wheelsInContact;
	local int wheelI;

	// true if no or one wheel contact and low speed
	if (Physics == PHYS_Havok)
	{
		for (wheelI = 0; wheelI < wheelsOutput.length; ++wheelI)
		{
			if (wheelsOutput[wheelI].groundContact)
			{
				++wheelsInContact;
			}
		}
		if (wheelsInContact < 2 && VSizeSquared(velocity) < (settledUpsideDownSpeed * settledUpsideDownSpeed))
			return true;
	}

	return super.isSettledUpsideDown();
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'Vehicles.Buggy'
    
 	bDrawDriverInTP=false

    Physics=PHYS_Havok
	bEdShouldSnap=True
	bStatic=False
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=False
    bProjTarget=True
	bBlockActors=True
	bBlockNonZeroExtentTraces=True
	bBlockZeroExtentTraces=True
	bBlockPlayers=True
	bWorldGeometry=False
	bBlockKarma=False
	bBlockHavok=True
    CollisionHeight=+000001.000000
	CollisionRadius=+000001.000000
	bAcceptsProjectors=False
	bCanBeBaseForPawns=True
	RemoteRole=ROLE_SimulatedProxy
	bNetInitialRotation=True
	bSpecialCalcView=True
	//bSpecialHUD=true
	
	// Chassis
	ChassisMass=750 //kg, 750;
	SteeringMaxAngle=4000 // hkMath::HK_REAL_PI / 10.0f or so;
	MaxSpeedFullSteeringAngle=70 //kph  (130.0f * (1.605f / 3.6f)) by default in a lot of Havok demos;
	FrictionEqualizer=0.5
	TorqueRollFactor=0.25
	TorquePitchFactor=0.5
	TorqueYawFactor=0.35 
	TorqueExtraFactor=-0.5
	ChassisUnitInertiaYaw=1.0
	ChassisUnitInertiaRoll=0.4
	ChassisUnitInertiaPitch=1.0

	// Engine Performance
	EngineTorque=500
	EngineMinRPM=1000
	EngineOptRPM=5500
	EngineMaxRPM=7500
	EngineTorqueFactorAtMinRPM=0.8
	EngineTorqueFactorAtMaxRPM=0.8
	EngineResistanceFactorAtMinRPM=0.05
	EngineResistanceFactorAtOptRPM=0.1
	EngineResistanceFactorAtMaxRPM=0.3
	GearDownshiftRPM=3500
	GearUpshiftRPM=6500
	GearClutchDelayTime=0
	GearReverseRatio=1
	TopSpeed=6500
	
	// Aerodynamics
	AerodynamicsAirDensity=1.3
	AerodynamicsFrontalArea=1
	AerodynamicsDragCoeff=0.7
	AerodynamicsLiftCoeff=-0.3
	ExtraGravity=(X=0,Y=0,Z=-5)
	SpinDamping=1
	CollisionSpinDamping=0
	CollisionThreshold=4
	
	// At least one gear, straight ratio of 1 
	GearRatios(0)=1
	
	Texture=Texture'Engine_res.Havok.S_HkVehicle'
	
	HavokDataClass=class'BuggyHavokData'

	ReplicationCarState=(digitalThrottleInput=DAI_Zero)

	applyHandbrakeSpeed = 200
	occupiedApplyHandbrakeSpeed = 500

	commonWheelMass = true
	commonWheelFriction = true
	commonWheelViscosityFriction = true
	commonSuspensionStrength = true
	commonSuspensionDampingCompression = true
	commonSuspensionDampingRelaxation = true
	commonSuspensionTravel = true

	leftFrontWheelIndex = 0
	leftRearWheelIndex = 2
	rightFrontWheelIndex = 1 
	rightRearWheelIndex = 3

	skidEffectEnergyThreshold = 25

	clientInterpolationHard = true
}