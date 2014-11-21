class FailDeployableTurret extends DeployableClasses.DeployableTurret;

var bool bStolen;

state FireReleased
{
	function eDeployableInfo deploy()
	{
		local eDeployableInfo result;
		local bool bOldUseCylinderCollision;
		local BaseInfo closestBase;
		local BaseInfo base;
		local TeamInfo closestBaseTeam;
		
		result = Super.deploy();

		if (result == DeployableInfo_Ok)
		{
			SetCollision(false, false, false);

			bOldUseCylinderCollision = baseDeviceClass.default.bUseCylinderCollision;
			baseDeviceClass.default.bUseCylinderCollision = true;
			/*
			if(bStolen) {
			*/
				//spawnedBaseDevice = new baseDeviceClass(true, Character(Owner), team, Location, Rotation);
				spawnedBaseDevice = new baseDeviceClass(true, Character(Owner), None, Location, Rotation);
			/*
			} else {
			
				ForEach AllActors(Class'Gameplay.BaseInfo', base){
					if(closestBase == None){
						closestBase = base;
					} else {
						if(VSize(closestBase.location - Location) > VSize(base.location - Location))
							closestBase = base;
						if(base.team != team)
							closestBaseTeam = base.team;
					}
				}
				//closestBaseTeam = closestBase.team;

				spawnedBaseDevice = new baseDeviceClass(true, Character(Owner), closestBaseTeam, Location, Rotation);
			//}
			*/

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

defaultproperties
{
     baseDeviceClass=Class'DeployableClasses.DeployedRepairer'
}
