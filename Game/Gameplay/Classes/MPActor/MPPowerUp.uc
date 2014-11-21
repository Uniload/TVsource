class MPPowerUp extends MPCarryable;

var() String	movementConfig			"If provided, this physics configuration will be applied to the carrier.";
var() float		damageReductionScale	"If non-zero, multiplies all damage taken by this amount.  NOT YET IMPLEMENTED.";
var() float		damageInflictionScale	"If non-zero, multiplies all damage inflicted by this amount.  NOT YET IMPLEMENTED.";

// addObjectives
function addObjectives()
{
}

function onPickedUp(Character c)
{
	//Level.Game.BroadcastLocalized(self, class'MPBallMessages', 4); 
	Level.Game.Broadcast(self, "You got a powerup.");

	enableBenefits();
}

function enableBenefits()
{
	if (carrier == None)
		return;

	if (movementConfig != "")
		enableMovementConfiguration();
}

function disableBenefits()
{
	if (carrier == None)
		return;

	disableMovementConfiguration();
}

function onDropped(Controller c)
{
	disableBenefits();
}

function onExistenceTimerExpired()
{
	disableBenefits();
}

function enableMovementConfiguration()
{ 
    // glenn: note this is obsolete see character.tick for new technique for MP configuration switches

//	carrier.movementConfiguration = movementConfig;
//	carrier.combatRole.default.armorClass.static.updateCharacterPhysics(carrier);
}

function disableMovementConfiguration()
{
    // glenn: note this is obsolete see character.tick for new technique for MP configuration switches

//	carrier.movementConfiguration = carrier.combatRole.default.armorClass.default.movementConfiguration;
//	carrier.combatRole.default.armorClass.static.updateCharacterPhysics(carrier);
}

defaultproperties
{
	DrawType				= DT_StaticMesh
	StaticMesh				= StaticMesh'MPGameObjects.Ball'
	idleAnim				= None;
	elasticity				= 0.4
    bUseCylinderCollision	= false	

	returnTime					= -1
	minRespawnTime				= 30
	maxRespawnTime				= 30
	existenceTime				= 15
}