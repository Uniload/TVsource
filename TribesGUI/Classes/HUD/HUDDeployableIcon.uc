class HUDDeployableIcon extends HUDEquipmentIcon;

var() config HUDMaterial	selectedMaterial;

var class previousDeployableClass;

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	bVisible = c.deployable != None;
	if (bVisible)
	{
		if(previousDeployableClass != c.deployable)
			DoUpdateFlash();

		quantityLabel.SetText("1");
		keyLabel.SetText(c.deployableHotkey);

		equipmentBar.activeFullTexture.material = c.deployable.default.hudIcon;
		equipmentBar.activeFullTexture.coords = c.deployable.default.hudIconCoords;
		equipmentBar.activeEmptyTexture.material = c.deployable.default.hudRefireIcon;
		equipmentBar.activeEmptyTexture.coords = c.deployable.default.hudRefireIconCoords;
		equipmentBar.maximumValue = 1;
		equipmentBar.value = 1;

		if(c.activeWeaponIdx == 3)
			equipmentBar.foregroundTexture = selectedMaterial;
		else
			equipmentBar.foregroundTexture.material = None;
	}
	
	previousDeployableClass = c.deployable;
}

defaultproperties
{
	selectedMaterial = (material=Texture'HUD.Tabs',coords=(U=0,V=11,UL=80,VL=40),style=1,drawColor=(R=255,G=255,B=255,A=255))
	bDrawQuantity = false
}
