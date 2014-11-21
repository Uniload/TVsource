///////////////////////////////////////////////////////////////////////////////
//
// Resupply Station
//
class ResupplyStationAccess extends BaseDeviceAccess;

var private ResupplyStation resupplyStation;
var Weapon oldUserWeapon;

function initialise(ResupplyStation station)
{
	resupplyStation = station;
}

//
// Called to check if the UseableObject can be used
// by a specific actor.
//
function bool CanBeUsedBy(Pawn user)
{
	if(user.IsA('Character'))
		return resupplyStation.isOnCharactersTeam(Character(user)) && resupplyStation.isFunctional();

	return false;
}

function lockUser(Character user)
{
	local Rotator characterRot;
	local Vector characterLoc;
	local float oldCharZ;
	local PlayerCharacterController pcc;

	pcc = PlayerCharacterController(user.Controller);

	oldCharZ = user.Location.Z;
	characterRot = resupplyStation.Rotation;
	characterRot.Yaw -= 16384;
	characterLoc = resupplyStation.Location - Vector(characterRot) * (user.CollisionRadius + resupplyStation.CollisionRadius) * 2;
	characterLoc.Z = oldCharZ;
	user.unifiedSetPosition(characterLoc);
	user.motor.setViewRotation(characterRot);
	user.unifiedSetVelocity(Vect(0, 0, 0));
    user.SetPhysics(PHYS_None);
	user.bReplicateAnimations = true;
	user.enterManualAnimationState();
	user.LoopAnim(resupplyStation.usageAnimationForCharacter);

	resupplyStation.currentUser = user;

	oldUserWeapon = user.weapon;
	user.motor.setWeapon(None);

	if (pcc != None)
	{
		pcc.currentResupply = resupplyStation;
		pcc.GotoState('PlayerUsingResupplyStation');
		pcc.ClientGotoState('PlayerUsingResupplyStation');
	}
}

function unlockUser(Character user)
{
	local PlayerCharacterController pcc;

	pcc = PlayerCharacterController(user.Controller);

	user.motor.setWeapon(oldUserWeapon);
	resupplyStation.currentUser = None;
	user.bReplicateAnimations = false;
	user.exitManualAnimationState();
    user.SetPhysics(PHYS_Movement);

	if (pcc != None)
	{
		pcc.GotoState('CharacterMovement');
		pcc.ClientGotoState('CharacterMovement');
	}

	// stop any previous health injections
	user.stopHealthInjection();
}

// Called on server when user presses use key in vicinity of inventory station.
function UsedBy(Pawn user)
{
	local Weapon w;
/*	local int maxHealthKits, numHealthKits;
	local class<Consumable> healthKitClass;
*/	local Character characterUser;
	local PlayerCharacterController pcc;

	characterUser = Character(user);

	// do nothing if used by non-character
	if(characterUser == None)
		return;

	pcc = PlayerCharacterController(characterUser.Controller);

	// unbind user if they access us again
/*	if(resupplyStation.currentUser == characterUser)
	{
		unlockUser(characterUser);
		return;
	}
*/
	// do nothing if we already have a user
	if(resupplyStation.currentUser != None && resupplyStation.currentUser.isAlive())
		return;

	// if an enemy do nothing
	if(! resupplyStation.isOnCharactersTeam(characterUser))
	{
		log("Attempted To Use Enemy Resupply Station");
		return;
	}

	// do nothing if resupply station is not functional
	if(! resupplyStation.isFunctional())
	{
		log("Resuppply Station is not functional");
		return;
	}

	super.UsedBy(user);

//	lockUser(characterUser);

	//
	// Play the usage animation
	//
	resupplyStation.PlayUsageAnimation();

	//
	// Fill up on health
	//
	// stop any previous health injections. 
	characterUser.stopHealthInjection();
	// inject a large amount so that if you're damaged at the station, you'll still recharge
	characterUser.healthInjection(resupplyStation.healRateHealthFractionPerSecond * characterUser.healthMaximum, characterUser.healthMaximum - characterUser.health);

	//
	// Weapon ammo reload
	//
	w = Weapon(characterUser.nextEquipment(None, class'Weapon'));
	while(w != None)
	{
		w.increaseAmmo(characterUser.getMaxAmmo(w.class));
		w = Weapon(characterUser.nextEquipment(w, class'Weapon'));
	}

	//
	// Grenade reload
	//
	if(HandGrenade(characterUser.altWeapon) != None)
	{
		characterUser.altWeapon.increaseAmmo(characterUser.armorClass.static.maxGrenades());
	}

	//
	// Fill up on health kits
	//
/*	// Paul: commenting it out - we dont carry health kits anymore
	numHealthKits = characterUser.numHealthKitsCarried();
	maxHealthKits = characterUser.armorClass.static.maxHealthKits();
	healthKitClass = characterUser.armorClass.static.getHealthKitClass();

	if (maxHealthKits != -1 && healthKitClass != None)
		for(numHealthKits = numHealthKits; numHealthKits < maxHealthKits; ++numHealthKits)
			characterUser.newEquipment(healthKitClass);
*/
}

defaultproperties
{
     Prompt="Press '%1' to use the Resupply Station"
     markerOffset=(Y=-40.000000)
     RemoteRole=ROLE_None
}
