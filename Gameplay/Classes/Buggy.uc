// Buggy

class Buggy extends HavokCar implements InventoryStationAccessControl
	dependsOn(InventoryStationAccess)
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

const DRIVER_INDEX = 0;
const GUNNER_INDEX = 1;

const FORCE_DEACTIVATE_DISTANCE = 5;
const FORCE_DEACTIVATE_TIME = 4;

var (Buggy) name turretBone;

// inventory station
var (Buggy) class<InventoryStationAccess> inventoryStationAccessClass;
var (Buggy) vector inventoryStationOffset;
var array<InventoryStationAccess> inventoryStationAccess;

var VehicleMountedTurret turret;
var class<VehicleMountedTurret> turretClass;

var (Buggy) vector gunnerCameraOffset;
var (Buggy) vector gunnerWeaponOffset;
var (Buggy) class<Weapon> gunnerWeaponClass;
var (Buggy) float gunnerMaximumPitch;
var (Buggy) float gunnerMinimumPitch;
var (Buggy) float gunnerAITurnRate;
var (Buggy) float gunnerClientTurnRate;

var (Buggy) int numberInventoryStationPositions;
var int maximumNumberInventoryStationPositions;

var (Boost) class<Buggy> boostClass;
var (Boost) class<HavokCarWheel> frontBoostWheelClass;
var (Boost) class<HavokCarWheel> rearBoostWheelClass;

var (Buggy) array<class<Weapon> > spawnDefaultWeapons;

var vector forceDeactivatePosition;
var float forceDeactivateTime;

// keeps track of whether or not this vehicle has been registered as a respawn vehicle on TeamInfo
var bool isRegisteredRespawnVehicle;

replication
{
	reliable if (Role == ROLE_Authority)
		turret;
}

function int getMinorPositionEntryIndex(int positionIndex)
{
	return getAccessIndex(positionIndex);
}

function spawnCharacter(Character character)
{
	local int inventoryStationPositionI;

	super.spawnCharacter(character);

	// put character into first available inventory station position
	for (inventoryStationPositionI = 2; inventoryStationPositionI < positions.length; ++inventoryStationPositionI)
	{
		if (positions[inventoryStationPositionI].occupant == None)
		{
			occupantEnter(character, inventoryStationPositionI);
			return;
		}
	}

	warn("attempted to spawn character in invalid position");
}

simulated function postNetReceive()
{
	super.postNetReceive();

	// initialise vehicle position data

	// ... gunner
	if ((positions[GUNNER_INDEX].toBePossessed == None) && (turret != None))
		positions[GUNNER_INDEX].toBePossessed = turret;
}

simulated function Material getTeamSkin()
{
	if (m_team != None)
		return m_team.buggySkin;

	return None;
}

simulated event PostNetBeginPlay()
{
	local vector xAxis, yAxis, zAxis;
	local int inventoryI;

    Super.PostNetBeginPlay();

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

	// create inventory stations
	assert(numberInventoryStationPositions <= maximumNumberInventoryStationPositions);
	positions.length = positions.length - (maximumNumberInventoryStationPositions - numberInventoryStationPositions);
	if (Level.NetMode != NM_Client)
	{
		GetAxes(rotation, xAxis, yAxis, zAxis);
		inventoryStationAccess.length = inventoryI;
		for (inventoryI = 0; inventoryI < numberInventoryStationPositions; ++inventoryI)
		{
			inventoryStationAccess[inventoryI] = spawn(inventoryStationAccessClass, self, ,location +
					inventoryStationOffset.X * xAxis + inventoryStationOffset.Y * yAxis + inventoryStationOffset.Z * zAxis);
			inventoryStationAccess[inventoryI].setBase(self);
			inventoryStationAccess[inventoryI].setCollision(false, false, false);
			inventoryStationAccess[inventoryI].initialise(self);
		}
	}

	// init AI
	initGunnerAI( GUNNER_INDEX );
}

simulated event Destroyed()
{
	local int inventoryI;

	// unregister vehicle respawn
	if (Level.NetMode != NM_Client && m_team != None)
	{
		m_team.removeVehicleRespawn(self);
		isRegisteredRespawnVehicle = false;
	}

	// clean up stuff attached to the buggy
	if (Level.NetMode != NM_Client)
	{
		turret.destroy();
	}

	// this will destroy wheels & joints
	Super.Destroyed();

	for (inventoryI = 0; inventoryI < inventoryStationAccess.length; ++inventoryI)
	{
		if (inventoryStationAccess[inventoryI] != None)
			inventoryStationAccess[inventoryI].destroy();
	}

	UnTriggerEffectEvent('ThrustingLoop');
}

function bool driverLeave(bool bForceLeave, int positionIndex)
{
	if (Super.driverLeave(bForceLeave, positionIndex))
	{
		updateRespawnState();
		return true;
	}
	else
		return false;
}

function accessRequired(Character accessor, InventoryStationAccess access, int armorIndex)
{

}

function bool isAccessible(Character accessor)
{
	return true;
}

function bool isFunctional()
{
	return true;
}

function changeApplied(InventoryStationAccess access)
{

}

function accessNoLongerRequired(Character accessor)
{

}

// Inventory station usage.
function bool directUsage()
{
	return false;
}

function bool isOnCharactersTeam(Character testCharacter)
{
	return team().isFriendly(testCharacter.team());
}

function occupantEnter(Character occupant, int positionIndex)
{
	super.occupantEnter(occupant, positionIndex);

	inventoryStationEnterProcessing(occupant, positionIndex);
}

function occupantSwitchPosition(Character occupant, int targetPositionIndex)
{
	super.occupantSwitchPosition(occupant, targetPositionIndex);

	inventoryStationEnterProcessing(occupant, targetPositionIndex);
}

function InventoryStationAccess getUnusedInventoryStation()
{
	local int accessI;

	// find one that is not being used
	for (accessI = 0; accessI < numberInventoryStationPositions; ++accessI)
	{
		if (inventoryStationAccess[accessI].currentUser == None)
			return inventoryStationAccess[accessI];
	}

	return None;
}

function int getAccessIndex(int positionIndex)
{
	if (positions[positionIndex].type == VP_INVENTORY_STATION_ONE)
		return 0;
	else if (positions[positionIndex].type == VP_INVENTORY_STATION_TWO)
		return 1;
	else if (positions[positionIndex].type == VP_INVENTORY_STATION_THREE)
		return 2;
	else if (positions[positionIndex].type == VP_INVENTORY_STATION_FOUR)
		return 3;
	return -1;
}

function inventoryStationEnterProcessing(Character occupant, int positionIndex)
{
	local bool result;
	local int accessI;

	// handle inventory station case
	accessI = getAccessIndex(positionIndex);
	if (accessI >= 0)
	{
		result = inventoryStationAccess[accessI].usedByProcessing(occupant);
		if (!result)
			warn("failed to use invnetory station on buggy");
	}

	updateRespawnState();
}

function settledUpsideDownChanged()
{
	updateRespawnState();
}

function updateRespawnState()
{
	if (isRegisteredRespawnVehicle)
	{
		if (!canCharacterRespawnAt())
		{
			m_team.removeVehicleRespawn(self);
			isRegisteredRespawnVehicle = false;
		}
	}
	else
	{
		if (canCharacterRespawnAt())
		{
			m_team.addVehicleRespawn(self);
			isRegisteredRespawnVehicle = true;
		}
	}
}

simulated function bool canCharacterRespawnAt()
{
	local int inventoryStationI;
	local TeamInfo occupantTeam;

	if (!isAlive())
		return false;

	// cannot respawn if being driven by an enemy
	occupantTeam = getOccupantTeam();
	if (occupantTeam != None && occupantTeam != m_team)
		return false;

	// cannot respawn if all inventory station slots are occupied
	for (inventoryStationI = 2; inventoryStationI < 2 + numberInventoryStationPositions; ++inventoryStationI)
		if (clientPositions[inventoryStationI].occupant == None)
			break;
	if (inventoryStationI == 2 + numberInventoryStationPositions)
		return false;

	// cannot respawn if settled upside down
	if (bSettledUpsideDown)
		return false;

	// cannot respawn if yet to be driven
	if (!bHasBeenOccupied)
		return false;

	return true;
}

function aboutToDie()
{
	kickInventoryStationUsers();

	super.aboutToDie();
}

function aboutToSettleUpsideDown()
{
	kickInventoryStationUsers();

	super.aboutToSettleUpsideDown();
}

function kickInventoryStationUsers()
{
	local int positionI;

	// terminate access for any inventory station users
	for (positionI = 2; positionI < positions.length; ++positionI)
	{
		if (positions[positionI].occupant != None)
		{
			PlayerCharacterController(positions[positionI].occupant.Controller).serverTerminateInventoryStationAccess();
		}
	}
}

// Inventory station access is complete.
function accessFinished(Character user, bool returnToUsualMovment)
{
	local int positionI;

	// get user position index
	for (positionI = 0; positionI < positions.length; ++positionI)
	{
		if (positions[positionI].occupant == user)
			break;
	}

	if (positionI == positions.length)
	{
		warn("inventory station user was not using this Buggy");
		return;
	}

	if (returnToUsualMovment)
		driverLeave(true, positionI);
}

simulated event vehicleUpdateParams()
{
	super.vehicleUpdateParams();

	// apply turret camera changes
	positions[GUNNER_INDEX].firstPersonCameraLocation = gunnerCameraOffset;
	positions[GUNNER_INDEX].firstPersonWeaponLocation = gunnerWeaponOffset;
}

simulated event bool ShouldProjectileHit(Actor projInstigator)
{
	// do not collide if it originated from us
	if (turret == projInstigator)
		return false;

	return super.ShouldProjectileHit(projInstigator);
}

simulated function tick(float deltaSeconds)
{
	local array<class<HavokCarWheel> > localWheelClasses;

	super.tick(deltaSeconds);

	// deactivate if we have been stationary for a while
	if (Physics == PHYS_Havok && HavokIsActive() && clientPositions[driverIndex].occupant == None)
	{
		if (VSizeSquared(Location - forceDeactivatePosition) < FORCE_DEACTIVATE_DISTANCE * FORCE_DEACTIVATE_DISTANCE)
		{
			if (Level.TimeSeconds > forceDeactivateTime)
			{
				HavokActivate(false);
			}
		}
		else
		{
			forceDeactivatePosition = Location;
			forceDeactivateTime = Level.TimeSeconds + FORCE_DEACTIVATE_TIME;
		}
	}
	else
	{
		forceDeactivateTime = Level.TimeSeconds + FORCE_DEACTIVATE_TIME;		
	}

	// boost processing
	if (Physics == PHYS_Havok)
	{
		if (ThrustInput > 0.5 && gear != -1)
		{
			if (currentSwitchClass != boostClass)
			{
				localWheelClasses[leftFrontWheelIndex] = frontBoostWheelClass;
				localWheelClasses[rightFrontWheelIndex] = frontBoostWheelClass;
				localWheelClasses[leftRearWheelIndex] = rearBoostWheelClass;
				localWheelClasses[rightRearWheelIndex] = rearBoostWheelClass;
				switchWheelClasses(localWheelClasses);
				switchClass(boostClass);

				TriggerEffectEvent('ThrustingLoop');
			}
		}
		else
		{
			if (currentSwitchClass != None && currentSwitchClass != class)
			{
				switchWheelClasses(havokCarWheelClasses);
				switchClass(class);
	
				UnTriggerEffectEvent('ThrustingLoop');
			}
		}
	}
}

// 
simulated function bool InventoryCalcView(out actor viewActor, out vector cameraLocation, out rotator cameraRotation)
{
	local vector lookAt;
	local vector HitLocation, HitNormal, OffsetVector;

	// always third person
	ViewActor = self;

	// calculate camera look at position
	cameraRotation = cameraRotation;
	cameraRotation.Roll = 0;
	cameraRotation.Pitch = 0;

	if(cameraRotation.yaw != Rotation.yaw)
	{
		if(cameraRotation.yaw > Rotation.yaw)
			cameraRotation.yaw -= (cameraRotation.yaw - Rotation.yaw) * 0.2;
		else
			cameraRotation.yaw += ( Rotation.yaw - cameraRotation.yaw) * 0.2;
	}

	lookAt = Location + (TPCameraLookat >> cameraRotation);

	// calculate camera location
	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCameraDistance;
	CameraLocation = lookAt + (OffsetVector >> cameraRotation);

	// ... handle case of obstruction between vehicle and camera location
	if (cameraTrace(HitLocation, HitNormal, CameraLocation, Location, false, vect(10, 10, 10)) != None)
		CameraLocation = HitLocation;

	return true;
}

simulated function bool getCurrentLoadoutWeapons(out InventoryStationAccess.InventoryStationLoadout weaponLoadout, Character user)
{
	local int i;

	if (!user.bSpawningAtVehicle)
		return false;

	for(i = 0; i < 10; ++i)
		weaponLoadout.weapons[i].weaponClass = None;

	for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS && i < spawnDefaultWeapons.length; ++i)
	{
		weaponLoadout.weapons[i].weaponClass = spawnDefaultWeapons[i];
	}

	return true;
}

cpptext
{
	UBOOL IsNetRelevantFor(APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation);

}


defaultproperties
{
     turretBone="Turret"
     inventoryStationAccessClass=Class'InventoryStationAccess'
     inventoryStationOffset=(X=-250.000000,Z=150.000000)
     turretClass=Class'BuggyMountedTurret'
     gunnerCameraOffset=(Z=50.000000)
     gunnerWeaponOffset=(Z=25.000000)
     gunnerWeaponClass=Class'AntiAircraftWeapon'
     gunnerMaximumPitch=10000.000000
     gunnerMinimumPitch=-3000.000000
     gunnerAITurnRate=12000.000000
     gunnerClientTurnRate=30000.000000
     numberInventoryStationPositions=4
     maximumNumberInventoryStationPositions=4
     GearRatios(0)=1.000000
     StopThreshold=40.000000
     positions(0)=(thirdPersonCamera=True,occupantControllerState="TribesPlayerDriving",enterAnimation="HatchClosing",exitAnimation="HatchOpening",occupiedAnimation="HatchClosed",unoccupiedAnimation="HatchOpen",ManifestXPosition=50,ManifestYPosition=20,occupantConnection="Character",occupantAnimation="Buggy_Stand")
     positions(1)=(Type=VP_GUNNER,hideOccupant=True,occupantControllerState="PlayerVehicleTurreting",ManifestXPosition=30,ManifestYPosition=20)
     positions(2)=(Type=VP_INVENTORY_STATION_ONE,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(3)=(Type=VP_INVENTORY_STATION_TWO,hideOccupant=True,ManifestXPosition=33,ManifestYPosition=67,bNotLabelledInManifest=True)
     positions(4)=(Type=VP_INVENTORY_STATION_THREE,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=53,bNotLabelledInManifest=True)
     positions(5)=(Type=VP_INVENTORY_STATION_FOUR,hideOccupant=True,ManifestXPosition=47,ManifestYPosition=67,bNotLabelledInManifest=True)
     Entries(0)=(Radius=200.000000,Height=200.000000,Offset=(Y=250.000000,Z=150.000000))
     Entries(1)=(Radius=200.000000,Height=200.000000,Offset=(Y=-250.000000,Z=150.000000))
     flipTriggers(0)=(Radius=400.000000,Height=400.000000)
     motorClass=Class'BuggyMotor'
     collisionDamageMagnitudeScale=0.000750
     bVehicleCameraTrace=True
     vehicleCameraTraceExtents=(X=10.000000,Y=10.000000,Z=10.000000)
     exits(0)=(Offset=(Y=300.000000,Z=100.000000))
     exits(1)=(Offset=(Y=-300.000000,Z=100.000000))
     driveYawCoefficient=0.100000
     bDrawDriverInTP=True
     rootBone="Buggy"
     ManifestLayoutMaterial=Texture'HUD.RoverSchematic'
     localizedName="rover"
     AirSpeed=5000.000000
     Health=800.000000
     bEnableHavokBackstep=True
}
