///
///
///
class TribesRespawnHUD extends TribesCommandHUD;

var bool bRespawnBaseSelected;
var bool bVehicleRespawn;
var int VehicleRespawnIndex, PreSelectedVehicleRespawnIndex;
var BaseInfo SelectedBase, PreSelectedBase;

function int getKeyCode(string key)
{
	local int i;

	// If it's a single character, assume we can just fetch the ascii representation
	if (Len(key) == 1)
		return Asc(Key);

	// Otherwise, do some hacky special processing to handle F-keys and TAB, which are the most likely
	// keys that useers will want to bind
	if (Left(key, 1) ~= "f")
	{
		i = int(Right(key, 1));
		return EInputKey.IK_F1 + i - 1;
	}

	if (key ~= "TAB")
		return EInputKey.IK_Tab;
}

simulated function UpdateHUDData()
{
	local TribesReplicationInfo PRI;
	local int baseIdx;
	local int vehicleIdx;
	local ClientSideCharacter.SpawnPointData spawnPoint;

	super.UpdateHUDData();

	clientSideChar.bInstantRespawnMode = Controller.IsSinglePlayer();

	PRI = TribesReplicationInfo(Controller.PlayerReplicationInfo);

	// Whether the client is allowed to exit the respawn HUD
	clientSideChar.bCanExitRespawnHUD = Controller.bForcedRespawn;
	clientSideChar.ExitRespawnKeyText = Controller.Player.InteractionMaster.GetKeyFromBinding("Respawn true", true);
	clientSideChar.ExitRespawnKeyBinding = getKeyCode(Controller.respawnKey);

	// team info
    if(PRI != None && PRI.team != None)
    {
	    // Base spawn areas
	    for(baseIdx = 0; baseIdx < PRI.team.MAX_BASES; ++baseIdx)
		{
			spawnPoint.bValid = false;
			if(PRI.team.respawnBases[baseIdx] != None)
			{
				spawnPoint.bValid = true;
				spawnPoint.spawnPointName = PRI.team.respawnBases[baseIdx].description;
				spawnPoint.spawnPointLocation = PRI.team.respawnBases[baseIdx].SpawnArrayLocation;
			}

			clientSideChar.SetSpawnArea(baseIdx, spawnPoint);
		}

		// Vehicle spawn areas
		for(vehicleIdx = 0; vehicleIdx < PRI.team.MAX_RESPAWN_VEHICLES; ++vehicleIdx)
		{
			spawnPoint.bValid = (PRI.team.respawnVehicles[vehicleIdx] != None);
			if (PRI.team.respawnVehicles[vehicleIdx] != None)
			{
				spawnPoint.spawnPointName = string(PRI.team.respawnVehicles[vehicleIdx].Label);
				spawnPoint.spawnPointLocation = PRI.team.respawnVehicles[vehicleIdx].Location;
			}
			else
			{
				spawnPoint.spawnPointName = "";
				spawnPoint.spawnPointLocation = vect(0,0,0);
			}

			clientSideChar.SetSpawnArea(PRI.team.MAX_BASES + vehicleIdx, spawnPoint);
		}

		clientSideChar.bNoMoreCarryables = PRI.team.bNoMoreCarryables;
    }
}

function HUDHidden()
{
	super.HUDHidden();
	bRespawnBaseSelected = false;
	bVehicleRespawn = false;
	SelectedBase = None;
}

function HUDShown()
{
	super.HUDShown();

	// hide the map if we can exit
	ClientSideChar.bShowRespawnMap = Controller.bForcedRespawn;
	bRespawnBaseSelected = false;
	SelectedBase = None;
	bVehicleRespawn = false;
}

// Must be called on creation of the HUD to set up the
// HUDAction class and assign delegates.
function InitActionDelegates()
{
	if(Response == None)
	{
		Response = new class'HUDRespawnAction';

		HUDRespawnAction(Response).SelectRespawnBase = impl_SelectRespawnBase;
		HUDRespawnAction(Response).DisplayRespawnMap = impl_DisplayRespawnMap;
		HUDRespawnAction(Response).ExitRespawnHUD = impl_ExitRespawnHUD;
	}

	super.InitActionDelegates();
}

//
// cleans up any action delegates for the hud response
function CleanupActionDelegates()
{
	if(HUDRespawnAction(Response) != None)
	{
		HUDRespawnAction(Response).SelectRespawnBase = None;
		HUDRespawnAction(Response).DisplayRespawnMap = None;
		HUDRespawnAction(Response).ExitRespawnHUD = None;
	}

	super.CleanupActionDelegates();
}

function Tick(float Delta)
{
	Super.Tick(Delta);

	if(bHideHud)
		return;

	bShowCursor = ClientSideChar.bShowRespawnMap;

	// Handle spawn preselection (occurs after forced respawn, which kills you)
	if (Controller.respawnDelay != -1)
	{
		if (PreSelectedBase != None)
		{
			SelectedBase = PreSelectedBase;
			bRespawnBaseSelected = true;
			PreSelectedBase = None;
		}
		else if (PreSelectedVehicleRespawnIndex != -1)
		{
			bRespawnBaseSelected = true;
			bVehicleRespawn = true;
			VehicleRespawnIndex = PreSelectedVehicleRespawnIndex;
			PreSelectedVehicleRespawnIndex = -1;
		}
	}

	if(bVehicleRespawn)
	{
		// check that the respawn vehicle is still valid
		if(! TribesReplicationInfo(Controller.PlayerReplicationInfo).team.validVehicleRespawnIndex(VehicleRespawnIndex))
		{
			bVehicleRespawn = false;
			bRespawnBaseSelected = false;
		}
	}
	else if(SelectedBase != None && SelectedBase.team != TribesReplicationInfo(Controller.PlayerReplicationInfo).team)
	{
		// check that the respawn base is still valid
		bRespawnBaseSelected = false;
		SelectedBase = None;
	}

	if(bRespawnBaseSelected && Controller.respawnDelay <= 0)
	{
		//Log("Calling DoRespawn() from Tick() due to bRespawnBaseSelected");
		// MJ:  This is now called only once when you click to spawn, which prevents unnecessary function calls, but
		// in Arena seems to prevent you from successfully spawning with a client-side Pawn 9 times out of 10.  Alex is
		// going to help me with this problem.
		DoRespawn();
		bRespawnBaseSelected = false;
	}
}

function DoRespawn()
{	
	local bool bKeepPawn;

	if (Controller.IsInState('PlayerTeleport'))
		bKeepPawn = true;

	//Log("Restarting player in DoRespawn()");

	// restart the player
	if(! bVehicleRespawn)
		Controller.ServerRestartPlayerAtBase(SelectedBase, bKeepPawn);
	else
		// keep existing pawn if we have one
		Controller.ServerRestartPlayerInVehicle(vehicleRespawnIndex, controller.pawn != None);
}

function impl_SelectRespawnBase(int respawnBaseIndex)
{
	local TribesReplicationInfo TRI;

	TRI = TribesReplicationInfo(PlayerOwner.PlayerReplicationInfo);

	// spawn at the nearest base if there are none avaialable
	if(respawnBaseIndex == -3 && TRI.Team.getNumVehicleRespawns() == 0 && TRI.Team.getNumRespawnBases() == 0)
	{
		Controller.ServerRestartPlayer();
		// MJ:  Don't get rid of the HUD because that will prevent the player from being able to click to respawn
		// It seems like there's an unnecessary click required by the player in this codepath but it's not critical.  This
		// path only seems to execute in Rabbit where you might not have a proper baseinfo
		//Controller.HUDManager.SetHUD("");
		return;		
	}

	// instant restart
	if(respawnBaseIndex == -1 && clientSideChar.bInstantRespawnMode)
	{
		Controller.ServerRestartPlayer();
		return;
	}

	if(respawnBaseIndex < 0 || clientSideChar.bNoMoreCarryables)
		return;

	// The respawnBaseIndex corresponds to availableSpawnAreas so this knowledge can be used to 
	// determine if this is a vehicle respawn and what the corresponding vehicle respawn index is.
	bVehicleRespawn = respawnBaseIndex >= TRI.team.MAX_BASES;
	VehicleRespawnIndex = respawnBaseIndex - TRI.team.MAX_BASES;

	// if not a vehicle respawn and the selection is >= 0 then set the respawn base
	if(! bVehicleRespawn && respawnBaseIndex > -1)
		SelectedBase = TRI.team.respawnBases[respawnBaseIndex];

	// If the player is still alive (because they brought up the respawn HUD manually) kill him first.  Don't
	// do this if the player is teleporting.  Preselect spawn point since the respawn screen will show up
	// after dying
	if (!Controller.IsInState('PlayerTeleport') && Controller.Pawn != None && Controller.Pawn.Health > 0)
	{
		if (bVehicleRespawn)
		{
			PreSelectedVehicleRespawnIndex = VehicleRespawnIndex;
		}
		else
		{
			PreSelectedBase = SelectedBase;
		}

		Controller.bForcedRespawn = true;
		Controller.ServerKillPlayer();

		// Hide respawn map
		clientSideChar.bShowRespawnMap = false;
		return;
	}

	bRespawnBaseSelected = true;
}

function impl_DisplayRespawnMap()
{
	ClientSideChar.bShowRespawnMap = true;
}


function impl_ExitRespawnHUD()
{
	if(clientSideChar.bCanExitRespawnHUD)
		PlayerCharacterController(PlayerOwner).ServerCancelRespawn();
	else
		Log("Respawn HUD unable to exit!");
}

defaultproperties
{
	HUDScriptType		= "TribesGUI.TribesRespawnHUDScript"
	HUDScriptName		= "default_RespawnHUD"
	bAllowInteractions	= true
	bShowCursor			= false
	PreSelectedVehicleRespawnIndex = -1
}
