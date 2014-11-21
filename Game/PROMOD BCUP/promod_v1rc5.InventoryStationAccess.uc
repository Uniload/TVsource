//class promodInventoryStationAccess extends Gameplay.InventoryStationAccess;


//function bool usedByProcessing(Character user)
//{
//	local PlayerCharacterController playerController;
//
//	playerController = PlayerCharacterController(user.controller);
//
	// do nothing if no player controller
//	if (playerController == None)
//		return false;

	// if an enemy do nothing
//	if (!accessControl.isOnCharactersTeam(user))
//	{
//		log("Attempted To Use Enemy Inventory Station");
//		return false;
//	}

	// if user is currently using inventory station have user exit
//	if (user == currentUser)
//	{
//		clientTerminateCharacterAccess(currentUser);
//		return false;
//	}

	// do nothing if inventory station is currently being used
//	if (currentUser != None)
//	{
//		log("INVENTORY STATION ALREADY BEING USED");
//		return false;
//	}

	// do nothing if inventory station is not functional
//	if (PlayerReplicationInfo.HasFlag != None && promod.TournamentOn)
//	{
//		log("INVENTORY STATION CANNOT BE ACCESSED");
//		return false;
//	}

//	currentUser = user;

	// register interest to access inventory station
//	accessControl.accessRequired(user, self, currentUser.armorClass.default.heightIndex);
//	bWaitingForAccess = true;

	// store use position
//	userPosition = currentUser.location;

	// check if access can begin immediately
//	if (accessControl.isAccessible(currentUser))
//	{
//		characterAccess();
//		bWaitingForAccess = false;
//	}
//	else
//	{
//		playerController.GotoState('PlayerWaitingInventoryStation');
//		playerController.clientInventoryStationWait();
//	}

//	return true;
//}

//defaultproperties {}