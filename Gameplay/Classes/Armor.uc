class Armor extends Core.Object
	native;

// The Armor object overrides the values in Pawn
var() float									collisionRadius				"The radius of the character's collision cylinder while wearing the armor";
var() float									collisionHeight				"The height of the character's collision cylinder while wearing the armor";
var() class<HavokSkeletalSystem>			HavokParamsClass			"The Havok Ragdoll parameters that the character will assume while wearing the armor";
var() float									breathingDurationMod		"Multiplier for the character's breathing duration (NOT IMPLEMENTED)";
var() float									health						"The amount of health the character has while wearing the armour";
var() float									energy						"The amount of energy the character has while wearing the armour *THIS SHOULD MATCH THE MOVEMENT CONFIG*";
var() float									ammoMod						"Multiplier applied to the amount of ammunition bought from an inventory station (NOT IMPLEMENTED)";
var() float									collisionDamageMod			"Multiplier affecting collision damage (NOT IMPLEMENTED)";
var() float									noise						"How much noise the armor makes when moving (i.e. footsteps). This affects how easily the player can be detected by the AI and human players (NOT IMPLEMENTED)";
var() float									jetPackNoise				"How much noise the jet-pack makes (NOT IMPLEMENTED)";
var() float									eyeHeight					"The eye-height of the first person camera while wearing the armor";
var() float									headFraction				"The fraction of the collision height that represents the head of the character while wearing the armor";
var() Material								hudIcon						"The icon displayed in the player's hud while wearing the armor";
var() int									maxCarriedWeapons			"The maximum number of weapons that can be carried";
var() String	                            movementConfiguration		"The movement configuration that the character will assume while wearing the armor";
var() String								movementConfigurationFastActive		"The movement configuration that the character will assume when activating a Speed Pack";
var() String								movementConfigurationFastPassive	"The movement configuration that the character will assume when wearing a Speed Pack";
var() class<MovementCollisionDamageType>	movementDamageTypeClass		"Damage type used for movement collision damage";
var() class<MovementCollisionDamageType>	movementDamageOtherTypeClass		"Damage type used for when you hit another character and damage them. allows an icon for a heavy splatting a light etc.";
var() class<MovementCrushingDamageType>	    movementCrushingDamageTypeClass		"Damage type used for movement crushing damage eg. large havok objects landing on your head (not vehicles)";
var() bool									bUseAlternateWeaponMesh		"The the alternate mesh defined for a weapon";
var() int									heightIndex					"An index representingthe height ofthe armour, used for aligning the InventoryStation arm";
var() localized	string						armorName					"Name to display to the user, eg: 'Light'";
var() localized String						infoString					"String shown in the inventory screen describing the armor";
var() class<Shield>							personalShieldClass			"The class of shield to use for this armor, or None to disable";
var() String								speechTag					"The loopup tag when pooling dynamic speech based on armor conditions (eg: Light, Medium..)";
var() class<RadarInfo>						radarInfoClass				"Radar info class defineing how this object is marked in the hud";
var() bool									bCanUseTurrets				"Whether the armor can get into turrets or not";
var() class<Weapon>							fallbackWeaponClass			"The weapon used when all else fails";
var() float                                 knockbackScale              "Scales the amount of knockback from weapons and explosions";
var() class<DamageType>						suicideDamageTypeClass		"Damage type used for when a player suicides on purpose";

var bool									bRestrictions; // for debugging

// capacity spec
struct native QuantityWeapon
{
	var() class<Weapon> typeClass;
	var() int quantity;
};

struct native QuantityGrenades
{
	var() class<HandGrenade> typeClass;
	var() int quantity;
};

struct native QuantityDeployable
{
	var() class<Deployable> typeClass;
	var() int quantity;
};

struct native QuantityConsumable
{
	var() class<Consumable> typeClass;
	var() int quantity;
};

var() private editinline Array<QuantityWeapon>		AllowedWeapons;
var() private editinline QuantityGrenades			AllowedGrenades;
var() private Array<class<Pack> >					AllowedPacks;
var() private editinline Array<QuantityDeployable>	AllowedDeployables;
var() private editinline Array<QuantityConsumable>	AllowedConsumables;
var() private Array<class<Vehicle> >				AllowedDriver;
var() private Array<class<Vehicle> >				AllowedPassenger;


// capacity query functions

// isWeaponAllowed
static function bool isWeaponAllowed(class<Weapon> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedWeapons.Length; i++)
	{
		if (default.AllowedWeapons[i].typeClass == typeClass)
			return true;
	}
	
	return false;
}

// isPackAllowed
static function bool isPackAllowed(class<Pack> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedPacks.Length; i++)
	{
		if (default.AllowedPacks[i] == typeClass)
			return true;
	}
	
	return false;
}

// isDeployableAllowed
static function bool isDeployableAllowed(class<Deployable> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedDeployables.Length; i++)
	{
		if (default.AllowedDeployables[i].typeClass == typeClass)
			return true;
	}
	
	return false;
}

// isConsumableAllowed
static function bool isConsumableAllowed(class<Consumable> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedConsumables.Length; i++)
	{
		if (default.AllowedConsumables[i].typeClass == typeClass)
			return true;
	}
	
	return false;
}

// isDriverAllowed
static function bool isDriverAllowed(class<Vehicle> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedDriver.Length; i++)
	{
		if (default.AllowedDriver[i] == typeClass)
			return true;
	}
	
	return false;
}

// isPassengerAllowed
static function bool isPassengerAllowed(class<Vehicle> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return true;

	for (i = 0; i < default.AllowedPassenger.Length; i++)
	{
		if (default.AllowedPassenger[i] == typeClass)
			return true;
	}
	
	return false;
}

// maxAmmo
// Returns -1 if weapon is not allowed
static function int maxAmmo(class<Weapon> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return 9999;

	for (i = 0; i < default.AllowedWeapons.Length; i++)
	{
		if (default.AllowedWeapons[i].typeClass == typeClass)
			return default.AllowedWeapons[i].quantity;
	}
	
	return -1;
}

// maxDeployable
// Returns -1 if deployable is not allowed
static function int maxDeployable(class<Object> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return 9999;

	for (i = 0; i < default.AllowedDeployables.Length; i++)
	{
		if (default.AllowedDeployables[i].typeClass == typeClass)
			return default.AllowedDeployables[i].quantity;
	}
	
	return -1;
}

// maxConsumable
// Returns -1 if consumable is not allowed
static function int maxConsumable(class<Consumable> typeClass)
{
	local int i;

	if (!default.bRestrictions)
		return 9999;

	for (i = 0; i < default.AllowedConsumables.Length; i++)
	{
		if (default.AllowedConsumables[i].typeClass == typeClass)
			return default.AllowedConsumables[i].quantity;
	}
	
	return -1;
}

// maxHealthKits
// Returns -1 if health kit is not allowed
static function int maxHealthKits()
{
	local int i;

	if (!default.bRestrictions)
		return 9999;

	for (i = 0; i < default.AllowedConsumables.Length; i++)
	{
		if (ClassIsChildOf(default.AllowedConsumables[i].typeClass, class'HealthKit'))
			return default.AllowedConsumables[i].quantity;
	}
	
	return -1;
}

// getHealthKitClass
// Return the class of health kit used by this armor
static function class<Consumable> getHealthKitClass()
{
	local int i;

	for (i = 0; i < default.AllowedConsumables.Length; i++)
	{
		if (ClassIsChildOf(default.AllowedConsumables[i].typeClass, class'HealthKit'))
			return default.AllowedConsumables[i].typeClass;
	}
	
	return None;
}

static function int maxGrenades()
{
	return default.AllowedGrenades.quantity;
}

static function class<HandGrenade> getHandGrenadeClass()
{
	return default.AllowedGrenades.typeClass;
}

// equip
// call this to equip the armour to a character
static function equip(Character c)
{
	if(c == None)
	{
		Warn("Armor::equip passed None Character instance.");
		return;
	}

	c.SetCollisionSize(default.collisionRadius, default.collisionHeight);

	c.healthMaximum			    = default.health;
	c.health				    = c.healthMaximum;
	c.personalShieldClass		= default.personalShieldClass;
	c.BaseEyeHeight			    = default.eyeHeight;
	c.EyeHeight				    = default.eyeHeight;
	c.default.BaseEyeHeight	    = default.eyeHeight;
	c.default.EyeHeight		    = default.eyeHeight;

	c.HeadHeight				= default.collisionHeight - (default.collisionHeight * default.headFraction);

	c.HavokParamsClass			= default.HavokParamsClass;

	c.destroyFallbackWeapon();

	c.armorClass			    = default.class;
}

static function bool useAlternateWeaponMesh()
{
	return default.bUseAlternateWeaponMesh;
}

defaultproperties
{
     EyeHeight=64.000000
     headFraction=0.200000
     hudIcon=Texture'Engine_res.S_Actor'
     maxCarriedWeapons=3
     heightIndex=1
     armorName="Light"
     infoString="[Info not available]"
     SpeechTag="Light"
     radarInfoClass=Class'RadarInfo'
     bCanUseTurrets=True
     knockbackScale=1.000000
     suicideDamageTypeClass=Class'Engine.Suicided'
     bRestrictions=True
}
