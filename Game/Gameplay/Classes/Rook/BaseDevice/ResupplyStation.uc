///////////////////////////////////////////////////////////////////////////////
//
// Resupply Station
//
class ResupplyStation extends BaseDevice;

//
// Access point variables
//
var(ResupplyStation) float accessPointOffset	"Offset of the access area from the front of the Resupply station";
var(ResupplyStation) float accessRadius			"Radius of the access area";
var(ResupplyStation) float accessHeight			"Height of the access area";
var(ResupplyStation) float healRateHealthFractionPerSecond;

var(ResupplyStation) class<ResupplyStationAccess>	accessClass		"Access class to spawn";
var(ResupplyStation) Name usageAnimationForCharacter "animation to play on a character that uses the station";
var ResupplyStationAccess access;
var Character currentUser;

function PostBeginPlay()
{
	local Vector accessPointLocation;
	local Vector xAxis, zAxis;

	Super.PostBeginPlay();

	// Place the access point in front of the resupply station (along the y axis)
	GetAxes(rotation, xAxis, accessPointLocation, zAxis);
	accessPointLocation *= accessPointOffset;
	accessPointLocation += location;

	// create the access point
	access = spawn(accessClass, self, , accessPointLocation, Rotation);
	access.setBase(self);
	access.setCollision(true, false, false);
	access.setCollisionSize(accessRadius, accessHeight);

	// set self as access control
	access.initialise(self);

	// Update useable points array
	UseablePoints[0] = access.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

function PlayUsageAnimation()
{
	if(! IsAnimating())
		PlayAnim('Stand');
}

function bool isOnCharactersTeam(Character testCharacter)
{
	return isFriendly(testCharacter);
}

simulated function Tick(float Delta)
{
	super.Tick(Delta);

	if (Level.NetMode != NM_Client)
	{
		if (currentUser != None)
		{
			if (currentUser.health >= currentUser.healthMaximum || !isFunctional())
			{
				access.unlockUser(currentUser);
			}
		}
	}
}


defaultproperties
{
	Mesh				= SkeletalMesh'BaseObjects.ResupplyStation'
	DrawType			= DT_Mesh

	bReplicateAnimations = true

	accessPointOffset	= 80
	accessRadius		= 50
	accessHeight		= 80
	accessClass			= class'Gameplay.ResupplyStationAccess'

	usageAnimationForCharacter = "Stand"

	healRateHealthFractionPerSecond=0.04
}