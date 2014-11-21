class InventoryStationAccess extends BaseDeviceAccess
	notplaceable
	dependsOn(CustomPlayerLoadout);

/// Inventory Station Protocol
///
/// Server										Client
///
/// UsedBy: Player pressed used in vicinity
/// of Inventory Station. Registers players
/// desire to use inventory station.
///
///												clientInventoryStationWait: Puts client into waiting state.
///
/// Tick: Waits for inventory station to
/// become accessible and then calls
/// characterAccess.
///
/// characterAccess: Puts user's Controller
/// into PlayerUsingInventoryStation state
/// and calls clientInventoryStationAccess on
/// user's Controller.
///
///												clientInventoryStationAccess: Hides HUD and
///												displays Inventory Station UI.
///
///												*** Player selects Loadout and eventually presses "Done". ***
///
///												finishCharacterAccess: Called by UI. Calls
///												serverFinishInventoryStationAccess on user's Controller and
///												clientTerminateCharacterAccess.
///
/// serverFinishInventoryStationAccess:			clientTerminateCharacterAccess: Calls
/// Confirms user was actually using this		clientFinishInventoryStationAccess on user's Controller.
/// Inventory Station. Puts user back into
/// default state and calls						clientFinishInventoryStationAccess: Shows HUD and removes
/// serverFinishCharacterAccess.				Inventory Station UI.
///
/// serverFinishCharacterAccess:
/// Confirms validity of selected loadout
/// and applies it.
///
/// *********************************************************************************************************
///
/// CASE INVENTORY STATION CEASES TO BE FUNCTIONAL WHILE BEING USED OR USER IS BLOWN OFF
///
/// *** Termination Condition Activated ***
///
/// Tick: Detects termination condition
/// and calls
/// serverTerminateInventoryStationAccess on
/// user's controller as a result.
///
/// serverTerminateInventoryStationAccess:
/// call serverTerminateCharacterAccess and
/// clientTerminateInventoryStationAccess.
///
/// serverTerminateCharacterAccess:
/// Puts user's controller into default
/// state.
///
///												clientTerminateInventoryStationAccess: Calls
///												clientFinishInventoryStationAccess (see above).

var private InventoryStationAccessControl accessControl;

var(InventoryStationAccess) float	healRateHealthFractionPerSecond	"Heal rate for the health injection";
var(InventoryStationAccess) bool	bCanUseCustomLoadouts			"Whether this station allows users to utilise custom loadouts";
var(InventoryStationAccess) bool	bAutoFillWeapons				"Whether to fill out the weapons array automatically";
var(InventoryStationAccess) bool	bAutoFillPacks					"Whether to fill out the packs array automatically";
var(InventoryStationAccess) bool	bAutoFillCombatRoles			"Whether to fill out the combat roles array automatically";
var(InventoryStationAccess) bool	bAutoConfigGrenades				"Whether to set the grenades class automatically";
var(InventoryStationAccess) bool	bInventoryTutorial				"Is this inventory station in tutorial mode";
var(InventoryStationAccess) int		NumFallbackWeapons				"Number of fall back weapons for the station (At the start of the weapons array)";
var(InventorystationAccess) bool	bDispenseGrenades				"Whether this station dispenses grenades";

var Character	currentUser;
var float		percentageHealth;
var vector		userPosition;
var bool		bWaitingForAccess;
var const int	maxWeapons;

struct InventoryStationCombatRole
{
	var () class<CombatRole> combatRoleClass;
	var () bool bEnabled;
};

struct InventoryStationPack
{
	var() class<Pack>	packClass;
	var() bool			bEnabled;
};

struct InventoryStationWeapon
{
	var() class<Weapon>	weaponClass;
	var() bool			bEnabled;
};

struct InventoryStationGrenades
{
	var() class<HandGrenade>	grenadeClass;
	var() bool					bEnabled;
};

struct InventoryStationLoadout
{
	var InventoryStationCombatRole		role;
	var InventoryStationWeapon			weapons[10];
	var int								activeWeaponSlot;
	var InventoryStationPack			pack;
	var InventoryStationGrenades		grenades;
	var bool							NoLoadout;
	var string							userSkin;
};

var(InventoryStationAccess) Array<InventoryStationCombatRole>	roles;
var(InventoryStationAccess) Array<InventoryStationWeapon>		weapons;
var(InventoryStationAccess) Array<InventoryStationPack>			packs;
var(InventoryStationAccess) Array<InventoryStationLoadout>		loadouts;
var(InventoryStationAccess) InventoryStationGrenades			grenades;
var(InventoryStationAccess) int									defaultLoadoutIndex;

replication
{
	reliable if (Role == ROLE_Authority)
		accessControl;
}


simulated function UpdatePrecacheRenderData()
{
	local int i;

	Super.UpdatePrecacheRenderData();

	// precache weapons
	for (i = 0; i < weapons.Length; ++i)
	{
		if (weapons[i].bEnabled)
			class'Weapon'.static.PrecacheWeaponRenderData(Level, weapons[i].weaponClass);
	}
}

// checks if a role is available by its FULL class name
simulated function bool IsRoleAvailable(String roleClassName)
{
	local int i;

	for(i = 0; i < roles.Length; ++i)
	{
		if(roleClassName ~= (roles[i].combatRoleClass.Outer.Name $"." $roles[i].combatRoleClass.Name) && roles[i].bEnabled)
			return true;
	}

	return false;
}

function InventoryStationAccess getCorrespondingInventoryStation()
{
	return self;
}

simulated function int getNumberLoadouts()
{
	return loadouts.Length;
}

simulated function InventoryStationLoadout getLoadout(int loadoutIndex)
{
	return loadouts[loadoutIndex];
}

simulated function InventoryStationLoadout getDefaultLoadout()
{
	return loadouts[defaultLoadoutIndex];
}

simulated function clientSetupInventoryStation(Character user)
{
	local int i;
	local InventoryStationWeapon w;
	local InventoryStationPack p;
	local InventoryStationCombatRole newRole;

	currentUser = user;
	if(currentUser != None)
		percentageHealth = FClamp(currentUser.health / currentUser.healthMaximum, 0.0, 1.0);
	else
		percentageHealth = 1.0;

	//================================
	// Auto Fill debug - fill out arrays

	if(bAutoFillWeapons)
	{
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
	if(bAutoFillCombatRoles && currentUser != None)
	{
		for(i = 0; i < currentUser.team().combatRoleData.Length; ++i)
		{
			newRole.combatRoleClass = currentUser.team().combatRoleData[i].role;
			newRole.bEnabled = true;
			roles[i] = newRole;
		}
	}
}

function bool CanBeUsedBy(Pawn user)
{
	local Character characterUser;
	local PlayerCharacterController playerController;

	playerController = PlayerCharacterController(user.controller);

	characterUser = Character(user);

	// do nothing if used by non-character
	if (characterUser == None)
		return false;

	// do nothing if no player controller
	if (playerController == None)
		return false;

	// if an enemy do nothing
	if (!accessControl.isOnCharactersTeam(characterUser))
		return false;

	// if user is currently using inventory station have user exit
	if (user == currentUser)
		return false;

	// do nothing if inventory station is currently begin used
	if (currentUser != None)
		return false;

	// do nothing if inventory station is not functional
	if (!accessControl.isFunctional())
		return false;

	return true;
}

function initialise(InventoryStationAccessControl newAccessControl)
{
	accessControl = newAccessControl;
}

simulated function InventoryStationLoadout GetCurrentUserLoadout()
{
	local InventoryStationLoadout currentLoadout;
	local Equipment nextEquipment;
	local int i;


	// combat role
	if(currentUser.combatRole == None)
	{
		// could be single player game, no combat role. 
		// We should set one here in case
		for(i = 0; i < currentUser.team().combatRoleData.Length; ++i)
		{
			if(currentUser.team().combatRoleData[i].role.default.armorClass == currentUser.armorClass)
			{
				currentUser.combatRole = currentUser.team().combatRoleData[i].role;
				break;
			}
		}
	}

	if(currentUser.combatRole != None)
	{
		currentLoadout.role.combatRoleClass = currentUser.combatRole;
	}
	else
	{
		currentLoadout.NoLoadout = true;
		return currentLoadout;
	}

	// skin
	currentLoadout.userSkin = PlayerCharacterController(currentUser.controller).getSkinPreference(currentUser.Mesh);

	// weapons
	if (!accessControl.getCurrentLoadoutWeapons(currentLoadout, currentUser))
	{
		for(i = 0; i < 10; ++i)
			currentLoadout.weapons[i].weaponClass = None;

		for (i = 0; i < class'Character'.const.NUM_WEAPON_SLOTS; ++i)
			if (currentUser.weaponSlots[i] != None)
				currentLoadout.weapons[i].weaponClass = currentUser.weaponSlots[i].class;
	}

	// pack
	nextEquipment = currentUser.nextEquipment(None, class'Gameplay.Pack');
	if(nextEquipment != None)
		currentLoadout.pack.packClass = class<Pack>(nextEquipment.class);

	// grenades
	nextEquipment = HandGrenade(currentUser.altWeapon);
	if(nextEquipment != None)
		currentLoadout.grenades.grenadeClass = class<HandGrenade>(nextEquipment.class);

	return currentLoadout;
}

/// Called on server when user presses use key in vicinity of inventory station.
function UsedBy(Pawn user)
{
	local Character characterUser;
	local bool result;

	if (!accessControl.directUsage())
		return;

	characterUser = Character(user);

	// do nothing if used by non-character
	if (characterUser == None)
		return;

	result = usedByProcessing(characterUser);

	// only super if actually using
	if (result)
	{
		super.UsedBy(user);
		characterUser.unifiedSetVelocity(Vect(0, 0, 0));
	}
}

// Does processing associated with a character using the inventory station. May be called directly.
function bool usedByProcessing(Character user)
{
	local PlayerCharacterController playerController;

	playerController = PlayerCharacterController(user.controller);

	// do nothing if no player controller
	if (playerController == None)
		return false;

	// if an enemy do nothing
	if (!accessControl.isOnCharactersTeam(user))
	{
		log("Attempted To Use Enemy Inventory Station");
		return false;
	}

	// if user is currently using inventory station have user exit
	if (user == currentUser)
	{
		clientTerminateCharacterAccess(currentUser);
		return false;
	}

	// do nothing if inventory station is currently being used
	if (currentUser != None)
	{
		log("INVENTORY STATION ALREADY BEING USED");
		return false;
	}

	// do nothing if inventory station is not functional
	if (!accessControl.isFunctional())
	{
		log("INVENTORY STATION CANNOT BE ACCESSED");
		return false;
	}

	currentUser = user;

	// register interest to access inventory station
	accessControl.accessRequired(user, self, currentUser.armorClass.default.heightIndex);
	bWaitingForAccess = true;

	// store use position
	userPosition = currentUser.location;

	// check if access can begin immediately
	if (accessControl.isAccessible(currentUser))
	{
		characterAccess();
		bWaitingForAccess = false;
	}
	else
	{
		playerController.GotoState('PlayerWaitingInventoryStation');
		playerController.clientInventoryStationWait();
	}

	return true;
}

function tick(float deltaSeconds)
{
	local bool isTouching;
	local Actor touchingTest;

	Super.tick(deltaSeconds);

	// if there is no access control, then just return
	if(accessControl == None)
		return;

	// bWaitingForAccess should never be true when currentUser is None
	if (bWaitingForAccess && currentUser == None)
		bWaitingForAccess = false;

	// check if access can begin
	if (bWaitingForAccess && accessControl.isAccessible(currentUser))
	{
		characterAccess();
		bWaitingForAccess = false;
		return;
	}

	// check if access must be terminated
	if (currentUser != None && !accessControl.isFunctional())
	{
		PlayerCharacterController(currentUser.Controller).serverTerminateInventoryStationAccess();
		return;
	}

	// check if user has been blown off inventory station
	if (accessControl.directUsage() && currentUser != None)
	{
		isTouching = false;
		foreach touchingActors(class'Actor', touchingTest)
			if (touchingTest == currentUser)
				isTouching = true;
		if (!isTouching)
		{
			serverTerminateCharacterAccess();

			// ... inform access control so as user will be removed from queue
			if (bWaitingForAccess)
				accessControl.accessNoLongerRequired(currentUser);
				
			currentUser = None;
			bWaitingForAccess = false;
			return;
		}
	}

	// Why not just apply an injection when the user enters?

	// while current user is actually using inventory station regenerate health
/*	if (currentUser != None && PlayerCharacterController(currentUser.Controller).isInState(
				'PlayerUsingInventoryStation'))
	{
		currentUser.increaseHealth(deltaSeconds * healRateHealthPerSecond);
	}
*/	
}

/// Grants inventory station access to a user. Called on server.
function characterAccess()
{
	local PlayerCharacterController playerController;

	if (bDeleteMe)
		return;

	playerController = PlayerCharacterController(currentUser.controller);

	// do nothing if no player controller
	if (playerController == None)
		return;

	playerController.inventoryStation = self;

	playerController.clientInventoryStationAccess(self);

	playerController.GotoState('PlayerUsingInventoryStation');

	// stop any previous health injections
	currentUser.stopHealthInjection();
	// and start an all new one! This uses a really big amount to
	// account for hte fact that the user can change armor and we want
	// it to fill all the way up.
	currentUser.healthInjection(healRateHealthFractionPerSecond * currentUser.healthMaximum, 500);
}

/// Does processing assocaited with a character actually electing to finish usage of an inventory station.
/// Called on client from Inventory Station user interface.
simulated function finishCharacterAccess(InventoryStationLoadout selectedLoadout)
{
	local PlayerCharacterController playerController;
	local Character cachedUser;

	playerController = PlayerCharacterController(currentUser.controller);

	// do nothing if no player controller
	if (playerController == None)
		return;

	cachedUser = currentUser;

	playerController.serverFinishInventoryStationAccess(
			self, 
			selectedLoadout.role.combatRoleClass,
			selectedLoadout.userSkin,
			selectedLoadOut.activeWeaponSlot,
			selectedLoadOut.pack.packClass,
			selectedLoadOut.grenades.grenadeClass,
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

	// current user may or may not be None here

	clientTerminateCharacterAccess(cachedUser);

	currentUser = None;
}

/// Called on the server from the server. Applies selected loadout to user. If returnToUsualMovment is true the character shall go back
/// to the usual movement state.
function serverFinishCharacterAccess(InventoryStationLoadout selectedLoadout, bool returnToUsualMovment, optional Character user)
{
	local class<CombatRole> newCombatRoleClass;
	local Mesh newMesh;
	local Jetpack jetpack;
	local Mesh armsMesh;
	local float temporaryHealth;

	local vector originalLocation;
	local float originalHeight;
	local vector originalOrigin;

//	local vector newLocation;

	local Equipment workEquipment;
	local Equipment newEquipment;
	local Weapon newWeapon;
	local HandGrenade newGrenades;

	local class<Gameplay.Weapon> workWeaponClass;
	local class<Gameplay.Pack> workPackClass;

	local int numHealthKits, maxHealthKits;
	local class<Consumable> healthKitClass;

	local bool bIsFemale;
	local int i;
	local bool armorEnabled;

	local PlayerCharacterController playerController;

	if(user != None)
		currentUser = user;

	if(currentUser == None)
	{
		Warn("currentUser was None in serverFinishCharacterAccess on '"$self $"' (user='" $user $"', returnToUsualMovment='" $returnToUsualMovment $"')");
		//
		// try and exit anyway, but there is no point in carrying on with this function:
		// without a PlayerController & Character there is nothing we can do.
		//
		accessControl.accessFinished(None, returnToUsualMovment);
		return;
	}

	// if the user has selected armor of their existing type, then they can have it
	// otherwise, we need to validate that this armor is enabled in this access.
	if(selectedLoadout.role.combatRoleClass.default.armorClass == currentUser.armorClass)
	{
		armorEnabled = true;
	}
	else
	{
		armorEnabled = false;
		for(i = 0; i < roles.Length; ++i)
		{
			if(selectedLoadout.role.combatRoleClass.default.armorClass == roles[i].combatRoleClass.default.ArmorClass && roles[i].bEnabled)
				armorEnabled = true;
		}
	}

	if(! armorEnabled)
	{
		LOG("User attempted to select an armor class which was unavailable: Reverting to previous armor.");
		accessControl.accessFinished(None, returnToUsualMovment);
		return;
	}


	playerController = PlayerCharacterController(currentUser.controller);

	if(playerController.IsSinglePlayer())
		bIsFemale = currentUser.bIsFemale;
	else
		bIsFemale = playerController.PlayerReplicationInfo.bIsFemale;

	accessControl.accessFinished(currentUser, returnToUsualMovment);

	accessControl.changeApplied(self);

	percentageHealth = FClamp(currentUser.health / currentUser.healthMaximum, 0.0, 1.0);

	// change to selected pack

	// ... delete pack (should only be one)
	workEquipment = currentUser.nextEquipment(None, class'Gameplay.Pack');
	while (workEquipment != None)
	{
		currentUser.removeEquipment(workEquipment);
		workEquipment.destroy();
		workEquipment = currentUser.nextEquipment(None, class'Gameplay.Pack');
	}

	// ... add new pack
	workPackClass = selectedLoadout.pack.packClass;
	if (workPackClass != None)
		currentUser.newPack(workPackClass);

	// ... charge pack
	if (currentUser.pack != None)
		currentUser.pack.setCharged();

	// change to selected armour if armour is different
	newCombatRoleClass = selectedLoadout.role.combatRoleClass;
	if (selectedLoadout.role.combatRoleClass.default.armorClass != currentUser.armorClass)
	{
		originalOrigin = currentUser.getMeshOrigin();
		originalLocation = currentUser.location;
		originalHeight = currentUser.collisionHeight;

		// ... change armour (do not add additional health)
		temporaryHealth = currentUser.health;
		currentUser.combatRole = newCombatRoleClass;

		newCombatRoleClass.default.armorClass.static.equip(currentUser);
		// apply the health modifier
		if(SinglePlayerCharacter(currentUser) != None)
		{
			currentUser.healthMaximum *= SinglePlayerCharacter(currentUser).healthModifier;
			if(currentUser.bApplyHealthFilter)
				currentUser.healthMaximum *= SinglePlayerGameInfo(currentUser.Level.Game).difficultyMods[TribesGUIControllerBase(PlayerController(currentUser.Controller).Player.GUIController).GuiConfig.CurrentCampaign.selectedDifficulty].playerHealthMultiplier;
		}
		if (temporaryHealth > currentUser.healthMaximum)
			temporaryHealth = currentUser.healthMaximum;
		currentUser.health = temporaryHealth;

		// ... change mesh
		newMesh = currentUser.team().getMeshForRole(newCombatRoleClass, bIsFemale);
		if (newMesh != None)
			currentUser.LinkMesh(newMesh);
		else
			log("InventoryStationAccess: No mesh defined for combat role "$newCombatRoleClass$", team "$
					currentUser.team()$ ", bIsFemale "$ bIsFemale);

/*		// ... move character to correct height
		newLocation = originalLocation - originalOrigin;
		newLocation.z = newLocation.z - originalHeight + currentUser.collisionHeight;
		newLocation += currentUser.getMeshOrigin();
		currentUser.unifiedSetPosition(newLocation);
*/
		// ... change jetpack mesh
		jetpack = currentUser.team().getJetpackForRole(currentUser, newCombatRoleClass, bIsFemale);
		currentUser.setJetpack(jetpack);

		// ... change arms mesh
		armsMesh = currentUser.team().getArmsMeshForRole(newCombatRoleClass);
		currentUser.setArmsMesh(armsMesh);
	}

	// change to selected weapons

	// ... delete all current weapons
	workEquipment = currentUser.nextEquipment(None, class'Gameplay.Weapon');
	while (workEquipment != None)
	{
		if (currentUser.Weapon == workEquipment)
			currentUser.weapon = None;

		currentUser.removeEquipment(workEquipment);
		workEquipment.destroy();

		workEquipment = currentUser.nextEquipment(None, class'Gameplay.Weapon');
	}

	// ... add new weapons and set ammo counts to maximum allowed by loadout spec

	for(i = 0; i < selectedLoadout.role.combatRoleClass.default.armorClass.default.maxCarriedWeapons; ++i)
	{
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
	}

	// ... set all weapons to max ammo
	newWeapon = Weapon(currentUser.nextEquipment(None, class'Weapon'));
	while (newWeapon != None)
	{
		newWeapon.ammoCount = currentUser.getMaxAmmo(newWeapon.class);
		newWeapon = Weapon(currentUser.nextEquipment(newWeapon, class'Weapon'));
	}
	
	// ... select first weapon
	if (workEquipment != None)
		currentUser.motor.setWeapon(Weapon(workEquipment));
	else
		currentUser.motor.setWeapon(currentUser.fallbackWeapon);

	// change to selected pack

	// ... delete pack (should only be one)
	workEquipment = currentUser.nextEquipment(None, class'Gameplay.Pack');
	while (workEquipment != None)
	{
		currentUser.removeEquipment(workEquipment);
		workEquipment.destroy();
		workEquipment = currentUser.nextEquipment(None, class'Gameplay.Pack');
	}

	// ... add new pack
	workPackClass = selectedLoadout.pack.packClass;
	if (workPackClass != None)
		currentUser.newPack(workPackClass);

	// ... charge pack
	if (currentUser.pack != None)
		currentUser.pack.setCharged();

	// Fill up on health kits
	numHealthKits = currentUser.numHealthKitsCarried();
	maxHealthKits = currentUser.armorClass.static.maxHealthKits();
	healthKitClass = currentUser.armorClass.static.getHealthKitClass();

	if (maxHealthKits != -1 && healthKitClass != None)
		for(numHealthKits = numHealthKits; numHealthKits < maxHealthKits; ++numHealthKits)
			currentUser.newEquipment(healthKitClass);
	// add health kit if character does not have one
	//if (bAutoFillHealthKits && currentUser.nextEquipment(None, currentUser.armorClass.static.getHealthKitClass()) == None)
	//{
	//	currentUser.newEquipment(currentUser.armorClass.static.getHealthKitClass());
	//}

	// take the grenades away from the user
	if(currentUser.altWeapon != None)
		currentUser.altWeapon.ammoCount = 0;

	// give the user grenades
	if(bDispenseGrenades)
	{
		if(selectedLoadout.grenades.grenadeClass != None)
			newGrenades = currentUser.newGrenades(selectedLoadout.grenades.grenadeClass);
		else if(grenades.bEnabled && grenades.grenadeClass != None)
			newGrenades = currentUser.newGrenades(grenades.grenadeClass);

		// apply pickup delay to prevent exploit of bypassing refire rate by constantly getting new loadouts
		newGrenades.applyPickupDelay();
	}

	// give character full energy
	currentUser.energy = currentUser.energyMaximum;

	// we applied a health injection when the user enteres the station, and
	// now we need to ensure that the remaining health injection will fill
	// the user to full health:
	currentUser.health = percentageHealth * currentUser.healthMaximum;
	currentUser.StopHealthInjection();
	currentUser.healthInjection(healRateHealthFractionPerSecond * currentUser.healthMaximum,
			currentUser.healthMaximum - currentUser.health);

	// change skin
	playerController.clientSetSkinPreference(currentUser.Mesh, selectedLoadout.userSkin);
	playerController.serverSetSkin(selectedLoadout.userSkin, currentUser.Mesh);
	//currentUser.tribesReplicationInfo.userSkinName = selectedLoadout.userSkin;

	if (returnToUsualMovment)
		currentUser.Controller.GotoState('CharacterMovement');
	else
		currentUser.Controller.GotoState('');
	currentUser.calculateExtents();
	currentUser.Wake();

	currentUser = None;
}

function serverTerminateCharacterAccess()
{
	// inform access control
	if (bWaitingForAccess)
		accessControl.accessNoLongerRequired(currentUser);
	else
		accessControl.accessFinished(currentUser, true);

	// we applied a health injection when the user enteres the station, and
	// now we need to ensure that the remaining health injection will fill
	// the user to full health:
	currentUser.StopHealthInjection();
	currentUser.healthInjection(healRateHealthFractionPerSecond * currentUser.healthMaximum, 
		currentUser.healthMaximum - currentUser.health);

	// update movement
	currentUser.Controller.GotoState('CharacterMovement');
	currentUser.calculateExtents();
	currentUser.Wake();

	// update properties
	currentUser = None;
	bWaitingForAccess = false;
}

// returns None if the weapon class is not allowed on the armor
function class<Gameplay.Weapon> ValidateWeaponClass(class<Gameplay.Weapon> weaponClass, class<Gameplay.Armor> armorClass)
{
	local Equipment nextEquipment;

	if (armorClass == None)
	{
		warn("armorClass is None");
		return None;
	}

	if(weaponClass != None)
	{
		nextEquipment = currentUser.nextEquipment(None, weaponClass);
		if(nextEquipment != None || ! armorClass.static.isWeaponAllowed(weaponClass))
		{
			log("LOOK AT YOU HACKER! PANTING AND SWEATING AS YOU TRY TO SELECT A WEAPON YOU ARE NOT ALLOWED TO HAVE!");
			return None;
		}
	}

	return weaponClass;
}


/// Abruptly forces character to finish using this inventory station. Called on server.
simulated function clientTerminateCharacterAccess(Character user)
{
	local PlayerCharacterController playerController;

	playerController = PlayerCharacterController(user.controller);

	if(currentUser != None)
		currentUser.stopHealthInjection();

	// do nothing if no player controller
	if (playerController == None)
		return;

	playerController.clientFinishInventoryStationAccess();
}

/// Returns the vehicle corresponding to this inventory station. Might be None.
function Vehicle getVehicleBase()
{
	return Vehicle(accessControl);
}

defaultproperties
{
	DrawType = DT_None
	bHidden = false

	bAlwaysRelevant = false

	bHardAttach=true
	bCollideActors=false
	CollisionRadius=+0080.000000
	CollisionHeight=+0100.000000
	bCollideWhenPlacing=false
	bOnlyAffectPawns=true

	RemoteRole=ROLE_SimulatedProxy

	bWaitingForAccess=false

	healRateHealthFractionPerSecond=0.04

	bAutoFillCombatRoles	= true
	bAutoFillWeapons		= true
	bAutoFillPacks			= true
	bAutoConfigGrenades		= true
	bCanUseCustomLoadouts	= true

	bDispenseGrenades = true

	maxWeapons = 10
	numFallbackWeapons = 1;

	prompt = "Press '%1' to enter the Inventory Station"
	markerOffset = (X=0,Y=-80,Z=0)
}
