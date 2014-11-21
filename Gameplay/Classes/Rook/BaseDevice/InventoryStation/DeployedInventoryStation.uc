class DeployedInventoryStation extends BaseDevice implements InventoryStationAccessControl;

var InventoryStationAccess access;
var (InventoryStation) class<InventoryStationAccess> accessClass;

var (InventoryStation) float accessRadius;
var (InventoryStation) float accessHeight;

replication
{
	reliable if (Role == ROLE_Authority)
		access;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	access = spawn(accessClass, self,,Location);
	access.setBase(self);
	access.setCollision(true, false, false);
	access.setCollisionSize(accessRadius, accessHeight);
	access.initialise(self);

	// Update useable points array
	UseablePoints[0] = access.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

function bool isAccessible(Character accessor)
{
	return true;
}

function bool isFunctional()
{
	return Health > 0;
}

function bool isOnCharactersTeam(Character testCharacter)
{
	return isFriendly(testCharacter);
}

simulated function destroyed()
{
	super.destroyed();

	if (access != none)
		access.destroy();
}

function accessFinished(Character user, bool returnToUsualMovment);
function accessRequired(Character accessor, InventoryStationAccess access, int armorIndex);
function accessNoLongerRequired(Character accessor);
function changeApplied(InventoryStationAccess access);

function bool directUsage()
{
	return true;
}

simulated function bool getCurrentLoadoutWeapons(out InventoryStationAccess.InventoryStationLoadout weaponLoadout, Character user)
{
	return false;
}

defaultproperties
{
	accessRadius	= 500
	accessHeight	= 500
	accessClass		= class'InventoryStationAccess'
	bWasDeployed	= true
	bNoDelete		= false
	bIgnoreEncroachers = true
	bIsDetectableByEnemies	= false
}