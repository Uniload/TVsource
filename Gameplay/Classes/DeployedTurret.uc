class DeployedTurret extends Turret
	native;

var Controller deployerController;	// controller of the player who placed the turret

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	weapon.animClass = class'EquippableDepTurretAnimator';
	weapon.LinkMesh(None);
	weapon.SetStaticMesh(None);

	if (deployer != None)
		deployerController = deployer.Controller;
}

// used by death message systems
function Controller GetKillerController()
{
	return deployerController;
}

defaultproperties
{
     bCanBeManned=False
     rootBone="DepTurretBase"
     pitchBone="Turret"
     pitchAxis=0
     bFlipYawDisplay=True
     bWasDeployed=True
     PeripheralVisionZAngle=3.141590
     AI_LOD_LevelMP=AILOD_ALWAYS_ON
     reactionDelay=1.500000
     PeripheralVision=-1.000000
     EyeHeight=0.000000
     bIgnoreEncroachers=True
}
