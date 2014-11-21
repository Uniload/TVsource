class HUDWeaponIcon extends HUDEquipmentIcon;

var() config HUDMaterial	selectedMaterial;
var() config Color			enabledColor;
var() config Color			disabledColor;
var() config int			NumAmmoCountDigits;

var class previousWeaponClass;
var int previousWeaponAmmo;
var	int	weaponIdx;

var localized string textInfiniteAmmo;

function UpdateData(ClientSideCharacter c)
{
	local String AmmoString;
	local int paddingCount, i;
	local ClientSideCharacter.HUDWeaponInfo weapon;
	local bool bIsBuckler;

	if(weaponIdx >= 0)
		weapon = c.weapons[weaponIdx];
	else if(weaponIdx == -1)
		weapon = c.fallbackWeapon;
	else if(weaponIdx == -2)
		weapon = c.activeWeapon;

	super.UpdateData(c);

	bVisible = weapon.type != None;
	if (bVisible)
	{
		bIsBuckler = ClassIsChildOf(weapon.type, class'Gameplay.Buckler');

		// flashing "updated" indicator
		if(previousWeaponClass != weapon.type || (weapon.ammo > previousWeaponAmmo && ! bIsBuckler))
			DoUpdateFlash();

		if(weapon.type.default.ammoUsage > 0 && ! bIsBuckler)
		{
			// set the value of the label before it gets rendered
			AmmoString $= weapon.ammo;
			paddingCount = NumAmmoCountDigits - Len(AmmoString);
			for(i = 0; i < paddingCount; ++i)
				AmmoString = "0" $AmmoString;
			quantityLabel.SetText(AmmoString);
		}
		else
			quantityLabel.SetText(textInfiniteAmmo);

		keyLabel.SetText(weapon.hotkey);

		if(previousWeaponClass != weapon.type)
		{
			equipmentBar.activeEmptyTexture.material = weapon.type.default.hudRefireIcon;
			equipmentBar.activeEmptyTexture.coords = weapon.type.default.hudRefireIconCoords;
			equipmentBar.activeFullTexture.material = weapon.type.default.hudIcon;
			equipmentBar.activeFullTexture.coords = weapon.type.default.hudIconCoords;
		}

		if(c.activeWeaponIdx == weaponIdx)
			equipmentBar.foregroundTexture = selectedMaterial;
		else
			equipmentBar.foregroundTexture.material = None;

		// only show recharge if we can fire
		if(weapon.bCanFire || bIsBuckler)
		{
			equipmentBar.defaultDrawColor = enabledColor;
			equipmentBar.maximumValue = weapon.refireTime;
			equipmentBar.value = weapon.timeSinceLastFire;
		}
		else
		{
			equipmentBar.defaultDrawColor = disabledColor;
			equipmentBar.maximumValue = 1;
			equipmentBar.value = 1;
		}
	}

	previousWeaponClass = weapon.type;
	previousWeaponAmmo = weapon.Ammo;
}

defaultproperties
{
	selectedMaterial = (material=Texture'HUD.Tabs',coords=(U=0,V=62,UL=80,VL=40),style=1,drawColor=(R=255,G=255,B=255,A=255))
	enabledColor = (R=255,G=255,B=255,A=255)
	disabledColor = (R=128,G=128,B=128,A=255)
	NumAmmoCountDigits = 3
	textInfiniteAmmo = "INF"
}