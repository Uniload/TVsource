class compPlayerCharacterController extends Gameplay.PlayerCharacterController;

var config bool bStartFirstPerson;

exec function kickvote(string name)
{
	//This hack allows a spectator to directly observe a player by pressing the vote to kick button.
	//Effectively disallows observers from voting to kick, of course. 
	if(PlayerReplicationInfo.bIsSpectator)
	{
		log("Spectating " $name);
		ConsoleCommand("Spectate " $ name);
	}
	else if (voteReplicationInfo!=None)
	{
		log("sending kick vote: "$name);
		voteReplicationInfo.SubmitKickVote(name);
	}
	else
		log("none voteReplicationInfo!");

}

function ServerRestartPlayerInVehicle(int vehicleRespawnIndex, bool bKeepPawn)
{
	Log("ServerRestartPlayerInVehicle");
	super.ServerRestartPlayerInVehicle(vehicleRespawnIndex, bKeepPawn);
	
}

//Set to 3rd person view when the player spawns.
function ClientRestart(Pawn aPawn, Name currentState)
{
	bJustRespawned = true;

	Log("Parent ClientRestart() called for "$self$" and pawn "$aPawn);
	super.ClientRestart(aPawn, currentState);

        //Switch to behindview.
        if(!bStartFirstPerson)
          {
           //bBehindView = true;
           ServerToggleBehindView();
           ToggleBehindView();
          }

	updateCasts();
}

defaultproperties
{
     bStartFirstPerson=True
     radarZoomScales(0)=0.100000
     radarZoomScales(1)=0.350000
     radarZoomScales(2)=0.950000
     zoomedFOVs(0)=50.000000
     zoomedFOVs(1)=23.000000
     zoomedFOVs(2)=8.000000
     zoomedMouseScale(0)=0.750000
     zoomedMouseScale(1)=0.400000
     zoomedMouseScale(2)=0.100000
     zoomMagnificationLevels(0)=2.000000
     zoomMagnificationLevels(1)=4.000000
     zoomMagnificationLevels(2)=10.000000
     ChatWindowSizes(0)=4
     ChatWindowSizes(1)=6
     ChatWindowSizes(2)=12
     SPChatWindowSizes(0)=6
}
