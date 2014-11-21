class TreadVehicle extends Car
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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

const TV_LINEAR_VELOCITY_ACCURACY_FACTOR = 100;
const TV_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 0.01;

const TV_ANGULAR_VELOCITY_ACCURACY_FACTOR = 1;
const TV_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR = 1;

struct native TreadVehicleReplicationState
{
	var vector Position;
	var quat rotation;
	var vector LinVel;
	var vector AngVel;

	var PlayerCharacterController.EDigitalAxisInput digitalThrottleInput;

	var PlayerCharacterController.EDigitalAxisInput digitalStrafeInput;

	var	byte ServerSteering[2];

	// need to put this here even though it is a Tank specific concept
	var bool ServerGripping;

	var bool softThrottleSteering;
};

var	TreadVehicleReplicationState replicationTreadVehicleState;
var TreadVehicleReplicationState oldReplicationTreadVehicleState;

// tread properties
var (TreadVehicle) vector treadPositionOffset;
var (TreadVehicle) float treadRadius;
var (TreadVehicle) float treadLength;

// tread engine properties
var (TreadVehicle) float throttleToVelocityFactor;
var (TreadVehicle) float throttleSteerToVelocityScaleFactor;
var (TreadVehicle) float steerToVelocityFactor;
var (TreadVehicle) float treadGainFactor;
var (TreadVehicle) float treadGainFactorStopping;
var (TreadVehicle) float maximumTreadVelocityDelta;

var int leftTreadChannel;
var (TreadVehicle) name leftForwardTreadAnimation;
var (TreadVehicle) name leftReverseTreadAnimation;
var int rightTreadChannel;
var (TreadVehicle) name rightForwardTreadAnimation;
var (TreadVehicle) name rightReverseTreadAnimation;

var float leftTreadSpinSpeed;
var float rightTreadSpinSpeed;
var (TreadVehicle) float spinSpeedToAnimationRate;
var (TreadVehicle) float animationRateToTexturePanRate;

var (TreadVehicle) float forceApplicationHeightOffset;

var (TreadVehicle) float lowFriction;

var (TreadVehicle) float treadVehicleGravityScale;

var Shader leftTreadShader;
var TexMatrix leftTreadTexPanner;
var() int leftTreadMaterialIndex;

var Shader rightTreadShader;
var TexMatrix rightTreadTexPanner;
var() int rightTreadMaterialIndex;

var bool softThrottleSteering;
var float switchOffSoftThrottleSteeringTime;
var (TreadVehicle) float softThrottleSteeringScale;
var (TreadVehicle) float softThrottleSteeringStayOnPeriod;

var (TreadVehicle) float centreOfMassHeightOffset;

var bool leftTreadContact;
var bool rightTreadContact;

var transient noexport private const int treadVehiclePadding[1];

replication
{
	unreliable if (Role == ROLE_Authority)
		replicationTreadVehicleState;
}

function processInput()
{
	super.processInput();

	// soft throttle steering processing
	if (abs(strafeInput) > 0.001)
		switchOffSoftThrottleSteeringTime = Level.TimeSeconds + softThrottleSteeringStayOnPeriod;
	softThrottleSteering = Level.TimeSeconds < switchOffSoftThrottleSteeringTime;
}

simulated event PostNetBeginPlay()
{
	local Matrix identity;

	Super.PostNetBeginPlay();

	// build controllable skins

	identity.XPlane.X = 1;
	identity.XPlane.Y = 0;
	identity.XPlane.Z = 0;
	identity.XPlane.W = 0;

	identity.YPlane.X = 0;
	identity.YPlane.Y = 1;
	identity.YPlane.Z = 0;
	identity.YPlane.W = 0;

	identity.ZPlane.X = 0;
	identity.ZPlane.Y = 0;
	identity.ZPlane.Z = 1;
	identity.ZPlane.W = 0;

	identity.WPlane.X = 0;
	identity.WPlane.Y = 0;
	identity.WPlane.Z = 0;
	identity.WPlane.W = 1;

	// ... left tread
	leftTreadShader = Shader(ShallowCopyMaterial(GetMaterial(leftTreadMaterialIndex), self));
	if (leftTreadShader != None)
	{
		leftTreadTexPanner = new class'TexMatrix';

		leftTreadTexPanner.Material = TexPanner(leftTreadShader.diffuse).Material;
		leftTreadTexPanner.matrix = identity;

		leftTreadShader.Diffuse = leftTreadTexPanner;
		leftTreadShader.SpecularityMask = leftTreadTexPanner;
		leftTreadShader.NormalMap = leftTreadTexPanner;

		Skins[leftTreadMaterialIndex] = leftTreadShader;
	}

	// ... right tread
	rightTreadShader = Shader(ShallowCopyMaterial(GetMaterial(rightTreadMaterialIndex), self));
	if (rightTreadShader != None)
	{
		rightTreadTexPanner = new class'TexMatrix';

		rightTreadTexPanner.Material = TexPanner(rightTreadShader.diffuse).Material;
		rightTreadTexPanner.matrix = identity;

		rightTreadShader.Diffuse = rightTreadTexPanner;
		rightTreadShader.SpecularityMask = rightTreadTexPanner;
		rightTreadShader.NormalMap = rightTreadTexPanner;

		Skins[rightTreadMaterialIndex] = rightTreadShader;
	}
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	// apply replicated throttle if client
	if (Level.NetMode == NM_Client)
	{
		ThrottleInput = class'PlayerCharacterController'.static.digitalToAnalogue(replicationTreadVehicleState.digitalThrottleInput, 1);
	}

	// apply replicated strafe if client
	if (Level.NetMode == NM_Client)
	{
		strafeInput = class'PlayerCharacterController'.static.digitalToAnalogue(replicationTreadVehicleState.digitalStrafeInput, 1);
	}

	// apply replicated gripping to client
	if (Level.NetMode == NM_Client)
	{
		if (replicationTreadVehicleState.serverGripping)
			DiveInput = true;
		else
			DiveInput = false;
	}
}

function bool needToPushStateToClient()
{
	local vector oldPosition;
	local vector oldLinearVelocity;
	local vector treadVehiclePosition, treadVehicleVelocity, treadVehicleAngularVelocity;
	local HavokRigidBodyState treadVehicleState;

	// get chassis state
	HavokGetState(treadVehicleState);

	treadVehiclePosition = treadVehicleState.Position;
	treadVehicleVelocity = treadVehicleState.LinVel;
	treadVehicleAngularVelocity = treadVehicleState.AngVel;

	// last position we sent
	oldPosition = replicationTreadVehicleState.Position;
	oldLinearVelocity = replicationTreadVehicleState.LinVel;

	if (VSize(oldPosition - treadVehiclePosition) > 5 || VSize(oldLinearVelocity - treadVehicleVelocity) > 1)
		return true;

	return false;
}

// Pack current state of whole car into the state struct, to be sent to the client.
// Should only get called on the server.
function pushStateToClient()
{
	local HavokRigidBodyState treadVehicleState;

	HavokGetState(treadVehicleState);

	replicationTreadVehicleState.position = HavokGetCenterOfMass();
	replicationTreadVehicleState.linVel = treadVehicleState.linVel * TV_LINEAR_VELOCITY_ACCURACY_FACTOR;
	replicationTreadVehicleState.rotation = treadVehicleState.quaternion;
	replicationTreadVehicleState.angVel = treadVehicleState.angVel * TV_ANGULAR_VELOCITY_ACCURACY_FACTOR;
	replicationTreadVehicleState.serverSteering[0] = getLowByte(outputCarDirection);
	replicationTreadVehicleState.serverSteering[1] = getHighByte(outputCarDirection);
	replicationTreadVehicleState.digitalThrottleInput = class'PlayerCharacterController'.static.analogueToDigital(throttleInput, 1);
	replicationTreadVehicleState.digitalStrafeInput = class'PlayerCharacterController'.static.analogueToDigital(strafeInput, 1);
	replicationTreadVehicleState.serverGripping = DiveInput;
	replicationTreadVehicleState.softThrottleSteering = softThrottleSteering;
}

simulated event vehicleStateReceived()
{
	// should never occur on server but just in case
	if (Role == ROLE_Authority)
		return;

	super.vehicleStateReceived();

	// update control inputs
	outputCarDirection = getAngle(replicationTreadVehicleState.serverSteering[0], replicationTreadVehicleState.serverSteering[1]);

	// throttle and handbrake are applied in tick()

	// update desired state
	currentDesiredHavokState.position = replicationTreadVehicleState.position;
	currentDesiredHavokState.velocity = replicationTreadVehicleState.linVel * TV_LINEAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.angularVelocity = replicationTreadVehicleState.angVel * TV_ANGULAR_VELOCITY_INVERSE_ACCURACY_FACTOR;
	currentDesiredHavokState.rotation = replicationTreadVehicleState.rotation;
	currentDesiredHavokState.newState = true;
}

cpptext
{
	virtual void PostBeginPlay();

	virtual void TickAuthoritative(float deltaSeonds);

	virtual bool HavokInitActor();
	void HavokPreStepCallback(FLOAT DeltaTime);
	virtual void HavokQuitActor();

	void initialiseTreads();

	virtual class hkShape* shapeProcessing(class hkShape* shape);

	void doTreadAnimationProcessing(float spinSpeed, const FName& forwardAnimation, const FName& reverseAnimation, int channel);

	virtual void PostEditChange();

	virtual bool groundContact();

	virtual UBOOL shouldPlayHavokHitFX(struct hkContactPointAddedEvent& event);

	bool isHavokInitialised();

	void PostNetReceive();

	class HkTreadCollisionListener* m_treadController;

}


defaultproperties
{
     treadPositionOffset=(X=-200.000000,Y=200.000000,Z=60.000000)
     treadRadius=100.000000
     treadLength=400.000000
     throttleToVelocityFactor=6.000000
     throttleSteerToVelocityScaleFactor=1.500000
     steerToVelocityFactor=4.000000
     treadGainFactor=0.050000
     treadGainFactorStopping=0.300000
     maximumTreadVelocityDelta=0.300000
     leftTreadChannel=1
     leftForwardTreadAnimation="leftforward"
     leftReverseTreadAnimation="leftbackward"
     rightTreadChannel=3
     rightForwardTreadAnimation="rightforward"
     rightReverseTreadAnimation="rightbackward"
     spinSpeedToAnimationRate=0.150000
     animationRateToTexturePanRate=3.100000
     forceApplicationHeightOffset=-100.000000
     lowFriction=0.001000
     treadVehicleGravityScale=8.000000
     leftTreadMaterialIndex=3
     rightTreadMaterialIndex=2
     softThrottleSteeringScale=0.750000
     softThrottleSteeringStayOnPeriod=0.750000
     centreOfMassHeightOffset=-100.000000
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     clientInterpolationPeriod=0.125000
}
