interface InventoryStationAccessControl
	dependsOn(InventoryStationAccess);

function bool isOnCharactersTeam(Character testCharacter);

/// Armor Index of 0 implies light, 1 medium and 2 heavy.
function accessRequired(Character accessor, InventoryStationAccess access, int armorIndex);

/// Character no longer requires inventory station access.
/// Called after accessRequired but before isAccessible has returned true.
function accessNoLongerRequired(Character accessor);

/// Returns true if Inventory Station can be accessed by the specified character.
/// Pre-Condition: a corresponding accessRequired call was made without a corresponding
/// accessNoLongerRequired
/// Pre-Condition: function is yet to return true (implies that after this function returns true it cannot
/// be called again with the same character until another accessRequired call)
function bool isAccessible(Character accessor);

function bool isFunctional();

function changeApplied(InventoryStationAccess access);

function bool directUsage();

function accessFinished(Character user, bool returnToUsualMovment);

/// Provides an opportunity to set the weapons to be displayed on the interface. Return false top use the default behaviour.
simulated function bool getCurrentLoadoutWeapons(out InventoryStationAccess.InventoryStationLoadout weaponLoadout, Character user);