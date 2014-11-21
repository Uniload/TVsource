//=====================================================================
// NS_MoveToLocation
//
// Higher level Cersei action to get to anywhere on the map using
// jetting and skiing as appropriate
//=====================================================================

class NS_MoveToLocation extends NS_Action
	threaded;

//=====================================================================
// Constants

const DIRECT_MOVE_MAXIMUM_DISTANCE = 1500;

const PRELIMINARY_MOVE_DISTANCE = 15000;

const PRELINARY_MOVE_DESTINATION_SEARCH_RADIUS = 5000;

struct TerminalConditions
{
	var float height;
	var float distanceXY;
	var float distanceZ;
	var float velocity;
};

//=====================================================================
// Variables

var Vector destination;
var Actor target;				// Actor being followed (if any - can be None)
var Character.SkiCompetencyLevels skiCompetency;
var Character.JetCompetencyLevels jetCompetency;
var Character.GroundMovementLevels groundMovement;
var float terminalDistanceXY;
var float terminalDistanceZ;
var float energyUsage;
var float terminalVelocity;
var float terminalHeight;

var Controller.FindPathAIProperties workAIProperties;

var NS_Action forwardAction;	// if we ever use this again make sure to AddRef/Release!

var Vector jetSkiDestination;	// destination for long range jetting/skiing

var bool jetpackCapable;
var bool bInZeroG;

var int routeCacheI;

var array<Actor> ignore;

var bool preliminaryMove;

var vector workVector;

var array<Vector> workPoints;

var vector originalDestination;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Every NS Action has a static startAction function which allocates the
// action, initialises it, and starts it running.
//
// destination: location where character desires to be at end of local move, snapped to ground
// target:      Actor being followed (can be None)
// skiCompetency: ski skill level during local move, none implies no skiing
// jetCompetency: jet skill level during local move, none implies no jetting
// groundMovement: type of ground based movement during local move, none implies only jetting and skiing
// energyUsage: min. amount of energy in pawn after action completes
// terminalVelocity: the speed you would like to be going when the action terminates
// terminalHeight: how high you'd like to be at destination
// terminalDistanceXY: distance from destination in XY for action to succeed
// terminalDistanceZ: distance from destination in Z for action to succeed

static function NS_MoveToLocation startAction( AI_Controller c, ActionBase parent, Vector destination,
	optional Actor target,
	optional Character.SkiCompetencyLevels skiCompetency, optional Character.JetCompetencyLevels jetCompetency,
	optional Character.GroundMovementLevels groundMovement,
	optional float energyUsage, optional TerminalConditions terminalConditions)
{
	local NS_MoveToLocation action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_MoveToLocation'( c, parent );

	// set action parameters
	action.destination = destination;
	action.originalDestination = destination;
	action.target = target;
	action.skiCompetency = skiCompetency;
	action.jetCompetency = jetCompetency;
	action.groundMovement = groundMovement;
	action.energyUsage = energyUsage;
	action.terminalVelocity = terminalConditions.velocity;
	action.terminalHeight = terminalConditions.height;
	action.terminalDistanceXY = terminalConditions.distanceXY;
	action.terminalDistanceZ = terminalConditions.distanceZ;

	action.runAction();
	return action;
}

//---------------------------------------------------------------------

function cleanup()
{
	//log( name @ controller.pawn.name @ "discard path! (cleanup)" );
	controller.discardFindPath();

	super.cleanup();
}

//=====================================================================
// States

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started; target:" @ target @ "(dist:" @ VDist( destination, controller.Pawn.Location ) @ ")" );

	// initialise find path AI properties

	// ... jetpack flag
	jetpackCapable = (jetCompetency == JC_DEFAULT && Character(controller.Pawn).jetCompetency > JC_NONE) || (jetCompetency > JC_NONE);
	workAIProperties.jetpack = jetpackCapable;

	// ... if in zero-g, call doLocalMove directly
	bInZeroG = (Character(controller.Pawn).Movement == MovementState_ZeroGravity);

	// ... team name
	if (Rook(controller.Pawn).team() == None)
		workAIProperties.teamName = 'None';
	else
		workAIProperties.teamName = Rook(controller.Pawn).team().name;

	// ... temporary
	workAIProperties.upCostFactor = 0;
	workAIProperties.downCostFactor = 0;

	// zero_g check
	if ( bInZeroG )
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": zero-g: doing direct move to" $ destination );

		waitForAction( class'NS_DoLocalMove'.static.startAction(controller, self, destination, false, ,
				skiCompetency, jetCompetency, groundMovement, energyUsage,
				terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ ));

		goto('ErrorCheck');
	}

	// construct ignore list
	if (target != None)
		ignore[0] = target;

	// if destination is sufficiently close and can be reached then move directly to destination
	if ( VDistSquared( destination, controller.Pawn.Location ) < DIRECT_MOVE_MAXIMUM_DISTANCE * DIRECT_MOVE_MAXIMUM_DISTANCE )
	{
		if ((terminalHeight <= 0) && controller.canPointBeReached(controller.Pawn.Location, destination, controller.Pawn, ignore))
		{
			if (controller.Pawn.logNavigationSystem)
				log( name $ ": doing direct move to" @ destination );

			waitForAction( class'NS_DoLocalMove'.static.startAction(controller, self, destination, false, ,
					skiCompetency, jetCompetency, groundMovement, energyUsage,
					terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ ));

			goto('ErrorCheck');
		}
		else if ((terminalHeight >= 0) && workAIProperties.jetpack &&
				controller.canPointBeReachedUsingJetpack(controller.Pawn.Location, destination, controller.Pawn))
		{
			if (controller.Pawn.logNavigationSystem)
				log( name $ ": doing direct jetpack move to" @ destination @ VSize2D(controller.Pawn.Velocity) );

			waitForAction( class'NS_DoLocalMove'.static.startAction(controller, self, destination, false, ,
					skiCompetency, jetCompetency, groundMovement, energyUsage,
					terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ, true ));

			goto('ErrorCheck');
		}
	}

	// todo: if pawn is in the air, find a path node in the direction of travel and call findPath with this
	// path node as the initial node (this is so findPath doesn't have to do anchoring on airborne pawns)

	//log( name @ controller.pawn.name @ "new path!" );
	controller.findPath(controller.Pawn.Location, destination, workAIProperties, ignore, controller.Pawn.logNavigationSystem);

	controller.getFindPathResult();

	// at this point route cache is guaranteed to contain at least one location or nothing if failure
	//assert(!controller.RouteComplete || (controller.routeCache.length > 0));

	// if no path was found and no jetpack then try to get a path with a jetpack
	if ((controller.routeCache.length == 0) && !workAIProperties.jetpack)
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": no path, attempting to find path using jetpack" );

		workAIProperties.jetpack = true;
		controller.discardFindPath();
		controller.findPath(controller.Pawn.Location, destination, workAIProperties, ignore, controller.Pawn.logNavigationSystem);
		controller.getFindPathResult();
	}

	// fail if no path was found
	if (controller.routeCache.length == 0)
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": cannot find path (immediately after attempt one)" );

		errorCode = ACT_CANT_FIND_PATH;
		goto('ErrorCheck');	
	}

	// have character move toward first location if waiting for path
	forwardAction = None;
	if (!controller.isFindPathComplete())
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": doing move to preliminary route first location" @ controller.routeCache[0].location );

		// don't do anything at this point
		controller.stopMove();

		// TO DO: DECIDE WHETHER OR NOT TO DO SOMETHING HERE, NEED TO HANDLE CASE WE HAVE JETPACK PATH WITH NO JETPACK
	}

	// wait for path to complete
	while ( class'Pawn'.static.checkAlive( controller.pawn ) && !controller.isFindPathComplete() )
	{
		sleep(0.0);
	}

	if ( class'Pawn'.static.checkDead( controller.pawn ) )
		fail( ACT_ALL_RESOURCES_DIED );

	// stop character moving toward destination 
	if (forwardAction != None && !forwardAction.hasCompleted())
		forwardAction.interruptAction();

	controller.getFindPathResult();
	//log( name @ controller.pawn.name @ "discard path!" );
	controller.discardFindPath();

	// if no path was found and no jetpack then try to get a path with a jetpack
	if ((controller.routeCache.length == 0) && !workAIProperties.jetpack)
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": no path, attempting to find path using jetpack" );

		workAIProperties.jetpack = true;
		controller.findPath(controller.Pawn.Location, destination, workAIProperties, ignore, controller.Pawn.logNavigationSystem);

		// wait for path to complete
		while ( class'Pawn'.static.checkAlive( controller.pawn ) && !controller.isFindPathComplete() )
		{
			sleep(0.0);
		}

		if ( class'Pawn'.static.checkDead( controller.pawn ) )
			fail( ACT_ALL_RESOURCES_DIED );

		controller.getFindPathResult();

		controller.discardFindPath();
	}

	// fail if no path was found
	if (controller.routeCache.length == 0)
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": cannot find path (after attempt one)" );

		errorCode = ACT_CANT_FIND_PATH;
		goto('ErrorCheck');
	}

	// fail if no jetpack but we have a jetpack path and the first element is a jetpack connection
	if (workAIProperties.jetpack && !jetpackCapable && controller.routeCache[0].jetpack)
	{
		if (controller.Pawn.logNavigationSystem)
			log( name $ ": cannot find path (got a jetpack path but first reach is a jetpack reach)" );

		errorCode = ACT_CANT_FIND_PATH;
		goto('ErrorCheck');	
	}

	// if no jetpack but we have a jetpack path cull all points after first jetpack connection
	if (workAIProperties.jetpack && !jetpackCapable)
	{
		for (routeCacheI = 1; routeCacheI < controller.routeCache.length; ++routeCacheI)
		{
			if (controller.routeCache[routeCacheI].jetpack)
			{
				controller.routeCache.length = routeCacheI;
				break;
			}
		}
	}

	waitForAction( class'NS_MoveAlongWaypoints'.static.startAction(controller, self, 0, controller.routeCache.length - 1,
			target, skiCompetency, jetCompetency, groundMovement, energyUsage,
			terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ ));

ErrorCheck:
	if (errorCode != ACT_SUCCESS)
	{
		// if irreversibly off course try again
		if (errorCode == ACT_IRREVERSIBLY_OFF_COURSE)
		{
			if (controller.Pawn.logNavigationSystem)
				log( name $ ": irreversibly off course thus attempting move again" );

			goto('Begin');
		}

		// if path not found due to search space exhaustion try again using a point a bit closer
		if (!preliminaryMove && errorCode == ACT_CANT_FIND_PATH && controller.lastFindPathResult == FPR_SearchSpaceExhausted)
		{
			preliminaryMove = true;

			// calculate preliminary move point
			workVector = destination - controller.Pawn.location;
			workVector = Normal(workVector);
			workVector = controller.Pawn.location + workVector * PRELIMINARY_MOVE_DISTANCE;

			// calculate preliminary move destination
			controller.getNodesWithinSphere(workVector, PRELINARY_MOVE_DESTINATION_SEARCH_RADIUS, workPoints);
			if (workPoints.length > 0)
				destination = workPoints[0];
			else
				destination = workVector;

			if (controller.Pawn.logNavigationSystem)
				log(name $ ": failed due to pathfinder search space exhaustion, doing preliminary move to" @ destination);

			goto('Begin');
		}

		if (controller.Pawn.logNavigationSystem)
			log( name $ ": failure" );

		fail(errorCode);
	}

	// try for original destination if this was a preliminary move
	if (preliminaryMove)
	{
		preliminaryMove = false;
		destination = originalDestination;
		goto('Begin');
	}

	// partial success if jetpack path used without jetpack
	if (workAIProperties.jetpack && !jetpackCapable)
		fail(ACT_PARTIAL_SUCCESS);

	succeed();
}
