class HUDGrenadesIcon extends HUDEquipmentIcon;

var class previousGrenadeClass;
var int previousGrenadeAmmo;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	if(c.grenades.type == None)
		bVisible = false;
	else
		bVisible = c.grenades.ammo > 0;

	if(bVisible)
	{
		// flashing "updated" indicator
		if(previousGrenadeClass != c.grenades.type || c.grenades.ammo > previousGrenadeAmmo)
			DoUpdateFlash();

		quantityLabel.SetText(""$c.grenades.ammo);
		keyLabel.SetText(c.grenades.hotkey);

		equipmentBar.activeEmptyTexture.material = c.grenades.type.default.hudRefireIcon;
		equipmentBar.activeEmptyTexture.coords = c.grenades.type.default.hudRefireIconCoords;
		equipmentBar.activeFullTexture.material = c.grenades.type.default.hudIcon;
		equipmentBar.activeFullTexture.coords = c.grenades.type.default.hudIconCoords;

		// only show recharge if we can fire
		if(c.grenades.bCanFire)
		{
			equipmentBar.maximumValue = c.grenades.refireTime;
			equipmentBar.value = c.grenades.timeSinceLastFire;
		}
		else
		{
			equipmentBar.maximumValue = 1;
			equipmentBar.value = 1;
		}
	}

	previousGrenadeClass = c.grenades.type;
	previousGrenadeAmmo = c.grenades.ammo;
}