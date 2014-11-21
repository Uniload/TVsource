// BaseDeviceDeployable
// This class enables Base Devices to be re-used as deployables.
class BaseDeviceDeployable extends Deployable;

var() class<BaseDevice> baseDeviceClass			"The type of BaseDevice that is spawned when the player uses the deployable.";

var BaseDevice spawnedBaseDevice;


// PostNetBeginPlay
simulated function PostNetBeginPlay()
{
	SetCollisionSize(baseDeviceClass.default.CollisionRadius, baseDeviceClass.default.CollisionHeight);

	Super.PostNetBeginPlay();
}

// FireReleased state
state FireReleased
{
	function eDeployableInfo deploy()
	{
		local eDeployableInfo result;
		local bool bOldUseCylinderCollision;
		
		result = Super.deploy();

		if (result == DeployableInfo_Ok)
		{
			SetCollision(false, false, false);

			bOldUseCylinderCollision = baseDeviceClass.default.bUseCylinderCollision;
			baseDeviceClass.default.bUseCylinderCollision = true;

			spawnedBaseDevice = new baseDeviceClass(true, Character(Owner), team, Location, Rotation);
			if (spawnedBaseDevice == None || spawnedBaseDevice.bDeleteMe)
			{
				bDeployed = false;
				return DeployableInfo_Blocked;
			}

			baseDeviceClass.default.bUseCylinderCollision = bOldUseCylinderCollision;
			spawnedBaseDevice.bUseCylinderCollision = bOldUseCylinderCollision;

			spawnedBaseDevice.bWasDeployed = true;
		}

		return result;
	}
}

// State Deployed
simulated state Deployed
{
	// Tick
	simulated function Tick(float Delta)
	{
		if (spawnedBaseDevice == None || spawnedBaseDevice.bDeleteMe)
		{
			Destroy();
		}
	}

	simulated function BeginState()
	{
		setupDropped();
	}

Begin:
	if (Owner != None)
		Owner.DetachFromBone(self);

	SetBase(None);
	SetDrawType(DT_None);
	bHidden = true;

	if (Level.NetMode != NM_Client)
		SetLocation(spawnedBaseDevice.Location);
}	

defaultproperties
{
	bCanBeDamaged	= false
	DrawType		= DT_StaticMesh
}