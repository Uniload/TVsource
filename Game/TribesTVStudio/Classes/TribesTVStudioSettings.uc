class TribesTVStudioSettings extends Keypoint;

var() string camSystemName[6];
var() float DesiredRailCamDistance[6];

var() int attract2CamSystem;
var() int pathNode2CamSystem;

defaultproperties
{
	attract2CamSystem=4
	pathNode2CamSystem=5

	camSystemName[4]="Attract cameras"
	camSystemName[5]="PathNode as rails"

	DesiredRailCamDistance[0]=400
	DesiredRailCamDistance[1]=400
	DesiredRailCamDistance[2]=400
	DesiredRailCamDistance[3]=400
	DesiredRailCamDistance[4]=400
	DesiredRailCamDistance[5]=400
}
