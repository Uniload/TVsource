class Turret extends BaseDevice
	native;


var TurretMotor		motor;
var Character		driver;
var bool			bGetOut;
var Rotator			initialRotation;
var protected float	currentPitch;
var protected float	currentYaw;
var protected int	targetPitch;
var protected int	targetYaw;

var() class<Weapon> weaponClass;
var() Name			driverAnimation			"The animation that the driver plays when seated in the turret";
var() bool			bCanBeManned			"Whether or not the turret can be manned by characters";
var() int			seatedCollisionHeight	"The collision height of the seated character";
var() int			seatedCollisionRadius	"The collision radius of the seated character";

////////// CAMERA //////////

var() float	MaxViewPitch		"0 to ignore, or maximum pitch amount in degrees (from initial rotation)"; 	// internally converted to unreal rot units
var() float	MaxViewYaw			"0 to ignore, or maximum yaw amount in degrees (from initial rotation)"; 	// internally converted to unreal rot units
var() private float ViewRate			"Maximum turret rotation rate in degrees per second";						// internally converted to unreal rot units
var() private float AIViewRate			"Maximum turret rotation rate in degrees per second, while an AI is manning the turret";	// internally converted to unreal rot units

var() name rootBone;
var() name seatBone;
var() name pitchBone;
var() int yawOffset				"Offset added to the yaw used for rotation display, may need to be tweaked in some cases";

var() int yawAxis				"The axis of rotation used for the yaw bone may sometimes need to be tweaked: 0, 1, 2 = X, Y, Z";
var() int pitchAxis				"The axis of rotation used for the pitch bone may sometimes need to be tweaked: 0, 1, 2 = X, Y, Z";
var() bool bFlipYawDisplay		"Turn this on if the turret appears to turn the wrong way";
var() bool bFlipPitchDisplay	"Turn this on if the turret appears to pitch the wrong way";

// character stuff
var int oldCollisionHeight;
var int oldCollisionRadius;

// weapon stuff
var Weapon	weapon;
var Weapon	oldDriverWeapon;

var bool bWasBehindView;

struct native TurretEntryData
{
	var () float radius;
	var () float height;
	var () class<TurretEntry> turretEntryClass;
};
var() TurretEntryData entry;
var TurretEntry TurretEntry;

replication
{
	reliable if (Role == ROLE_Authority)
		weapon, driver, initialRotation;

	reliable if (Role == ROLE_Authority && !bNetOwner)
		targetPitch, targetYaw;

	reliable if (Role == ROLE_Authority)
		ClientDriverEnter, ClientDriverLeave;
}

function PostBeginPlay()
{
	CreateVisionNotifier();
	CreateHearingNotifier();

	Super.PostBeginPlay();

	initTurretAI();

	weapon = Spawn(weaponClass,self,,location);
	weapon.equip();
	weapon.gotostate('Held');
}

function PostLoadGame()
{
	super.PostLoadGame();

	if (driver != None)
	{
		driver.enterManualAnimationState();
		driver.bReplicateAnimations = true;
		driver.LoopAnim(driverAnimation);
	}
}

simulated function PostNetReceive()
{
	local Rotator newRot;

	Super.PostNetReceive();

	if (motor != None)
	{
		newRot.Pitch = targetPitch;
		newRot.Yaw = targetYaw;

		motor.setViewTarget(newRot);
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	MaxViewYaw = (MaxViewYaw / 360) * 65536;
	MaxViewPitch = (MaxViewPitch / 360) * 65536;
	ViewRate = (ViewRate / 360) * 65536;
	AIViewRate = (AIViewRate / 360) * 65536;

	motor = new class'TurretMotor'(self);

	// only have entry triggers on server
	if (Level.NetMode != NM_Client && bCanBeManned)
	{
		if(entry.turretEntryClass == None)
			entry.turretEntryClass = class'TurretEntry';
		TurretEntry = spawn(entry.turretEntryClass, self, ,GetBoneCoords(seatbone).Origin);
		TurretEntry.setBase(self);
		TurretEntry.setCollision(true, false, false);
		TurretEntry.setCollisionSize(entry.radius, entry.height);

		// Update useable points array
		UseablePoints[0] = TurretEntry.GetUseablePoint();
		UseablePointsValid[0] = UP_Valid;
	}

	initialRotation = Rotation;
	targetPitch = Rotation.Pitch;
	targetYaw = Rotation.Yaw;
	currentPitch = Rotation.Pitch;
	currentYaw = Rotation.Yaw;
}

simulated function IFiringMotor firingMotor()
{
	return motor;
}

// Returns the character (if it exists) that is controlling this rook (i.e. turret or vehicle)
simulated function Character getControllingCharacter()
{
	return driver;
}

function initTurretAI()
{
	local int i;

	vehicleAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_VehicleResource", class'Class'));
	mountAI = new class<Tyrion_ResourceBase>( DynamicLoadObject( "Tyrion.AI_GunnerResource", class'Class'));

	vehicleAI.setResourceOwner( self );
	mountAI.setResourceOwner( self );

	for ( i = 0; i < goals.length; i++ )
	{
		if ( goals[i] != None )
			goals[i].static.findResource( self ).assignGoal( goals[i] );
	}

	for ( i = 0; i < abilities.length; i++ )
	{
		if ( abilities[i] != None )
			abilities[i].static.findResource( self ).assignAbility( abilities[i] );
	}
}

// cleanup AI when turret dead
event bool cleanupAI()
{
	if ( super.cleanupAI() )
		return true;

	vehicleAI.cleanup();
	mountAI.cleanup();

	vehicleAI.deleteSensors();
	mountAI.deleteSensors();
 
	vehicleAI.deleteRemovedActions();
	mountAI.deleteRemovedActions();

	return false;
}

// Cause all resources attached to this pawn to re-check their goals
function rematchGoals()
{
	vehicleAI.bMatchGoals = true;
	mountAI.bMatchGoals = true;
}

simulated function Destroyed()
{
	super.Destroyed();

	if (weapon != None)
		weapon.Destroy();

	if (motor != None)
		motor.Destroy();
}

simulated function Tick(float deltaSeconds)
{
	local bool gotOut;
	
	Super.Tick(deltaSeconds);

	// kick dead drivers
	if (Role == ROLE_Authority)
	{
		if (driver != None && !driver.isAlive())
			DriverLeave(true);
	}

	// stop firing if we have no occupant
	if (driver == None && !bWasDeployed && weapon != None)
		weapon.releaseFire(true);

	// check if a driver exited the turret
	if (bGetOut)
	{
		if (Level.NetMode != NM_Client)
		{
			gotOut = DriverLeave(true);
			if (!gotOut )
			{
				Log("Couldn't Leave - staying in!");
			}
		}

		bGetOut = false;
	}

	// update aim
	// only update aim here if we are not human-controlled (AIs don't count)
	// due to turret prediction, we must update human controlled turret aiming from the playercontroller
	if (PlayerCharacterController(Controller) == None)
	{
		updateAim(deltaSeconds);
	}

	// AI debug display
	if ( bShowTyrionCharacterDebug || bShowSensingDebug )
		displayTyrionDebugHeader();
	if ( bShowSensingDebug )
		displayEnemiesList();
	if ( bShowTyrionCharacterDebug && vehicleAI != None )
	{
		vehicleAI.displayTyrionDebug();
		mountAI.displayTyrionDebug();
	}
}

simulated function ClientDriverEnter(Controller c, Character driver)
{
	driver.SetPhysics(PHYS_None);

	driver.bHardAttach = true;
	driver.bCollideWorld = false;
	driver.SetCollision(true, false, false);
	AttachToBone(driver, seatBone);
	driver.SetRelativeLocation(Vect(0,0,0));
	driver.SetRelativeRotation(Rot(0,0,0));

	if (Controller != None && motor != None)
		Controller.SetRotation(motor.getViewRotation());
}

function DriverEnter(Character p)
{
	local Controller c;
	local PlayerController pc;

	pc = PlayerController(p.Controller);
	c = p.Controller;

  	// set pawns current controller to control the vehicle pawn instead
	driver = p;

	// ... when moving out of fusion collision state is set back to what it was so must set physics to
	// ... PHYS_None before updating collision
	driver.SetPhysics(PHYS_None);

	oldCollisionHeight = driver.CollisionHeight;
	oldCollisionRadius = driver.CollisionRadius;
	driver.SetCollisionSize(seatedCollisionRadius, seatedCollisionHeight);

	driver.SetCollision(true, false, false);
	driver.bCollideWorld = false;
	driver.Velocity = vect(0,0,0);

	driver.SetLocation(Location);

	driver.SetPhysics(PHYS_None);

	// snap turret yaw to player's view
	if ( pc != None )
	{
		currentYaw = driver.Rotation.Yaw % 65536;
		if (MaxViewYaw != 0)
			currentYaw = Clamp(currentYaw, initialRotation.Yaw - MaxViewYaw, initialRotation.Yaw + MaxViewYaw);

		currentPitch = driver.controller.rotation.pitch % 65536;
		if (currentPitch > 32767)
			currentPitch -= 65536;
		if (MaxViewPitch != 0)
			currentPitch = Clamp(currentPitch, initialRotation.Pitch - MaxViewPitch, initialRotation.Pitch + MaxViewPitch);

		targetYaw = currentYaw;
		targetPitch = currentPitch;

		updateModelRotation();

		weapon.AISpread = Rot(0.0, 0.0, 0.0);
	}

	// set playercontroller to view the vehicle
	if (pc != None)
	{
		bWasBehindView = pc.bBehindView;

		pc.ClientSetViewTarget(self);
		pc.bBehindView = false;
		pc.ClientSetBehindView(false);
	}

	// disconnect Controller from Driver and connect to KVehicle
	c.Unpossess();

	// keeps the driver relevant
	c.Possess(self);
	
	// set the driver's owner to be us, so that bOwnerNoSee will take effect
	driver.SetOwner(c);

	// save the driver's current weapon, and holster it
	oldDriverWeapon = driver.weapon;
	driver.motor.setWeapon(None);

	// seat the driver
	driver.enterManualAnimationState();
	driver.bReplicateAnimations = true;
	driver.LoopAnim(driverAnimation);
	AttachToBone(driver, seatBone);
	driver.SetRelativeLocation(Vect(0,0,0));
	driver.SetRelativeRotation(Rot(0,0,0));

	dispatchMessage(new class'MessageDriverEnter'(label, p.label));

	ClientDriverEnter(c, driver);
}

// Called from when player wants to get out.
function bool DriverLeave(bool bForceLeave)
{
	local PlayerController pc;
	local Controller c;
	local Vector leaveLoc, rotVec;
	local Rotator r;

	// do nothing if we're not being driven
	if (driver == None)
		return false;

	pc = PlayerController(Controller);
	c = Controller;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.
	
	driver.SetCollisionSize(oldCollisionRadius, oldCollisionHeight);

	driver.bHardAttach = false;
	driver.bCollideWorld = true;
	driver.SetCollision(true, true, true);
	driver.SetBase(None);
	
	r.Yaw = currentYaw;
	driver.SetRotation(r);

	c.Unpossess();
	// reconnect Controller to driver
	c.Possess(driver);

	Controller = None;

	if (driver.isAlive())
	{
		ClientDriverLeave(c, driver, targetPitch, targetYaw);

		driver.PlayWaiting();

		driver.exitManualAnimationState();
		driver.bReplicateAnimations = false;
		driver.Acceleration = vect(0, 0, 24000);
		driver.SetPhysics(PHYS_Movement);

		updateModelRotation();

		r.Yaw -= 16384;
		rotVec = Vector(r);
		leaveLoc = GetBoneCoords(seatBone).Origin;
		leaveLoc += rotVec * driver.CollisionRadius * 2;

		driver.SetLocation(leaveLoc);
		if (driver.movementObject != None)
		{
			driver.movementObject.setEndPosition(leaveLoc);
		}

		// restore the driver's weapon
		driver.motor.setWeapon(oldDriverWeapon);
		oldDriverWeapon = None;
	}

	if (pc != None)
	{
		// set playercontroller to view the person that got out
		pc.ClientSetViewTarget(driver);
		if (!driver.isAlive())
		{
			pc.bBehindView = true;
		}
		else
			pc.bBehindView = bWasBehindView;
	
		pc.ClientSetBehindView(pc.bBehindView);
	}

	dispatchMessage(new class'MessageDriverLeave'(label, driver.label));

	// turret now has no driver
	driver = None;

	return true;
}

simulated function ClientDriverLeave(Controller c, Character driver, float finalPitch, float finalYaw)
{
	driver.SetPhysics(PHYS_Movement);
	driver.SetBase(None);
	targetPitch = finalPitch;
	targetYaw = finalYaw;
}

// returns true if the turret can sight the location given its view constraints
function bool canTargetPoint(Vector targetLoc)
{
	local Vector fireLoc;
	local Vector toTarget;
	local Rotator toTargetRotation;

	if (motor == None)
		return false;

	fireLoc = weapon.calcProjectileSpawnLocation(initialRotation);
	toTarget = Normal(targetLoc - fireLoc);
	toTargetRotation = Rotator(toTarget);
	
	// test pitch
	if (MaxViewPitch != 0)
	{
		if (Abs(toTargetRotation.Pitch - initialRotation.Pitch) > MaxViewPitch)
		{
			return false;
		}
	}

	if (MaxViewYaw != 0)
	{
		if (Abs(toTargetRotation.Yaw - initialRotation.Yaw) > MaxViewYaw)
		{
			return false;
		}
	}

	return true;
}

simulated function overrideCurrentRotation(Rotator newRotation)
{
	currentPitch = newRotation.Pitch;
	currentYaw = newRotation.Yaw;
}

simulated function updateModelRotation()
{
	local Rotator newRot;

	if (rootBone != '')
	{
		newRot = Rot(0,0,0);
		if (yawAxis == 0)
			newRot.Pitch = currentYaw - initialRotation.Yaw + yawOffset;
		else if (yawAxis == 1)
			newRot.Roll = currentYaw - initialRotation.Yaw + yawOffset;
		else if (yawAxis == 2)
			newRot.Yaw = currentYaw - initialRotation.Yaw + yawOffset;
		
		if (bFlipYawDisplay)
		{
			newRot.Pitch *= -1;
			newRot.Yaw *= -1;
			newRot.Roll *= -1;
		}

		SetBoneRotation(rootBone, newRot);
	}

	if (pitchBone != '')
	{
		newRot = Rot(0,0,0);
		if (pitchAxis == 0)
			newRot.Pitch = currentPitch;
		else if (pitchAxis == 1)
			newRot.Roll = currentPitch;
		else if (pitchAxis == 2)
			newRot.Yaw = currentPitch;

		if (bFlipPitchDisplay)
		{
			newRot.Pitch *= -1;
			newRot.Yaw *= -1;
			newRot.Roll *= -1;
		}

		SetBoneRotation(pitchBone, newRot);
	}

	if (TurretEntry != None)
	{
		TurretEntry.SetLocation(GetBoneCoords(seatBone).Origin);
		UseablePoints[0] = TurretEntry.GetUseablePoint();
	}

	// manually set character pos on ded server
	if (Level.NetMode == NM_DedicatedServer && driver != None)
	{
		driver.Move(GetBoneCoords(seatbone).Origin - driver.Location);
	}
}

// Returns true if character successfully took control of turret.
function bool TryToControl(Character p)
{
	local Controller C;
	local Name stateName;

	if (!bCanBeManned)
		return false;

	if (!p.armorClass.default.bCanUseTurrets)
		return false;

	stateName = GetStateName();
	if (stateName != 'Damaged' && stateName != 'Active' && stateName != 'Initialization')
		return false;
	
	C = p.Controller;

	if ( (driver == None) && (C != None) && (team() == None || team().isFriendly(p.team())) )
	{        
		DriverEnter(p);
		return true;
	}
	else
	{
		return false;
	}
}

simulated function updateAim(float deltaSeconds)
{
	local float pitchInc;
	local float yawInc;
	local float pitchDiff;
	local float yawDiff;
	local Name stateName;

	stateName = GetStateName();
	if (stateName != 'Damaged' && stateName != 'Active')
		return;

	if (currentPitch != targetPitch || currentYaw != targetYaw)
	{
		pitchDiff = targetPitch - currentPitch;
		yawDiff = targetYaw - currentYaw;

		if (yawDiff > 0)
		{
			yawInc = FMin(yawDiff, getViewRate() * deltaSeconds);
			if (MaxViewYaw == 0 || currentYaw + yawInc < initialRotation.Yaw + MaxViewYaw)
				currentYaw += yawInc;
		}
		else if (yawDiff < 0)
		{
			yawInc = -FMin(-yawDiff, getViewRate() * deltaSeconds);
			if (MaxViewYaw == 0 || currentYaw + yawInc > initialRotation.Yaw - MaxViewYaw)
				currentYaw += yawInc;
		}

		if (pitchDiff > 0)
		{
			pitchInc = FMin(pitchDiff, getViewRate() * deltaSeconds);
			if (MaxViewPitch == 0 || currentPitch + pitchInc < initialRotation.Pitch + MaxViewPitch)
				currentPitch += pitchInc;
		}
		else if (pitchDiff < 0)
		{
			pitchInc = -FMin(-pitchDiff, getViewRate() * deltaSeconds);
			if (MaxViewPitch == 0 || currentPitch + pitchInc > initialRotation.Pitch - MaxViewPitch)
				currentPitch += pitchInc;
		}

		// update model rotation
		updateModelRotation();
	}

	if (Controller != None && motor != None)
		Controller.SetRotation(motor.getViewRotation());
}


simulated state Unpowered
{
	simulated function BeginState()
	{
		DriverLeave(true);

		Super.BeginState();
	}
}

simulated state Destructed
{
	simulated function BeginState()
	{
		DriverLeave(true);

		Super.BeginState();
	}
}

simulated state Disabled
{
	simulated function BeginState()
	{
		DriverLeave(true);

		Super.BeginState();
	}
}

simulated function onTeamChange()
{
	DriverLeave(true);
}

simulated function float getViewRate()
{
	if (driver == None || PlayerCharacterController(controller) == None)
		return AIViewRate;
	else
		return ViewRate;
}

defaultproperties
{
     weaponClass=Class'Spinfusor'
     driverAnimation="Pod_Stand"
     bCanBeManned=True
     seatedCollisionHeight=50
     seatedCollisionRadius=36
     MaxViewPitch=45.000000
     ViewRate=180.000000
     AIViewRate=180.000000
     rootBone="Base"
     seatBone="Character"
     pitchBone="Top"
     yawAxis=2
     pitchAxis=1
     Entry=(Radius=50.000000,Height=50.000000)
     PeripheralVisionZAngle=1.221700
     playerControllerState="PlayerTurreting"
     AI_LOD_Level=AILOD_MINIMAL
     SightRadius=8000.000000
     bReplicateMovement=False
     bUpdateSimulatedPosition=False
     Mesh=SkeletalMesh'BaseObjects.Turret'
     CollisionRadius=80.000000
     CollisionHeight=80.000000
     bBlockKarma=False
     bNetNotify=True
}
