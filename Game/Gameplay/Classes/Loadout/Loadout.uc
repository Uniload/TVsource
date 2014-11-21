// Loadout
// Defines a set of equipment that can be assigned to a character. Can be used to define
// designer presets as well as the player's custom presets.
//
// Should be used via a class reference.
class Loadout extends Core.Object
	native
	editinlinenew
    perobjectconfig
	config(profiles);

struct native DeployableInfo
{
	var() class<Deployable>		deployableClass "NOT IMPLEMENTED";
	var() int					amount				"NOT IMPLEMENTED Set this field to zero to use the deployable's ammo amount";
};

struct native WeaponInfo
{
	var() class<Weapon>			weaponClass;
	var() int					ammo				"Set this field to zero to use the weapon's ammo amount";
};

struct native GrenadeInfo
{
	var() class<HandGrenade>	grenadeClass;
	var() int					ammo				"Set this field to zero to use the weapon's ammo amount";
};

struct native ConsumableInfo
{
	var() class<Consumable>		consumableClass;
	var() int					amount;
};

var() config class<Pack>							packClass "NOT IMPLEMENTED";
var() config editinline Array<DeployableInfo>		deployableList "NOT IMPLEMENTED";
var() config editinline Array<WeaponInfo>			weaponList;
var() config editinline GrenadeInfo					grenades;
var() config editinline Array<ConsumableInfo>		consumableList;

// isValid
// returns false if the given loadout is invalid for a character
function bool isValid(Character c, Armor a)
{
	local int i;

	// tbd: check validity of pack
	// tbd: check validity of deployables
	// check validity of weapons
	for (i = 0; i < weaponList.Length; i++)
	{
		if (weaponList[i].ammo > c.getMaxAmmo(weaponList[i].weaponClass))
			return false;
	}

	return true;
}

// equip
// gives the equipment in the loadout to the player
function bool equip(Character c)
{
	local int i;
	local int j;
	local Weapon w;
	local HandGrenade hg;

	c.destroyEquipment();

	// add equipment back to front, as addEquipment adds to head

	// add consumables
	for (i = consumableList.Length - 1; i > -1; i--)
	{
//		Log(consumableList[i].consumableClass);
		for (j = 0; j < consumableList[i].amount; ++j)
		{
			c.newEquipment(consumableList[i].consumableClass);
		}
	}

	// add pack
	if (packClass != None)
	{
		c.newPack(packClass);
	}

	// tbd: add deployables

	// add weapons
	for (i = 0; i < weaponList.Length; ++i)
	{
		j = c.getMaxAmmo(weaponList[i].weaponClass);

		if (j != -1)
		{
			w = Weapon(c.newEquipment(weaponList[i].weaponClass));
			w.ammoCount = c.getModifiedAmmo(weaponList[i].ammo);
			
			w.rookMotor = c.motor;    //added line for rookMotor

			// set ammo count if needed
			if (w.ammoCount == 0)
				w.ammoCount = j;
		}
		else
			Log("Warning: weapon in loadout not allowed by armor");
	}

	if (grenades.grenadeClass != None)
	{
		hg = c.newGrenades(grenades.grenadeClass);

		hg.ammoCount = grenades.ammo;

		if (hg.ammoCount == 0)
		{
			j = c.armorClass.static.maxGrenades();

			if (j != -1)
				hg.ammoCount = j;
			else
				hg.ammoCount = 0;
		}
	}

	return true;
}