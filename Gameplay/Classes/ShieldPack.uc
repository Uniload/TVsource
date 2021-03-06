class ShieldPack extends Pack;

var (ShieldPack) float passiveFractionDamageBlocked;
var (ShieldPack) float activeFractionDamageBlocked;
var (ShieldPack) Material passiveIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (ShieldPack) Material activeIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (ShieldPack) Material passiveHitMaterial	"Overlay material to be used when shield has been impacted";
var (ShieldPack) Material activeHitMaterial		"Overlay material to be used when shield has been impacted";
var (ShieldPack) float hitStayTime				"Length of time that the hit material is displayed for on damage";

var Material currentIdle;
var Material currentHit;
var float currentHitTime;
var float lastHealth;

simulated function applyPassiveEffect(Character characterOwner)
{
	currentIdle = passiveIdleMaterial;
	currentHit = passiveHitMaterial;
	characterOwner.shieldActive = true;
	characterOwner.shieldFractionDamageBlocked = passiveFractionDamageBlocked;
}

simulated function removePassiveEffect(Character characterOwner)
{
	characterOwner.shieldActive = false;
}

simulated function startActiveEffect(Character characterOwner)
{
	currentIdle = activeIdleMaterial;
	currentHit = activeHitMaterial;
	lastHealth = characterOwner.health;
	characterOwner.shieldFractionDamageBlocked = activeFractionDamageBlocked;
}

simulated function finishActiveEffect()
{
	if (heldBy != None)
		heldBy.shieldFractionDamageBlocked = passiveFractionDamageBlocked;
	currentIdle = passiveIdleMaterial;
	currentHit = passiveHitMaterial;
}

simulated event Material GetOverlayMaterialForOwner(int Index)
{
	if (currentHitTime <= 0)
	{
		return currentIdle;
	}
	else
	{
		return currentHit;
	}
}

simulated function tick(float deltaSeconds)
{
	super.tick(deltaSeconds);

	if (currentHitTime > 0)
		currentHitTime -= deltaSeconds;

	if (localHeldBy != None)
	{
		if (lastHealth != localHeldBy.health)
		{
			if (lastHealth > localHeldBy.health)
			{
				currentHitTime = hitStayTime;
			}

			lastHealth = localHeldBy.health;
		}
	}
}

defaultproperties
{
     passiveFractionDamageBlocked=0.500000
     activeFractionDamageBlocked=0.800000
     passiveIdleMaterial=Texture'BaseObjects.ResupplyStationLum'
     activeIdleMaterial=Texture'BaseObjects.ResupplyStationLum'
     passiveHitMaterial=Texture'BaseObjects.ResupplyStationLum'
     activeHitMaterial=Texture'BaseObjects.ResupplyStationLum'
     hitStayTime=0.500000
     thirdPersonMesh=StaticMesh'packs.ShieldPack'
     StaticMesh=StaticMesh'packs.ShieldPackDropped'
}
