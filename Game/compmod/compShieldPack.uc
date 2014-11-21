class compShieldPack extends EquipmentClasses.PackShield;

var (ShieldPack) float passiveFractionDamageBlocked;
var (ShieldPack) float activeFractionDamageBlocked;

var (compShieldPack) Material passiveIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (compShieldPack) Material activeIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (compShieldPack) Material passiveHitMaterial	"Overlay material to be used when shield has been impacted";
var (compShieldPack) Material activeHitMaterial		"Overlay material to be used when shield has been impacted";
var (compShieldPack) float hitStayTime				"Length of time that the hit material is displayed for on damage";

var()	float lightActiveShield;
var()	float lightPassiveShield;
var()	float mediumActiveShield;
var()	float mediumPassiveShield;
var()	float heavyActiveShield;
var()	float heavyPassiveShield;

var Material currentIdle;
var Material currentHit;
var float currentHitTime;
var float lastHealth;


function startHeldByCharacter(Character holder)
{
	heldBy = holder;
	playEffect(passiveEffectName);
	applyPassiveEffect(holder);
	holder.createThirdPersonMesh(class);
	bHeld = true;
	bDropped = false;
	SetPhysics(PHYS_None);
	SetDrawType(DT_None);
	bCollideWorld = false;
	SetCollision(false, false, false);
	if(holder.combatRole.default.armorClass.default.armorName == "Light")
	{
		log("light");
		passiveFractionDamageBlocked = lightPassiveShield;
		activeFractionDamageBlocked = lightActiveShield;
		
	}
	else if(holder.combatRole.default.armorClass.default.armorName == "Medium")
	{
	log("medium");
		passiveFractionDamageBlocked = mediumPassiveShield;
		activeFractionDamageBlocked = mediumActiveShield;
		
	}
	else 
	{
		passiveFractionDamageBlocked = heavyPassiveShield;
		activeFractionDamageBlocked = heavyActiveShield;
	
	}
}

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
     hitStayTime=0.500000
     lightActiveShield=0.600000
     lightPassiveShield=0.200000
     mediumActiveShield=0.680000
     mediumPassiveShield=0.200000
     heavyActiveShield=0.830000
     heavyPassiveShield=0.200000
     rechargeTimeSeconds=8.000000
     rampUpTimeSeconds=0.000000
     durationSeconds=1.500000
     deactivatingDuration=0.000000
}
