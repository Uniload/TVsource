// Pathfinding System Test Harness

class PFTestHarness extends Engine.Actor;

var HUD selfHUD;

var bool enabled;

var bool initialised;

var vector startPoint;
var bool startPointInit;

var vector endPoint;
var bool endPointInit;

var bool showNodes;

var bool showReach;

var bool stepEnabled;

var bool stepThroughInProgress;
var int currentStep;

var bool traversalCheckEnabled;

var array<Controller.RouteCacheElement> routeCacheOne;
var array<Controller.RouteCacheElement> routeCacheTwo;
var array<Controller.RouteCacheElement> routeCacheThree;

var Controller.FindPathAIProperties AIPropertiesOne;
var Controller.FindPathAIProperties AIPropertiesTwo;
var Controller.FindPathAIProperties AIPropertiesThree;

var int routeCahcesInit;

var bool continueFlag;

var bool showQuadtree;

function initialise(HUD initHUD)
{
	selfHUD = initHUD;

	initialised = true;
}

function drawDebug()
{
	local int routeI;
	local int checkI;

	// do nothing if not initialises
	if (!initialised)
		return;

	// draw route if necessary
	for (routeI = 0; routeI < routeCahcesInit; ++routeI)
	{
		if (routeI == 0)
		{
			drawRoute(routeCacheOne, class'Canvas'.Static.MakeColor(255, 0, 0),
					class'Canvas'.Static.MakeColor(255, 255, 255));
		}
		else if (routeI == 1)
		{
			drawRoute(routeCacheTwo, class'Canvas'.Static.MakeColor(0, 255, 0),
					class'Canvas'.Static.MakeColor(255, 255, 255));		
		}
		else
		{
			drawRoute(routeCacheThree, class'Canvas'.Static.MakeColor(0, 0, 255),
					class'Canvas'.Static.MakeColor(255, 255, 255));		
		}
	}
	
	// ... do native debug rendering if view port is accessible
	if (Viewport(selfHUD.playerOwner.player) != None)
		selfHUD.playerOwner.drawPathDebug(Viewport(selfHUD.playerOwner.player), showQuadtree, showNodes,
				stepEnabled, showReach);

	if (traversalCheckEnabled)
	{
		for (checkI = 0; checkI < selfHUD.playerOwner.debugTraversalLineChecks.length; ++checkI)
		{
			selfHUD.Draw3DLine(selfHUD.playerOwner.debugTraversalLineChecks[checkI].start,
					selfHUD.playerOwner.debugTraversalLineChecks[checkI].end,
					selfHUD.playerOwner.debugTraversalLineChecks[checkI].colour);
		}
	}
}

function drawRoute(array<Controller.RouteCacheElement> route, Color normalColor, Color jetpackColor)
{
	local int routeSegmentI;

	// ... draw route segments
	for (routeSegmentI = 0; routeSegmentI < route.length - 1; ++routeSegmentI)
	{
		if (route[routeSegmentI + 1].jetpack)
			selfHUD.Draw3DLine(route[routeSegmentI].location, route[routeSegmentI + 1].location, jetpackColor);
		else
			selfHUD.Draw3DLine(route[routeSegmentI].location, route[routeSegmentI + 1].location, normalColor);
	}
		
	// ... draw route points
	for (routeSegmentI = 0; routeSegmentI < route.length; ++routeSegmentI)
	{
		if (route[routeSegmentI].jetpack)
			selfHUD.Draw3DLine(route[routeSegmentI].location + vect(0,0,-40),
					route[routeSegmentI].location + vect(0,0,40), jetpackColor);
		else
			selfHUD.Draw3DLine(route[routeSegmentI].location + vect(0,0,-40),
					route[routeSegmentI].location + vect(0,0,40), normalColor);
	}
}

function pathfindDebug()
{
	assert(initialised);
	
	enabled = true;
}

function showPathNodes()
{
	assert(initialised);
	
	showNodes = !showNodes;
}

function toggleShowQuadtree()
{
	assert(initialised);
	
	showQuadtree = !showQuadtree;
}

function toggleShowReach()
{
	assert(initialised);
	
	showReach = !showReach;
}

function diagnostics()
{
	assert(initialised);
	
	selfHUD.playerOwner.pathDiagnostics();
}

function toggleStep()
{
	stepEnabled = !stepEnabled;
}

function toggleTraversalCheck()
{
	traversalCheckEnabled = !traversalCheckEnabled;
	if (traversalCheckEnabled)
		log("Traversal Check Enabled");
}

function step()
{
	// do nothing if not debugging
	if (!enabled)
		return;

	// do nothing if start and end point not initialised
	if ((!startPointInit) || (!endPointInit))
		return;

	assert(!selfHUD.playerOwner.RouteComplete);

	log("Step: " $ currentStep);

	++currentStep;

	selfHUD.playerOwner.continueFindPath(false);
	selfHUD.playerOwner.getFindPathResult();
	copyRouteCache(selfHUD.playerOwner.RouteCache, routeCacheOne);
	routeCahcesInit = 1;

	// stop if route complete
	if (selfHUD.playerOwner.RouteComplete)
	{
		log("Route Complete");
		selfHUD.playerOwner.discardFindPath();
		startPointInit = false;
		endPointInit = false;
	}
}

function markPointHere()
{
	markPoint(selfHUD.playerOwner.pawn.location);
}

function markPoint(vector point)
{
	local array<Actor> ignore;

	// initialise start or end point
	if (!startPointInit)
	{
		startPoint = point;
		Log("Start Point: " $ startPoint);
		startPointInit = true;
	}
	else
	{
		endPoint = point;
		endPointInit = true;
		Log("End Point: " $ endPoint);
	}
	
	// update path if new start and end point
	if (startPointInit && endPointInit)
	{
		if (stepEnabled)
		{
			selfHUD.playerOwner.FindPath(startPoint, endPoint, AIPropertiesOne, ignore, true, true);
			selfHUD.playerOwner.getFindPathResult();
			stepThroughInProgress = true;
			currentStep = 0;
			routeCahcesInit = 0;
		}	
		else if (traversalCheckEnabled)
		{
			selfHUD.playerOwner.debugTraversalCheck(startPoint, endPoint);
			startPointInit = false;
			endPointInit = false;
		}
		else
		{
			// ... one
			selfHUD.playerOwner.FindPath(startPoint, endPoint, AIPropertiesOne, ignore, true, true);
			selfHUD.playerOwner.continueFindPath(true);
			selfHUD.playerOwner.getFindPathResult();
			selfHUD.playerOwner.discardFindPath();
			if (selfHUD.playerOwner.RouteCache.Length == 0)
				log("Failed to find path.");
			copyRouteCache(selfHUD.playerOwner.RouteCache, routeCacheOne);
			log("Route Cache One Obstacles");
			logObstacles(routeCacheOne);
			
			// ... two
			selfHUD.playerOwner.FindPath(startPoint, endPoint, AIPropertiesTwo, ignore, true, true);
			selfHUD.playerOwner.continueFindPath(true);
			selfHUD.playerOwner.getFindPathResult();
			selfHUD.playerOwner.discardFindPath();
			if (selfHUD.playerOwner.RouteCache.Length == 0)
				log("Failed to find path.");
			copyRouteCache(selfHUD.playerOwner.RouteCache, routeCacheTwo);
			log("Route Cache Two Obstacles");
			logObstacles(routeCacheTwo);
			
			// ... three
			selfHUD.playerOwner.FindPath(startPoint, endPoint, AIPropertiesThree, ignore, true, true);
			selfHUD.playerOwner.continueFindPath(true);
			selfHUD.playerOwner.getFindPathResult();
			selfHUD.playerOwner.discardFindPath();
			if (selfHUD.playerOwner.RouteCache.Length == 0)
				log("Failed to find path.");
			copyRouteCache(selfHUD.playerOwner.RouteCache, routeCacheThree);
			log("Route Cache Three Obstacles");
			logObstacles(routeCacheThree);
			
			routeCahcesInit = 3;

			// ... reset start and end point state
			startPointInit = false;
			endPointInit = false;
		}
	}
}

function pathfindMarkPoint()
{
	local vector X;
	local vector Y;
	local vector Z;
	local vector startTrace;
	local vector endTrace;
	local vector hitLocation;
	local vector hitNormal;

	// do nothing if not enabled or initialised
	if (!initialised || !enabled)
		return;
		
	stepThroughInProgress = false;
		
	// determine point
	GetAxes(selfHUD.playerOwner.getViewRotation(), X, Y, Z);
	startTrace = selfHUD.playerOwner.viewTarget.location;
//	startTrace.Z += selfHUD.playerOwner.baseEyeHeight;
	endTrace = startTrace + X * 30000;
	if (Trace(hitLocation, hitNormal, endTrace, startTrace, True) == None)
	{
		Log("WARNING: trace failed");
		return;
	}

	// account for character height
	hitLocation.Z += 80;
	
	markPoint(hitLocation);
}

function copyRouteCache(array<Controller.RouteCacheElement> source,
		out array<Controller.RouteCacheElement> destination)
{
	local int vectorI;

	destination.length = source.length;
	for (vectorI = 0; vectorI < source.length; ++vectorI)
	{
		destination[vectorI] = source[vectorI];
	}
}

function logObstacles(array<Controller.RouteCacheElement> routeCache)
{
	local int index;
	for (index = 0; index < routeCache.length; ++index)
	{
		if (routeCache[index].obstacle != None)
		{
			log("Obstacle: " $ routeCache[index].obstacle);
		}
	}
}

defaultProperties
{
	RemoteRole = ROLE_None

	enabled = false
	initialised = false
	
	startPointInit = false
	endPointInit = false
	
	showNodes = false
	
	stepEnabled = false
	
	stepThroughInProgress = false
	
	showReach = false
	
	DrawType = DT_None
	
	routeCahcesInit = 0
	
	AIPropertiesOne = (upCostFactor=0,downCostFactor=0,jetpack=false,Airborne=false)
	AIPropertiesTwo = (upCostFactor=0,downCostFactor=0,jetpack=false,Airborne=true)
	AIPropertiesThree = (upCostFactor=0,downCostFactor=0,jetpack=true,Airborne=false)

	continueFlag = false

	showQuadtree = false

	traversalCheckEnabled = false
}