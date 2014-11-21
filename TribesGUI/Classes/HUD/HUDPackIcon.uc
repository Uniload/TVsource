class HUDPackIcon extends HUDEquipmentIcon;

var() config HUDMaterial	rechargingMaterial;
var() config HUDMaterial	activeMaterial;

var ClientSideCharacter.ePackState oldPackState;
var class previousPackClass;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	bVisible = c.pack != None;
	if (bVisible)
	{
		// flashing "updated" indicator
		if(previousPackClass != c.pack)
			DoUpdateFlash();

		quantityLabel.SetText("1");
		keyLabel.SetText(c.packHotkey);

		equipmentBar.activeFullTexture.material = c.pack.default.hudIcon;
		equipmentBar.activeFullTexture.coords = c.pack.default.hudIconCoords;
		equipmentBar.activeEmptyTexture.material = c.pack.default.hudRefireIcon;
		equipmentBar.activeEmptyTexture.coords = c.pack.default.hudRefireIconCoords;
		equipmentBar.maximumValue = 1;
		equipmentBar.value = c.packProgressRatio;

		if(oldPackState != c.packState)
		{
			if(c.packState == c.ePackState.PS_Recharging)
			{
				// set textures and variables for recharge
				equipmentBar.bReverse = false;
				equipmentBar.activeFullTexture = rechargingMaterial;
			}
			else if(c.packState == c.ePackState.PS_Active)
			{
				// set textures and variables for active
				equipmentBar.bReverse = true;
				equipmentBar.activeFullTexture = activeMaterial;
			}
			else if(c.packState == c.ePackState.PS_Ready)
			{
				equipmentBar.bReverse = false;
				equipmentBar.activeFullTexture = fullTexture;
			}
		}

		oldPackState = c.packState;
	}

	previousPackClass = c.Pack;
}

defaultproperties
{
	bDrawQuantity = false
}
