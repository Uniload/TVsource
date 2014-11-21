//=====================================================================
// NS_JetSkiManager
//
// Manage long distance jetting/skiing
//=====================================================================

class NS_JetSkiManager extends NS_Action implements IBooleanActionCondition
	threaded;

//=====================================================================
// Constants

const MIN_SKIING_SPEED = 622.2f;		// minimum skiing speed: 28 kph / 3.6 * 80
const MIN_SKIING_TIME = 1.0f;			// you always ski for at least this long
const MAX_AIRSPACE_FOR_SKIING = 500;	// maximum amount of airspace to continue skiing
const COS_MAX_SKIING_ANGLE = 0.0f;		// cos(90 Degrees): max angular deviation from line to destination
const TERMINAL_DISTANCE_XY = 5000;		// how close you need to get to your landing spot/ski destination 
const TERMINAL_DISTANCE_Z = 1000;

//=====================================================================
// Variables

var Vector destination;
var Actor target;				// Actor being followed (can be None)
var Character.SkiCompetencyLevels skiCompetency;
var Character.JetCompetencyLevels jetCompetency;
var float terminalDistanceXY;
var float terminalDistanceZ;
var float energyUsage;
var float terminalVelocity;
var float terminalHeight;

var BaseAICharacter ai;
var bool bJetpacking;
var bool bSkiing;
var Vector landingSpot;
var Vector walkDestination;		// if no landingSpot is found, the place you walk to before trying again
var int landingSpotUpdateTick;	// tick on which landingSpot was last updated
var float skiStartTime;			// time the last ski doLocalMove started

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Every NS Action has a static startAction function which allocates the
// action, initialises it, and starts it running.

static function NS_JetSkiManager startAction( AI_Controller c, NS_Action parent, Vector destination, Vector landingSpot,
	Actor target,
	optional Character.SkiCompetencyLevels skiCompetency, optional Character.JetCompetencyLevels jetCompetency,
	optional float energyUsage, optional float terminalVelocity, optional float terminalHeight,
	optional float terminalDistanceXY, optional float terminalDistanceZ )
{
	local NS_JetSkiManager action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_JetSkiManager'( c, parent );

	// set action parameters
	action.destination = destination;
	action.landingSpot = landingSpot;
	action.target = target;
	action.skiCompetency = skiCompetency;
	action.jetCompetency = jetCompetency;
	action.energyUsage = energyUsage;
	action.terminalVelocity = terminalVelocity;
	action.terminalHeight = terminalHeight;
	action.terminalDistanceXY = terminalDistanceXY;
	action.terminalDistanceZ = terminalDistanceZ;

	c.bJetSkiManager = true;
	action.runAction();
	return action;
}

//---------------------------------------------------------------------
// The test used to figure out when to interrupt skiing to do another jetpack hop

static function bool actionTest( ActionBase parent, NS_Action child )
{
	local NS_JetSkiManager jetski;
	local BaseAICharacter ai;
	local Vector destination;
	local Vector velocity2D;		// x/y velocity of character
	local Vector direction2D;		// x/y direction vector to destination
	local float velocityDotDirection;

	jetski = NS_JetSkiManager(parent);
	ai = jetski.ai;
	destination = jetski.getDestination();

	velocity2D.X = ai.Velocity.X;
	velocity2D.Y = ai.Velocity.Y;

	direction2D.X = destination.X - ai.Location.X;
	direction2D.Y = destination.Y - ai.Location.Y;

	velocityDotDirection = (velocity2D Dot direction2D) / VSize2D(velocity2D) / VSize2D(direction2D);

	// if AI is totally going the wrong way or moving too slowly: interrupt skiing
	if ( velocityDotDirection < COS_MAX_SKIING_ANGLE )
	{
		if ( ai.bShowJSDebug )
			log( jetski.name @ "(" @ ai.name @ "): STOPPING skiing because I'm way off course" );
		return true;
	}

	// some time has passed since skiing started
	if ( ai.level.timeSeconds < jetski.skiStartTime + 0.2f )
		return false;

	if ( VSizeSquared( ai.Velocity ) < MIN_SKIING_SPEED * MIN_SKIING_SPEED )
	{
		if ( ai.bShowJSDebug )
			log( jetski.name @ "(" @ ai.name @ "): STOPPING skiing because I'm too slow" );
		return true;
	}

	if ( ai.Velocity.Z >= 0 && ai.getAirSpace() > MAX_AIRSPACE_FOR_SKIING )
	{
		if ( ai.bShowJSDebug )
			log( jetski.name @ "(" @ ai.name @ "): STOPPING skiing because I'm flying through the air (like I just don't care)" );
		return true;
	}

	// if there's a good opportunity to jetpack, take it!
	if ( ai.level.timeSeconds >= jetski.skiStartTime + MIN_SKIING_TIME &&	// some time has passed since skiing started
		ai.Velocity.Z >= 0 &&												// heading up!
		!jetski.controller.bSuitableTerrainForSkiing( destination, 1.0f ) )	// ski route good for 1 sec in the future?
	{
		if ( ai.bShowJSDebug )
			log( jetski.name @ "(" @ ai.name @ "): Looking for new ski route..." );

		jetski.landingSpot = jetski.controller.findLandingSpot( destination, ai.energy - jetski.energyUsage, jetski.jetCompetency, -3 );
		if ( jetski.landingSpot != ai.Location )
		{
			jetski.landingSpotUpdateTick = jetski.controller.lastTick;
			if ( ai.bShowJSDebug )
				log( jetski.name @ "(" @ ai.name @ "): STOPPING skiing to jetpack after" @ ai.level.timeSeconds - jetski.skiStartTime $ "s" );

			return true;
		}
	}

	return false;
}

//---------------------------------------------------------------------

private final function Vector getDestination()
{
	if ( target != None )
		return target.Location;
	else
		return destination;
}

//---------------------------------------------------------------------
// Has the action's destination been reached?

private final function bool destinationReached()
{
	local Vector dest;

	dest = getDestination();

	// simple check for now
	return VSizeSquared2D( dest - controller.Pawn.Location ) < terminalDistanceXY * terminalDistanceXY &&
		abs(dest.Z - controller.Pawn.Location.Z) < terminalDistanceZ;
}

//---------------------------------------------------------------------

private final function bool bCloseToDestination()
{
	return VSizeSquared( getDestination() - controller.Pawn.Location ) <
		class'NS_MoveAlongWaypoints'.const.MIN_HIGHSPEED_JETSKI_DIST * class'NS_MoveAlongWaypoints'.const.MIN_HIGHSPEED_JETSKI_DIST;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	controller.bJetSkiManager = false;
}

//=====================================================================
// States

//---------------------------------------------------------------------
// Some thoughts on computing a long-range ski/jet route:
// This computation will be fairly reactive for now: It looks for the next good landing spot (if jetting)
// or the next launch point (if skiing). In the future, we can have it plan out the route to a greater extent
// if that proves useful.
// AI's generally plan to their next jet/ski segment along a line connecting their current position to
// their destination. This is especially true for jetting. During skiing, we might want to change
// direction slightly to take advantage of particularly juicy downhill slopes.
// Although AI's plan jetting along a line, they could consider multiple lines in an arc from their current
// position before deciding on one.
// Maybe ski routes don't have to planned much. Long, skiiable parts of the map can be taken into
// consideration when computing points to land/take off from, but these segments don't have to be stored.
// Whenever you are moving on the ground you are constantly checking to see if you should be skiing
// instead. 
// Take off points could be computed dynamically - when your skiing speed gets too slow and you are headed
// up along the side of a hill, jetpack to the next downward slope.
//
// Rules of Thumb:
// - use smallest amount of energy possible (duh)
// - large energy expenditure is justified when a lot of height/speed will be gained
// - intersect terrain under "sweet spot" angle
// - look one or two landing spots ahead (one will probably suffice)
//
// Todo: Finding the landing spot needs to be more reactive. The AI should never turn away from
// his destination, and should be able to update the landing spot while airborne => modify DLM/ add special flag?

state Running
{
Begin:
	ai = BaseAICharacter(controller.Pawn);

	if ( ai.bShowJSDebug || ai.logNavigationSystem )
		log( name @ "(" @ ai.name @ "): move to" @ getDestination() @ "started (dist:" @ VDist( getDestination(), ai.Location ) $ ")" @ destinationReached() );

	landingSpotUpdateTick = controller.lastTick;	// use passed-in value on first call so you can't instantly fail!

	do
	{
		// if jetpacking: look for point to jetpack to
		if ( (!bSkiing || bJetpacking) ) //&& !bCloseToDestination() )
		{
			if ( landingSpotUpdateTick != controller.lastTick )
				landingSpot = controller.findLandingSpot( getDestination(), ai.energy - energyUsage, jetCompetency, -3 );

			if ( landingSpot == ai.Location )
			{
				if ( ai.bShowJSDebug )
					log( name @ "(" @ ai.name @ "): no good landing spot found" );
			}
			else
			{
				if ( ai.bShowJSDebug )
					log( name @ "(" @ ai.name @ "): jetpacking!" @ VDist(landingSpot, ai.Location));

				// todo: periodically look for a better landing spot while airborne (only if it can't get to the planned spot???)
				waitForAction( class'NS_DoLocalMove'.static.startAction(controller, self, landingSpot, false, ,
						skiCompetency, jetCompetency,, energyUsage,
						class'ActionBase'.const.DONT_CARE, 0, FMin(TERMINAL_DISTANCE_XY, 0.75f * VDist(landingSpot, ai.Location)), TERMINAL_DISTANCE_Z, true, true ));

				bSkiing = true;
			}

			bJetpacking = false;
		}

		// if skiing: look for point to take off
		if ( errorcode == ACT_SUCCESS && bSkiing && !bCloseToDestination() )
		{
			if ( ai.bShowJSDebug )
				log( name @ "(" @ ai.name @ "): skiing!" );

			skiStartTime = ai.Level.timeSeconds;

			// keep skiing in desired direction to you decide to jetpack again
			interruptActionIf( class'NS_DoLocalMove'.static.startAction(controller, self, getDestination(), false, ,
					skiCompetency, jetCompetency,, energyUsage,
					class'ActionBase'.const.DONT_CARE, 0, TERMINAL_DISTANCE_XY, terminalDistanceZ, false, true ),
					class'NS_JetSkiManager');

			bSkiing = false;
			bJetpacking = true;
		}

		if ( !bSkiing && !bJetpacking )
		{
			if ( ai.bShowJSDebug )
				log( name @ "(" @ ai.name @ "): couldn't find to place to jet to or ski" );

			break;
		}
	} until ( errorcode != ACT_SUCCESS || destinationReached() || bCloseToDestination() );

	if ( destinationReached() )
	{
		if ( ai.bShowJSDebug || ai.logNavigationSystem )
			log( name @ "(" @ ai.name @ "): REACHED destination" );
		succeed();
	}
	else
	{
		if ( ai.bShowJSDebug || ai.logNavigationSystem )
			log( name @ "(" @ ai.name @ "): RETURNING to moveAlongWaypoints" );
		fail( ACT_IRREVERSIBLY_OFF_COURSE );	// <- causes MoveToLocation to try again (todo: create more appropriate failure code that does the same thing?)
	}
}
