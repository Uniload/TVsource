///
/// class: InventoryStationStandaloneAccess
///
/// Implements an InventoryStationAccess class which can be 
/// used without the need for a physical InventoryStation object
///
class InventoryStationStandaloneAccess extends InventoryStationAccess;

var TeamInfo				playerTeam;

//
// 
//
simulated function SetupAccessData(TeamInfo team)
{
	local int i;
	local InventoryStationWeapon w;
	local InventoryStationPack p;
	local InventoryStationCombatRole newRole;

	playerTeam = team;

	//================================
	// Auto Fill debug - fill out arrays

	if(bAutoFillWeapons)
	{
		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponEnergyBlade", class'class'));
		w.bEnabled = true;
		weapons[10] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponSpinfusor", class'class'));
		w.bEnabled = true;
		weapons[0] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponChaingun", class'class'));
		w.bEnabled = true;
		weapons[1] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponBlaster", class'class'));
		w.bEnabled = true;
		weapons[2] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponGrenadeLauncher", class'class'));
		w.bEnabled = true;
		weapons[3] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponSniperRifle", class'class'));
		w.bEnabled = true;
		weapons[4] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponMortar", class'class'));
		w.bEnabled = true;
		weapons[5] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponRocketPod", class'class'));
		w.bEnabled = true;
		weapons[6] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponBuckler", class'class'));
		w.bEnabled = true;
		weapons[7] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponBurner", class'class'));
		w.bEnabled = true;
		weapons[8] = w;

		w.weaponClass = class<Weapon>(DynamicLoadObject("EquipmentClasses.WeaponGrappler", class'class'));
		w.bEnabled = true;
		weapons[9] = w;
	}

	if(bAutoFillPacks)
	{
		p.packClass = class<Pack>(DynamicLoadObject("EquipmentClasses.PackSpeed", class'class'));
		p.bEnabled = true;
		packs[0] = p;

		p.packClass = class<Pack>(DynamicLoadObject("EquipmentClasses.PackRepair", class'class'));
		p.bEnabled = true;
		packs[1] = p;

		p.packClass = class<Pack>(DynamicLoadObject("EquipmentClasses.PackEnergy", class'class'));
		p.bEnabled = true;
		packs[2] = p;

		p.packClass = class<Pack>(DynamicLoadObject("EquipmentClasses.PackShield", class'class'));
		p.bEnabled = true;
		packs[3] = p;
	}

	if(bAutoConfigGrenades)
	{
		grenades.grenadeClass = class<HandGrenade>(DynamicLoadObject("EquipmentClasses.WeaponHandGrenade", class'class'));
		grenades.bEnabled = true;
	}
	//================================

	// fill out the roles array with team data
	if(bAutoFillCombatRoles)
	{
		for(i = 0; i < playerTeam.combatRoleData.Length; ++i)
		{
			newRole.combatRoleClass = playerTeam.combatRoleData[i].role;
			newRole.bEnabled = true;
			roles[i] = newRole;
		}
	}

	percentageHealth = 1.0;
}

//
// Returns NoLoadout to force the UI to use the profile data
//
simulated function InventoryStationLoadout GetCurrentUserLoadout()
{
	local InventoryStationLoadout loadout;

	loadout.NoLoadout = true;

	return loadout;
}

//
// Overridden to just store the selected loadout and exit.
//
simulated function finishCharacterAccess(InventoryStationLoadout selectedLoadout)
{
	PlayerCharacterController(Level.GetLocalPlayerController()).
		serverFinishEquippingPreRestart(
			selectedLoadout.role.combatRoleClass,
			selectedLoadout.userSkin,
			selectedLoadout.activeWeaponSlot,
			selectedLoadout.pack.packClass,
			selectedLoadout.grenades.grenadeClass,
			selectedLoadout.weapons[0].weaponClass,
			selectedLoadout.weapons[1].weaponClass,
			selectedLoadout.weapons[2].weaponClass,
			selectedLoadout.weapons[3].weaponClass,
			selectedLoadout.weapons[4].weaponClass,
			selectedLoadout.weapons[5].weaponClass,
			selectedLoadout.weapons[6].weaponClass,
			selectedLoadout.weapons[7].weaponClass,
			selectedLoadout.weapons[8].weaponClass,
			selectedLoadout.weapons[9].weaponClass);
}

