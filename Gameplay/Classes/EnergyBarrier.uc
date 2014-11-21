//
// 
//
class EnergyBarrier extends BaseDevice implements PathfindingObstacle
	native;

simulated state Active
{
	simulated function BeginState()
	{
		super.BeginState();
		setCollision(true, true, true);
		bHidden = false;
		HavokSetBlocking(true);
	}
}

simulated state Damaged
{
	simulated function BeginState()
	{
		super.BeginState();
		setCollision(true, true, true);
		bHidden = false;
		HavokSetBlocking(true);
	}
}

simulated state UnPowered
{
	simulated function BeginState()
	{
		super.BeginState();
		setCollision(false, false, false);
		bHidden = true;
		HavokSetBlocking(false);
	}
}

simulated state Disabled
{
	simulated function BeginState()
	{
		super.BeginState();
		setCollision(false, false, false);
		bHidden = true;
		HavokSetBlocking(false);
	}
}

simulated state Destructed
{
	simulated function BeginState()
	{
		super.BeginState();
		setCollision(false, false, false);
		bHidden = true;
		HavokSetBlocking(false);
	}
}

function bool canBePassed(name teamName)
{
	return (teamName == 'None') || (team() == None) || (teamName == team().name);
}

// Energybarriers should be bAlwaysRelevant. They send hardly any data and because they're usually placed within geometry, the
// relevance raytrace tends not to hit them when it should.

defaultproperties
{
     bAIThreat=False
     bUseAlternateSelfIllumMaterial=True
     teamSpecificHavokCollisionFiltering=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'FX.EnergyBarrier512'
     bWorldGeometry=True
     bAlwaysRelevant=True
     Mesh=None
     bCanBeDamaged=False
     bCollideWorld=False
}
