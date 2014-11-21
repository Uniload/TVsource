class TribesInventoryPackButton extends TribesInventoryButton;

var InventoryStationAccess.InventoryStationPack packData;

function SetPackData(InventoryStationAccess.InventoryStationPack data)
{
	packData = data;
	Icon = packData.packClass.default.inventoryIcon;
	Caption = packData.packClass.default.localizedName;
}
