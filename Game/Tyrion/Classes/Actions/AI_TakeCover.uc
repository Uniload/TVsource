//=====================================================================
// AI_TakeCover
// Tries to find a location that offers protection from fire
//=====================================================================

class AI_TakeCover extends AI_MovementAction
	dependsOn(NS_MoveToLocation)
	editinlinenew;

//=====================================================================
// Constants

const MAX_SEARCH_TICKS = 5;					// number of ticks you try looking for cover
const SEARCH_RADIUS = 2000.0f;				// max distance of cover location
const MAX_REACHABLE_NODES_CONSIDERED = 10;
const SEARCH_DURATION = 10;					// time to look around for if no cover is found (seconds)
const BASE_NODE_GAP = 125.0f;				// manual keep in synch with PFGlobalConstants::BASE_NODE_GAP

//=====================================================================
// Variables

var(Parameters) bool bSearch "look around if no cover is found?";
var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn target;

var BaseAICharacter ai;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var NS_MoveToLocation.TerminalConditions terminalCOnditions;
var Vector destination;
var int i;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	if ( child.isA( 'NS_MoveToLocation' ))
		errorCode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	if ( child.isA( 'NS_MoveToLocation' ))
		errorCode = anErrorCode;
}

//---------------------------------------------------------------------
// Find cover from shots fired by "target"
// returns false if no cover found
// "result" contains location of cover (BASE_NODE_GAP above the ground) - is undefined if no cover is found

static final function bool findCover( out Vector result, Pawn pawn, Pawn enemy, optional bool bDontUsePathNodes )
{
	local int i,j;
	local Vector trialDest, pawnDest;
	local bool bNewTrial;
	local array<Vector> nodes;
	local AI_Controller c;
	local array<Actor> ignore;

	c = AI_Controller(pawn.controller);

	c.getNodesWithinSphere( pawn.Location, SEARCH_RADIUS, nodes );
	for ( i = 0; i < MAX_REACHABLE_NODES_CONSIDERED; ++i )
	{
		bNewTrial = false;
		while ( j < nodes.length && !bNewTrial && !bDontUsePathNodes )
		{
			trialDest = nodes[j];
			pawnDest = trialDest;
			pawnDest.Z += pawn.CollisionHeight - BASE_NODE_GAP;	// where pawn will be located when it reaches "trialDest"

			// todo (possibly): call findPath (copy usage in MovetoLocation) to get nodes around corners
			if ( c.canPointBeReached( pawn.Location, trialDest, pawn, ignore ) &&
				!c.isPointEncroachedForMovement( pawn, pawnDest ) )
			{
				//log( pawn.name @ "looking at point" @ j @ "in nodes array (i:" @ i $ ")" );
				bNewTrial = true;
			}
			++j;
		}

		if ( !bNewTrial )
		{
			//log( pawn.name @ "looking at random point (i:" @ i $ ")" );
			trialDest = c.getRandomLocation( pawn, pawn.Location, SEARCH_RADIUS, 200 );
			bNewTrial = true;
		}

		result = trialDest;
		trialDest.Z += 2.0f * pawn.CollisionHeight - BASE_NODE_GAP;		// trace to top of head

		if ( c.offersCover( enemy, trialDest ) )	// does trialDest offer cover?
		{
			//log( pawn.name @ "can't be seen by" @ enemy.name @ "(i:" @ i $ ")" );
			return true;
		}
	}

	return false;
}

//---------------------------------------------------------------------
// Make the AI search for a specified time

latent function search( BaseAICharacter ai, float time )
{
	// wait for movement to stop or animation will be clobbered
	AI_Controller(ai.controller).stopMove();

	while ( !isZero( ai.Velocity ) )
		yield();
	ai.LoopAnimation( "AI_Searching" );

	Sleep( time );

	ai.StopAnimation();
}

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") started on" @ ai.name );

	if ( class'Pawn'.static.checkDead( target ) )
	{
		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") Target is dead. Succeeding." );
		succeed();
	}

	terminalConditions.distanceXY = 50;	// gotta hit cover fairly exactly

	for ( i = 0; i < MAX_SEARCH_TICKS; i++ )
	{
		if ( findCover( destination, ai, target, i != 0 ) )
		{
			waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(ai.controller),
						self, destination, None,,,, energyUsage, terminalConditions ));

			break;
		}
		yield();

		if ( class'Pawn'.static.checkDead( ai ) )
			fail( ACT_ALL_RESOURCES_DIED );
	}

	// look towards enemy (unnecessary if a general "stay faced towards enemy" goal is ever added to AI's)
	waitForAction( class'NS_Turn'.static.startAction( AI_Controller(ai.controller), self, Rotator(target.Location - ai.Location) ));	// cheat: accessing target's location

	if ( errorCode != ACT_SUCCESS )
	{
		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") couldn't reach cover" );

		if ( bSearch )
		{
			search( ai, SEARCH_DURATION );
			succeed();
		}
		else
			fail( ACT_CANT_REACH_DESTINATION );
	}
	else
	{
		if ( i == MAX_SEARCH_TICKS )
		{
			if ( ai.logTyrion )
				log( name @ "(" @ ai.name @ ") couldn't find cover! Eep!" );

			if ( bSearch )
			{
				search( ai, SEARCH_DURATION );
				succeed();
			}
			else
				fail( ACT_GENERAL_FAILURE );	// couldn't find cover
		}
		else
		{
			Sleep(10.0f);			// stay in cover for a while... (todo: is there a test I can use here instead?)

			if ( ai.logTyrion )
				log( name @ "(" @ ai.name @ ") succeeded" );
			succeed();
		}
	}

}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_TakeCoverGoal'
}