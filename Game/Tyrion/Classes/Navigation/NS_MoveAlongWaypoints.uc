//=====================================================================
// NS_MoveAlongWaypoints
//
// Follow a series of waypoints, do local obstacle avoidance and
// short distance jetting/skiing
//=====================================================================

class NS_MoveAlongWaypoints extends NS_Action
	threaded
	dependsOn(AI_Controller);

//=====================================================================
// Constants

const TERMINAL_DISTANCE_XY_JS = 1000;	// distance from destination in XY for doLocalMove to succeed while jetting
const TERMINAL_DISTANCE_Z_JS = 500;		// and for Z
const MAX_ANGLE_BETWEEN_PATH_SEGMENTS = 0.349;	// (PI/180*20) max deviation between path segments to allow larger termination distances

const MIN_HIGHSPEED_JETSKI_DIST = 2000;		// minimum distance for which to use high speed jetpacking/skiing
const MIN_HEIGHT_ABOVE_OUTSIDE_PATHNODE = 5000;
const N_TERRAIN_SAMPLES = 9;			// (was 30) number of terrain samples to find a good landing spot

//=====================================================================
// Variables

var int routeSegmentI;

var Character.SkiCompetencyLevels skiCompetency;
var Character.JetCompetencyLevels jetCompetency;
var Character.GroundMovementLevels groundMovement;
var float terminalDistanceXY;
var float terminalDistanceZ;
var float energyUsage;
var float terminalVelocity;
var float terminalHeight;

var int routeCacheStartIndex;
var int routeCacheEndIndex;
var Actor target;

var float dlmEnergyUsage;		// energyUsage parameter for the next doLocalMove
var float energyRequired;		// energy needed for next doLocalMove
var float initialEnergy;		// debug: energy level before jetpack attempt
var NS_Action moveAction;

var BaseAICharacter ai;
var float nextTerminalDistanceXY;
var float nextTerminalDistanceZ;
var bool bJetpack;				// character can use jetpacking to traverse this path
var bool bSkippedNodes;			// nodes were skipped (implying that you *must* jetpack)
var array<Actor> ignore;

var Vector landingSpot;			// initial spot to jetpack to
var Vector jetSkiDestination;	// destination for high speed jetpacking/skiing

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Every NS Action has a static startAction function which allocates the
// action, initialises it, and starts it running.
//
// target:        Actor being followed (can be None)
// skiCompetency: ski skill level during local move, none implies no skiing
// jetCompetency: jet skill level during local move, none implies no jetting
// groundMovement: type of ground based movement during local move, none implies only jetting and skiing
// energyUsage: min. amount of energy in pawn after action completes
// terminalVelocity: the speed you would like to be going when the action terminates
// terminalHeight: how high you'd like to be at destination
// terminalDistanceXY: distance from destination in XY for action to succeed
// terminalDistanceZ: distance from destination in Z for action to succeed

static function NS_MoveAlongWaypoints startAction( AI_Controller c, NS_Action parent,
	int routeCacheStartIndexIn, int routeCacheEndIndexIn, optional Actor target,
	optional Character.SkiCompetencyLevels skiCompetency, optional Character.JetCompetencyLevels jetCompetency,
	optional Character.GroundMovementLevels groundMovement,
	optional float energyUsage, optional float terminalVelocity, optional float terminalHeight,
	optional float terminalDistanceXY, optional float terminalDistanceZ)
{
	local NS_MoveAlongWaypoints action;
	local int i;
	local Vector lastLocation;
	local Vector thisLocation;
	local Vector thisSegment;
	local Vector nextSegment;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_MoveAlongWaypoints'( c, parent );

	// set action parameters
	action.routeCacheStartIndex = routeCacheStartIndexIn;
	action.routeCacheEndIndex = routeCacheEndIndexIn;

	action.target = target;
	action.skiCompetency = skiCompetency;
	action.jetCompetency = jetCompetency;
	action.groundMovement = groundMovement;
	action.energyUsage = energyUsage;
	action.terminalVelocity = terminalVelocity;
	action.terminalHeight = terminalHeight;
	action.terminalDistanceXY = terminalDistanceXY;
	action.terminalDistanceZ = terminalDistanceZ;
	action.ai = BaseAICharacter(action.controller.pawn);

	// Initialize variables in routeCache
	lastLocation = action.ai.Location;

	for ( i = routeCacheStartIndexIn; i < routeCacheEndIndexIn; i++ )
	{
		thisLocation = action.controller.routeCache[i].location;

		action.controller.routeCache[i].energy = action.ai.energyRequiredToJet( lastLocation, action.controller.routeCache[i].location, 0, true);

		if ( i < routeCacheEndIndexIn - 1 )
		{
			thisSegment = thisLocation - lastLocation;
			thisSegment /= VSize( thisSegment );	// normalize
			nextSegment = action.controller.routeCache[i + 1].location - thisLocation;
			nextSegment /= VSize( nextSegment );	// normalize

			action.controller.routeCache[i].angle = (thisSegment Dot nextSegment);
			//log( " angle " $ i $ ": " $ controller.routeCache[i].angle );
		}

		lastLocation = thisLocation;
	}

	action.runAction();
	return action;
}

//---------------------------------------------------------------------
// Possibly skip nodes of there is a jetpack link coming up
//
// return value:    nodes were skipped?
// dlmEnergyUsage:  (output) minimum energy to save for upcoming jump
// routeSegmentI:   (output) new routeCacheIndex
//
// Note: The function assumes that the end points of jetpack links aren't points that the AI is required to
// touch. Conceivably, there might be good reasons within the pathfinder to break one long jetpack link into
// smaller segments. Although this function only skips links if LOS exists to the destination, it may be
// worth thinking about adding a flag to nodes indicating that the AI must actually get there.

private final function bool skipNodes( out float dlmEnergyUsage, out int routeSegmentI )
{
	local int i;
	local bool bJetpackLinkFound;
	local bool bSkippedNodes;
	local float energyNeeded;

	for ( i = routeSegmentI + 1; i <= routeCacheEndIndex; i++ )
	{
		if ( !bJetpackLinkFound && controller.routeCache[i].jetpack )
		{
			bJetpackLinkFound = true;
			dlmEnergyUsage = energyUsage + controller.routeCache[i].energy;	// save energy for upcoming jump
		}

		// Can I jetpack directly to this node from where I am now?
		if ( bJetpackLinkFound )
		{
			energyNeeded = controller.canJetToPoint( ai, ai.Location, controller.routeCache[i].location, ai.energy - energyUsage );
			
			if ( energyNeeded >= 0 )
			{
				if ( ai.bShowJSDebug )
					log( name @ "(" @ ai.name @ "): Jumping directly to node" @ i @ "(" $ i - routeSegmentI @ "links ahead - requires" @ energyNeeded @ "energy)" );

				routeSegmentI = i;
				dlmEnergyUsage = energyUsage;	// since we're jumping directly, no need to save
				bSkippedNodes = true;
			}
		}
	}

	return bSkippedNodes;
}

//---------------------------------------------------------------------
// Is an element in the routeCache suitable for highspeed jetpacking/skiing?

private final function bool bRoomToSki( Controller.RouteCacheElement element )
{
	return element.height > MIN_HEIGHT_ABOVE_OUTSIDE_PATHNODE;
}

//---------------------------------------------------------------------
// is there space above me?
// (not used)

private final function bool bHeadRoom( Pawn ai )
{
	local Vector endPoint;

	endPoint = ai.Location;
	endPoint.Z += MIN_HEIGHT_ABOVE_OUTSIDE_PATHNODE;

	return (controller.jetLookAhead( ai.Location, endPoint ) == None);
}

//---------------------------------------------------------------------
// Should this destination be reached by fast jetpacking/skiing?
//
// return value:      do long range jetpacking/skiing?
// landingSpot:       (output) initial landing spot (only defined when function return true)
// jetSkiDestination: (output) destination to jetpacki/ski to (only defined when function return true)
// routeSegmentI:     (input, output) old and new routeCacheIndex
//
// Note: - function assumes controller routeCache has been initialized

private final function bool bDoLongRangeJetSki( out Vector landingSpot, out Vector jetSkiDestination, out int routeSegmentI )
{
	local int i;
	local bool bNodesSkipped;

	//log( "checking for skiability..." );

	if ( ai.bLogEnergyUsage )
		return false;

	i = routeSegmentI;

	//log( " 1. not too close... " @ i $ "/" $ controller.routeCache.length );

	while ( i < controller.routeCache.length - 1 &&
			bRoomToSki( controller.routeCache[i] ) &&
			bRoomToSki( controller.routeCache[i+1]) )
	{
		++i;
		bNodesSkipped = true;
	}

	if ( bNodesSkipped )
	{
		//log( " 2. room to ski..." );
		jetSkiDestination = controller.routeCache[i].location;

		// too close?
		if ( VDistSquared( jetSkiDestination, ai.location ) < MIN_HIGHSPEED_JETSKI_DIST * MIN_HIGHSPEED_JETSKI_DIST )
			return false;

		landingSpot = controller.findLandingSpot( jetSkiDestination, ai.energy - energyUsage, jetCompetency, N_TERRAIN_SAMPLES );
		if ( ai.Location == landingSpot )
			return false;		// no landing spot found

		//log( " 3. landing spot found..." );
		//return false;	// comment in to disable long-range jetpacking/skiing

		routeSegmentI = i;
		return true;
	}
	else
		return false;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( moveAction != None )
	{
		moveAction.Release();
		moveAction = None;
	}
}

//=====================================================================
// States

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ ai.name @ "): started" );

	// if terminal height corresponds to an airborne height the last route cache connection has to be jetpacked
	if ( terminalHeight > 0 )
		controller.routeCache[routeCacheEndIndex].jetpack = true;

	// Process path links
	routeSegmentI = routeCacheStartIndex;
	dlmEnergyUsage = energyUsage;

	while ( routeSegmentI <= routeCacheEndIndex )
	{
		// skip nodes if long range jetpacking/skiing possible
		if ( (jetCompetency == JC_DEFAULT && ai.jetCompetency > JC_NONE || jetCompetency > JC_NONE ) &&
			(skiCompetency == SC_DEFAULT && ai.skiCompetency > SC_NONE || skiCompetency > SC_NONE ) &&
			bDoLongRangeJetSki( landingSpot, jetSkiDestination, routeSegmentI ) )
		{
			waitForAction( class'NS_JetSkiManager'.static.startAction(controller, self, jetSkiDestination, landingSpot,
							target, skiCompetency, jetCompetency, energyUsage,
							terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ ));

			if ( errorCode != ACT_SUCCESS )
				fail( ACT_IRREVERSIBLY_OFF_COURSE );	// make MoveToLocation try again...
			else
			{
				if ( ai.bShowJSDebug )
					log( name @ "(" @ ai.name @ "): JetSkiManager succeeded" );

				routeSegmentI++;						// or go to next segment
				continue;
			}
		}

		// skip nodes if there is a jetpack link coming up
		if ( energyUsage < ai.energy &&
			((jetCompetency == JC_DEFAULT && ai.jetCompetency > JC_NONE) || jetCompetency > JC_NONE) )
		{
			bJetpack = true;
			bSkippedNodes = skipNodes( dlmEnergyUsage, routeSegmentI );
			assert( routeSegmentI <= routeCacheEndIndex );
		}

		// energy sanity check (pawn might not be exactly at waypoint)
		if ( controller.routeCache[routeSegmentI].jetpack )
			energyRequired = ai.energyRequiredToJet( ai.location, controller.routeCache[routeSegmentI].location, controller.speedInDirection( ai.Velocity, controller.routeCache[routeSegmentI].location - ai.location ), false );
		else
			energyRequired = 0;
		if ( energyRequired > ai.energyMaximum - energyUsage )
		{
			if ( ai.bShowJSDebug || ai.logNavigationSystem )
				log( name @  "(" @ ai.name @ "): fail: can't possibly get" @ energyRequired @ "energy" );
			controller.stopMove();
			fail( ACT_INSUFFICIENT_ENERGY );	// doesn't take into account that the AI could rest after the jump to get back to the required energy level
		}
		else if ( ai.bLogEnergyUsage && controller.routeCache[routeSegmentI].jetpack )
			log( name @ "(" @ ai.name @ "): need" @ energyRequired @ "energy - got" @ ai.energy - energyUsage );

		// wait if you don't have enough energy to get to the next waypoint
		while ( ai.energy < energyUsage + energyRequired )
		{
			if ( ai.bShowJSDebug )
				log( name @ "(" @ ai.name @ "): waiting for energy (" $ ai.energy @ "<" @ energyUsage + energyRequired $ ")" );
			controller.stopMove();
			Sleep(0.5);
			if ( class'Pawn'.static.checkDead( ai ) )
				fail( ACT_ALL_RESOURCES_DIED );
		}

		// process intermediate nodes

		if ( moveAction != None )
		{
			moveAction.Release();
			moveAction = None;
		}

		// treat energy barriers as normal
		if (controller.routeCache[routeSegmentI].obstacle != None &&
				EnergyBarrier(controller.routeCache[routeSegmentI].obstacle) == None)
		{
			// handle obstacle by calling obstacle specific action

			// ... door case
			if (Door(controller.routeCache[routeSegmentI].obstacle) != None)
			{
				if ((routeSegmentI + 1) < controller.routeCache.length)
					moveAction = class'NS_DoDoorMove'.static.startAction(controller, self,
							controller.routeCache[routeSegmentI - 1].location, Door(controller.routeCache[
							routeSegmentI].obstacle), controller.routeCache[routeSegmentI].location,
							true, controller.routeCache[routeSegmentI + 1].location).myAddRef();
				else
					moveAction = class'NS_DoDoorMove'.static.startAction(controller, self,
							controller.routeCache[routeSegmentI - 1].location, Door(controller.routeCache[
							routeSegmentI].obstacle), controller.routeCache[routeSegmentI].location,
							false, vect(0,0,0)).myAddRef();
			}
			// ... elevator case
			else if (ElevatorVolume(controller.routeCache[routeSegmentI].obstacle) != None)
			{
				// Terminal distance is currently a magic number. In future we may want to set this based
				// on parameters.
				moveAction = class'NS_DoZeroGravityLocalMove'.static.startAction(controller, self,
						controller.routeCache[routeSegmentI].location, ElevatorVolume(
						controller.routeCache[routeSegmentI].obstacle), 150, 400).myAddRef();
			}
			else
				warn("unknown obstacle type");
		}
		else if ((routeSegmentI + 1) < controller.routeCache.length)
		{
			if ( ai.logNavigationSystem )
				log( name @ "(" @ ai.name @ "): move to" @ controller.routeCache[routeSegmentI].location @ "started" );

			// when jetpacking in approximately a straight line, make terminationDistances much larger
			if ( bJetpack && controller.routeCache[routeSegmentI].angle > cos(MAX_ANGLE_BETWEEN_PATH_SEGMENTS) )
			{
				//log( "LARGE TERMINATION FOR NEXT DLM" );
				nextTerminalDistanceXY = TERMINAL_DISTANCE_XY_JS;
				nextTerminalDistanceZ = TERMINAL_DISTANCE_Z_JS;
			}
			else
			{
				nextTerminalDistanceXY = 0;
				nextTerminalDistanceZ = 0;
			}

			moveAction = class'NS_DoLocalMove'.static.startAction(controller, self,
					controller.routeCache[routeSegmentI].location, true, controller.routeCache[routeSegmentI + 1].location,
					skiCompetency, jetCompetency, groundMovement,
					dlmEnergyUsage, DONT_CARE, DONT_CARE, nextTerminalDistanceXY, nextTerminalDistanceZ,
					controller.routeCache[routeSegmentI].jetpack || bSkippedNodes).myAddRef();
		}
		// process final node
		else if (routeSegmentI < controller.routeCache.length)
		{
			if ( ai.logNavigationSystem )
				log( name @ "(" @ ai.name @ "): move to" @ controller.routeCache[routeSegmentI].location @ "started" );

			moveAction = class'NS_DoLocalMove'.static.startAction(controller, self,
					controller.routeCache[routeSegmentI].location, false, vect(0, 0, 0),
					skiCompetency, jetCompetency, groundMovement,
					energyUsage, terminalVelocity, terminalHeight,
					terminalDistanceXY, terminalDistanceZ,
					controller.routeCache[routeSegmentI].jetpack || bSkippedNodes).myAddRef();
		}

		initialEnergy = ai.energy;

		waitForAction( moveAction );

		if ( ai.bLogEnergyUsage )
			log( name @ "(" @ ai.name @ "): used" @ initialEnergy - ai.energy @ "energy" );

		// fail and propagate error if doLocalMove failed
		if (errorCode != ACT_SUCCESS)
		{
			// construct ignore list
			if (target != None)
				ignore[0] = target;

			// child didn't have enough energy, goto previous waypoint
			if (errorCode == ACT_INSUFFICIENT_ENERGY && routeSegmentI > routeCacheStartIndex &&
				controller.canPointBeReached( ai.Location, controller.routeCache[routeSegmentI].Location, ai, ignore ))
			{
				if ( ai.bShowJSDebug || ai.logNavigationSystem )
					log( name @ "(" @ ai.name @ "): insufficient energy, go to previous waypoint and try again" );
		
				routeSegmentI--;
				continue;
			}

			if ( ai.logNavigationSystem )
				log( name @ "(" @ ai.name @ "): failure" );

			fail(errorCode);
		}

		routeSegmentI++;
	}

	if ( ai.logNavigationSystem )
		log( name @ "(" @ ai.name @ "): success" );

	succeed();
}
