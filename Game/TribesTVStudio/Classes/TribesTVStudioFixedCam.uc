class TribesTVStudioFixedCam extends Keypoint;

var() float ViewAngle;
var() float MinZoomDist;
var() float MaxZoomDist;
var() float MaxDistance;	//maximum distance this camera will be picked from
var() float MaxRotation;
var() int SystemNum;
var() float Priority;

defaultproperties
{
    ViewAngle=100
    MinZoomDist=600
    MaxZoomDist=1200
		MaxDistance=5000
		MaxRotation=32000
		SystemNum=0;
		bDirectional=true;
		priority=1;
}
