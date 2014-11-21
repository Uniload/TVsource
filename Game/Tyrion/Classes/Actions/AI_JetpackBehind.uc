//=====================================================================
// AI_JetpackBehind
// aggressive movement towards and behind the opponent
//=====================================================================

class AI_JetpackBehind extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Constants

const DIAGONAL_ROTATION = 0.7853981f;	// (PI/4) = 45 deg
const DIAGONAL_DISTANCE = 2000;
const DIRECT_DISTANCE = 2000;
const MIN_ENERGY_TO_JETPACK = 75.0f;	// ai needs this much energy to jetpack behind player (as opposed to walk)
const TERMINAL_HEIGHT = 800;

//=====================================================================
// Variables

var(Parameters) editinline float proximity "How close to get while following";
var(Parameters) editinline vector destination "Where to jetpack to? (if (0,0,0) the action will chose a point)";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IFollowFunction followFunction;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var AI_Goal pursueGoal;
var BaseAICharacter ai;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from subGoals

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	super.goalNotAchievedCB( goal, child, errorCode );

	if ( goal == pursueGoal )
		instantFail( ACT_LOST_TARGET );
}

//---------------------------------------------------------------------
// return false if no good point found

final static function bool getJetpackBehindPoint( out vector destination, BaseAICharacter ai, Pawn target )
{
	local Vector targetVector;		// normalized Vector to target
	local AI_Controller c;

	c = AI_Controller(ai.controller);

	targetVector = target.Location - ai.Location;
	targetVector.Z = 0;
	targetVector /= VSize2D( targetVector );

	// 1. check for a good position diagonally behind target
	destination = DIAGONAL_DISTANCE * rotateZ( targetVector, DIAGONAL_ROTATION ) + target.Location;
	//destination = class'AI_GainHeight'.static.findHighPosition( ai, destination, 1000, 0, ai.energy > MIN_ENERGY_TO_JETPACK );
	destination = c.getRandomLocation( ai, destination, 1000, 0, ai.energy > MIN_ENERGY_TO_JETPACK );

	if ( destination != ai.Location )
	{
		//log( "Picked 1st jetpackBehindPoint" @ VDist( destination, ai.Location ) @ VSize2D( destination - ai.Location ) );
		return true;
	}

	// 2. check for a good position behind target
	destination = DIRECT_DISTANCE * targetVector + target.Location;
	//destination = class'AI_GainHeight'.static.findHighPosition( ai, destination, DIRECT_DISTANCE-100, 0, ai.energy > MIN_ENERGY_TO_JETPACK );
	destination = c.getRandomLocation( ai, destination, DIRECT_DISTANCE-100, 0, ai.energy > MIN_ENERGY_TO_JETPACK );

	//if ( destination != ai.Location )
	//	log( "Picked 2nd jetpackBehindPoint" );

	return ( destination != ai.Location );
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	followFunction = None;

	if ( class'Pawn'.static.checkAlive( rook() ) )
		AI_Controller(rook().controller).stopMove();

	if ( pursueGoal != None )
	{
		pursueGoal.Release();
		pursueGoal = None;
	}
}

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal
/*
static function float selectionHeuristic( AI_Goal goal )
{
	// Preconditions are the conditions for when being aggressive is a good idea
	// (taken from Michael Johnston’s “The Bridge” document)
	//
	// Basically, we want to exploit situations where attacking might result in a kill
	//
	// <Duel just started> ||
	// <I have a perceived energy advantage> ||
	// <Target HP low> ||
	// <Target vulnerable> ||
	// <Just landed first hit> ||
	// <My HP extremely low>

	if ( Rook(goal.resource.pawn()).vision.isVisible( AI_ChaseGoal(goal).target ) &&
		( FRand() < 0.5 ||
		AI_ChaseGoal(goal).target.health < 0.25f * AI_ChaseGoal(goal).target.default.health ||	// target hp low
		goal.resource.pawn().health < 0.2f * goal.resource.pawn().default.health ))	// my HP extremely low
		return 1.0;
	else
		return 0.0;
}
*/

//---------------------------------------------------------------------
// height of ceiling above specified location

private final function float ceilingHeight( Pawn pawn, Vector loc )
{
	local Vector hitLocation, hitNormal, endLoc, extent;

	endLoc = loc;
	endLoc.Z += TERMINAL_HEIGHT;
	extent.X = Pawn.CollisionRadius;
	extent.Y = Pawn.CollisionRadius;
	extent.Z = Pawn.CollisionHeight;

	if ( pawn.Trace( hitLocation, hitNormal, endloc, loc, true, extent ) == None )
		return TERMINAL_HEIGHT;
	else
		return ( hitLocation.Z - loc.Z );
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( ai.logTyrion )
		log( name @ "started." @ ai.name @ "is getting behind" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "(" @ ai.name @ ") can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( VSizeSquared2D( target.Location - ai.Location ) > proximity * proximity )
	{
		pursueGoal = (new class'AI_PursueGoal'( movementResource(),
					achievingGoal.priority, target, 0.75f * proximity, followFunction,, 0, class'ActionBase'.const.DONT_CARE, 0 )).postGoal( self ).myAddRef();

		while ( class'Pawn'.static.checkAlive( ai ) &&
			    class'Pawn'.static.checkAlive( target ) &&
				VSizeSquared2D( target.Location - ai.Location ) > proximity * proximity )
			yield();

		pursueGoal.unPostGoal( self );	// no need to Release since goal can't be overwritten
	}

	if ( destination == vect(0,0,0) && !getJetpackBehindPoint( destination, ai, target ) )
	{
		//log( "Failed to find a good point" );
		succeed();		// failed to find a good point
	}

	if ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) )
	{
		//log( name @ "(" @ ai.name @ "): distance of random point from me:" @ VSize2D( destination - ai.Location ) $
		//	", distance from player:" @ VSize2D( target.Location - ai.Location ) @
		//	"valid:" @ followFunction == None || followFunction.validDestination( destination ) @
		//	"energy:" @ ai.energy );

		if ( followFunction == None || followFunction.validDestination( destination ) )
		{
			if ( ai.energy > MIN_ENERGY_TO_JETPACK )
				waitForAction( class'NS_DoLocalMove'.static.startAction( AI_Controller(ai.controller), self,
								destination, false, ,,,,,, FMin( TERMINAL_HEIGHT, ceilingHeight( ai, destination )),
								200, 1000, true ));
			else
				waitForAction( class'NS_DoLocalMove'.static.startAction( AI_Controller(ai.controller), self,
								destination, false ));
		}

		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") succeeded" );
	}

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_JetpackBehindGoal'
}