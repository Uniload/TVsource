class x2InventoryStationAccess extends BaseObjectClasses.InventoryStationAccessDefault;

function serverFinishCharacterAccess(InventoryStationLoadout selectedLoadout, bool returnToUsualMovment, optional Character user)
{



	/* {
		// add each weapon
		workWeaponClass = ValidateWeaponClass(selectedLoadout.weapons[i].weaponClass, newCombatRoleClass.default.armorClass);
		if (workWeaponClass != None)
		{
			newEquipment = currentUser.newEquipment(workWeaponClass);

			// apply pickup delay to prevent exploit of bypassing refire rate by constantly getting new loadouts
			Weapon(newEquipment).applyPickupDelay();

			// remember the first weapon
			if (i == 0)
			{
				workEquipment = newEquipment;
			}
		}
	} */

	// ... add new pack
	workPackClass = ValidatePackClass(selectedLoadout.pack.packClass, newCombatRoleClass.default.armorClass);
	if (workPackClass != None)
		currentUser.newPack(workPackClass);


	super.serverFinishCharacterAccess(InventoryStationLoadout selectedLoadout, bool returnToUsualMovment, optional Character user)
}

function class<Gameplay.Pack> ValidatePackClass(class<Gameplay.Pack> PackClass, class<Gameplay.Armor> armorClass)
{
	local Equipment nextEquipment;

	if (armorClass == None)
	{
		return None;
	}

	if(packClass != None)
	{
		nextEquipment = currentUser.nextEquipment(None, packClass);
		if(nextEquipment != None || ! armorClass.static.isPackAllowed(packClass))
		{
			log("Hacker attempted Gameplay pack hack.");
			return None;
		}
	}

	return packClass;
}

defaultproperties
{
}
