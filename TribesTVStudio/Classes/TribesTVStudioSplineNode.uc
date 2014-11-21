class TribesTVStudioSplineNode extends Keypoint;

var() float ViewAngle;
var() float MinZoomDist;
var() float MaxZoomDist;
var() float MaxDistance;	//maximum distance this camera will be picked from
var() int SystemNum;
var() float Priority;

//each spline node belongs to a specific spline indexed by splineid
//inside each spline the spline is indexed by the node id from 0 to the number of nodes-1
//the crossingId indexes the splines connection to spline crossings and only works for the two end nodes
//-1 means that the spline ends in nothing
var() int splineId;
var() int nodeId;
var() int crossingId;

defaultproperties
{
	ViewAngle=100
	MinZoomDist=600
	MaxZoomDist=1200
	MaxDistance=5000
	SystemNum=0
	crossingId=-1;
	Priority=1;
}
