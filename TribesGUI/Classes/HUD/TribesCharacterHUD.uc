class TribesCharacterHUD extends TribesInGameHUD;

var float					lastHitConfirmTime;
var InventoryStationAccess	lastUseableInventory;

simulated function UpdateHUDData()
{
	local PlayerProfile ActiveProfile;
	local String currentCombatRoleClassName;
	local Character character;
	local int i;
	local bool bWasLoadoutSelection;

	super.UpdateHUDData();

	character = GetCharacter();
	if(character == None)
		return;

	UpdateHUDEquipmentData();

	if (clientSideChar.bHitObject && clientSideChar.lastHitObjectTime - lastHitConfirmTime > 0.25)
	{
		lastHitConfirmTime = clientSideChar.lastHitObjectTime;
		PlayerOwner.TriggerEffectEvent('HitNoise');
	}

    // glenn: fix el spammo on none team

    if (character.team()!=none)
    {
	    // could be single player game, no combat role. 
	    // We should set one here in case
	    for(i = 0; i < character.team().combatRoleData.Length; ++i)
	    {
		    if(character.team().combatRoleData[i].role.default.armorClass == character.armorClass)
		    {
			    currentCombatRoleClassName = character.team().combatRoleData[i].role.Outer.Name $"." $character.team().combatRoleData[i].role.Name;
			    break;
		    }
	    }
	}

	bWasLoadoutSelection = clientSideChar.bLoadoutSelection;

	clientSideChar.bLoadoutSelection = Controller.CanUseQuickInventoryLoadoutMenu();
	if(clientSideChar.bLoadoutSelection)
	{
		if(! bWasLoadoutSelection)
		{
			// Start the health injection/ammo replenishment
			character.serverDoInventoryRefill(Controller.CurrentUseableInventoryAccess.healRateHealthFractionPerSecond * character.healthMaximum);

			ActiveProfile = TribesGUIController(Controller.Player.GUIController).profileManager.GetActiveProfile();
			for(i = 0; i < ActiveProfile.loadoutSlots.Length; ++i)
			{
				ClientSideChar.LoadoutNames[i] = ActiveProfile.loadoutSlots[i].LoadoutName;
				if(currentCombatRoleClassName == ActiveProfile.loadoutSlots[i].combatRoleClassName || 
					Controller.CurrentUseableInventoryAccess.IsRoleAvailable(ActiveProfile.loadoutSlots[i].combatRoleClassName))
						ClientSideChar.LoadoutEnabled[i] = 1;
				else
					ClientSideChar.LoadoutEnabled[i] = 0;
			}
		}

		lastUseableInventory = Controller.CurrentUseableInventoryAccess;
	}
}

//
// initialises any action delegates for the hud response
function InitActionDelegates()
{
	super.InitActionDelegates();

	// chat delegates
	if(Response == None)
		Response = new class'HUDAction';

	Response.SelectLoadout = impl_SelectLoadout;
}

//
// cleans up any action delegates for the hud response
function CleanupActionDelegates()
{
	if(Response != None)
		Response.SelectLoadout = None;

	super.CleanupActionDelegates();
}

//
// Selects a loadout
function impl_SelectLoadout(int slot)
{
	local InventoryStationAccess access;
	local CustomPlayerLoadout SelectedLoadout;
	local int i;
	local class<Weapon> weapons[10];

	// ensure that the access is still valid
/*	if(! ClassIsChildOf(Controller.GetUseableObjectClass(), class'InventoryStationAccess'))
	{
		log("access no longer valid");
		return;
	}
*/
	access = Controller.CurrentUseableInventoryAccess;
	if(access == None)
	{
		log("Invalid Inventory station access");
		return;
	}

	// if they are already the 'proper' user of this access, then
	// don't let them do a quick loadout
	if(Controller.character == access.currentUser)
		return;

	SelectedLoadout = TribesGUIController(Controller.Player.GUIController).profileManager.GetActiveProfile().GetLoadout(slot);
	if(SelectedLoadout == None)
	{
		log("Invalid loadout selection");
		return;
	}

	for(i = 0; i < SelectedLoadout.weaponList.Length && i < access.maxWeapons; i++)
		weapons[i] = SelectedLoadout.weaponList[i].weaponClass;

	if (Controller.Level.NetMode == NM_Client && Controller.character != None)
		Controller.character.detachGrapple();

	Controller.character.StopMovementEffects();
	Controller.ResetInputState();

	Controller.serverFinishQuickInventoryStationAccess(
		access,
		SelectedLoadout.combatRoleClass, 
		SelectedLoadout.static.GetSkinPreference(SelectedLoadout.skinPreferences, Controller.character.team().GetMeshForRole(SelectedLoadout.combatRoleClass, Controller.character.bIsFemale)), 
		0, 
		SelectedLoadout.packClass, 
		SelectedLoadout.grenades.grenadeClass, 
		weapons[0], 
		weapons[1], 
		weapons[2], 
		weapons[3], 
		weapons[4], 
		weapons[5], 
		weapons[6], 
		weapons[7], 
		weapons[8], 
		weapons[9]);
}

defaultproperties
{
	HUDScriptType = "TribesGUI.TribesCharacterHUDScript"
	HUDScriptName = "default_CharacterHUD"
}