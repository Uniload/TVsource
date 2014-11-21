class anticsCharacterController extends Gameplay.PlayerCharacterController;

var bool LogCheater; // Determines whether or not to log the cheater.
var Rotator PreviousRotation; // Previous rotation of the client.
var bool StateBuffer; // Blocks violations between state switches.
var float StateBufferLength; // Length of the state buffer (in seconds).
var int ViolationCount; // Number of violations incurred.

replication
{
	reliable if (Role < ROLE_Authority)
		UpdateViolationCount;
}

simulated state CharacterMovement
{
	function PlayerMove(float DeltaTime)
	{
		local vector x,y,z;
		local Rotator ViewRotation;
		local float incYaw, incPitch;
		local float jump, ski, thrust;

		// Had problem where client would not change to PlayerUsingInventoryStation when using Buggy. They would occasionally be in the
		// Buggy (PHYS_None) yet still be in this state. By adding the following code the server shall send down state updates meaning
		// that the client is guaranteed to eventually go to PlayerUsingInventoryStation.
		if (character.Physics == PHYS_None && Role < ROLE_Authority)
			TribesStateServerMove(Level.TimeSeconds);

		if (character == None || character.Physics != PHYS_Movement)
			return;

		// freeze player during cutscenes
		if (isInCutscene())
		{
			releaseFire();
			TribesProcessMove(0, 0, 0, 0, 0);
			return;
		}

		GetAxes(Rotation,x,y,z);

		Pawn.CheckBob(DeltaTime, y);

		ViewRotation = character.motor.getViewRotation();
		
		// Verify the rotation.
		VerifyRotation(ViewRotation);
		
		incYaw = 32.0 * DeltaTime * aTurn;
		incPitch = 32.0 * DeltaTime * aLookUp;
		if (character.isZoomed())
		{
			incYaw *= zoomedMouseScale[zoomLevel];
			incPitch *= zoomedMouseScale[zoomLevel];
		}

		ViewRotation.Yaw += incYaw;
		ViewRotation.Pitch += incPitch;

		character.motor.setMoveRotation(ViewRotation);
		character.motor.setViewRotation(ViewRotation);
		
		// Set the previous rotation.
		PreviousRotation = character.motor.getViewRotation();

		// zoom
		if (character.motor != None)
			character.motor.setZoomed(bZoom != 0);

		if (Role < ROLE_Authority)
		{
			TribesReplicateMove(aForward / 24000, aStrafe / 24000, bSki == 1 && character != None && !character.bDisableSkiing,
					bJetpack == 1 && character != None && !character.bDisableJetting, bJump == 1);
		}
		else
		{
			if (bJump>0)
    			jump = 1.0;
	   		else
			    jump = 0.0;
	
			if (bSki>0 && character != None && !character.bDisableSkiing)
				ski = 1.0;
			else
				ski = 0.0;

			if (bJetpack>0 && character != None && !character.bDisableJetting)
				thrust = 1.0;
			else
				thrust = 0.0;

			TribesProcessMove(aForward / 24000, aStrafe / 24000, jump, ski, thrust);
		}
	}
	
	function BeginState()
	{
		Super.BeginState();
		ResetStateBuffer();
	}
}

state PlayerTurreting
{
	function processTurretMove(float DeltaTime, float turn, float lookup)
	{
		local Turret Turret;
		local Rotator newRot;

		Turret = Turret(Pawn);
		if (Turret == None)
			return;

		newRot = turret.motor.getViewRotation();
		
		// Verify the rotation.
		VerifyRotation(newRot);

		newRot.Yaw += turn * DeltaTime;
		newRot.Pitch += lookUp * DeltaTime;

		turret.motor.setViewTarget(newRot);
		
		// Set the previous rotation.
		PreviousRotation = turret.motor.getViewTarget();

		turret.updateAim(DeltaTime);
	}
	
	function BeginState()
	{
		Super.BeginState();
		ResetStateBuffer();
	}
}

state PlayerVehicleTurreting
{
	function PlayerMove(float deltaTime)
	{
		local rotator moveRotation;
		local VehicleMountedTurret turret;
		local DynamicTurretRotationProcessingOutput output;
		local float zoomScale;

		turret = VehicleMountedTurret(Pawn);
		if (turret == None)
			return;

		// use turret rotation as base rotation
		moveRotation = turret.worldSpaceNoRollRotation;

		// zoom
		if (turret.getDriver() != None)
			turret.getDriver().setZoomed(bZoom != 0);
		
		zoomScale = 1;
		if (bZoom != 0)
			zoomScale = zoomedMouseScale[zoomLevel];
			
		// Verify the rotation.
		VerifyRotation(moveRotation);

		// apply user input (copy pasted from PlayerController.UpdateRotation)
		moveRotation.Yaw += 32.0 * deltaTime * aTurn * zoomScale;
		moveRotation.Pitch += 32.0 * deltaTime * aLookUp * zoomScale;

		output = dynamicTurretRotationProcessing(moveRotation, turret.ownerVehicle.Rotation, turret.minimumPitch, turret.maximumPitch,
				turret.yawConstrained, turret.yawPositiveDirection, turret.yawStart, turret.yawRange);
		turret.worldSpaceNoRollRotation = output.worldSpaceNoRollRotation;
		turret.vehicleSpaceRotation = output.vehicleSpaceRotation;

		setRotation(turret.worldSpaceNoRollRotation);
		
		// Set the previous rotation.
		PreviousRotation = turret.worldSpaceNoRollRotation;

		// forward to result server
		if (Role < ROLE_Authority)
		{
			serverVehicleTurretMove(class'Vehicle'.static.packPitchAndYaw(turret.worldSpaceNoRollRotation),
					class'Vehicle'.static.packPitchAndYaw(turret.vehicleSpaceRotation));
		}
	}
	
	function BeginState()
	{
		Super.BeginState();
		ResetStateBuffer();
	}
}

state TribesPlayerDriving
{
	function PlayerMove( float DeltaTime )
	{
		local Vehicle drivenVehicle;
		local float zoomScale;
		local rotator newRotation;

		drivenVehicle = Vehicle(Pawn);

		if (drivenVehicle == None)
			return;

		// zoom
		if (drivenVehicle.getDriver() != None)
			drivenVehicle.getDriver().setZoomed(bZoom != 0);

		zoomScale = 1;
		if (bZoom != 0)
			zoomScale = zoomedMouseScale[zoomLevel];

		newRotation = Rotation;
		
		// Verify the rotation.
		VerifyRotation(newRotation);

		// apply user input (copy pasted from PlayerController.UpdateRotation)
		newRotation.Yaw += 32.0 * deltaTime * aTurn * zoomScale;
		newRotation.Pitch += 32.0 * deltaTime * aLookUp * zoomScale;

		newRotation = normalize(newRotation);
		newRotation.Pitch = clamp(newRotation.Pitch, drivenVehicle.driverMinimumPitch, drivenVehicle.driverMaximumPitch);

		setRotation(newRotation);
		
		// Set the previous rotation.
		PreviousRotation = newRotation;

		// give vehicle a chance to do any necessary processing
		drivenVehicle.playerMoveProcessing(DeltaTime);

		// only servers can actually do the driving logic
		if (Role < ROLE_Authority)
			tribesServerDrive(analogueToDigital(aForward, 24000), analogueToDigital(aStrafe, 24000), class'Vehicle'.static.packPitchAndYaw(Rotation), bJetpack == 1, bSki == 1);
		else
			tribesProcessDrive(aForward, aStrafe, Rotation, bJetpack == 1, bSki == 1);
	}
	
	function BeginState()
	{
		Super.BeginState();
		ResetStateBuffer();
	}
}

// Verifies the view rotation.
function VerifyRotation(Rotator ViewRotation)
{	
	// First, make sure the state buffer is not in effect.
	// Then, check to see if view rotation is equal to the previous rotation.
	// If not, a violation has occurred.
	if(!StateBuffer && ViewRotation != PreviousRotation)
	{
		UpdateViolationCount(PlayerReplicationInfo.PlayerName, ViolationCount++);
		log("Client violation #" $ ViolationCount @ "detected in state '" $ GetStateName() $ "'!", 'antics');
	}
}

// Resets the state buffer.
function ResetStateBuffer()
{
	StateBuffer = true;
	SetTimer(StateBufferLength, false);
}

function Timer()
{
	StateBuffer = false;
}

// Updates the client's violation count on the server.
function UpdateViolationCount(string playerName, int violationCount)
{
	local Controller C;
	
	for(C = Level.ControllerList; C != None; C = C.NextController)
	{		
		if(C.PlayerReplicationInfo.PlayerName == playerName)
		{
			anticsCharacterController(C).ViolationCount = violationCount;
			break;
		}
	}
}

defaultproperties
{
     LogCheater=True
     StateBuffer=True
     StateBufferLength=1.000000
     radarZoomScales(0)=0.100000
     radarZoomScales(1)=0.350000
     radarZoomScales(2)=0.950000
     zoomedFOVs(0)=50.000000
     zoomedFOVs(1)=23.000000
     zoomedFOVs(2)=8.000000
     zoomedMouseScale(0)=0.750000
     zoomedMouseScale(1)=0.400000
     zoomedMouseScale(2)=0.100000
     zoomMagnificationLevels(0)=2.000000
     zoomMagnificationLevels(1)=4.000000
     zoomMagnificationLevels(2)=10.000000
     ChatWindowSizes(0)=4
     ChatWindowSizes(1)=6
     ChatWindowSizes(2)=12
     SPChatWindowSizes(0)=6
}
