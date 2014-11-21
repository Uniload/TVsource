//================================================================
// Class: TribesDebugHUDScript
//
// The default Tribes HUD script implementation.
//
//================================================================

class TribesDebugHUDScript extends TribesHUDScript;

var HUDHealthBar health;
var HUDEnergyBar energy;
var HUDContainer healthEnergyGroup;

//
// Initalises the component
//
overloaded function Construct()
{
	super.Construct();

	// only show health and energy on the debug hud
	healthEnergyGroup	= HUDContainer(AddElement("TribesGUI.HUDContainer", "default_healthEnergyGroup"));
	health				= HUDHealthBar(healthEnergyGroup.AddElement("TribesGUI.HUDHealthBar", "default_health"));
	energy				= HUDEnergyBar(healthEnergyGroup.AddElement("TribesGUI.HUDEnergyBar", "default_energy"));
}
