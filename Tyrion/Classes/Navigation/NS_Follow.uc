//=====================================================================
// NS_Follow
//
// Higher level Cersei action to get to follow any target on the map using
// jetting and skiing as appropriate.
// Also works for vehicles.
//=====================================================================

class NS_Follow extends NS_Action implements IBooleanActionCondition
	threaded
	dependson(NS_MoveToLocation);

import enum GroundMovementLevels from Gameplay.Character;

//=====================================================================
// Constants

const MIN_PREDICTION_SPEED = 5.0f;	// (km/h) min speed target must be going to use prediction code on it
const MAX_UPDATE_TICKS = 200;		// how many ticks between interrupting and updating MoveToLocation?
const MIN_UPDATE_TICKS = 20;
const PROXIMITY_HYSTERESIS_FACTOR = 1.2f;	// multiplied by proximity to determine distance at which to start moving again
const PROXIMITY_HYSTERESIS_MAX = 500.0f;	// upper limit on distance added to proximity
const LOOKAHEAD_DISTANCE = 250;				// how far to look ahead for "validDestination" checks
const DEFAULT_HEIGHT_ABOVE_GROUND = 1000.0f;// default terminalHeight for flying vehicles

//=====================================================================
// Variables

var Actor target;			// the thing you are following
var Rook targetRook;
var float proximity;		// how close do you want to get?
var IFollowFunction followFunction;
var int positionIndex;		// index of this pawn in a formation (starts at 1)
var float energyUsage;
var float terminalVelocity;
var float terminalHeight;
var float desiredSpeed;

var int tickCounter;
var float distance;			// distance to target
var Vector destination;		// where I'm moving to
var Vector offset;			// offset of destination position from target
var float height;			// terrain height at target point
var bool bDoLOSCheck;		// follow until LOS of target has been achieved?
var bool bPredictedLocation;// when false, don't use predicted location!
var Character.GroundMovementLevels groundMovement;

var NS_MoveToLocation.TerminalConditions terminalConditions;

var array<Actor> ignore;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Every NS Action has a static startAction function which allocates the
// action, initialises it, and starts it running.

static function NS_Follow startAction( AI_Controller c, ActionBase parent, Actor target, float proximity,
									  optional IFollowFunction followFunction, optional int positionIndex,
									  optional float energyUsage, optional float terminalVelocity, optional float terminalHeight,
									  optional float desiredSpeed )
{
	local NS_Follow action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_Follow'( c, parent );

	// set action parameters
	action.target = target;
	action.proximity = proximity;

	action.followFunction = followFunction;
	action.positionIndex = positionIndex;
	action.energyUsage = energyUsage;
	action.terminalVelocity = terminalVelocity;
	action.terminalHeight = terminalHeight;
	action.desiredSpeed = desiredSpeed;

	action.runAction();
	return action;
}

//---------------------------------------------------------------------
// The test used to figure out when to interrupt MoveToLocation with 
// the updated target location

static function bool actionTest( ActionBase parent, NS_Action child )
{
	local NS_Follow follow;

	follow = NS_Follow(parent);

	// interrupt action when target dies
	if ( follow.targetRook != None && class'Pawn'.static.checkDead( follow.targetRook ) )
		return true;

	follow.computeDestinationAndDistance();

	// don't count time spent pathfinding in tickCount (or AI can get interrupted before it has had a chance to pathfind)
	if (child.controller.isFindPathComplete())
	{
		follow.tickCounter++;
	}

	if (	// enough time elapsed?
		   (!child.controller.bAvoiding &&
			!child.controller.bJetSkiManager &&
			follow.tickCounter > Min( MAX_UPDATE_TICKS, Max( MIN_UPDATE_TICKS, follow.distance / 10 )) )
			// close enough?
		|| (follow.distance <= follow.proximityFunction() && follow.bLOSCheck())
			// can't move any further?
		|| (follow.followFunction != None &&
			!follow.followFunction.validDestination( follow.predictedLocation( follow.destination )) &&
			!follow.followFunction.validDestination( follow.destination )))
	{
		if ( child.controller.Pawn.logNavigationSystem )
			log( follow.name $ ":" @ child.controller.Pawn.name @ "updating target location after" @ follow.tickCounter @ "ticks. Distance" @ follow.distance @ "(" $ follow.proximityFunction() $ ")" );

		follow.tickCounter = 0;
		return true;
	}
	else
		return false;
}

//---------------------------------------------------------------------
// Return false if LOS check is required and target cannot be seen

private final function bool bLOSCheck()
{
	return !bDoLOSCheck || (Rook(controller.pawn).bUnobstructedLOF && Rook(controller.pawn).vision.isLocallyVisible( targetRook ));
}

//---------------------------------------------------------------------
// look ahead from the pawn's current position in direction of the destination

private final function Vector predictedLocation( Vector destination )
{
	local Vector direction;

	direction = destination - controller.pawn.Location;
	direction *= LOOKAHEAD_DISTANCE / VSize( direction );

	return controller.pawn.Location + direction;
}

//---------------------------------------------------------------------
// how close do you want to get?

private final function float proximityFunction()
{
	if ( followFunction != None )
		return followFunction.proximityFunction();
	else
		return proximity;
}

//---------------------------------------------------------------------
// maximum distance from target before movement engages again

private final function float maxWaitingDistance()
{
	local float maxDistance;

	maxDistance = proximityFunction();
	maxDistance += FMin( maxDistance * (PROXIMITY_HYSTERESIS_FACTOR - 1.0f), PROXIMITY_HYSTERESIS_MAX );
	return maxDistance;
}

//---------------------------------------------------------------------
// Compute location to move to and distance to it

function computeDestinationAndDistance()
{
	local float runSpeed;
	local array<Actor> ignore;
	local Vector lastValidLocation;

	// what's my destination offset to target?
	if ( followFunction != None && targetRook != None && followFunction.updateOffset( controller.Pawn, targetRook, positionIndex ))
	{
		offset = followFunction.offset( targetRook, positionIndex );

		if ( controller.Pawn.logNavigationSystem )
			log( name @ "(" @ controller.Pawn.name @ ") followFunction.offset:" @ offset);
	}

	if ( bPredictedLocation &&
		((followFunction != None && !IsZero( offset )) || VSize( target.Velocity ) > MIN_PREDICTION_SPEED * 80.0f / 3.6f ))
	{
		runSpeed = ( 30.f * 80.f / 3.6f );	// todo: average run/sprint speed - READ FROM FUSION

		destination = target.Location;
		if ( followFunction != None )
			destination += offset;
		if ( targetRook != None )
		{
			destination = targetRook.predictedLocation( VDist( destination, controller.Pawn.Location ) / runSpeed );
			if ( followFunction != None )
				destination += offset;
		}

		// where's the target going to be when I get close
		//old: destination.Z += VDist( destination, target.Location );		// point to start the raytrace from
		//old: destination.Z = controller.getTerrainHeight( destination ) + controller.Pawn.CollisionHeight;
		controller.canPointBeReached( target.Location, destination, controller.Pawn, ignore, lastValidLocation );
		destination = lastValidLocation;
	}
	else
		// don't bother using prediction if target's velocity small
		destination = target.Location;
		
	distance = VDist( destination, controller.Pawn.Location );
}

//---------------------------------------------------------------------
// return pertinent information about an action for debugging

function string actionDebuggingString()
{
	if ( target == None )
		return String(name) @ "None," $ proximityFunction() $ "," $ maxWaitingDistance();
	else
		return String(name) @ target.label $ "," $ proximityFunction() $ "," $ maxWaitingDistance();
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	followFunction = None;
}

//=====================================================================
// States

state Running
{
Begin:
	if ( controller.Pawn.logNavigationSystem )
		log( name @ "(" @ controller.Pawn.name @ ") started following" @ target.name );

	targetRook = Rook(target);

	// initialize offset
	if ( followFunction != None && targetRook != None )
		offset = followFunction.offset( targetRook, positionIndex );

	// enemy targets are followed until LOS is achieved
	bDoLOSCheck = targetRook != None && !Rook(controller.Pawn).isFriendly( targetRook );

	while ( ( targetRook == None || class'Pawn'.static.checkAlive( targetRook ) )
			&& class'Pawn'.static.checkAlive( controller.pawn ) )
	{
		computeDestinationAndDistance();

		// check whether within proximity of target
		while (		// close enough?
				   (distance < maxWaitingDistance() && bLOSCheck() )
					// can't move any further?
				|| (followFunction != None &&
					!followFunction.validDestination( destination ) &&
					!followFunction.validDestination( predictedLocation( destination ))))
		{
			//log( name @ "(" @ controller.Pawn.name @ "): holding at" @ distance @ "distance (" @ maxWaitingDistance() @ "). LOS:" @ bLOSCheck() @
			//	"validDest:" @ followFunction == None || followFunction.validDestination( destination ) );

			controller.stopMove();
			yield();
			if ( (targetRook != None && class'Pawn'.static.checkDead( targetRook )) || class'Pawn'.static.checkDead( controller.pawn ) )
				goto 'exit';
			computeDestinationAndDistance();
		}

		if ( Rook(controller.pawn).bShowSquadDebug )
			Rook(controller.pawn).desiredLocation = destination;
		
		if ( controller.Pawn.logNavigationSystem && distance != VDist( controller.Pawn.Location, target.Location ))
			log( name $ ": Starting a new move for" @ controller.pawn.name $ ". Moving to target's predicted location (" $ distance - VDist( controller.Pawn.Location, target.Location ) @ "ahead)" );

		if ( bDoLOSCheck )
			terminalConditions.distanceXY = FMin( 200, proximityFunction() );	// need to keep following enemies till LOF is achieved
		else
			terminalConditions.distanceXY = proximityFunction();
		terminalConditions.velocity = terminalVelocity;
		terminalConditions.height = terminalHeight;

		if ( controller.Pawn.IsA( 'Character' ))
		{
			// Unreal won't let me cast from a float to an enum...
			if ( desiredSpeed == class'Character'.const.GM_Walk_Int )
				groundMovement = GM_WALK;
			else if ( desiredSpeed == class'Character'.const.GM_Run_Int )
				groundMovement = GM_RUN;
			interruptActionIf( class'NS_MoveToLocation'.static.startAction( controller, self, destination, target,
				, , groundMovement, energyUsage, terminalConditions ), class'NS_Follow' );
		}
		else if ( controller.Pawn.IsA( 'Car' ))
		{
			interruptActionIf( class'CarMoveToLocation'.static.startAction( controller,	self, destination, desiredSpeed ),
				class'NS_Follow' );
		}
		else
		{
			height = controller.getTerrainHeight( destination );
			if ( terminalHeight == 0 )
				destination.Z = FMax( destination.Z, height + DEFAULT_HEIGHT_ABOVE_GROUND ); 
			else
				destination.Z += terminalHeight;

			interruptActionIf( class'AircraftMoveToLocation'.static.startAction( controller, self, destination, true, desiredSpeed ),
				class'NS_Follow' );
		}

		if ( tickCounter != 0 && errorCode != ACT_SUCCESS && class'Pawn'.static.checkAlive( controller.pawn ) )
		{
		   	if ( controller.Pawn.logNavigationSystem )
				if ( bPredictedLocation )
					log( name @ "(" @ controller.Pawn.name @ "): Couldn't find path to predicted location; trying again with actual location" );
				else
					log( name @ "(" @ controller.Pawn.name @ "): WARNING: couldn't find path" );

			controller.stopMove();
			bPredictedLocation = false;
		}
		else
			bPredictedLocation = true;
	}

exit:
	if ( class'Pawn'.static.checkAlive( controller.pawn ) )
		succeed();	// only succeeds if target died and I didn't die
	else
		fail( ACT_ALL_RESOURCES_DIED );
}

//=====================================================================

defaultproperties
{
	bPredictedLocation = true
}
