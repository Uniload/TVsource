//================================================================
// Class: TribesIngameHUDScript
//
// The default Tribes HUD script implementation.
//
//================================================================

class TribesVehicleHUDScript extends TribesInGameHUDScript;

var HUDVehicleManifest positionsManifest;

var HUDHealthBarVehicle vehicleHealthBar;

var HUDWeaponIcon weaponIcon;

//
// Initalises the component
//
overloaded function Construct()
{
	super.Construct();

	positionsManifest = HUDVehicleManifest(AddElement("TribesGUI.HUDVehicleManifest", "default_PositionsManifest"));
	vehicleHealthBar = HUDHealthBarVehicle(AddElement("TribesGUI.HUDHealthBarVehicle", "default_VehicleHealth"));

	weaponIcon = HUDWeaponIcon(AddElement("TribesGUI.HUDWeaponIcon", "default_VehicleWeaponIcon"));
	weaponIcon.weaponIdx = -2;	// active weapon (vehicles/turrets)
}
