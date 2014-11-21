class cmodShieldPack extends EquipmentClasses.PackShield;

var (ShieldPack) float passiveFractionDamageBlocked;
var (ShieldPack) float activeFractionDamageBlocked;

var (cmodShieldPack) Material passiveIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (cmodShieldPack) Material activeIdleMaterial	"Overlay material, if any, to be used when shield is active but has not been impacted";
var (cmodShieldPack) Material passiveHitMaterial	"Overlay material to be used when shield has been impacted";
var (cmodShieldPack) Material activeHitMaterial		"Overlay material to be used when shield has been impacted";
var (cmodShieldPack) float hitStayTime				"Length of time that the hit material is displayed for on damage";

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
var character characterOwner;
var int vieenregistree;
var int differencevie;


function PostBeginPlay(){
super.PostBeginPlay();
characterOwner = Character(Owner);
}


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
	characterOwner.shieldFractionDamageBlocked = activeFractionDamageBlocked;
	vieenregistree=characterOwner.health;
}

simulated function finishActiveEffect()
{
	if (heldBy != None)
	characterOwner.shieldFractionDamageBlocked = passiveFractionDamageBlocked;
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

        differencevie=4*(characterOwner.health-vieenregistree);

        if ((characterOwner.shieldFractionDamageBlocked == activeFractionDamageBlocked) && (differencevie<-20)) //si le sp est actif et qu'on s'en est trop pris dans la gueule
        {
                characterOwner.shieldFractionDamageBlocked = passiveFractionDamageBlocked; //on le desactive
                Level.Game.Broadcast(self, "ShieldPack blocked a severe hit. Disabling it", 'Say');
        }

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
vieenregistree=characterOwner.health;

}

defaultproperties
{
     passiveFractionDamageBlocked=0.200000
     activeFractionDamageBlocked=0.750000
     hitStayTime=0.500000
     rechargeTimeSeconds=16.000000
     rampUpTimeSeconds=0.200000
     durationSeconds=3.000000
     deactivatingDuration=0.000000
}
