//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioSplineHandler extends object;

var TribesTVStudioTestController controller;

struct SplineNode {
	var Vector location;
	var float maxDistance;
	var float viewAngle;
	var float minZoomDist;
	var float maxZoomDist;
	var float Priority;
};

struct SplinePath{
	var array<SplineNode> nodes;
	var int lowCrossing;
	var int highCrossing;
	var int lastSearchId;
};

struct SplineCrossing{
	var array<int> connections;
};

var array<SplinePath> splines;
var array<SplineCrossing> crossings;
var int lastSearch;		//id that is increased for every search, just to keep us from searching the same spline several times

var int curSpline;	//the spline the camera currently resides on
var float curPos,curSpeed;
var Vector location;

var int targetNode,targetSpline; //the spline/node closest to the target (on a spline neighbouring the current)

var int otherSpline;		//the spline we are about to cross over to or has crossovered (sp?) from
var bool highCur,highOther;
var Vector otherNode1,otherNode2;	//the two nodes closest to the curSpline on the otherSpline
var int activeCrossing;		//the crossing that the above takes place on

var int newSpline,newPos;	//temp variables when selecting a new spline, to be able to keep the old if they are good enough

function FillSplineList(int camSys)
{
	local TribesTVStudioSplineNode mapsn;
	local SplineNode sn;
	local int a;

	//zero all
	splines.length=0;
	crossings.length=0;

	curSpline=-1;

	//add the splines
  foreach controller.AllActors(class'TribesTVStudioSplineNode', mapsn)
	{
		if(mapsn.SystemNum==camSys){
			sn.location=mapsn.location;
			sn.maxDistance=mapsn.MaxDistance;
			sn.viewAngle=mapsn.viewAngle;
			sn.minZoomDist=mapsn.minZoomDist;
			sn.maxZoomDist=mapsn.maxZoomDist;
			sn.priority=mapsn.Priority;
			a=mapsn.splineId;
			if(a>=splines.length)
				splines.length=a+1;

			if(mapsn.nodeId>=splines[a].nodes.length){
				splines[a].nodes.length=mapsn.nodeId+1;
				splines[a].highCrossing=mapsn.crossingId;
			}
			if(mapsn.nodeId==0){
				splines[a].lowCrossing=mapsn.crossingId;
			}
			splines[a].nodes[mapsn.nodeId] = sn;
		}
	}

	//add the connected splines to the crossings
	for(a=0;a<splines.length;++a){
		if(splines[a].lowCrossing!=-1){
			if(splines[a].lowCrossing>=crossings.length)
				crossings.length=splines[a].lowCrossing+1;
			crossings[splines[a].lowCrossing].connections.length=crossings[splines[a].lowCrossing].connections.length+1;
			crossings[splines[a].lowCrossing].connections[crossings[splines[a].lowCrossing].connections.length-1]=a;
		}
		if(splines[a].highCrossing!=-1){
			if(splines[a].highCrossing>=crossings.length)
				crossings.length=splines[a].highCrossing+1;
			crossings[splines[a].highCrossing].connections.length=crossings[splines[a].highCrossing].connections.length+1;
			crossings[splines[a].highCrossing].connections[crossings[splines[a].highCrossing].connections.length-1]=a;
		}
	}
}

//find the spline node closest to the target with los
function bool FindBestSplineNode(out float bestdist,Vector targetPos)
{
	local int s,n;

	bestDist=40000;
	++lastSearch;
	newSpline=-1;

	for (s = 0; s < splines.length; s++){
		if(FindBestNodeInSpline(s,lastSearch,n,bestDist)){
			newSpline = s;
			newPos=n;
		}
	}

	if(newSpline!=-1){
		return true;
	}
	return false;
}

function Move(float deltaTime)
{
	local float wantedPos,wantedSpeed;
	local float dp;

	if(targetNode!=-1){
		wantedPos=FindClosestPos();

		wantedSpeed=FindDistance(targetSpline,wantedPos)*1.5;

		if(wantedSpeed>curSpeed){
			curSpeed+=300*deltaTime;
			if(curSpeed<0)
				curSpeed/=1+deltaTime;
		} else {
			curSpeed-=300*deltaTime;
			if(curSpeed>0)
				curSpeed/=1+deltaTime;
		}
		//spline->(un)real space magnitude
		dp=VSize(location-CalcPos(curSpline,curPos+0.001))*1000;

		curPos+=curSpeed*deltaTime/dp;

		if(curPos<-1){
			SwitchSpline(false,-1-curPos);
		} else if(curPos>splines[curSpline].nodes.length){
			SwitchSpline(true,curPos-splines[curSpline].nodes.length);
		}

		location=CalcPos(curSpline,curPos);
		
		controller.SetPosition(location);
	}
	controller.SetRotation(controller.CameraTrack2(DeltaTime));
}

//swtich from one spline to the next using the active crossing and other values
function SwitchSpline(bool high,float newPos)
{
	local int s;

	if(highOther){
		curPos=splines[otherSpline].nodes.length-1-newPos;
		s=curSpline;
		curSpline=otherSpline;
		SetOther(s,activeCrossing);
		highCur=true;
		curSpeed=-abs(curSpeed);
	} else {
		curPos=newPos;
		s=curSpline;
		curSpline=otherSpline;
		SetOther(s,activeCrossing);
		highCur=false;
		curSpeed=abs(curSpeed);
	}
}

//finds the distance and direction from the current pos to a given pos
function float FindDistance(int spline,float pos)
{
	local float dist;

	dist=VSize(CalcPos(spline,pos)-location);

	if(spline==curSpline){
		if(pos>curPos)
			return dist;
		else
			return -dist;
	}
	if(highCur)
		return dist;
	else
		return -dist;
}

//calculate the camera location from a position on a spline using cardianal splines
function Vector CalcPos(int spline,float pos)
{
	local Vector v_1,v0,v1,v2;
	local int node,maxNode;
	local float u;
	local Vector a,b,c,d;
	
	maxNode=splines[spline].nodes.length-1;

	if(pos>=0)
		node=int(pos);
	else
		node=int(pos)-1;

	u=pos-node;

	if(node>0){
		v_1=splines[spline].nodes[node-1].location;
	}else{
		if(node==0){
			if(otherSpline==spline || activeCrossing!=splines[spline].lowCrossing){
				v_1=splines[spline].nodes[0].location*2 - splines[spline].nodes[1].location;
			} else {
				v_1=otherNode1;
			}
		} else {
			if(otherSpline==spline || activeCrossing!=splines[spline].lowCrossing){
				v_1=splines[spline].nodes[0].location*2 - splines[spline].nodes[1].location;
			} else {
				v_1=otherNode2;
			}
		}
	}
	if(node>=0){
		v0=splines[spline].nodes[node].location;
	} else {
		if(otherSpline==spline || activeCrossing!=splines[spline].lowCrossing){
			v0=splines[spline].nodes[0].location*2 - splines[spline].nodes[1].location;
		} else {
			v0=otherNode1;
		}
	}
	if(node<maxNode){
		v1=splines[spline].nodes[node+1].location;
	} else {
		if(otherSpline==spline || activeCrossing!=splines[spline].highCrossing){
			v1=splines[spline].nodes[maxNode].location*2 - splines[spline].nodes[maxNode-1].location;
		} else {
			v1=otherNode1;
		}
	}
	if(node<maxNode-1){
		v2=splines[spline].nodes[node+2].location;
	} else {
		if(node==maxNode-1){
			if(otherSpline==spline || activeCrossing!=splines[spline].highCrossing){
				v2=splines[spline].nodes[maxNode].location*2 - splines[spline].nodes[maxNode-1].location;
			} else {
				v2=otherNode1;
			}
		} else {
			if(otherSpline==spline || activeCrossing!=splines[spline].highCrossing){
				v2=splines[spline].nodes[maxNode].location*2 - splines[spline].nodes[maxNode-1].location;
			} else {
				v2=otherNode2;
			}
		}
	}

	a=-0.5*v_1 + 1.5*v0 - 1.5*v1 + 0.5*v2;
	b=   1*v_1 - 2.5*v0 + 2.0*v1 - 0.5*v2;
	c=-0.5*v_1          + 0.5*v1;
	d=               v0;

	return u*u*u*a+u*u*b+u*c+d;
}

//find the position closest to the target between target node +-1 (linearly interpolating the spline)
//todo: doesnt try finding nodes over crossings
function float FindClosestPos()
{
	local float bestDistSqr,bestPos;
	local Vector targVec,railVec;
	local float cDist,closeDistSqr;
	local Vector targPos;
	local Vector v0,v1;

	v0=splines[targetSpline].nodes[targetNode].location;

	targPos=controller.camTargetPos;
	targPos+=Normal(location-targPos)*controller.wantedDist;

	targVec=targPos-v0;

	bestDistSqr=targVec Dot targVec;
	bestPos=targetNode;

	if(!controller.inViewLastTimer){
		return bestPos;
	}

	if(targetNode!=0){
		v1=splines[targetSpline].nodes[targetNode-1].location;
		railVec=Normal(v1-v0);

		cDist=railVec Dot targVec;
		if(cDist>0){			
			closeDistSqr=targVec Dot targVec-cDist*cDist;
			if(closeDistSqr<bestDistSqr){
				bestDistSqr=closeDistSqr;
				bestPos=targetNode-min(cDist/VSize(v0-v1),1);
			}
		}
	}
	if(targetNode!=splines[targetSpline].nodes.length-1){
		v1=splines[targetSpline].nodes[targetNode+1].location;
		railVec=Normal(v1-v0);

		cDist=railVec Dot targVec;
		if(cDist>0){			
			closeDistSqr=targVec Dot targVec-cDist*cDist;
			if(closeDistSqr<bestDistSqr){
				bestDistSqr=closeDistSqr;
				bestPos=targetNode+min(cDist/VSize(v0-v1),1);
			}
		}
	}

	return bestPos;
}

//recreates the view when splines has been selected
//but leave it if we are already close enough to find a fast way to the new target
//todo: define when to keep the old camera better
function SplineSelected()
{
	local float dist;

	UpdateGoalNode();
	dist=VSize(splines[targetSpline].nodes[targetNode].location-location);

	if(targetNode==-1 || (!controller.targetLos(location) && dist>500) || dist>2000){
		curPos=newPos;
		curSpline=newSpline;
		curSpeed=0;
		location=splines[curSpline].nodes[int(curPos)].location;
		controller.SetPosition(location,true);
		controller.FovAngle = splines[curSpline].nodes[int(curPos)].ViewAngle;
		controller.focuspoint = controller.camTargetPos;
		controller.SetRotation(controller.CameraTrack2(0));
	}
}

//Sets a new goal node
//The camera will aim for a position +-1 from this node on the spline
//Only checks the current spline and its neighbours
function UpdateGoalNode()
{
	local float bestdist;
	local int n;
	local int a,c;

	targetNode=-1;
	bestDist=40000;
	++lastSearch;

	if(curSpline==-1)
		return;

	if(FindBestNodeInSpline(curSpline,lastSearch,n,bestDist)){
		targetNode=n;
		targetSpline=curSpline;
	}
	if(splines[curSpline].lowCrossing!=-1){
		c=splines[curSpline].lowCrossing;
		for(a=0;a<crossings[c].connections.length;++a){
			if(FindBestNodeInSpline(crossings[c].connections[a],lastSearch,n,bestDist)){
				targetNode=n;
				targetSpline=crossings[c].connections[a];
				highCur=false;
				SetOther(targetSpline,c);
				activeCrossing=c;
			}			
		}
	}
	if(splines[curSpline].highCrossing!=-1){
		c=splines[curSpline].highCrossing;
		for(a=0;a<crossings[c].connections.length;++a){
			if(FindBestNodeInSpline(crossings[c].connections[a],lastSearch,n,bestDist)){
				targetNode=n;
				targetSpline=crossings[c].connections[a];
				highCur=true;
				SetOther(targetSpline,c);
				activeCrossing=c;
			}			
		}
	}

	controller.curcam2=targetNode;
}

//Sets up the other variables
function SetOther(int s,int c)
{
	otherSpline=s;
	if(splines[s].lowCrossing==c){
		highOther=false;
		otherNode1=splines[s].nodes[0].location;
		otherNode2=splines[s].nodes[1].location;
	} else {
		highOther=true;
		otherNode1=splines[s].nodes[splines[s].nodes.length-1].location;
		otherNode2=splines[s].nodes[splines[s].nodes.length-2].location;
	}	
}

//find the spline node closest to the target with los in a specific spline
function bool FindBestNodeInSpline(int spline,int searchId,out int bestNode,out float bestDist)
{
	local float dist,modDist;
	local int n;
	local bool better;

	better=false;

	if(searchId==splines[spline].lastSearchId)
		return false;
	splines[spline].lastSearchId=searchId;

	for (n = 0; n < splines[spline].nodes.length; n++){
		
		dist = VSize(controller.camTargetPos - splines[spline].nodes[n].location);
		modDist=dist/splines[spline].nodes[n].priority;
		if ((modDist < bestdist) && dist < splines[spline].nodes[n].maxDistance && controller.TargetLOS(splines[spline].nodes[n].location)){
			bestNode=n;
			bestdist = modDist;
			better=true;
		}
	}
	if(better)
		return true;
	else
		return false;
}

function SetFovValues(out float minzoomdist,out float maxzoomdist,out float viewangle)
{
	minzoomdist = splines[curSpline].nodes[int(curPos)].minzoomdist;
	maxzoomdist = splines[curSpline].nodes[int(curPos)].maxzoomdist;
	viewangle = splines[curSpline].nodes[int(curPos)].ViewAngle;	
}
