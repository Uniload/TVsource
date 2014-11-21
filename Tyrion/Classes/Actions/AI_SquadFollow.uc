//=====================================================================
// AI_SquadFollow
// Has a squad follow a pawn
//=====================================================================

class AI_SquadFollow extends AI_SquadAction implements IFollowFunction
	editinlinenew;

//=====================================================================
// Constants

const MAX_SQUAD_SIZE = 9;			// maximum number of pawns in a squad
const MIN_LEADER_SPEED = 3;			// (km/h) min speed of leader for followers to update position

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "A pawn to follow";
var(Parameters) float proximity "How close to get to one's desired position while following";
var(Parameters) float formationDiameter "What's the approximate diameter of the formation?";
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;
var(Parameters) Character.GroundMovementLevels preferredGroundMovement;

var(InternalParameters) editconst Pawn target;

var int i;
var Pawn pawn;
var int aliveFollowers;	// number of alive pawns in the squad who are following (doesn't include followee or player)

var AI_Goal followGoals[MAX_SQUAD_SIZE];	// followers' goals
var int positionMap[MAX_SQUAD_SIZE];		// maps followers positionIndex to the index used by the offset function
var int lastUpdateOffset[MAX_SQUAD_SIZE];	// what was the result of the last positionIndex pawn's call to updateOffset?

//=====================================================================
// Functions

//---------------------------------------------------------------------
// number of alive pawns currently following

function int nFollowers()
{
	return aliveFollowers;
}

//---------------------------------------------------------------------
// number of alive and dead pawns

function int nPossibleFollowers()
{
	return squad().pawns.length;
}

//---------------------------------------------------------------------
// IFollowFunction interface: is a given location a valid place to follow to?

function bool validDestination( Vector point )
{
	return true;
}

//---------------------------------------------------------------------
// IFollowFunction interface: how close do you want to get to the target?

function float proximityFunction()
{
	return proximity;
}

//---------------------------------------------------------------------
// Inform an action that a particular pawn died

function pawnDied( Pawn member ) 
{
	local int i;

	if ( squad().logTyrion )
		log( name $ ": (" @ squad().name @ ")" @ member.name @ "died!" );

	assert( member != None );

	// remove followGoal of dead pawn (pawns list is not changed so positionIndexes still make sense)
	for ( i = 0; i < squad().pawns.length; i++ )
	{
		if ( squad().pawns[i] == member && followGoals[i] != None )
		{
			followGoals[i].unPostGoal( self );
			followGoals[i].Release();
			followGoals[i] = None;
			// this may give the wrong number if pawnDied is called before statecode is called, but that's ok,
			// because aliveFollowers will be recomputed in state anyways
			aliveFollowers--;
			break;
		}
	}
}

//---------------------------------------------------------------------
// Sanity check for "aliveFollowers"

function bool verifyAliveFollowers()
{
	local int i;
	local int actualFollowers;

	for ( i = 0; i < squad().pawns.length; i++ )
		if ( class'Pawn'.static.checkAlive( squad().pawns[i] ) && squad().pawns[i] != target )
		{
			//log( squad().name @ "contains:" @ squad().pawns[i].name );
			actualFollowers++;
		}

	if ( actualFollowers != aliveFollowers )
	{
		log( "AI ERROR:" @ name $ ": aliveFollowers is" @ aliveFollowers @ "; should be" @ actualFollowers );
		return false;
	}
	else
		return true;
}

//---------------------------------------------------------------------
// IFollowFunction interface: should offset be updated?

function bool updateOffset( Pawn follower, Pawn leader, int positionIndex )
{
	local float distanceSquared;
	local int i, sumUpdateOffsets;

	//log( "updateOffset called by" @ follower.name @ "("$ positionIndex $ ")" );

	distanceSquared = VDistSquared( leader.Location, follower.Location );

	if ( ( VSize( leader.Velocity ) / 80 * 3.6f > MIN_LEADER_SPEED && distanceSquared > formationDiameter * formationDiameter )
			|| distanceSquared > 4 * formationDiameter * formationDiameter )
	{
		// if all pawns are waiting for a new offset, remap positions before sending this one off
		for ( i = 0; i < nPossibleFollowers(); i++ )
			sumUpdateOffsets += lastUpdateOffset[i];

		if ( sumUpdateOffsets == 0 )
			assignPawnsToPositions();

		lastUpdateOffset[positionIndex] = 1;
		return true;
	}
	else
	{
		lastUpdateOffset[positionIndex] = 0;
		return false;
	}
}

//---------------------------------------------------------------------
// IFollowFunction interface: offset for follow function

function Vector offset( Pawn leader, int positionIndex )
{
	return offsetInternal( leader, positionMap[positionIndex] );
}

function Vector offsetInternal( Pawn leader, int positionIndex )
{
	local Vector result;
	local int row;

	// hard code positions for now; x is back(-)/front(+); y is left(-)/right(+)
	switch ( nFollowers() )
	{
	case 1:
		result.X = -100;
		result.Y = -5/6 * formationDiameter;
		break;
	case 2:
		switch( positionIndex )
		{
		case 0:
			result.X = -100;
			result.Y = -2/3 * formationDiameter;
			break;
		case 1:
			result.X = -100;
			result.Y = +2/3 * formationDiameter;
			break;
		}
		break;
	case 3:
		switch( positionIndex )
		{
		case 0:
			result.X = -100;
			result.Y = -5/6 * formationDiameter;
			break;
		case 1:
			result.X = -2/3 * formationDiameter;
			result.Y = 0;
			break;
		case 2:
			result.X = -100;
			result.Y = +5/6 * formationDiameter;
			break;
		}
		break;
	default:
		switch( positionIndex )
		{
		case 0:
			result.X = -100;
			result.Y = -formationDiameter;
			break;
		case 1:
			result.X = -4/6 * formationDiameter;
			result.Y = -200;
			break;
		case 2:
			result.X = -4/6 * formationDiameter;
			result.Y = +200;
			break;
		case 3:
			result.X = -100;
			result.Y = formationDiameter;
			break;
		default:
			row = (nFollowers() - 3) / 2;	// assuming this rounds down
			result.X = -300 * row;
			result.Y = ((positionIndex % 2) * 2 - 1) * 1/2 * formationDiameter;
			break;
		}
		break;
	}

	if ( positionIndex < 0 || positionIndex > nFollowers()-1 )
		log( "AI WARNING:" @ name @ "offsetInternal referencing illegal positionIndex (" $ positionIndex $ "). Squad only has" @ nFollowers() @ "followers" );

	//log( positionIndex $ " ("$ nFollowers() $") picked offset " $ result );

	return result >> rotator(leader.Velocity);
	//return result >> Character(leader).motor.getMoveRotation();
}

//---------------------------------------------------------------------
// assign pawns to squad positions

function assignPawnsToPositions()
{
	local int positionIndex, pawnIndex, bestPositionIndex;
	local int bPositionUsed[MAX_SQUAD_SIZE];	// (boolean arrays not allowed)
	local float bestDistSquared, distSquared;
	local Pawn pawn;

	for ( pawnIndex = 0; pawnIndex < nPossibleFollowers(); pawnIndex++ )
	{
		pawn = squad().pawns[pawnIndex];

		if ( class'Pawn'.static.checkAlive( pawn ) && pawn != target )
		{
			bestDistSquared = 99999999999999.9f;

			// find positionIndex closest to this position
			for ( positionIndex = 0; positionIndex < nFollowers(); positionIndex++ )
			{
				// distance of pawn from this position
				distSquared = VDistSquared( pawn.Location, offsetInternal( target, positionIndex ) + target.Location );

				if ( bPositionUsed[positionIndex] == 0 && distSquared < bestDistSquared )
				{
					bestDistSquared = distSquared;
					bestPositionIndex = positionIndex;
				}
			}

			bPositionUsed[bestPositionIndex] = 1;
			positionMap[pawnIndex] = bestPositionIndex;

			if ( Rook(pawn).bShowSquadDebug )
				log( "Assigning" @ pawn.name @ "to position" @ bestPositionIndex );
		}
		else
			positionMap[pawnIndex] = -1;
	}
}

//---------------------------------------------------------------------

function cleanup()
{
	local int i;
	local Controller c;

	super.cleanup();

	// stop all the followers
	for ( i = 0; i < squad().pawns.length; i++ )
	{
		if ( followGoals[i] != None )
		{
			c = followGoals[i].resource.pawn().controller;
			if ( c != None )
				AI_Controller(c).stopMove();
			followGoals[i].Release();
			followGoals[i] = None;
		}
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(squad().findByLabel( class'Engine.Pawn', targetName, true ));

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( squad().pawns.length > MAX_SQUAD_SIZE )
	{
		log( "AI ERROR:" @ name @ "contains more than" @ MAX_SQUAD_SIZE @ "pawns" );
		assert( squad().pawns.length > MAX_SQUAD_SIZE );
	}

	if ( squad().logTyrion )
		log( name @ "started." @ squad().name @ "is following" @ target.name );

	// create follow goals for pawns that are alive
	aliveFollowers = 0;
	for ( i = 0; i < MAX_SQUAD_SIZE; ++i )
	{
		if ( i < squad().pawns.length )
			pawn = squad().pawns[i];
		else
			pawn = None;

		if ( class'Pawn'.static.checkAlive( pawn ) && pawn != target )
		{
			followGoals[i] = (new class'AI_FollowGoal'( AI_MovementResource(pawn.movementAI),
								achievingGoal.priority, target, proximity, self, i,,,, preferredGroundMovement )).postGoal( self ).myAddRef();
			aliveFollowers++;
		}
		else
			followGoals[i] = None;
	}

	while ( class'Pawn'.static.checkAlive( target ) && nFollowers() > 0 )
	{
		if ( Rook(target).bShowSquadDebug )
			log( name $ ": Assigning new positions (" $ nFollowers() @ "guys left)" ) ;

		assignPawnsToPositions();

		// a goal only succeeds when the target dies (in which case all will succeed)
		// a goal only fails when the resource dies - that goal is removed in the callback
		waitForAllGoals( followGoals[0], followGoals[1], followGoals[2], followGoals[3],
						followGoals[4], followGoals[5], followGoals[6], followGoals[7], followGoals[8]);
	}

	if ( squad().logTyrion )
		log( name @ "stopped." );

	if ( nFollowers() > 0 )
		succeed();
	else
		fail( ACT_ALL_RESOURCES_DIED );
}

//=====================================================================

function classConstruct()
{
	resourceUsage = class'AI_Resource'.const.RU_LEGS;
}

defaultproperties
{
	satisfiesGoal = class'AI_SquadFollowGoal'
}