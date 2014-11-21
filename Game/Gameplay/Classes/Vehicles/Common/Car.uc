// Car

// Base Tribes 4-wheeled vehicle class. Effectively a copy past of KCar.
class Car extends Vehicle
	native
    abstract
	notplaceable;

var (Car) float StopThreshold; // forward velocity under which brakes become drive

var (Car) float upsideDownDamagePerSecond;

// moved this up from HavokCar because it is used in processInput
var (HavokVehicleGeneral) float	SteeringMaxAngle;  // unreal units

var (Car) float strafeSteerAngleOffset;

var int Gear; // 1 is forward, -1 is backward, currently symmetric power/torque curve

// effect states
var bool effectDeccelerating;
var bool effectAccelerating;

var int outputCarDirection;

var float carSteer;

////////// NAVIGATION //////////

var float stopSteeringSize;
var float stopVelocitySize;
var float driveThrottleCoefficient;
var float maximumYawChange;
var float minimumNavigationThrottle;

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

	// initially make sure parameters are sync'ed with Karma
	VehicleUpdateParams();
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	// do upside down damage processing

	// The PHYS_None check prevents this code from running after the game ends.

	if (Level.NetMode != NM_Client && bSettledUpsideDown && Physics != PHYS_None)
	{
		TakeDamage(deltaSeconds * upsideDownDamagePerSecond, self, Location, vect(0,0,0), class'DamageType');
	}
}

function ProcessInput()
{
	super.processInput();

	// steering
	outputCarDirection = Normalize(rotationInput).yaw;
	if (outputCarDirection < 0)
		outputCarDirection += 65536;
}

simulated function updateGear()
{
	local float ForwardVel; 
	local bool bIsInverted;

	local vector worldForward, worldUp;

	worldForward = vect(1, 0, 0) >> Rotation;
	worldUp = vect(0, 0, 1) >> Rotation;

	ForwardVel = Velocity Dot worldForward;

	bIsInverted = worldUp.Z < 0.2;

	// 'ForwardVel' isn't very helpful if we are inverted, so we just pretend its positive.
	if (bIsInverted)
		ForwardVel = 2 * StopThreshold;

	if (clientPositions[driverIndex].occupant == None)
	{
		Gear = 0;
	}
	else
	{
		if (ThrottleInput > 0.01) // pressing forwards
		{
			if (ForwardVel < -StopThreshold && Gear != 1) // going backwards - so brake first
			{
				if (effectAccelerating)
				{
					UnTriggerEffectEvent('CarAccelerating');
					effectAccelerating = false;
				}
				if (!effectDeccelerating)
				{
					TriggerEffectEvent('CarDeccelerating');
					effectDeccelerating = true;
				}

				Gear = 0;
			}
			else // stopped or going forwards, so drive
			{
				if (effectDeccelerating)
				{
					UnTriggerEffectEvent('CarDeccelerating');
					effectDeccelerating = false;
				}
				if (!effectAccelerating)
				{
					TriggerEffectEvent('CarAccelerating');
					effectAccelerating = true;
				}

				Gear = 1;
			}
		}
		else if (ThrottleInput < -0.01) // pressing backwards
		{
			if (ForwardVel < StopThreshold) // start going backwards
			{
				if (effectDeccelerating)
				{
					UnTriggerEffectEvent('CarDeccelerating');
					effectDeccelerating = false;
				}
				if (!effectAccelerating)
				{
					TriggerEffectEvent('CarAccelerating');
					effectAccelerating = true;
				}

				Gear = -1;
			}
			else // otherwise, we are going forwards, or still holding brake, so just brake
			{
				if (effectAccelerating)
				{
					UnTriggerEffectEvent('CarAccelerating');
					effectAccelerating = false;
				}
				if (!effectDeccelerating)
				{
					TriggerEffectEvent('CarDeccelerating');
					effectDeccelerating = true;
				}

				Gear = 0;
			}
		}
		else // not pressing either
		{
			// do nothing
		}
	}
}

simulated function applyOutput()
{
	local rotator steeringDirection;
	local vector inputDirection;
	local vector carDirection;

	local vector workVector;
	local rotator workRotator;

	local float steerAngle;

	updateGear();

	// steering
	steeringDirection.yaw = outputCarDirection;

	// ... user input direction
	inputDirection = vect(1,0,0) >> steeringDirection;
	inputDirection.Z = 0;
	inputDirection = Normal(inputDirection);

	// ... apply strafe offset
	if (StrafeInput != 0)
	{
		workRotator.Pitch = 0;
		workRotator.Roll = 0;
		if (StrafeInput > 0)
			workRotator.Yaw = -strafeSteerAngleOffset;
		else if (StrafeInput < 0)
			workRotator.Yaw = strafeSteerAngleOffset;
		inputDirection = inputDirection >> workRotator;
	}

	// ... current car direction
	carDirection = vect(1,0,0) >> rotation;
	carDirection.Z = 0;
	carDirection = Normal(carDirection);

	// ... desired steer angle
	steerAngle = acos(inputDirection dot carDirection);
	steerAngle *= 65536 / (2 * PI);
	steerAngle = clamp(steerAngle, 0, SteeringMaxAngle);
	workVector = inputDirection cross carDirection;
	if (workVector.Z < 0)
		steerAngle *= -1;
	if (gear == -1)
		steerAngle *= -1;

	steerAngle = clamp(steerAngle, -SteeringMaxAngle, SteeringMaxAngle);

	if (positions[driverIndex].occupant == None)
	{
		steerAngle = 0;
	}

	// ... actual car steer value
	carSteer = steerAngle / SteeringMaxAngle;
}

// Clean up wheels etc.
simulated event Destroyed()
{
	UnTriggerEffectEvent('CarAccelerating');
	UnTriggerEffectEvent('CarDeccelerating');

	Super.Destroyed();
}

defaultproperties
{
	Gear=1

//	WheelVert=-0.5

	StopThreshold=100

	effectDeccelerating=false
	effectAccelerating=false

	stopSteeringSize=50
	stopVelocitySize=50
	driveThrottleCoefficient=0.09
	driveYawCoefficient=0.05
	maximumYawChange=450

	SteeringMaxAngle = 20000

	upsideDownDamagePerSecond = 100

	strafeSteerAngleOffset = 8192

	minimumNavigationThrottle = -1
}