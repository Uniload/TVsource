class HUDRespawnAction extends HUDAction;

//
// Selects the players next respawn base
//
Delegate SelectRespawnBase(int respawnBaseIndex);

//
// Displays the command map
//
Delegate DisplayRespawnMap();

//
// Exits the respawn HUD back to the Player walking state, if allowed
//
Delegate ExitRespawnHUD();