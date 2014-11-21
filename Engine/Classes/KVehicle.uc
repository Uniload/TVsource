// Generic 'Karma Vehicle' base class that can be controlled by a Pawn.

class KVehicle extends Pawn
    native
    abstract;

//cpptext
//{
//#ifdef WITH_KARMA
//	virtual void PostNetReceive();
//    virtual void PostEditChange();
//	virtual void setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV);
//	virtual void TickSimulated( FLOAT DeltaSeconds );
//	virtual void TickAuthoritative( FLOAT DeltaSeconds );
//#endif
//
//}
//
//// generic controls (set by controller, used by concrete derived classes)
//var (KVehicle) float    Steering; // between -1 and 1
//var (KVehicle) float    Throttle; // between -1 and 1
//
//var			   Pawn     Driver;
//
//var (KVehicle) array<vector>	ExitPositions;		// Positions (rel to vehicle) to try putting the player when exiting.
//
//var (KVehicle) vector	DrivePos;		// Position (rel to vehicle) to put player while driving.
//var (KVehicle) rotator	DriveRot;		// Rotation (rel to vehicle) to put driver while driving.
//
//// Effect spawned when vehicle is destroyed
//var (KVehicle) class<Actor>	DestroyEffectClass;
//
//// Simple 'driving-in-rings' logic.
//var (KVehicle) bool		bAutoDrive;
//
//var			   bool     bGetOut;
//
//// The factory that created this vehicle.
//var			   KVehicleFactory	ParentFactory;
//
//// Weapon system
//var				bool	bVehicleIsFiring, bVehicleIsAltFiring;
//
//const					FilterFrames = 5;
//var				vector	CameraHistory[FilterFrames];
//var				int		NextHistorySlot;
//var				bool	bHistoryWarmup;
//
//// Useful function for plotting data to real-time graph on screen.
//native final function GraphData(string DataName, float DataValue);
//
//replication
//{
//	reliable if(Role==ROLE_Authority)
//		ClientKDriverEnter, ClientKDriverLeave;
//	
//	reliable if(Role < ROLE_Authority)
//		VehicleFire, VehicleCeaseFire;
//}
//
//// Really simple at the moment!
//#if IG_SHARED    //tcohen: hooked, used by effects system and reactive world objects
//function PostTakeDamage(float Damage, Pawn instigatedBy, Vector hitlocation, 
//						Vector momentum, class<DamageType> damageType)
//#else
//function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
//						Vector momentum, class<DamageType> damageType)
//#endif
//{
//	local PlayerController pc;
//
//	Health -= Damage;
//
//	//Log("Ouch! "$Health);
//
//	// The vehicle is dead!
//	if(Health <= 0)
//	{
//		if ( Controller != None )
//		{
//			pc = PlayerController(Controller);
//
//			if( Controller.bIsPlayer && pc != None )
//			{
//				ClientKDriverLeave(pc); // Just to reset HUD etc.
//
//				// THIS WAS HOW IT WAS IN UT2003, DONT KNOW ABOUT WARFARE...
//				// pc.PawnDied(self); // This should unpossess the controller and let the player respawn
//			}
//			else
//#if IG_TRIBES3
//				Controller.PawnDied(self);
//#else
//				Controller.Destroy();
//#endif
//		}
//
//		Destroy(); // Destroy the vehicle itself (see Destroyed below)
//	}
//
//    //KAddImpulse(momentum, hitlocation);
//}
//
//// Vehicles dont get telefragged.
//event EncroachedBy( actor Other )
//{
//	Log("KVehicle("$self$") Encroached By: "$Other$".");
//}
//
//// You got some new info from the server (ie. VehicleState has some new info).
//event VehicleStateReceived();
//
//// Called when a parameter of the overall articulated actor has changed (like PostEditChange)
//// The script must then call KUpdateConstraintParams or Actor Karma mutators as appropriate.
//simulated event KVehicleUpdateParams();
//
//// Do some server-side vehicle firing stuff
//function VehicleFire(bool bWasAltFire)
//{
//	if(bWasAltFire)
//		bVehicleIsAltFiring = true;
//	else
//		bVehicleIsFiring = true;
//}
//
//function VehicleCeaseFire(bool bWasAltFire)
//{
//	if(bWasAltFire)
//		bVehicleIsAltFiring = false;
//	else
//		bVehicleIsFiring = false;
//}
//
//
//// The pawn Driver has tried to take control of this vehicle
//function TryToDrive(Pawn p)
//{
//	local Controller C;
//	C = p.Controller;
//
//    if ( (Driver == None) && (C != None) && C.bIsPlayer && !C.IsInState('PlayerDriving') && p.IsHumanControlled() )
//	{        
//		KDriverEnter(p);
//    }
//}
//
//// Events called on driver entering/leaving vehicle
//
//simulated function ClientKDriverEnter(PlayerController pc)
//{
//	//log("Enter: "$pc.Pawn);
//
//	//pc.myHUD.bCrosshairShow = false;
//	//pc.myHUD.bShowWeaponInfo = false;
//	//pc.myHUD.bShowPersonalInfo = false;
//	//pc.myHUD.bShowPoints = false;
//
//	pc.bBehindView = true;
//	pc.bFixedCamera = false;
//	pc.bFreeCamera = true;
//
//    pc.SetRotation(rotator( vect(-1, 0, 0) >> Rotation ));
//}
//
//function KDriverEnter(Pawn p)
//{
//	local PlayerController pc;
//
//    //log("KVehicle KDriverEnter");
//
//	// Set pawns current controller to control the vehicle pawn instead
//	Driver = p;
//
//	// Move the driver into position, and attach to car.
//	Driver.SetCollision(false, false, false);
//	Driver.bCollideWorld = false;
//	Driver.bPhysicsAnimUpdate = false;
//	Driver.Velocity = vect(0,0,0);
//	Driver.SetPhysics(PHYS_None);
//	Driver.SetBase(self);
//
//	pc = PlayerController(p.Controller);
//	//pc.ClientSetBehindView(true);
//	//pc.ClientSetFixedCamera(false);
//
//	// Disconnect PlyaerController from Driver and connect to KVehicle.
//	pc.Unpossess();
//	Driver.SetOwner(pc); // This keeps the driver relevant.
//	pc.Possess(self);
//
//	pc.ClientSetViewTarget(self); // Set playercontroller to view the vehicle
//
//	// Change controller state to driver
//    pc.GotoState('PlayerDriving');
//
//	ClientKDriverEnter(pc);
//}
//
//simulated function ClientKDriverLeave(PlayerController pc)
//{
//	//local vector exitLookDir;
//
//	//log("Leave: "$pc.Pawn);
//
//	pc.bBehindView = false;
//	pc.bFixedCamera = true;
//	pc.bFreeCamera = false;
//	// This removes any 'roll' from the look direction.
//	//exitLookDir = Vector(pc.Rotation);
//	//pc.SetRotation(Rotator(exitLookDir));
//
//    //pc.myHUD.bCrosshairShow = pc.myHUD.default.bCrosshairShow;
//	//pc.myHUD.bShowWeaponInfo = pc.myHUD.default.bShowWeaponInfo;
//	//pc.myHUD.bShowPersonalInfo = pc.myHUD.default.bShowPersonalInfo;
//	//pc.myHUD.bShowPoints = pc.myHUD.default.bShowPoints;
//
//	// Reset the view-smoothing
//	NextHistorySlot = 0;
//	bHistoryWarmup = true;
//}
//
//// Called from the PlayerController when player wants to get out.
//function bool KDriverLeave(bool bForceLeave)
//{
//	local PlayerController pc;
//	local int i;
//	local bool havePlaced;
//	local vector HitLocation, HitNormal, tryPlace;
//
//    //log("KVehicle KDriverLeave");
//
//	// Do nothing if we're not being driven
//	if(Driver == None)
//		return false;
//
//	// Before we can exit, we need to find a place to put the driver.
//	// Iterate over array of possible exit locations.
//	
//	Driver.bCollideWorld = true;
//	Driver.SetCollision(true, true, true);
//	
//	havePlaced = false;
//	for(i=0; i < ExitPositions.Length && havePlaced == false; i++)
//	{
//		//Log("Trying Exit:"$i);
//	
//		tryPlace = Location + (ExitPositions[i] >> Rotation);
//	
//		// First, do a line check (stops us passing through things on exit).
//		if( Trace(HitLocation, HitNormal, tryPlace, Location, false) != None )
//			continue;
//			
//		// Then see if we can place the player there.
//		if( !Driver.SetLocation(tryPlace) )
//			continue;
//		
//		havePlaced = true;
//		
//		//Log("SUCCESS!");		
//	}
//
//	// If we could not find a place to put the driver, leave driver inside as before.
//	if(!havePlaced && !bForceLeave)
//	{
//		Log("Could not place driver.");
//	
//		Driver.bCollideWorld = false;
//		Driver.SetCollision(false, false, false);
//	
//		return false;
//	}
//
//	pc = PlayerController(Controller);
//
//	//Log("Pre ClientKDriverLeave");
//	ClientKDriverLeave(pc);
//	//Log("Post ClientKDriverLeave");
//
//	// Reconnect PlayerController to Driver.
//	pc.Unpossess();
//	pc.Possess(Driver);
//
//	pc.ClientSetViewTarget(Driver); // Set playercontroller to view the persone that got out
//
//	Controller = None;
//
//	Driver.PlayWaiting();
//	Driver.bPhysicsAnimUpdate = Driver.Default.bPhysicsAnimUpdate;
//
//	// Do stuff on client
//	//pc.ClientSetBehindView(false);
//	//pc.ClientSetFixedCamera(true);
//
//    Driver.Acceleration = vect(0, 0, 24000);
//	Driver.SetPhysics(PHYS_Falling);
//	Driver.SetBase(None);
//
//	// Car now has no driver
//	Driver = None;
//
//	// Put brakes on before you get out :)
//    Throttle=0;
//    Steering=0;
//    
//	// Stop firing when you get out!
//	bVehicleIsFiring = false;
//	bVehicleIsAltFiring = false;
//
//    return true;
//}
//
//// Special calc-view for vehicles
//simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
//{
//	local vector CamLookAt, HitLocation, HitNormal;
//	local PlayerController pc;
//	local int i, averageOver;
//
//	pc = PlayerController(Controller);
//
//	// Only do this mode we have a playercontroller viewing this vehicle
//	if(pc == None || pc.ViewTarget != self)
//		return false;
//
//	ViewActor = self;
//	CamLookAt = Location + (vect(-100, 0, 100) >> Rotation); 
//
//	//////////////////////////////////////////////////////
//	// Smooth lookat position over a few frames.
//	CameraHistory[NextHistorySlot] = CamLookAt;
//	NextHistorySlot++;
//
//	if(bHistoryWarmup)
//		averageOver = NextHistorySlot;
//	else
//		averageOver = FilterFrames;
//
//	CamLookAt = vect(0, 0, 0);
//	for(i=0; i<averageOver; i++)
//		CamLookAt += CameraHistory[i];
//
//	CamLookAt /= float(averageOver);
//
//	if(NextHistorySlot == FilterFrames)
//	{
//		NextHistorySlot = 0;
//		bHistoryWarmup=false;
//	}
//	//////////////////////////////////////////////////////
//
//	CameraLocation = CamLookAt + (vect(-600, 0, 0) >> CameraRotation);
//
//	if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10) ) != None )
//	{
//		CameraLocation = HitLocation;
//	}
//
//	return true;
//}
//
//simulated function Destroyed()
//{
//	//Log("KVehicle Destroyed");
//
//	// If there was a driver in the vehicle, destroy him too
//	if(Driver != None)
//		Driver.Destroy();
//
//	// Decrease number of cars active out of parent factory
//	if(ParentFactory != None)
//		ParentFactory.VehicleCount--;
//
//	// Trigger any effects for destruction
//	if(DestroyEffectClass != None)
//		spawn(DestroyEffectClass, , , Location, Rotation);
//
//	Super.Destroyed();
//}
//
//// Just to intercept 'getting out' request.
//simulated event Tick(float deltaSeconds)
//{
//	local bool gotOut;
//	if(bGetOut && ROLE==Role_Authority)
//	{
//		gotOut = KDriverLeave(false);
//		if(!gotOut )
//		{
//			Log("Couldn't Leave - staying in!");
//		}
//	}
//	bGetOut = false;
//}
//
//// Includes properties from KActor
//defaultproperties
//{
//    Steering=0
//    Throttle=0
//
//	ExitPositions(0)=(X=0,Y=0,Z=0)
//
//	DrivePos=(X=0,Y=0,Z=0)
//	DriveRot=()
//
//	bHistoryWarmup = true;
//
//
//    Physics=PHYS_Karma
//	bEdShouldSnap=True
//	bStatic=False
//	bShadowCast=False
//	bCollideActors=True
//	bCollideWorld=False
//    bProjTarget=True
//	bBlockActors=True
//	bBlockNonZeroExtentTraces=True
//	bBlockZeroExtentTraces=True
//	bBlockPlayers=True
//	bWorldGeometry=False
//	bBlockKarma=True
//    CollisionHeight=+000001.000000
//	CollisionRadius=+000001.000000
//	bAcceptsProjectors=True
//	bCanBeBaseForPawns=True
//	bAlwaysRelevant=True
//	RemoteRole=ROLE_SimulatedProxy
//	bNetInitialRotation=True
//	bSpecialCalcView=True
//	//bSpecialHUD=true
//}

defaultproperties
{
}
