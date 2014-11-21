// Equippable
// Base class for equipment that can be selected or are visible in a first-person view and can be
// fired, thrown or take other actions in response to the user's fire button. This includes weapons, throwable
// flags or balls, and deployables
class Equippable extends Equipment
	native;

// First and third person displays
var() Mesh			firstPersonMesh				"The mesh seen in your first-person view";
var() Mesh			thirdPersonMesh				"The mesh seen when others look at your weapon";
var() Mesh			firstPersonAltMesh			"The mesh seen in your first-person view if your armor uses an alternate weapon mesh";
var() Mesh			thirdPersonAltMesh			"The mesh seen when others look at your weapon if your armor uses an alternate weapon mesh";

var() StaticMesh	thirdPersonStaticMesh		"The mesh seen when others look at your weapon";
var() StaticMesh	thirdPersonAltStaticMesh	"The mesh seen when others look at your weapon if your armor uses an alternate weapon mesh";
var() Vector		thirdPersonAttachmentOffset	"Offset from attachment point for 3rd person mesh";
var() Name			thirdPersonAttachmentBone	"The bone to attach the deployable to when in third person";

var() private Vector	firstPersonOffset		"The position of the weapon in a first person view";
var() private Vector	firstPersonAltOffset	"The position of the weapon in a first person view if your armor uses an alternate weapon mesh";
var() float			firstPersonBobMultiplier	"from 0 to 1";
var() float			firstPersonTraceLength		"Trace used to stop gun hitting wall";
var() Vector		firstPersonTraceExtent;
var() float			firstPersonAltTraceLength		"Trace used to stop gun hitting wall";
var() Vector		firstPersonAltTraceExtent;
var() bool			bFirstPersonUseTrace		"Whether a trace should be used to pull the gun away from objects in the first person";

var() string		animPrefix					"Prefix used for arm and weapon animations";

var() bool			automaticallyHold			"Force this equippable to enter the Held state as soon as it is spawned.";

var float			firstPersonInterpStep;		// Used in interpolating the gun position when it hits a wall
var float			firstPersonInterpTarget;	// "", an offset along the gun retraction vector
var float			firstPersonInterpCurrent;	// ""

// Delays
var() float			unequipDuration				"The amount of time that the unequip animation takes to play";
var() float			equipDuration				"The amount of time that the equip animation takes to play";

// Internals
var IFiringMotor	rookMotor;				// motor to query for firing funcitonality
var bool			bMeshChangeOK;
var Rook			rookOwner;
var bool			bIsFirstPerson;
var float			startEquippingTime;

var byte            fireCount;						    // used for replicating firing events to other clients for sim proxies
var byte			localFireCount;

var byte            demoFireCount;                      // used locally for replicating firing events to the demo recording
var byte            localDemoFireCount;                 

var bool			equipped;
var float			equipDurationCounter;
var Vector			equippablePos;

var Name			fireState;
var Name			releaseFireState;

var bool			attemptedAttach;					// prevents constant spam if attachment fails

var() class<EquippableAnimator> animClass;

var() string		equippedArmAnim;

var bool			bPlayedCharacterEquipAnim;

// Replication
replication
{
	// server to client variables
	unreliable if (Role == ROLE_Authority)
		rookOwner, equipped;

    // server to sim proxy variables
	unreliable if (Role == ROLE_Authority && !bNetOwner)
		fireCount;
		
	// demo recording variables
	unreliable if (Role == ROLE_Authority && bDemoRecording)
	    demoFireCount;

	// client to server functions
	reliable if (Role < ROLE_Authority)
		sendServerRequestFire, sendServerRequestReleaseFire;
}

// PostBeginPlay
simulated function PostBeginPlay()
{
	if (automaticallyHold)
		GotoState('Held');

	Super.PostBeginPlay();

	firstPersonInterpCurrent = 0;
	firstPersonInterpTarget = 0;
}

simulated function initialiseRookMotor()
{
	if (rookOwner != None)
		rookMotor = rookOwner.firingMotor();
	else
		rookMotor = None;
}

// PostNetBeginPlay
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	rookOwner = Rook(Owner);
}

protected function setMovementReplication(bool replicate)
{
	super.setMovementReplication(replicate);
	bReplicateMovement = replicate;
}

function pickup(Character newOwner)
{
	Super.pickup(newOwner);
	rookOwner = newOwner;
	rookMotor = newOwner.motor;
}

simulated function bool keepArms()
{
	return false;
}

simulated function bool armsFirstPersonStatus(bool bNewIsFirstPerson)
{
	return bNewIsFirstPerson && (!bHidden || keepArms());
}

// selectMesh
// Display third or first-person mesh accordingly
simulated function selectMesh(optional bool bForceChange)
{
	local bool bNewIsFirstPerson;

	// attempt to initialise rook motor if not already (case occurs on client at start)
	if (rookMotor == None)
	{
		initialiseRookMotor();
	}

	// check for change to/from first person view
	bNewIsFirstPerson = firstPersonStatus();

	if (bNewIsFirstPerson != bIsFirstPerson || bForceChange || !bMeshChangeOK)
	{
		bIsFirstPerson = bNewIsFirstPerson;

		if (bNewIsFirstPerson)
		{
			setupFirstPerson();
		}
		else
		{
			setupThirdPerson();
		}
	}

	bHidden = shouldHide(bNewIsFirstPerson);
	animClass.static.firstPersonStatus(self, armsFirstPersonStatus(bNewIsFirstPerson));
}

// firstPersonStatus
// Returns true if the owning Rook has a first person view
simulated function bool firstPersonStatus()
{
    local PlayerController localPlayerController;
    local PlayerController ownerPlayerController;
    
	// do nothing if no owner
	if (rookOwner == None)
		return false;

    localPlayerController = Level.GetLocalPlayerController();
    ownerPlayerController = PlayerController(rookOwner.controller);

    // handle early exit cases: no owner controller, no local controller  
	if (ownerPlayerController==None || localPlayerController==None)
		return false;

    // normal case: check if owner controller is the current local player controller and is not in behind view
    
	if (ownerPlayerController!=None && ownerPlayerController==localPlayerController && !ownerPlayerController.bBehindView)
		return true;

    // demo recording case: check if rook is currently the view target of the demo player controller and not in behind view

    if (localPlayerController.ViewTarget==rookOwner && !localPlayerController.bBehindView)
        return true;

    // otherwise we must be in third person view

    return false;        
}

simulated function bool useAlternateMesh()
{
	local Character c;

	c = Character(rookOwner);

	return c != None && c.armorClass != None && c.armorClass.static.useAlternateWeaponMesh();
}

// setupFirstPerson
simulated function setupFirstPerson()
{
	if (useAlternateMesh())
		LinkMesh(firstPersonAltMesh);
	else	
		LinkMesh(firstPersonMesh);

	SetDrawType(DT_Mesh);
	bHidden = false;
	bMeshChangeOK = true;
}

// moveWeapon
simulated function moveWeapon()
{
	local Vector hitLocation, startTrace, endTrace, traceDir, hitNormal, traceExtent;
	local Rotator r;
	local float traceLength;

	if (rookOwner == None || rookOwner.controller == None)
		return;

	// attempt to initialise rook motor if not already (case occurs on client at start)
	if (rookMotor == None)
	{
		initialiseRookMotor();
		if (rookMotor == None)
			return;
	}

	SetRotation(rookMotor.getFirstPersonEquippableRotation(self));

	equippablePos = rookMotor.getFirstPersonEquippableLocation(self);
	
	if (bFirstPersonUseTrace)
	{
		if (useAlternateMesh())
		{
			traceLength = firstPersonAltTraceLength;
			traceExtent = firstPersonAltTraceExtent;
		}
		else
		{
			traceLength = firstPersonTraceLength;
			traceExtent = firstPersonTraceExtent;
		}

		traceDir = Vector(Rotation);
		startTrace = equippablePos + traceDir * traceLength * 0.5;
		endTrace = equippablePos + traceDir * traceLength;

		// prevent equippable from sticking in walls
		if (Trace(hitLocation, hitNormal, endTrace, startTrace, true, traceExtent) != None)
		{
			firstPersonInterpTarget = VSize(endTrace - equippablePos) - VSize(hitLocation - equippablePos);
		}
		else
		{
			firstPersonInterpTarget = 0;
		}

		calculateInterpolation();

		// Retract equippable on a vector back and slightly down (avoids near clipping probs)
		if (firstPersonInterpCurrent != 0)
		{
			r = rookOwner.controller.GetViewRotation();
			r.Pitch += 4096;
			Normalize(r);

			equippablePos -= Vector(r) * firstPersonInterpCurrent;
		}
	}

	if (Level.NetMode != NM_DedicatedServer)
	{
		r = rookOwner.controller.GetViewRotation();
		equippablePos -= Vector(r) * ((Level.GetLocalPlayerController().DefaultFOV - 85) * 0.3);
	}

	//LOG(firstPersonInterpCurrent$", "$firstPersonInterpTarget);
	if (bIsFirstPerson)
		SetLocation(equippablePos);

	animClass.static.setLocRot(self, equippablePos, rookMotor.getFirstPersonEquippableRotation(self));
}

// setupThirdPerson
simulated function setupThirdPerson()
{
	local Rook attachRook;
	local name attachBoneName;

	// attempt to initialise rook motor if not already (case occurs on client at start)
	if (rookMotor == None)
		return;

	// if we have no third person mesh, that's ok (like deployable turret weapon)
	if ((thirdPersonMesh == None && thirdPersonStaticMesh == None)|| (useAlternateMesh() && thirdPersonAltMesh == None && thirdPersonStaticMesh == None))
	{
		bMeshChangeOK = true;
		SetDrawType(DT_Mesh);
		LinkMesh(None);
		return;
	}

	// using static meshes
	if (thirdPersonStaticMesh != None || thirdPersonAltStaticMesh != None)
	{
		LinkMesh(None);	// clear possible skeletal mesh

		if (useAlternateMesh())
			SetStaticMesh(thirdPersonAltStaticMesh);
		else	
			SetStaticMesh(thirdPersonStaticMesh);
		SetDrawType(DT_StaticMesh);
	}
	// else skeletal meshes (old support code)
	else
	{
		SetStaticMesh(None);	// clear possible static mesh

		if (useAlternateMesh())
			LinkMesh(thirdPersonAltMesh);
		else	
			LinkMesh(thirdPersonMesh);
		SetDrawType(DT_Mesh);
	}

	bHidden = false;

	rookMotor.getThirdPersonEquippableAttachment(self, attachRook, attachBoneName);
	if (attachRook != None && attachBoneName != '')
	{
		SetBase(None);
		if (!attachRook.AttachToBone(self, attachBoneName))
		{
			LOG("Warning: Rook "$attachRook.Name$" has no bone "$attachBoneName$", hiding equippable " $ class.name);
			SetDrawType(DT_None);
			return;
		}

		SetRelativeLocation(thirdPersonAttachmentOffset);
	}

	bMeshChangeOK = true;
}

simulated function calculateInterpolation()
{
	local float interpDiffNormal, interpDiffSize;

	if (bIsFirstPerson)
	{
		interpDiffSize = firstPersonInterpTarget - firstPersonInterpCurrent;
		if (interpDiffSize != 0)
			interpDiffNormal = (firstPersonInterpTarget - firstPersonInterpCurrent) / interpDiffSize;
		firstPersonInterpCurrent += interpDiffNormal * (firstPersonInterpStep * interpDiffSize);
	}
}

// Tick
simulated function Tick(float DeltaTime)
{
	if (!equipped)
	{
		GotoState('Unequipping');
		return;
	}

	attachWeaponHack();

	moveWeapon();

	selectMesh();
	
	checkFireCount();
}

simulated function attachWeaponHack()
{
	local Rook rookAttach;
	local name boneNameAttach;

	// hack, otherwise weapon does not sometimes get attached
	if ((!bIsFirstPerson) && (!attemptedAttach) && (rookOwner != None) && (Level.NetMode == NM_Client) && (DrawType != DT_None) &&
			(DrawType != DT_Mesh || Mesh != None) && (DrawType != DT_StaticMesh || StaticMesh != None))
	{
		// attempt to initialise rook motor if not already (case occurs on client at start)
		if (rookMotor == None)
		{
			initialiseRookMotor();
		}

		if (rookMotor != None)
		{
			rookMotor.getThirdPersonEquippableAttachment(self, rookAttach, boneNameAttach);
			if (rookAttach != None)
			{
				attemptedAttach = true; // We only ever attempt to attach once. If it fails, stiff ****
				rookAttach.AttachToBone(self, boneNameAttach);
			}
		}
	}
}

simulated function checkFireCount()
{
    local bool demoPlayback;

    // initialize fire counts first time
    
    if (localFireCount==0 && fireCount!=0)
        localFireCount = fireCount;
    
    if (localDemoFireCount==0 && demoFireCount!=0)
        localDemoFireCount = demoFireCount;
    
    // determine if we are in demo playback
    
	if (Level.GetLocalPlayerController() != None)
		demoPlayback = DemoController(Level.GetLocalPlayerController()) != None || Level.GetLocalPlayerController().bDemoOwner;
	else
		demoPlayback = false;

	if (demoPlayback && demoFireCount!=localDemoFireCount)
	{
	    // firing in demo playback
	
        handleFire();

    	onThirdPersonFireCount();

	    handleReleaseFire();

	    localDemoFireCount = demoFireCount;
	}
	else if (Level.NetMode==NM_Client && Role<=ROLE_SimulatedProxy && fireCount!=localFireCount)
	{
	    // 3rd person firing for simulated proxies

    	onThirdPersonFireCount();

	    localFireCount = fireCount;
	}
}

// onThirdPersonFireCount
// Do muzzle flashes or animation effects here
simulated function onThirdPersonFireCount()
{
}

// fire
event simulated bool fire(optional bool _fireOnce)
{
	if (Role != ROLE_Authority)
		sendServerRequestFire();

	return handleFire();
}

event simulated bool releaseFire(optional bool bClientOnly)
{
	if (Role != ROLE_Authority && !bClientOnly)
		sendServerRequestReleaseFire();

	return handleReleaseFire();
}

// sendServerRequestFire
// Sent to the server to request a projectile
private function bool sendServerRequestFire()
{
	return handleFire();
}

// sendServerRequestReleaseFire
// Sent to the server to request a projectile
protected function bool sendServerRequestReleaseFire()
{
	return handleReleaseFire();
}

// handleFire
// overridden in state
private function bool handleFire()
{
	return false;
}

// handleReleaseFire
// overridden in state
protected function bool handleReleaseFire()
{
	return false;
}

function bool canUnequip()
{
	return true;
}

// unEquip
// Disables the weapon and prevents it from being drawn
function unEquip()
{
	equipped = false;
}

// equip
// Makes the weapon active and readies it for firing
function equip()
{
	if (rookOwner != None)
		equipped = true;
}

simulated state Held
{
	simulated function Tick(float DeltaTime)
	{
		if (equipped)
			GotoState('Equipping');
	}
}

// Idle state
simulated state Idle
{
	simulated function BeginState()
	{
		TriggerEffectEvent('Idle');
		// NOTE: weapons override this, and do not call the base class... must update weapon if you do extra stuff here
	}

	simulated function EndState()
	{
		UnTriggerEffectEvent('Idle');
		// NOTE: weapons override this, and do not call the base class... must update weapon if you do extra stuff here
	}

	simulated protected function bool handleFire()
	{
		local Character character;

		GotoState(fireState);

		// remove invincibility if you fire a weapon
		character = Character(Owner);
		if (character != None && character.bTempInvincible)
			character.removeTempInvincibility();

		return true;
	}

	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);

		if (rookMotor != None && rookMotor.shouldFire(self))
		{
			fire();
			return;
		}

		if (!IsInState('Idle')) // State change is possible in Global.Tick
			return;

		if (bIsFirstPerson)
			if (!IsAnimating())
				playIdleAnim();
	}
}

simulated function playIdleAnim()
{
	animClass.static.playEquippableAnim(self, 'Idle');
}

// FirePressed
// Entered when the fire button is pressed, do your shooting code here
simulated state FirePressed
{
	simulated protected function bool handleReleaseFire()
	{
		GotoState(releaseFireState);
		return true;
	}
}

// FireReleased state
// This state is entered when firing stops. Charge up weapons will override this to implement attacking after charging
simulated state FireReleased
{
}

simulated state Equipping
{
	simulated function Tick(float Delta)
	{
		moveWeapon();

		equipDurationCounter += Delta;
		if (equipDurationCounter >= equipDuration)
		{
			TriggerEffectEvent('Equipped');
			GotoState('Idle');
        }
		else
		{
			if (!equipped)
				GotoState('Unequipping');
		}
	}

Begin:
	if (!equipped)
		GotoState('Unequipping');

	selectMesh(true);

	TriggerEffectEvent('Equipping');

	playEquipAnim();

	equipDurationCounter = 0;
}

simulated function bool shouldPlayEquipAnim()
{
	// solve anim ordering problems on clients
	if (Level.NetMode == NM_Client && Character(rookOwner) != None && Character(rookOwner).weapon != self)
		return false;
	
	return true;
}

simulated function playEquipAnim()
{
	if (!shouldPlayEquipAnim())
		return;

	animClass.static.playEquippableAnim(self, 'Select');
}

simulated state Unequipping
{
	simulated function BeginState()
	{
		super.BeginState();
	}

	simulated function Tick(float Delta)
	{
		moveWeapon();
	}

Begin:
	playUnequipAnim();

	Sleep(unequipDuration);

	GotoState('Held');
}

simulated function playUnequipAnim()
{
	if (!shouldPlayEquipAnim())
		return;

	animClass.static.playEquippableAnim(self, 'Deselect');
}

simulated state Dropped
{
	simulated function BeginState()
	{
		equipped = false;

		setDroppedMesh();

		SetBase(None);
		rookOwner = None;
		rookMotor = None;

		Super.BeginState();
	}

	simulated function Tick(float Delta) {}
	simulated function onMessage(Message m) {}
}

simulated function setDroppedMesh()
{
	if (thirdPersonMesh != None)
	{
		LinkMesh(thirdPersonMesh);
		SetDrawType(DT_Mesh);
	}
	else if (thirdPersonStaticMesh != None)
	{
		LinkMesh(None);
		SetStaticMesh(thirdPersonStaticMesh);
		SetDrawType(DT_StaticMesh);
	}
}

function drawDebug(HUD debugHUD);

simulated function bool shouldHide(bool bIsFirstPerson)
{
	if (bIsFirstPerson)
	{
		// hide when players are zoomed in first person
		if (Character(rookOwner) != None && Character(rookOwner).isZoomed())
			return true;

		// bHideFirstPersonWeapon
		if (PlayerCharacterController(rookOwner.Controller) != None && PlayerCharacterController(rookOwner.Controller).bHideFirstPersonWeapon)
			return true;
	}

	return false;
}

simulated function Vector getFirstPersonOffset()
{
	if (useAlternateMesh())
		return firstPersonAltOffset;
	else	
		return firstPersonOffset;
}

simulated function setFirstPersonOffset(Vector v)
{
	if (useAlternateMesh())
		firstPersonAltOffset = v;
	else	
		firstPersonOffset = v;
}

// PRECACHING
static simulated function PrecacheEquippableRenderData(LevelInfo Level, class<Equippable> EquipClass)
{
	Level.AddPrecacheMesh(EquipClass.default.firstPersonMesh);
	Level.AddPrecacheMesh(EquipClass.default.thirdPersonMesh);
	Level.AddPrecacheMesh(EquipClass.default.firstPersonAltMesh);
	Level.AddPrecacheMesh(EquipClass.default.thirdPersonAltMesh);

	Level.AddPrecacheStaticMesh(EquipClass.default.thirdPersonStaticMesh);
	Level.AddPrecacheStaticMesh(EquipClass.default.thirdPersonAltStaticMesh);
}

simulated function UpdatePrecacheRenderData()
{
	Super.UpdatePrecacheRenderData();
	PrecacheEquippableRenderData(Level, Class);
}


defaultproperties
{ 
	bNoRepMesh = true	// client always sets the correct mesh
	bReplicateMovement = false

	bCanDrop = true

	triggeredBy = "all"

	DrawType = DT_Mesh

	firstPersonTraceLength = 100
	firstPersonTraceExtent = (X=1,Y=10,Z=1)
	firstPersonAltTraceLength = 100
	firstPersonAltTraceExtent = (X=1,Y=10,Z=1)
	firstPersonBobMultiplier = 0.15
	firstPersonInterpStep = 0.25
	bFirstPersonUseTrace = true

	fireState = FirePressed
	releaseFireState = FireReleased

	attemptedAttach = false

	animClass = class'EquippableAnimator'

	thirdPersonAttachmentBone = "weapon"
}