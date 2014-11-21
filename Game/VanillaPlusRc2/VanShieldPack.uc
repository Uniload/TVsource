class VanShieldPack extends EquipmentClasses.PackShield;

var (ShieldPack) float passiveFractionDamageBlocked;
var (ShieldPack) float activeFractionDamageBlocked;

var (VanShieldPack) Material passiveIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (VanShieldPack) Material activeIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (VanShieldPack) Material passiveHitMaterial	"Overlay material to be used when shield has been impacted";
var (VanShieldPack) Material activeHitMaterial		"Overlay material to be used when shield has been impacted";
var (VanShieldPack) float hitStayTime				"Length of time that the hit material is displayed for on damage";

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

var Sound shieldCharged; 
var sound shieldActive;

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


// The pack is fully charged and ready to be activated.
simulated state Charged
{
	simulated function BeginState()
	{
		if (heldBy != None && heldBy.Controller == Level.GetLocalPlayerController())
		{
			heldBy.TriggerEffectEvent(Name(Class.Name$chargedEffectName));
			//sound hack
			#if IG_EFFECTS
			        heldBy.PlaySound(shieldCharged,255,,30,200,,,,false,,);
				LOG("played sound1");
			#else
				heldBy.PlaySound(shieldCharged,SLOT_None,255,,156,,false,,);
				LOG("played sound2");
			#endif 
		}

		rechargingAlpha = 1.0;
	}

//maybe can delete stuff below here, and let the super handle it

	simulated function activate()
	{
		// if we have no controller, we're probably driving or manning a turret and shouldn't be allowed to use our pack.
		if (Character(Owner) == None || Character(Owner).Controller == None)
			return;

		// some packs cannot be used while touching an inventory station - handle that here
		if (Level.NetMode != NM_Client && cannnotBeUsedWhileTouchingInventoryStation && isInRangeOfInventoryStation())
			return;

		GotoState('Activating');

		// inform clients
		if (Level.NetMode != NM_Client && !IsInState('Active'))
			packActivatedTrigger = !packActivatedTrigger;
	}


Begin:

}

defaultproperties
{
     passiveFractionDamageBlocked=0.500000
     activeFractionDamageBlocked=0.800000
     hitStayTime=0.500000
     lightActiveShield=0.520000
     lightPassiveShield=0.100000
     mediumActiveShield=0.530000
     mediumPassiveShield=0.100000
     heavyActiveShield=0.700000
     heavyPassiveShield=0.100000
     shieldCharged=Sound'TV_gui.ui_watched2'
     shieldActive=Sound'TV_packs.shieldpack_loop1'
     rechargeTimeSeconds=8.000000
     rampUpTimeSeconds=0.000000
     durationSeconds=1.500000
     deactivatingDuration=0.000000
}
