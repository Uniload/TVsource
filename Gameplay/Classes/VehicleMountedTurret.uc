// VehicleMountedTurret
//
// The gameplay aspect of a turret mounted on a vehicle. Visual aspect is handled by actual weapon.
// Has an initialise function that must be called after spawning. The
// rationale for the existence of this behaviour is that specific sub classes of this class are not created
// therefore specific data must be pushed down into instances of this class.

class VehicleMountedTurret extends Rook implements IFiringMotor
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

var name pivotBone;
var name pitchPivotBone;

var protected Vehicle.VehiclePositionType positionType;
var private Vehicle.VehiclePositionType localPositionType;

// initialise in PostBeginPlay
var int positionIndex;

var vehicle ownerVehicle;

var Weapon weapon;

var float maximumPitch;
var float minimumPitch;

var float yawStart;
var float yawRange;
var bool yawConstrained;
var bool yawPositiveDirection;

var rotator worldSpaceNoRollRotation;
var rotator vehicleSpaceRotation;
var rotator vehicleSpaceClientDisplayRotation;

var rotator turretOffsetRotation;
var name turretBone;

var float maximumClientDisplayTurnRate;

var rotator vehicleSpaceRotationAI;
var float maximumAITurnRate;

// The specific way turrets rotate in third person is slightly different dependent on bone rotations. This property specified which
// specific method to use. This is rather nasty. Perhaps it would be better to standardise bone rotations.
var int thirdPersonRotationType;

var Vector cachedCameraLocation;

replication
{
	// This could be optimised by having the appropriate values for each vehicle mounted turret type stored in a class that is simply
	// passed down. The VehicleMountedTurret can then simply access the default values.

	reliable if (Role == ROLE_Authority)
		ownerVehicle, clientOccupantEnter, maximumPitch, minimumPitch, weapon, positionType, yawConstrained, yawStart, yawRange,
				yawPositiveDirection, turretOffsetRotation, turretBone, maximumClientDisplayTurnRate;

	reliable if (Role == ROLE_Authority && !bNetOwner)
		vehicleSpaceRotation;
}

simulated function setPositionType(Vehicle.VehiclePositionType newPositionType)
{
	positionType = newPositionType;
	positionIndex = ownerVehicle.getPositionIndex(positionType);
}

simulated function IFiringMotor firingMotor()
{
	return self;
}

// Returns the character (if it exists) that is controlling this rook (i.e. turret or vehicle)
simulated function Character getControllingCharacter()
{
	if (positionIndex < 0)
		return None;
	else
		return ownerVehicle.positions[positionIndex].occupant;
}

simulated function Character getDriver()
{
	if (positionIndex < 0)
		return None;
	else
		return ownerVehicle.positions[positionIndex].occupant;
}

simulated function faceRotation(rotator newRotation, float deltaTime)
{
	// ignored
}

simulated function clientOccupantEnter(PlayerController pc, Character newDriver, int positionIndex)
{
	local Vehicle.ClientOccupantEnterData data;

	// forward to vehicle
	data.controller = pc;
	data.positionIndex = positionIndex;
	data.occupant = newDriver;
	ownerVehicle.clientOccupantEnter(data);
}

simulated function postNetBeginPlay()
{
	super.postNetBeginPlay();

	localPositionType = positionType;

	if (Vehicle(owner) != None)
	{
		ownerVehicle = Vehicle(owner);
		if (positionType != VP_NULL)
			positionIndex = ownerVehicle.getPositionIndex(positionType);
	}
}

simulated function postNetReceive()
{
	super.postNetReceive();

	// update owner vehicle
	if (Vehicle(owner) != None)
	{
		ownerVehicle = Vehicle(owner);
		if (positionType != VP_NULL)
			positionIndex = ownerVehicle.getPositionIndex(positionType);
	}

	// handle position type updates
	if (ownerVehicle != None && localPositionType != positionType)
	{
		if (positionType != VP_NULL)
			positionIndex = ownerVehicle.getPositionIndex(positionType);
		localPositionType = positionType;
	}
}

function updateParams(float inMaximumPitch, float inMinimumPitch, float inYawStart, float inYawRange)
{
	maximumPitch = inMaximumPitch;
	minimumPitch = inMinimumPitch;

	yawStart = inYawStart;
	if (yawStart < 0)
		yawStart += 65536;
	yawRange = inYawRange;
}

function initialise(class<Weapon> turretWeaponClass, name inTurretBone, float inMaximumPitch, float inMinimumPitch, bool inYawConstrained,
		float inYawStart, float inYawRange, bool inYawPositiveDirection, float inMaximumClientDisplayTurnRate, float inMaximumAITurnRate)
{
	local coords turretOffsetCoords;

	turretBone = inTurretBone;

	maximumPitch = inMaximumPitch;
	minimumPitch = inMinimumPitch;

	yawConstrained = inYawConstrained;
	yawStart = inYawStart;
	if (yawStart < 0)
		yawStart += 65536;
	yawRange = inYawRange;
	yawPositiveDirection = inYawPositiveDirection;

	// initialise weapon
	weapon = spawn(turretWeaponClass, self, , location);
	weapon.setOwner(self);
	weapon.equip();

	turretOffsetCoords = ownerVehicle.getBoneCoords(turretBone, true);
	turretOffsetRotation = orthoRotation(turretOffsetCoords.XAxis, turretOffsetCoords.YAxis, turretOffsetCoords.ZAxis);
	turretOffsetRotation = turretOffsetRotation - ownerVehicle.Rotation;

	vehicleSpaceRotation = turretOffsetRotation;

	maximumClientDisplayTurnRate = inMaximumClientDisplayTurnRate;

	maximumAITurnRate = inMaximumAITurnRate;
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	// update vehicle display rotation
	if (Level.NetMode == NM_Client)
	{
		vehicleSpaceClientDisplayRotation = class'Vehicle'.static.interpolateRotation(vehicleSpaceClientDisplayRotation,
				vehicleSpaceRotation, maximumClientDisplayTurnRate, deltaSeconds);
	}

	// update AI rotation
	if (controller != None && !controller.bIsPlayer)
	{
		vehicleSpaceRotationAI = class'Vehicle'.static.interpolateRotation(vehicleSpaceRotationAI, vehicleSpaceRotation, maximumAITurnRate,
				deltaSeconds);
	}

	// stop firing if no occupant
	if (weapon != None && weapon.IsInState('FirePressed') && Controller == None)
		weapon.releaseFire();

	// make sure owner vehicle is up to date
	if (ownerVehicle == None && Vehicle(owner) != None)
		ownerVehicle = Vehicle(owner);

	// make sure position index is up to date
	if (positionIndex < 0 && positionType != VP_NULL && ownerVehicle != None)
		positionIndex = ownerVehicle.getPositionIndex(positionType);
}

function useEnergy(float amount)
{

}

function float getEnergy()
{
	return 1000;
}

function processMove(rotator worldSpaceNoRollRotation_, rotator vehicleSpaceRotation_)
{
	worldSpaceNoRollRotation = worldSpaceNoRollRotation_;
	vehicleSpaceRotation = vehicleSpaceRotation_;
}

// Forwards call to owner vehicle.
function getOut()
{
	if (ownerVehicle == None)
	{
		warn("owner vehicle is none");
		return;
	}

	ownerVehicle.getOut(positionType);
}

// Forwards call to owner vehicle.
simulated function bool specialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	// for sake of robustness set a reasonable camera location
	CameraLocation = Location;	

	if (ownerVehicle == None)
		return false;

	if (positionIndex < 0)
		return false;

	if (controller == None)
		return false;

	ViewActor = controller;

	// camera position is locked to vehicle
	CameraLocation = ownerVehicle.getBoneCoords(turretBone, true).origin +
			(ownerVehicle.positions[positionIndex].firstPersonCameraLocation >> worldSpaceNoRollRotation);

	// puts each element between +/- 32767
	Normalize(CameraRotation);

	// don't draw the driver
	ownerVehicle.positions[positionIndex].occupant.bOwnerNoSee = true;

	cachedCameraLocation = CameraLocation;

	return true;
}

simulated function vector EyePosition()
{
	return cachedCameraLocation - Location;
}

function turretFire()
{
	if (weapon == None)
		return;

	fire(false);
}

function turretCeaseFire()
{
	if (weapon == None)
		return;

	releaseFire();
}

function fire(optional bool fireOnce)
{
	weapon.fire(fireOnce);
}

function altFire(optional bool fireOnce)
{

}

function releaseFire()
{
	weapon.releaseFire();
}

function releaseAltFire()
{

}

function bool shouldFire(Equippable e)
{
	return false;
}

function setFirePressed(Equippable e, bool pressed)
{
}

function vector getProjectileSpawnLocation()
{
	return ownerVehicle.getBoneCoords(turretBone, true).origin + (ownerVehicle.positions[positionIndex].firstPersonWeaponLocation >>
			worldSpaceNoRollRotation) + (weapon.projectileSpawnOffset >> worldSpaceNoRollRotation);
}

function setViewRotation(Rotator r)
{
	local PlayerCharacterController.DynamicTurretRotationProcessingOutput output;
	output = class'PlayerCharacterController'.static.dynamicTurretRotationProcessing(r, ownerVehicle.Rotation, minimumPitch,
			maximumPitch, yawConstrained, yawPositiveDirection, yawStart, yawRange);

	worldSpaceNoRollRotation = output.worldSpaceNoRollRotation;
	vehicleSpaceRotation = output.vehicleSpaceRotation;
}

simulated function Rotator getDefaultOccupantRotation()
{
	return QuatToRotator(QuatProduct(QuatFromRotator(vehicleSpaceRotation), QuatFromRotator(ownerVehicle.rotation)));
}

function Rotator getViewRotation()
{
	// AI case
	if (controller != None && !controller.bIsPlayer)
		return QuatToRotator(QuatProduct(QuatFromRotator(vehicleSpaceRotationAI), QuatFromRotator(ownerVehicle.rotation)));

	return worldSpaceNoRollRotation;
}

function onShotFiredNotification()
{
	// ignore
}

simulated function vector getFirstPersonEquippableLocation(Equippable subject)
{
	return ownerVehicle.getBoneCoords(turretBone, true).origin + (ownerVehicle.positions[positionIndex].firstPersonWeaponLocation >>
			worldSpaceNoRollRotation);
}

simulated function rotator getFirstPersonEquippableRotation(Equippable subject)
{
	return worldSpaceNoRollRotation;
}

simulated function getThirdPersonEquippableAttachment(Equippable subject, out Rook attachTo, out name boneName)
{
	attachTo = ownerVehicle;
	boneName = 'turret';
}

function bool aimAdjustViewRotation()
{
	return true;
}

function Rook getPhysicalAttachment()
{
	return ownerVehicle;
}

function Weapon getWeapon()
{
	return weapon;
}

// returns true if the turret can sight the location given its view constraints
function bool canTargetPoint(Vector targetLoc)
{
	return true;
}

function destroyed()
{
	super.destroyed();

	weapon.destroy();
}

simulated function Actor getEffectsBaseActor()
{
	return None;
}

simulated function bool customFiredEffectProcessing()
{
	return false;
}

simulated function doCustomFiredEffectProcessing()
{
	assert(false);
}

simulated function Name getKillerLabel()
{
	if (ownerVehicle != None)
		return ownerVehicle.label;

	return super.getKillerLabel();
}

simulated function getAlternateAimAdjustStart(rotator cameraRotation, out vector newAimAdjustStart);

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(0,255,0);

	Canvas.SetPos(4,YPos);

	// owner vehicle
	Canvas.DrawText("Owner Vehicle:" @ ownerVehicle);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	// position type and index
	Canvas.DrawText("Position Type:" @ positionType $ ", Position Index:" @ positionIndex);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

cpptext
{
	virtual UBOOL Tick(FLOAT deltaSeconds, ELevelTick TickType);
	virtual void tickAI( FLOAT DeltaSeconds );
	virtual FVector GetViewPoint();
	virtual UBOOL shouldLookForPawns();
	virtual UBOOL IsNetRelevantFor(APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation);
	virtual UBOOL canBeSeenBy(APawn* pawn) {return Controller && Controller->bIsPlayer;};	// AI's only see player controlled turrets

}


defaultproperties
{
     positionType=VP_NULL
     localPositionType=VP_NULL
     positionIndex=-1
     maximumClientDisplayTurnRate=8000.000000
     maximumAITurnRate=12000.000000
     PeripheralVisionZAngle=3.141590
     bCanBeSensed=False
     playerControllerState="PlayerVehicleTurreting"
     AI_LOD_Level=AILOD_MINIMAL
     bSpecialCalcView=True
     PeripheralVision=-1.000000
     DrawType=DT_None
     bStasis=False
     bOnlyAffectPawns=True
     bHardAttach=True
     bShouldBaseAtStartup=False
     CollisionRadius=80.000000
     CollisionHeight=400.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bBlockHavok=False
     bNetNotify=True
     bRotateToDesired=False
}
