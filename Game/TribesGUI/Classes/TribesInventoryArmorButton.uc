class TribesInventoryArmorButton extends TribesInventoryButton;

var InventoryStationAccess.InventoryStationCombatRole roleData;

function SetArmorData(TeamInfo team, InventoryStationAccess.InventoryStationCombatRole data)
{
	roleData = data;

	Icon = team.GetArmorIconForRole(roleData.combatRoleClass);
	Caption = roleData.combatRoleClass.default.armorClass.default.armorName;
}
