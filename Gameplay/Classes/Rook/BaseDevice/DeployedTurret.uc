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
	bWasDeployed	= true
	bNoDelete		= false
	bCanBeManned	= false
	bIgnoreEncroachers = true

	rootBone		= "DepTurretBase"
	yawAxis			= 2
	yawOffset		= 0
	pitchBone		= "Turret"
	pitchAxis		= 0
	bFlipYawDisplay = true

	AI_LOD_LevelMP	= AILOD_ALWAYS_ON
	reactionDelay	= 1.5

	peripheralVision = -1				// 360 degree view
	peripheralVisionZAngle = 3.14159	// 180 degrees up/down

	EyeHeight		= 0
}