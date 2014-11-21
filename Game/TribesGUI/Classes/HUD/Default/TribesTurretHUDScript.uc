//================================================================
// Class: TribesTurretHUDScript
//
// Turret HUD script implementation
//
//================================================================

class TribesTurretHUDScript extends TribesInGameHUDScript;

var HUDHealthBarTurret turretHealthBar;
var HUDWeaponIcon weaponIcon;

//
// Initalises the component
//
overloaded function Construct()
{
	super.Construct();

	turretHealthBar = HUDHealthBarTurret(AddElement("TribesGUI.HUDHealthBarTurret", "default_TurretHealth"));

	weaponIcon = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_TurretWeaponIcon"));
	weaponIcon.weaponIdx = -2;	// active weapon (vehicles/turrets)
}
