class AssaultShip extends JointControlledAircraft;

const DRIVER_INDEX = 0;
const LEFT_GUNNER_INDEX = 1;
const RIGHT_GUNNER_INDEX = 2;

var (AssaultShip) name leftTurretBone;
var (AssaultShip) name rightTurretBone;

var class<VehicleMountedTurret> turretClass;
var VehicleMountedTurret leftTurret;
var VehicleMountedTurret rightTurret;

var (AssaultShip) class<Weapon> turretWeaponClass;

// gunner control
var (AssaultShip) float gunnerMinimumPitch;
var (AssaultShip) float gunnerMaximumPitch;
var (AssaultShip) float gunnerYawStart;
var (AssaultShip) float gunnerYawRange;
var (AssaultShip) vector gunnerCameraOffset;
var (AssaultShip) vector gunnerWeaponOffset;

var (AssaultShip) float gunnerAITurnRate;
var (AssaultShip) float gunnerClientTurnRate;

var int leftEngineDustEffectIndex;
var int rightEngineDustEffectIndex;

var vector leftEngineDustEffectLocation;
var vector rightEngineDustEffectLocation;

var (AssaultShip) float engineDustTraceLength;
var (AssaultShip) float engineDustGroundOffset;

replication
{
	reliable if (Role == ROLE_Authority)
		leftTurret, rightTurret;
}

simulated event postNetBeginPlay()
{
	super.postNetBeginPlay();

	// initialise vehicle position data

	// ... left gunner
	if (Level.NetMode != NM_Client)
	{
		// ... turret
		leftTurret = spawn(turretClass, self, , getBoneCoords(leftTurretBone, true).origin, rotation);
		leftTurret.setPositionType(VP_LEFT_GUNNER);
		leftTurret.setTeam(team());
		assert(leftTurret != None);
		leftTurret.SetBase(self);
		positions[LEFT_GUNNER_INDEX].toBePossessed = leftTurret;
		leftTurret.initialise(turretWeaponClass, leftTurretBone, gunnerMaximumPitch, gunnerMinimumPitch, true, -gunnerYawStart,
				gunnerYawRange, false, gunnerClientTurnRate, gunnerAITurnRate);
	}
	positions[LEFT_GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[LEFT_GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;

	// ... right gunner
	if (Level.NetMode != NM_Client)
	{
		// ... turret
		rightTurret = spawn(turretClass, self, , getBoneCoords(rightTurretBone, true).origin, rotation);
		rightTurret.setPositionType(VP_RIGHT_GUNNER);
		rightTurret.setTeam(team());
		assert(rightTurret != None);
		rightTurret.SetBase(self);
		positions[RIGHT_GUNNER_INDEX].toBePossessed = rightTurret;
		rightTurret.initialise(turretWeaponClass, rightTurretBone, gunnerMaximumPitch, gunnerMinimumPitch, true, gunnerYawStart,
				gunnerYawRange, true, gunnerClientTurnRate, gunnerAITurnRate);
	}
	positions[RIGHT_GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[RIGHT_GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;

	// init AI
	initGunnerAI( LEFT_GUNNER_INDEX );
	initGunnerAI( RIGHT_GUNNER_INDEX );
}

simulated function postNetReceive()
{
	super.postNetReceive();

	// initialise vehicle position data

	// ... left gunner
	if ((positions[LEFT_GUNNER_INDEX].toBePossessed == None) && (leftTurret != None))
		positions[LEFT_GUNNER_INDEX].toBePossessed = leftTurret;

	// ... right gunner
	if ((positions[RIGHT_GUNNER_INDEX].toBePossessed == None) && (rightTurret != None))
		positions[RIGHT_GUNNER_INDEX].toBePossessed = rightTurret;
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	// update weapon skins
	if (leftTurret != None && leftTurret.weapon != None)
	{
		if (leftTurret.weapon.bIsFirstPerson)
			leftTurret.weapon.skins[0] = None;
		else
			leftTurret.weapon.skins[0] = skins[0];
	}
	if (rightTurret != None && rightTurret.weapon != None)
	{
		if (rightTurret.weapon.bIsFirstPerson)
			rightTurret.weapon.skins[0] = None;
		else
			rightTurret.weapon.skins[0] = skins[0];
	}
}

function vector getProjectileSpawnLocation()
{
	return getBoneCoords('muzzle', true).origin;
}

simulated function Material getTeamSkin()
{
	if (m_team != None)
		return m_team.assaultShipSkin;

	return None;
}

simulated event Destroyed()
{
	// clean up stuff attached
	if (Level.NetMode != NM_Client)
	{
		if (leftTurret != None)
			leftTurret.destroy();
		if (rightTurret != None)
			rightTurret.destroy();
	}

	super.destroyed();
}

simulated function Actor getEffectsBaseActor()
{
	return self;
}

simulated function initialiseEffects()
{
	super.initialiseEffects();

	addEffect('leftEngineDust', true, leftEngineDustEffectIndex);
	addEffect('rightEngineDust', true, rightEngineDustEffectIndex);
}

simulated function bool isEffectCauserActive(int effectCauserIndex)
{
	local vector traceStart;
	local vector traceEnd;

	local vector dummy;

	switch (effectCauserIndex)
	{
	case leftEngineDustEffectIndex:

		// trace from engine to ground
		if (positions[driverIndex].occupant == None)
			return false;
		traceStart = getBoneCoords('airLeft', true).origin;
		traceEnd = traceStart + (vect(0, 0, -1) >> Rotation) * engineDustTraceLength;
		return Trace(leftEngineDustEffectLocation, dummy, traceEnd, traceStart) != None;

	case rightEngineDustEffectIndex:

		// trace from engine to ground
		if (positions[driverIndex].occupant == None)
			return false;
		traceStart = getBoneCoords('airRight', true).origin;
		traceEnd = traceStart + (vect(0, 0, -1) >> Rotation) * engineDustTraceLength;
		return Trace(rightEngineDustEffectLocation, dummy, traceEnd, traceStart) != None;
	}

	return super.isEffectCauserActive(effectCauserIndex);
}

simulated function updateDynamicEffectStates()
{	
	local vector groundOffset;

	super.updateDynamicEffectStates();

	groundOffset.Z = engineDustGroundOffset;

	// move engine dust effects
	
	// I am assuming that the location is valid if the effect is playing.

	if (effects[leftEngineDustEffectIndex].observer.emitter != None && effects[leftEngineDustEffectIndex].flag)
		effects[leftEngineDustEffectIndex].observer.emitter.setLocation(leftEngineDustEffectLocation + groundOffset);
	if (effects[rightEngineDustEffectIndex].observer.emitter != None && effects[rightEngineDustEffectIndex].flag)
		effects[rightEngineDustEffectIndex].observer.emitter.setLocation(rightEngineDustEffectLocation + groundOffset);
}

simulated event vehicleUpdateParams()
{
	super.vehicleUpdateParams();

	// apply turret camera changes
	if (leftTurret != None)
		leftTurret.updateParams(gunnerMaximumPitch, gunnerMinimumPitch, -gunnerYawStart, gunnerYawRange);
	if (rightTurret != None)
		rightTurret.updateParams(gunnerMaximumPitch, gunnerMinimumPitch, gunnerYawStart, gunnerYawRange);
	positions[LEFT_GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[LEFT_GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;
	positions[RIGHT_GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[RIGHT_GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;
}

simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	// do not collide if it originated from us
	if (leftTurret == projInstigator || rightTurret == projInstigator)
		return false;

	return super.ShouldProjectileHit(projInstigator);
}

simulated function updateEffectsStates()
{
	super.updateEffectsStates();

	// have flight rotation trump existing strafe animation flag values
	if (zAxisFlightRotation > flightRotationEffectMagnitude)
	{
		strafeRight = true;
		strafeLeft = false;
	}
	else if (zAxisFlightRotation < -flightRotationEffectMagnitude)
	{
		strafeRight = false;
		strafeLeft = true;
	}
}

defaultProperties
{
	DrawType = DT_Mesh
	Mesh = SkeletalMesh'Vehicles.AssaultShip'

	positions(0)=(type=VP_DRIVER,hideOccupant=true,occupantControllerState=TribesPlayerDriving,thirdPersonCamera=true,lookAtInheritPitch=true,enterAnimation=HatchClosing,occupiedAnimation=HatchClosed,unoccupiedAnimation=HatchOpen,exitAnimation=HatchOpening)
	positions(1)=(type=VP_LEFT_GUNNER,hideOccupant=false,occupantControllerState=PlayerVehicleTurreting,thirdPersonCamera=false,occupantAnimation=AShipGunner_Stand,occupantConnection=gunnerleft)
	positions(2)=(type=VP_RIGHT_GUNNER,hideOccupant=false,occupantControllerState=PlayerVehicleTurreting,thirdPersonCamera=false,occupantAnimation=AShipGunner_Stand,occupantConnection=gunnerright)

	HavokDataClass = class'AssaultShipHavokData'

	TPCameraLookat=(X=0,Y=0,Z=700)
	TPCameraDistance=1000

	turretClass = class'Gameplay.AssaultShipMountedTurret'

	turretWeaponClass = class'Gameplay.AntiAircraftWeapon'

	gunnerCameraOffset = (X=0,Y=0,Z=50)
	gunnerWeaponOffset = (X=0,Y=0,Z=25)
	gunnerMaximumPitch = 10000
	gunnerMinimumPitch = -3000
	gunnerYawStart = -2000
	gunnerYawRange = 40000

	leftTurretBone = turretleft
	rightTurretBone = turrettright

	driverWeaponClass = class'AssaultShipWeapon'

	motorClass = class'AssaultShipMotor'

	customInertiaTensor = true
	customInertiaTensorDiagonal = (X=150,Y=150,Z=150)

	gunnerClientTurnRate = 30000

	navigationTurnRate = 250

	engineDustTraceLength = 1500
	engineDustGroundOffset = 100

	minimumCollisionDamageMagnitude = 200
	collisionDamageMagnitudeScale = 0.00075

	gunnerAITurnRate = 12000

	leftAnimation = WingsLeft
	rightAnimation = WingsRight
	spawningAnimation = WingsClosed
	gearUpAnimation = GearUp

	constrainAircraftPitch = true
	minimumAircraftPitch = -5000
	maximumAircraftPitch = 5000

	navigationMinimumPitch = -6000
	thrustThresholdPitch = 1500

	cornerSlowDownSpeedCoefficient = 10

	driveYawCoefficient = 25
	drivePitchCoefficient = 25

	localizedName = "assault ship"
}