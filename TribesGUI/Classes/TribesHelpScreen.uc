class TribesHelpScreen extends TribesGUIPage;

import enum EDeployableInfo from Gameplay.Deployable;

var TribesHelpHUDScript				HUDOverlay;
var Gameplay.ClientSideCharacter	HUDData;

var(TribesGui) private EditInline Config GUILabel	FireKey				"";
var(TribesGui) private EditInline Config GUILabel	FallbackKey			"";
var(TribesGui) private EditInline Config GUILabel	WeaponOneKey		"";
var(TribesGui) private EditInline Config GUILabel	WeaponTwoKey		"";
var(TribesGui) private EditInline Config GUILabel	WeaponThreeKey		"";
var(TribesGui) private EditInline Config GUILabel	ThrowGrenadeKey		"";
var(TribesGui) private EditInline Config GUILabel	UsePackKey			"";
var(TribesGui) private EditInline Config GUILabel	UseKey				"";
var(TribesGui) private EditInline Config GUILabel	CommandMapKey		"";
var(TribesGui) private EditInline Config GUILabel	JetPackKey			"";
var(TribesGui) private EditInline Config GUILabel	SkiKey				"";
var(TribesGui) private EditInline Config GUILabel	ForwardKey			"";
var(TribesGui) private EditInline Config GUILabel	BackKey				"";
var(TribesGui) private EditInline Config GUILabel	LeftKey				"";
var(TribesGui) private EditInline Config GUILabel	RightKey			"";

function InitComponent(GUIComponent MyOwner)
{
	super.InitComponent(MyOwner);

	OnKeyEvent = InternalOnKeyEvent;
}

function String GetHotkey(String Binding, bool bLocalized, optional bool bShortened)
{
	local String hotKey;
	hotKey = Controller.Master.GetKeyFromBinding(Binding, bLocalized);

	if(Len(hotKey) > 2 && bShortened)
		hotKey = Left(hotKey, 2);
	if(hotKey == "`")
		hotKey = "~";

	return hotKey;
}

function OnActivate()
{
	local int i;

	Controller.bHideMouseCursor = true;
	PlayerCharacterController(PlayerOwner()).SetPause(true);

	if(HUDOverlay == None)
		HUDOverlay = new class'TribesGui.TribesHelpHUDScript';

	if(HUDData == None)
		HUDData = new class'Gameplay.ClientSideCharacter';

	HUDData.charRotation = Rot(0,-16384,0);

	// health/energy data
	HUDData.health = 100;
	HUDData.healthMaximum = 100;
	HUDData.healthInjectionAmount = 0;
	HUDData.energy = 100;
	HUDData.energyMaximum = 100;
	HUDData.bShowEnergyBar = true;

	// set the active weapon type to None (no reticule)
	HUDData.activeWeapon.type = None;

	// primary weapons
	for(i = 0; i < 3; ++i)
	{
		HUDData.weapons[i].type = class'Gameplay.Weapon';
		HUDData.weapons[i].ammo = 20;
		HUDData.weapons[i].bCanFire = true;
		HUDData.weapons[i].refireTime = 1.0;
		HUDData.weapons[i].timeSinceLastFire = 1.0;
		HUDData.weapons[i].Spread = 0;
	}

	// fallback weapon
	HUDData.fallbackWeapon.type = class'Gameplay.Weapon';
	HUDData.fallbackWeapon.ammo = 1;
	HUDData.fallbackWeapon.bCanFire = true;
	HUDData.fallbackWeapon.refireTime = 1;
	HUDData.fallbackWeapon.timeSinceLastFire = 1;

	// carryable
	HUDData.carryable = class'MPCarryable';
	HUDData.numCarryables = 1;

	// deployable
	HUDData.deployable = class'Gameplay.Deployable';
	HUDData.bDeployableActive = true;
	HUDData.deployableState = EDeployableInfo.DeployableInfo_Ok;

	// pack
	HUDData.pack = class'Gameplay.Pack';

	// grenades
	HUDData.grenades.type = class'Gameplay.HandGrenade';
	HUDData.grenades.ammo = 5;
	HUDData.grenades.bCanFire = true;
	HUDData.grenades.refireTime = 1.0;
	HUDData.grenades.timeSinceLastFire = 1.0;

	// Hotkeys
	for(i = 0; i < 3; ++i)
		HUDData.weapons[i].hotkey = GetHotkey("SwitchWeapon "$string(i+1), true, true);

	HUDData.fallbackWeapon.hotkey = GetHotkey("SwitchToFallbackWeapon", true, true);
	HUDData.deployableHotkey = GetHotkey("equipDeployable", true, true);
	HUDData.healthKitHotkey = GetHotkey("UseHealthKit", true, true);
	HUDData.packHotkey = GetHotkey("activatePack", true, true);
	HUDData.grenades.hotkey = GetHotkey("altFire", true, true);
	HUDData.carryableHotkey = GetHotkey("equipCarryable", true, true);

	HUDData.bSensorGridFunctional = true;
	HUDData.CurrentChatWindowSize = 4;

	// keybiding labels
	FireKey.Caption = GetHotkey("Fire", true);
	FallbackKey.Caption = GetHotkey("SwitchToFallbackWeapon", true);
	WeaponOneKey.Caption = GetHotkey("SwitchWeapon 1", true);
	WeaponTwoKey.Caption = GetHotkey("SwitchWeapon 2", true);
	WeaponThreeKey.Caption = GetHotkey("SwitchWeapon 3", true);
	ThrowGrenadeKey.Caption = GetHotkey("altFire", true);
	UsePackKey.Caption = GetHotkey("activatePack", true);
	UseKey.Caption = GetHotkey("Use", true);
	CommandMapKey.Caption = GetHotkey("Button bObjectives", true);
	JetPackKey.Caption = GetHotkey("Jetpack", true);
	SkiKey.Caption = GetHotkey("Ski", true);
	ForwardKey.Caption = GetHotkey("MoveForward", true);
	BackKey.Caption = GetHotkey("MoveBackward", true);
	LeftKey.Caption = GetHotkey("StrafeLeft", true);
	RightKey.Caption = GetHotkey("StrafeRight", true);

	HUDOverlay.PreShow(HUDData);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if( state == EInputAction.IST_Release || 
		Key == EInputKey.IK_MouseWheelUp ||
		Key == EInputKey.IK_MouseWheelDown ||
		Key == EInputKey.IK_MouseX || 
		Key == EInputKey.IK_MouseY)
			return false;

	// close this menu
	Controller.bHideMouseCursor = false;
	PlayerCharacterController(PlayerOwner()).MyHUD.bHideHud = false;
	PlayerCharacterController(PlayerOwner()).SetPause(false);
	Controller.CloseMenu();

	return true;
}

function OnClientDraw(Canvas C)
{
	super.OnClientDraw(C);
	HUDOverlay.DoUpdate(C, HUDData.LevelTimeSeconds);
}