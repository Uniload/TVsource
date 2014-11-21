class TribesInventoryWeaponButton extends TribesInventoryButton;

var InventoryStationAccess.InventoryStationWeapon weaponData;
var bool bIsFallback;

function SetWeaponData(InventoryStationAccess.InventoryStationWeapon data)
{
	weaponData = data;
	Icon = weaponData.weaponClass.default.inventoryIcon;
	Caption = weaponData.weaponClass.default.localizedName;
}
