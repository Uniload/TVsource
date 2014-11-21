class HUDHealthKitIcon extends HUDEquipmentIcon;

var() config HUDMaterial	lowHealthAlertMaterial;
var() config float			lowHealthThreshold;

var bool bMaterialsSwitched;

function UpdateData(ClientSideCharacter c)
{
	bVisible = c.healthKit != None;
	if (bVisible)
	{
		quantityLabel.SetText(""$c.healthKitQuantity);
		keyLabel.SetText(c.healthKitHotkey);

		if(FClamp(c.health / c.healthMaximum, 0.0, 1.0) < lowHealthThreshold)
		{
			if(! bMaterialsSwitched)
			{
				equipmentBar.activeFullTexture = lowHealthAlertMaterial;
				bMaterialsSwitched = true;
			}
		}
		else
		{
			bMaterialsSwitched = false;
			equipmentBar.activeFullTexture = equipmentBar.fullTexture;
		}

		equipmentBar.activeFullTexture.material = c.healthKit.default.hudIcon;
		equipmentBar.activeFullTexture.coords = c.healthKit.default.hudIconCoords;
		equipmentBar.activeEmptyTexture.material = c.healthKit.default.hudRefireIcon;
		equipmentBar.activeEmptyTexture.coords = c.healthKit.default.hudRefireIconCoords;
		equipmentBar.maximumValue = 1;
		equipmentBar.value = 1;
	}

	super.UpdateData(c);
}

defaultproperties
{
	lowHealthThreshold = 0.25
	bDrawQuantity = false
}