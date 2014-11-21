class HavokVehicle extends Pawn
	native;

cpptext
{
#ifdef UNREAL_HAVOK

	// Actor interface.
	virtual bool HavokInitActor();
	virtual void HavokQuitActor();
	
	virtual void PostNetReceive();
    virtual void PostEditChange();
    
	virtual void setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV);
	
	virtual void TickSimulated( FLOAT DeltaSeconds );
	virtual void TickAuthoritative( FLOAT DeltaSeconds );
	
	virtual void HavokPreStepCallback(FLOAT DeltaTime);
	
	virtual void RemakeVehicle();  // updates the internal Havok Raycast vehicle. Called by default in VehicleUpdateParams event, but you can call it whenever you change suspension params etc. No need to call this if you just chaneg steering + throtle in the UpdateVehicle event.
	virtual void BuildVehicle();    // constructs the vehicle, internal call from PostBeginPlay

	virtual void syncVehicleToBones();
	
#endif
}

var const transient int hkVehicleDataPtr; //the HavokVehicleData pointer for this vehicle (stores the couple of Havok ptrs required to interface with the Havok SDK)

var (HavokVehicle) editinline array<HavokVehicleWheel>		Wheels; // Wheel data
var (HavokVehicle) editinline array<float>					GearRatios; //1 per gear, just add another value to get more gears. Gear ratios (3 == low speed, 0.5 == high speed)

// generic controls (set by controller, used by concrete derived classes)
var (HavokVehicle) float    Steering; // between -1 and 1
var (HavokVehicle) float    Throttle; // between -1 and 1
var (HavokVehicle) float	Rise;	  // between -1 and 1

var			   Pawn				Driver;

var (HavokVehicle) array<vector>	ExitPositions;		// Positions (rel to vehicle) to try putting the player when exiting.
var (HavokVehicle) array<vector>	EntryPositions;		// Positions (rel to vehicle) to create triggers for entry.

var (HavokVehicle) vector	DrivePos;		// Position (rel to vehicle) to put player while driving.
var (HavokVehicle) rotator	DriveRot;		// Rotation (rel to vehicle) to put driver while driving.
var (HavokVehicle) name		DriveAnim;		// Animation to play while driving.

//// CAMERAS ////
var (HavokVehicle) bool		bDrawMeshInFP;		// Whether to draw the vehicle mesh when in 1st person mode.
var	(HavokVehicle) bool		bDrawDriverInTP;	// Whether to draw the driver when in 3rd person mode.
var (HavokVehicle) bool		bZeroPCRotOnEntry;	// If true, set camera rotation to zero on entering vehicle. If false, set it to the vehicle rotation.

var (HavokVehicle) vector   FPCamPos;	// Position of camera when driving first person.

var (HavokVehicle) vector   TPCamLookat;
var (HavokVehicle) float    TPCamDistance;

var (HavokVehicle) int		MaxViewYaw; // Maximum amount you can look left and right
var (HavokVehicle) int		MaxViewPitch; // Maximum amount you can look up and down 

//// PHYSICS ////
var (HavokVehicleGeneral) float		ChassisMass; //kg, 750;
var (HavokVehicleGeneral) float		SteeringMaxAngle;  //~3000 Unreal units, (in Havok it hkMath::HK_REAL_PI / 10.0f);
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
var (HavokVehicleEngine) float		TopSpeed; 	// 130
	
	// Aerodynamics
var (HavokVehicleAerodynamics) float	AerodynamicsAirDensity; // 1.3f
var (HavokVehicleAerodynamics) float	AerodynamicsFrontalArea; // 1 (m^2)
var (HavokVehicleAerodynamics) float	AerodynamicsDragCoeff; //0.7f;
var (HavokVehicleAerodynamics) float	AerodynamicsLiftCoeff; //-0.3f;
var (HavokVehicleAerodynamics) vector	ExtraGravity; // 0,0,-5
var (HavokVehicleAerodynamics) float	SpinDamping; //1.0f; 
var (HavokVehicleAerodynamics) float	CollisionSpinDamping; // 0.0f;
var (HavokVehicleAerodynamics) float	CollisionThreshold; //4.0f; 


//// EFFECTS ////

// Effect spawned when vehicle is destroyed
var (HavokVehicle) class<Actor>	DestroyEffectClass;

// Created in PostNetBeginPlay and destroyed when vehicle is.
#if !IG_TRIBES3	// rowan: don't support HavokVehicleTrigger, as they are based of old AIScript class
var			   array<HavokVehicleTrigger>	EntryTriggers;
#endif

var			   bool     bGetOut;

// The factory that created this vehicle.
var			   HavokVehicleFactory	ParentFactory;

// Shadow projector
var			   ShadowProjector	VehicleShadow;

struct native HavokCarState
{
	var HavokRigidBodyState ChassisState;

	var float				ServerHandbrake;
	var float				ServerBrake;
	var float				ServerGas;
	var int					ServerGear;
	var	float				ServerSteering;

	var int					bNewState; // bools inside structs == scary!
};

var		HavokCarState			CarState;
var		bool					bNewCarState;

replication
{
	reliable if(Role==ROLE_Authority)
		ClientDriverEnter, ClientDriverLeave;

	unreliable if(Role == ROLE_Authority)
		CarState;
}

// Useful function for plotting data to real-time graph on screen.
native final function GraphData(string DataName, float DataValue);


// Really simple at the moment!
function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional float projectileFactor)
{
	local PlayerController pc;

	Health -= Damage;

	Log("Ouch! "$Health);

	// The vehicle is dead!
	if(Health <= 0)
	{
		if ( Controller != None )
		{
			pc = PlayerController(Controller);

			if( Controller.bIsPlayer && pc != None )
			{
				ClientDriverLeave(pc); // Just to reset HUD etc.

				// THIS WAS HOW IT WAS IN UT2003, DONT KNOW ABOUT WARFARE...
				// pc.PawnDied(self); // This should unpossess the controller and let the player respawn
			}
			else
#if IG_TRIBES3
				Controller.PawnDied(self);
#else
				Controller.Destroy();
#endif
		}

		Destroy(); // Destroy the vehicle itself (see Destroyed below)
	}

    unifiedAddImpulseAtPosition(momentum, hitlocation);
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

// You got some new info from the server (ie. the CarState has some new info).
event HavokVehicleStateReceived();

// Do script car model stuff here - in the UpdateVehicle you can change steering and throtle., if you change suspension sparams, number of wheels etc, call Remake
simulated event UpdateVehicle( float DeltaTime );

// Redo the vehicle params.. all of them:
native function RemakeVehicle();

// Do any general vehicle set-up when it gets spawned.
simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ;
#if !IG_TRIBES3	// rowan: don't support HavokVehicleTrigger, as they are based of old AIScript class
	local int i;
	local HavokVehicleTrigger NewTrigger;
#endif
    Super.PostNetBeginPlay();

	if(Level.NetMode != NM_Client)
	{
	    GetAxes(Rotation,RotX,RotY,RotZ);

#if !IG_TRIBES3	// rowan: don't support HavokVehicleTrigger, as they are based of old AIScript class
		EntryTriggers.Length = EntryPositions.Length;

		for(i=0; i<EntryPositions.Length; i++)
		{
			// Create triggers for gettting into the hoverbike - only on the server
			NewTrigger = spawn(class'HavokVehicleTrigger', self,, Location + EntryPositions[i].X * RotX + EntryPositions[i].Y * RotY + EntryPositions[i].Z * RotZ);
			NewTrigger.SetBase(self);
			NewTrigger.SetCollision(true, false, false);

			EntryTriggers[i] = NewTrigger;
		}
#endif
	}

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

simulated event bool HavokUpdateState(out HavokRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewCarState)
		return false;

	newState = CarState.ChassisState;
	bNewCarState = false;

	return true; // Get Havok to update the chassis rb
	//return false;
}


// The pawn Driver has tried to take control of this vehicle
function TryToDrive(Pawn p)
{
	local Controller C;
	C = p.Controller;

    if ( (Driver == None) && (C != None) && C.bIsPlayer && !C.IsInState('PlayerDriving') && p.IsHumanControlled() )
	{        
		DriverEnter(p);
    }
}

// Events called on driver entering/leaving vehicle

simulated function ClientDriverEnter(PlayerController pc)
{
	log("Enter: "$pc.Pawn);

	//pc.myHUD.bCrosshairShow = false;
	//pc.myHUD.bShowWeaponInfo = false;
	//pc.myHUD.bShowPersonalInfo = false;
	//pc.myHUD.bShowPoints = false;

	pc.bBehindView = true;
	pc.bFixedCamera = false;
	pc.bFreeCamera = true;

	// Set rotation of camera when getting into vehicle based on bZeroPCRotOnEntry
	if(	bZeroPCRotOnEntry )
		pc.SetRotation( rot(0, 0, 0) );
	else
		pc.SetRotation( rotator( vect(1, 0, 0) >> Rotation ) );
}

function DriverEnter(Pawn p)
{
	local PlayerController pc;
	local vector AttachPos;

    log("HavokVehicle DriverEnter");

	// Set pawns current controller to control the vehicle pawn instead
	Driver = p;

	// Move the driver into position, and attach to car.
	Driver.SetCollision(false, false, false);
	Driver.bCollideWorld = false;
	Driver.bPhysicsAnimUpdate = false;
	Driver.Velocity = vect(0,0,0);
//	Driver.SetPhysics(PHYS_None);

	AttachPos = Location + (DrivePos >> Rotation);
	Driver.SetLocation(AttachPos);

	Driver.SetPhysics(PHYS_None);

	Driver.bHardAttach = true;
	Driver.SetBase(None);
	Driver.SetBase(self);
	Driver.SetRelativeRotation(DriveRot);
	Driver.SetPhysics(PHYS_None);

	pc = PlayerController(p.Controller);
	//pc.ClientSetBehindView(true);
	//pc.ClientSetFixedCamera(false);

	// Disconnect PlyaerController from Driver and connect to HavokVehicle.
	pc.Unpossess();
	Driver.SetOwner(self); // This keeps the driver relevant.
	pc.Possess(self);

	pc.ClientSetViewTarget(self); // Set playercontroller to view the vehicle

	// Change controller state to driver
    pc.GotoState('PlayerDriving');

	ClientDriverEnter(pc);
}

simulated function ClientDriverLeave(PlayerController pc)
{
	//local vector exitLookDir;

	log("Leave: "$pc.Pawn);

	//pc.bBehindView = false;
	pc.bFixedCamera = true;
	pc.bFreeCamera = false;

	// Stop messing with bOwnerNoSee
	Driver.bOwnerNoSee = Driver.default.bOwnerNoSee;

	// This removes any 'roll' from the look direction.
	//exitLookDir = Vector(pc.Rotation);
	//pc.SetRotation(Rotator(exitLookDir));

    //pc.myHUD.bCrosshairShow = pc.myHUD.default.bCrosshairShow;
	//pc.myHUD.bShowWeaponInfo = pc.myHUD.default.bShowWeaponInfo;
	//pc.myHUD.bShowPersonalInfo = pc.myHUD.default.bShowPersonalInfo;
	//pc.myHUD.bShowPoints = pc.myHUD.default.bShowPoints;
}

// Called from the PlayerController when player wants to get out.
function bool DriverLeave(bool bForceLeave)
{
	local PlayerController pc;
	local int i;
	local bool havePlaced;
	local vector HitLocation, HitNormal, tryPlace;

    log("HavokVehicle DriverLeave");

	// Do nothing if we're not being driven
	if(Driver == None)
		return false;

	// Before we can exit, we need to find a place to put the driver.
	// Iterate over array of possible exit locations.
	
	Driver.bHardAttach = false;
	Driver.bCollideWorld = true;
	Driver.SetCollision(true, true, true);
	
	havePlaced = false;
	for(i=0; i < ExitPositions.Length && havePlaced == false; i++)
	{
		//Log("Trying Exit:"$i);
	
		tryPlace = Location + (ExitPositions[i] >> Rotation);
	
		// First, do a line check (stops us passing through things on exit).
		if( Trace(HitLocation, HitNormal, tryPlace, Location, false) != None )
			continue;
			
		// Then see if we can place the player there.
		if( !Driver.SetLocation(tryPlace) )
			continue;
		
		havePlaced = true;
		
		//Log("SUCCESS!");		
	}

	// If we could not find a place to put the driver, leave driver inside as before.
	if(!havePlaced && !bForceLeave)
	{
		Log("Could not place driver.");
	
		Driver.bHardAttach = true;
		Driver.bCollideWorld = false;
		Driver.SetCollision(false, false, false);
	
		return false;
	}

	pc = PlayerController(Controller);

	ClientDriverLeave(pc);

	// Reconnect PlayerController to Driver.
	pc.Unpossess();
	Driver.SetOwner(pc);
	pc.Possess(Driver);

	pc.ClientSetViewTarget(Driver); // Set playercontroller to view the persone that got out

	Controller = None;

	Driver.PlayWaiting();
	Driver.bPhysicsAnimUpdate = Driver.Default.bPhysicsAnimUpdate;

	// Do stuff on client
	//pc.ClientSetBehindView(false);
	//pc.ClientSetFixedCamera(true);

    Driver.Acceleration = vect(0, 0, 24000);
	Driver.SetPhysics(PHYS_Falling);
	Driver.SetBase(None);

	// Car now has no driver
	Driver = None;

	// Put brakes on before you get out :)
    Throttle=0;
    Steering=0;
	Rise=0;
    
    return true;
}

simulated function Destroyed()
{
#if !IG_TRIBES3
	local int i;
#endif

	Log("HavokVehicle Destroyed");

	// Destroy the triggers used for getting in.
#if !IG_TRIBES3	// rowan: don't support HavokVehicleTrigger, as they are based of old AIScript class
	for(i=0; i<EntryTriggers.Length; i++)
	{
		if(EntryTriggers[i] != None)
			EntryTriggers[i].Destroy();
	}
#endif

	// If there was a driver in the vehicle, destroy him too
	if(Driver != None)
		Driver.Destroy();

	// Decrease number of cars active out of parent factory
	if(ParentFactory != None)
		ParentFactory.VehicleCount--;

	// Trigger any effects for destruction
	if(DestroyEffectClass != None)
		spawn(DestroyEffectClass, , , Location, Rotation);

	// Destroy shadow projector
    if (VehicleShadow != None) 
		VehicleShadow.Destroy();

	Super.Destroyed();
}

// Just to intercept 'getting out' request.
simulated event Tick(float deltaSeconds)
{
	local bool gotOut;

	if(bGetOut && ROLE==Role_Authority)
	{
		gotOut = DriverLeave(false);
		if(!gotOut )
		{
			Log("Couldn't Leave - staying in!");
		}
	}
	bGetOut = false;
}

// This will get called if we couldn't move a pawn out of the way. 
function bool EncroachingOn( actor Other )
{
	if ( Other == None )
		return false;

	// If its a non-vehicle pawn, do lots of damage.
	if( Pawn(Other) != None && HavokVehicle(Other) == None )
	{
		Other.TakeDamage(10000, None, Other.Location, vect(0,0,0), class'Crushed');
		return false;
	}
}

// Glue a shadow projector on
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        VehicleShadow = Spawn(class'ShadowProjector', self, '', Location);
        VehicleShadow.ShadowActor = self;
        VehicleShadow.bBlobShadow = false;
        VehicleShadow.LightDirection = Normal(vect(1,1,6));
        VehicleShadow.LightDistance = 1200;
        VehicleShadow.MaxTraceDistance = 350;
        VehicleShadow.InitShadow();
    }
}

// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local PlayerController pc;
	local quat CarQuat, LookQuat, ResultQuat;

	pc = PlayerController(Controller);

	// Only do this mode we have a playercontroller viewing this vehicle
	if(pc == None || pc.ViewTarget != self)
		return false;

	if(pc.bBehindView) ///// THIRD PERSON ///////
	{
		ViewActor = self;
		CamLookAt = Location + (TPCamLookat >> Rotation); 

		OffsetVector = vect(0, 0, 0);
		OffsetVector.X = -1.0 * TPCamDistance;

		CameraLocation = CamLookAt + (OffsetVector >> CameraRotation);

		if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10) ) != None )
		{
			CameraLocation = HitLocation;
		}

		bOwnerNoSee = false;

		if(bDrawDriverInTP)
			Driver.bOwnerNoSee = false;
		else
			Driver.bOwnerNoSee = true;
	}
	else ////// FIRST PERSON //////
	{
		ViewActor = self;

		// Camera position is locked to car
		CameraLocation = Location + (FPCamPos >> Rotation);

		//Log(CameraRotation);
		CarQuat = QuatFromRotator(Rotation);

		// Limit where you can look while driving.

		Normalize(CameraRotation); // Puts each element between +/- 32767

		if(CameraRotation.Yaw > MaxViewYaw)
			CameraRotation.Yaw = MaxViewYaw;
		else if(CameraRotation.Yaw < -MaxViewYaw)
			CameraRotation.Yaw = -MaxViewYaw;

		//if(CameraRotation.Pitch > MaxViewPitch)
		//	CameraRotation.Pitch = MaxViewPitch;
		//else if(CameraRotation.Pitch < -MaxViewPitch)
		//	CameraRotation.Pitch = -MaxViewPitch;

		//pc.DesiredRotation = CameraRotation;
		//pc.SetRotation(CameraRotation);

		LookQuat = QuatFromRotator(CameraRotation);
		ResultQuat = QuatProduct(LookQuat, CarQuat);
		CameraRotation = QuatToRotator(ResultQuat);

		if(bDrawMeshInFP)
			bOwnerNoSee = false;
		else
			bOwnerNoSee = true;

		Driver.bOwnerNoSee = true; // In first person, dont draw the driver
	}

	return true;
}

defaultproperties
{
    Steering=0
    Throttle=0
	Rise=0
	
	//ExitPositions(0)=(X=0,Y=0,Z=0)	
    ExitPositions(0)=(Y=-315.000000,Z=100.000000)
    ExitPositions(1)=(Y=315.000000,Z=100.000000)
    ExitPositions(2)=(Y=0.000000,Z=-400.000000)
    ExitPositions(3)=(Y=0.000000,Z=400.000000)
    EntryPositions(0)=(Y=265.000000,Z=10.000000)
    EntryPositions(1)=(Y=-265.000000,Z=10.000000)
    
 	bDrawDriverInTP=false
	bDrawMeshInFP=true

	DrivePos=(X=0,Y=0,Z=0)
	bZeroPCRotOnEntry=true

	TPCamLookat=(X=-100,Y=0,Z=100)
	TPCamDistance=600

	MaxViewYaw=16000
	MaxViewPitch=16000

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
	bAcceptsProjectors=True
	bCanBeBaseForPawns=True
	bAlwaysRelevant=True
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
	TopSpeed=130
	
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
	
}