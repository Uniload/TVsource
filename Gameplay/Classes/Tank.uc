class Tank extends TreadVehicle
	placeable
	native;

const DRIVER_INDEX = 0;
const GUNNER_INDEX = 1;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var vector cannonOffset;
var vector turretOffset;

var rotator cannonWorldSpaceNoRollRotation;
var rotator cannonVehicleSpaceRotation;

var (Tank) float cannonMinimumPitch;
var (Tank) float cannonMaximumPitch;

var float boostAvailableTime;
var (Tank) float timeBetweenBoosts;
var (Tank) float boostAngle;
var (Tank) float boostStrength;
var (Tank) float boostUpStrength;
var (Tank) float boostUpDuration;
var bool boostInProgress;
var float boostSecondStageTime;

var VehicleMountedTurret turret;
var class<VehicleMountedTurret> turretClass;
var name turretBone;

var (Tank) vector gunnerCameraOffset;
var (Tank) vector gunnerWeaponOffset;
var (Tank) class<Weapon> gunnerWeaponClass;
var (Tank) float gunnerMaximumPitch;
var (Tank) float gunnerMinimumPitch;
var (Tank) float gunnerClientTurnRate;
var (Tank) float gunnerAITurnRate;

var (Tank) float cannonAITurnRate;
var (Tank) float cannonClientTurnRate;

var rotator cannonTargetRotation;
var rotator cannonDisplayVehicleSpaceRotation;

var bool localBoostEventSignal;
var bool boostEventSignal;

var const bool gripping;

var bool bCanHitTarget;

var rotator currentViewRotation;

var int boostChannel;
var float boostOpenAnimationLength;
var bool openAnimationPlayed;
var bool closeAnimationPlayed;
var float boostCloseTime;
var (Tank) float boostEffectDuration;

var int gripAnimationChannel;
var name gripAnimation;
var (Tank) float gripAnimationBlendTime;

var (Tank) float landingEffectAirTime;
var int landingChannel;

var float lastTreadContactTime;

var int throttleForwardAndGroundContactIndex;

replication
{
	reliable if (!bNetOwner && Role == ROLE_Authority)
		cannonVehicleSpaceRotation;

	reliable if (Role == ROLE_Authority)
		boostEventSignal;
}

simulated native function setGripping(bool grippingEnabled);

simulated function initialiseEffects()
{
	super.initialiseEffects();

	addEffect('throttleForwardAndGroundContact', false, throttleForwardAndGroundContactIndex);
}

simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	switch (effectCauserIndex)
	{
	case throttleForwardAndGroundContactIndex:
		return (ThrottleInput > 0) && (leftTreadContact || rightTreadContact);
	}

	return super.isEffectCauserActive(effectCauserIndex);
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	turretOffset = getBoneCoords('tankTurret', true).origin - Location;
	turretOffset = turretOffset << Rotation;
	cannonOffset = getBoneCoords('cannon', true).origin - Location - turretOffset;

	// initialise vehicle position data

	// ... gunner
	if (Level.NetMode != NM_Client)
	{
		// ... turret
		turret = spawn(turretClass, self, , getBoneCoords(turretBone, true).origin, rotation);
		assert(turret != None);
		turret.SetBase(self);
		turret.setTeam(team());
		positions[GUNNER_INDEX].toBePossessed = turret;
		turret.initialise(gunnerWeaponClass, turretBone, gunnerMaximumPitch, gunnerMinimumPitch, false, 0, 0, true, gunnerClientTurnRate,
				gunnerAITurnRate);
	}
	positions[GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;

	// init AI
	initGunnerAI( GUNNER_INDEX );

	// setup boost animation channel
	AnimBlendParams(2, 1);

	boostOpenAnimationLength = GetAnimLength('jetopen');
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	// handle the boost effect
	if (boostEventSignal != localBoostEventSignal)
	{
		TriggerEffectEvent('TankBoost');
		localBoostEventSignal = boostEventSignal;
		boostAvailableTime = Level.TimeSeconds + timeBetweenBoosts;
		boostCloseTime = Level.TimeSeconds + boostEffectDuration;
		closeAnimationPlayed = false;
	}
}

simulated function Material getTeamSkin()
{
	if (m_team != None)
		return m_team.tankSkin;

	return None;
}

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = self;
	boneName = 'cannon';
}

function vector getProjectileSpawnLocation()
{
	local vector workLocation;
	local rotator workRotation;

	// cannot simply do a getBoneCoords here becuase this code will needs to run on dedicated server
	workLocation = driverWeapon.projectileSpawnOffset;
	workRotation = cannonDisplayVehicleSpaceRotation;
	workRotation.Yaw = 0;
	workLocation = (workLocation >> workRotation);
	workLocation += cannonOffset;
	workRotation = cannonDisplayVehicleSpaceRotation;
	workRotation.Pitch = 0;
	workLocation = (workLocation >> workRotation);
	workLocation += turretOffset;
	workLocation = (workLocation >> Rotation);
	workLocation += Location;
	return workLocation;
}

simulated function applyOutput()
{
	local vector boostImpulse;

	super.applyOutput();

	// boost processing
	if (Role == ROLE_Authority && Level.TimeSeconds > boostAvailableTime && ThrustInput > 0.5)
	{
		// apply first stage
		boostImpulse = vect(0, 0, 1);
		boostImpulse *= boostUpStrength;
		HavokImpartCOMImpulse(boostImpulse);

		boostCloseTime = Level.TimeSeconds + boostEffectDuration;
		closeAnimationPlayed = false;

		// update boost available time
		boostAvailableTime = Level.TimeSeconds + timeBetweenBoosts;

		boostSecondStageTime = Level.TimeSeconds + boostUpDuration;
		boostInProgress = true;

		// effect processing
		boostEventSignal = !boostEventSignal;
		TriggerEffectEvent('TankBoost');
	}
}

simulated function playerMoveProcessing(float deltaTime)
{
	super.playerMoveProcessing(deltaTime);
}

simulated function rotator getViewRotation()
{
	// AI case
	if (controller != None && !controller.bIsPlayer)
		return QuatToRotator(QuatProduct(QuatFromRotator(cannonDisplayVehicleSpaceRotation), QuatFromRotator(rotation)));

	return currentViewRotation;
}

function setViewRotation(Rotator r)
{
	cannonTargetRotation = r;
}

simulated function tick(float deltaSeconds)
{
	local rotator workRotation;
	local PlayerCharacterController playerController;
	local PlayerCharacterController.DynamicTurretRotationProcessingOutput output;
	local vector boostImpulse;

	super.tick(deltaSeconds);

	// In the following code the player driving the tank uses his rotation which may not be the exact same rotation the server currently
	// has. Is the reduced latency offered by the technique a overcome the inaccuracy introduced?

	// if we are the server or the player controlling the tank update the cannon rotation based on the controller rotation
	playerController = PlayerCharacterController(controller);
	if ((driverWeapon != None) &&
			// player case
			((playerController != None) && ((Level.GetLocalPlayerController() == playerController) || (ROLE >= ROLE_Authority))) ||
			// ai case
			((controller != None) && (!controller.bIsPlayer))
			)
	{
		if (controller.bIsPlayer)
			currentViewRotation = playerController.Rotation;
		else
			currentViewRotation = cannonTargetRotation;

		// position turret based on raw rotation
		output = class'PlayerCharacterController'.static.dynamicTurretRotationProcessing(currentViewRotation,
				Rotation, cannonMinimumPitch, cannonMaximumPitch, false);
		cannonWorldSpaceNoRollRotation = output.worldSpaceNoRollRotation;
		cannonVehicleSpaceRotation = output.vehicleSpaceRotation;

		// aim adjust rotation
		if (controller.bIsPlayer)
		{
			currentViewRotation = getAimAdjustedViewRotation(playerController, getProjectileSpawnLocation(), driverIndex);
			output = class'PlayerCharacterController'.static.dynamicTurretRotationProcessing(currentViewRotation,
					Rotation, cannonMinimumPitch, cannonMaximumPitch, false);

			// if we are constrained do not aim adjust the rotation
			if (currentViewRotation != output.worldSpaceNoRollRotation)
			{
				bCanHitTarget = false;
				currentViewRotation = cannonWorldSpaceNoRollRotation;
			}
			else
			{
				bCanHitTarget = true;
			}
		}
	}

	// update cannon display rotation
	if ((playerController != None) && ((Level.GetLocalPlayerController() == playerController) || (ROLE >= ROLE_Authority)))
	{
		// authoritative player case
		cannonDisplayVehicleSpaceRotation = cannonVehicleSpaceRotation;
	}
	else if (controller != None && !controller.bIsPlayer)
	{
		// ai case
		cannonDisplayVehicleSpaceRotation = interpolateRotation(cannonDisplayVehicleSpaceRotation, cannonVehicleSpaceRotation,
				cannonAITurnRate, deltaSeconds);
	}
	else if (clientPositions[driverIndex].occupant != None)
	{
		// other client case
		cannonDisplayVehicleSpaceRotation = interpolateRotation(cannonDisplayVehicleSpaceRotation, cannonVehicleSpaceRotation,
				cannonClientTurnRate, deltaSeconds);
	}
	

	// rotate cannon
	
	// ... base
	workRotation = rot(0, 0, 0);
	workRotation.Pitch = cannonDisplayVehicleSpaceRotation.Yaw;
	setBoneDirection('tankturret', workRotation, , , 2);

	// ... barrel
	workRotation = rot(0, 0, 0);
	workRotation.Yaw = -cannonDisplayVehicleSpaceRotation.Pitch;
	if (driverWeapon != None)
		driverWeapon.setBoneDirection('tankgun', workRotation, , , 2);

	// gripping processing processing
	if (DiveInput)
	{
		if (!gripping)
			setGripping(true);
	}
	else
	{
		if (gripping)
			setGripping(false);
	}

	// boost processing
	if (Role == ROLE_Authority && boostInProgress && Level.TimeSeconds > boostSecondStageTime)
	{
		// apply second stage
		boostImpulse = vect(1, 0, 0) >> Rotation;
		boostImpulse.Z = 0;
		boostImpulse = Normal(boostImpulse);
		boostImpulse.Z = tan(boostAngle);
		boostImpulse = Normal(boostImpulse);
		boostImpulse *= boostStrength;
		HavokImpartCOMImpulse(boostImpulse);

		boostInProgress = false;
	}

	// boost animation
	if (Level.TimeSeconds + boostOpenAnimationLength > boostAvailableTime && !openAnimationPlayed)
	{
		PlayAnim('jetopen', , , boostChannel);
		openAnimationPlayed = true;
	}
	if (Level.TimeSeconds > boostCloseTime && !closeAnimationPlayed)
	{
		PlayAnim('jetclose', , , boostChannel);
		closeAnimationPlayed = true;
		openAnimationPlayed = false;
	}

	// check if need to play landing effect
	if (Level.TimeSeconds - lastTreadContactTime > landingEffectAirTime && (leftTreadContact || rightTreadContact) &&
			!IsAnimating(landingChannel))
	{
		PlayAnim('landing', , , landingChannel);
		TriggerEffectEvent('Landed');
	}

	// update lastTreadContactTime
	if (leftTreadContact || rightTreadContact)
		lastTreadContactTime = Level.TimeSeconds;
}

simulated function rotator getAimAdjustedViewRotation(PlayerController pc, Vector fireLocation, int positionIndex)
{
	local Vector startLocation;
	local Rotator workRotation;
	local Vector hitLocation;

	// calculate trace start as camera look at point
	workRotation = pc.rotation;
	workRotation.Roll = 0;
	if (!positions[positionIndex].lookAtInheritPitch)
		workRotation.Pitch = 0;
	startLocation = positions[positionIndex].toBePossessed.Location + (TPCameraLookat >> workRotation);

	driverWeapon.aimTrace(hitLocation, startLocation, Vector(pc.rotation));

	return Rotator(hitLocation - fireLocation);
}

simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	// do not collide if it originated from us
	if (turret == projInstigator)
		return false;

	return super.ShouldProjectileHit(projInstigator);
}

simulated event destroyed()
{
	// clean up stuff attached to the tank
	if (Level.NetMode != NM_Client)
		turret.destroy();

	super.destroyed();
}

simulated event Vector unifiedGetNaturalCOMPosition()
{
	return Location;
}

cpptext
{
	virtual FVector GetViewDirection();

	void TickAuthoritative(float deltaSeconds);

}


defaultproperties
{
     cannonMinimumPitch=-3000.000000
     cannonMaximumPitch=10000.000000
     timeBetweenBoosts=2.000000
     boostAngle=0.785000
     boostStrength=5000000.000000
     boostUpStrength=9000000.000000
     boostUpDuration=1.000000
     turretClass=Class'TankMountedTurret'
     turretBone="gunner"
     gunnerCameraOffset=(Z=50.000000)
     gunnerWeaponOffset=(Z=25.000000)
     gunnerWeaponClass=Class'TankGunnerWeapon'
     gunnerMaximumPitch=10000.000000
     gunnerMinimumPitch=-3000.000000
     gunnerClientTurnRate=30000.000000
     gunnerAITurnRate=12000.000000
     cannonAITurnRate=12000.000000
     cannonClientTurnRate=24000.000000
     boostChannel=2
     closeAnimationPlayed=True
     boostEffectDuration=0.500000
     gripAnimationChannel=4
     gripAnimation="ski"
     gripAnimationBlendTime=0.500000
     landingEffectAirTime=1.000000
     driveThrottleCoefficient=0.130000
     minimumNavigationThrottle=0.500000
     positions(0)=(hideOccupant=True,thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting")
     inverseCosUprightAngle=0.850000
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     motorClass=Class'TankMotor'
     bCollisionDamageEnabled=False
     bVehicleCameraTrace=True
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     stayUprightEnabled=True
     stayUprightDamping=0.900000
     stayUprightStrength=30.000000
     driveYawCoefficient=0.100000
     cornerSlowDownSpeedCoefficient=1000000.000000
     stopForEnemies=False
     driverWeaponClass=Class'TankWeapon'
     retriggerEffectEvents=True
     localizedName="jump tank"
     Mesh=SkeletalMesh'Vehicles.Tank'
     havokDataClass=Class'TankHavokData'
}
