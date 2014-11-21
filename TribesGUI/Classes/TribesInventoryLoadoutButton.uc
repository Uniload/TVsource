class TribesInventoryLoadoutButton extends TribesInventoryButton;

var InventoryStationAccess.InventoryStationLoadout	loadoutData;
var CustomPlayerLoadout	customLoadoutData;

var int					slotIndex;
var bool				bEmptySlot;
var localized String	emptyText;

function Refresh()
{
	Caption = customLoadoutData.loadoutName;
}

function SetEmpty(bool empty)
{
	bEmptySlot = empty;
	if(bEmptySlot)
		Caption = emptyText;
}

defaultproperties
{
	bAllowMultiLine = true
	bEmptySlot	 = true
	emptyText	= "Empty"
}