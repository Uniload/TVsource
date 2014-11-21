// An actual door object that opens and closes
class Door extends Mover implements PathfindingObstacle;

var()	editdisplay(displayActorLabel)
		editcombotype(enumBaseInfo)
		BaseInfo	ownerBase				"baseInfo that this door belongs to";
var()	bool		bLocked					"Whether the door is able to be opened or not";
var()	Material	lockedMaterial			"The mesh's standard material defines the material displayed when the door is unlocked; use this variable to set the material displayed when the door is locked";
var()	int			lockedMaterialIndex		"The index of the material to change on the door when it is locked (typically 0)";

var bool		bOldLocked;
var bool		bBumped;
var bool		bCanClose;
var Material	unlockedMaterial;
var bool		bWasPowered;
var bool		bPowered;
var bool		bUsesPower;
var DoorSensor	doorSensor;

replication
{
	reliable if (Role == ROLE_Authority)
		bLocked;
}

// enumBaseInfo
function enumBaseInfo(Engine.LevelInfo l, Array<BaseInfo> a)
{
	local BaseInfo b;

	ForEach DynamicActors(class'BaseInfo', b)
	{
		a[a.length] = b;
	}
}

// displayActorLabel
function string displayActorLabel(Actor t)
{
	return string(t.label);
}

// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// construct sensor if required
	if (initialState == 'SensorControlled')
	{
		doorSensor = spawn(class'DoorSensor');
		doorSensor.init(self);
	}

	prevKeyNum = KeyNum;
	bOldLocked = bLocked;
	bCanClose = true;

	unlockedMaterial = GetCurrentMaterial(lockedMaterialIndex);
	onLockedChange(bLocked);
}

// isPowered
//
// If the door does not have a base defined, then it
// is always powered, otherwise power depends on the base
function bool isPowered()
{
	if (!bUsesPower) 
		return true;

	if(ownerBase == None)
		return true;

	if(ownerBase.isPowered())
		return true;

	return false;
}

// Tick
function Tick(float Delta)
{
	// change the material if the locked/unlocked state changes
	if (bOldLocked != bLocked)
	{
		onLockedChange(bLocked);
		bOldLocked = bLocked;
	}

	bPowered = isPowered();
	if(bPowered != bWasPowered && doorSensor != None)
	{
		if(bPowered && ! bClosed && touching.Length <= 0)
		{
			bCanClose = true;
			doorSensor.SetTimer(StayOpenTime, false);
		}
	}
	bWasPowered = bPowered;
}

// DoOpen
function DoOpen()
{
	if (!bLocked)
		Super.DoOpen();
}

// onLockedChange
function onLockedChange(bool bVal)
{
	if (bVal)
	{
		if (lockedMaterial != None)
			Skins[lockedMaterialIndex] = lockedMaterial;
	}
	else
	{
		if (unlockedMaterial != None)
			Skins[lockedMaterialIndex] = unlockedMaterial;
	}
}

// SensorControlled
//
// The original default state was BumpOpenTimed. This state was added to have a way of explicitily 
// specifying a sensor controlled door. The rationale for deriving from BumpOpenTimed is that it was the
// default state prior to adding this one.
state SensorControlled extends BumpOpenTimed
{
	// dont disable the trigger, we want the door 
	// to open if it is in the closing state
	function DisableTrigger();

	// Pulled straight from BumpOpenTimed, and modified to 
	// go to the SensorControlled state rather than BumpOpenTimed
	function Bump( actor Other )
	{
		if (!bOpening && !bDelaying)
		{
			if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
				return;
			if ( (BumpType == BT_PlayerBump) && !Pawn(Other).IsPlayerPawn() )
				return;
			if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
				return;
			Global.Bump( Other );
			SavedTrigger = None;
			Instigator = Pawn(Other);
			// DLB Controller clean pass: removed AI logic Instigator.Controller.WaitForMover(self);
			GotoState( 'SensorControlled', 'Open' );
		}
	}
}

function bool canBePassed(name teamName)
{
	if(! isPowered())
	{
		if(bClosed)
			return false;
		else
			return true;
	}

	// if this is a trigger controlled door it can only be passed if opened
	if ((InitialState == 'TriggerToggle') || (InitialState == 'TriggerControl'))
		return !bClosed;

	// if this is a sensor controlled door it can only be passed if unlocked
	if (InitialState == 'SensorControlled')
		return !bLocked;

	warn("door type not handled");

	return true;
}

defaultproperties
{
	MoverEncroachType		= ME_IgnoreWhenEncroach
	InitialState			= SensorControlled

	bProjTarget	= true
	bUsesPower	= false
}