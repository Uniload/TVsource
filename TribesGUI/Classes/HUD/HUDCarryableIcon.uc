class HUDCarryableIcon extends HUDEquipmentIcon;

var class previousCarryableClass;
var int previousCarryableAmount;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	bVisible = c.carryable != None && c.numCarryables > 0;
	if(bVisible)
	{
		if(previousCarryableClass != c.carryable && previousCarryableAmount < c.numCarryables)
			DoUpdateFlash();

		quantityLabel.SetText(""$c.numCarryables);
		keyLabel.SetText(c.carryableHotkey);

		equipmentBar.activeFullTexture.material = c.carryable.default.hudIcon;
		equipmentBar.activeFullTexture.coords = c.carryable.default.hudIconCoords;

		equipmentBar.maximumValue = 1;
		equipmentBar.value = 1;
	}

	previousCarryableClass = c.carryable;
	previousCarryableAmount = c.numCarryables;
}