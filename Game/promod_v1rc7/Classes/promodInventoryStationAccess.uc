class promodInventoryStationAccess extends Gameplay.InventoryStationAccess;


function bool CanBeUsedBy(Pawn user)
{
	local Character characterUser;
	local PlayerCharacterController playerController;

	playerController = PlayerCharacterController(user.controller);

	characterUser = Character(user);

	// do nothing if used by non-character
	if (characterUser == None)
		return false;

	// do nothing if no player controller
	if (playerController == None)
		return false;

	// if an enemy do nothing
	if (!accessControl.isOnCharactersTeam(characterUser))
		return false;

	// if user is currently using inventory station have user exit
	if (user == currentUser)
		return false;

	// do nothing if inventory station is currently begin used
	if (currentUser != None)
		return false;

	// do nothing if inventory station is not functional
	if (!accessControl.isFunctional())
		return false;
		
	// do nothing if the player has the flag
	if(PlayerReplicationInfo.HasFlag != None)
		return false;

	return true;
}