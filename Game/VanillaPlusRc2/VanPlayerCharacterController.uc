class VanPlayerCharacterController extends Gameplay.PlayerCharacterController;

exec function kickvote(string name)
{	

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

defaultproperties
{
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
