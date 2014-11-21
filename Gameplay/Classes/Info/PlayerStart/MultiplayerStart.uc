//=============================================================================
// Multiplayer start location.
//=============================================================================
class MultiplayerStart extends PlayerStart
	placeable;

var() class<CombatRole>		combatRole			"The combat role for the player that spawns at this point";
var() class<Loadout>		loadoutOverride		"Allows the designer to override the loadout for the player that spawns at this point, else the player spawns with the default loadout defined in the combat role";

// defaultPawnClassName
function string defaultPawnClassName()
{
	return "";
}

defaultproperties
{
}
