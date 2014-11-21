class DoorSensor extends Engine.Actor;

var Door ownerDoor;

replication
{
	reliable if (Role == ROLE_Authority)
		ownerDoor;
}

function init(Door owner)
{
	ownerDoor = owner;

	// set it to trigger once only, meaning that 
	// the door will not auto close after it opens
	ownerDoor.bTriggerOnceOnly = true;

	SetLocation(owner.Location);
	SetCollisionSize(owner.CollisionRadius, owner.CollisionHeight);
}

simulated function Touch(Actor Other)
{
	local Rook r;

	r = Rook(Other);

	if (r != None && ownerDoor.isPowered())
	{
		ownerDoor.Bump(r);
		ownerDoor.bCanClose = false;
	}
}

simulated function UnTouch(Actor Other)
{
	// only allow closing when the touching array is empty
	// the reason 1 == empty is because the Other actor passed
	// to the UnTouch call has not yet been removed from the 
	// touching array.
	if(touching.Length <= 1 && ownerDoor.isPowered())
	{
		ownerDoor.bCanClose = true;
		SetTimer(ownerDoor.StayOpenTime, false);
	}
}

simulated function Timer()
{
	// if we can close...
	if(ownerDoor.bCanClose)
		ownerDoor.gotoState('SensorControlled', 'Close');
}

defaultproperties
{
	bHidden = true
	bCollideActors = true
	bOnlyAffectPawns = true
}