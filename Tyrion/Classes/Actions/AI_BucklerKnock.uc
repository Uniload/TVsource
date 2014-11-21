//=====================================================================
// AI_BucklerKnock
// Tries to ram a target with the buckler
//=====================================================================

class AI_BucklerKnock extends AI_CharacterAction implements IBooleanActionCondition
	editinlinenew;

//=====================================================================
// Constants

const TIME_OUT_DURATION = 4.0f;			// how long to try ramming your target
const SPRINT_SPEED = 777.0f;			// ( 35.0f * 80.0f / 3.6f )

//=====================================================================
// Variables

var(Parameters) editinline Name targetName "Label of target (should be Player)";
var(Parameters) float knockDistance "max ramming distance";

var(InternalParameters) Pawn target;	// pawn I want to ram

var BaseAICharacter ai;
var AI_Controller c;
var ACT_ErrorCodes errorCode;			// errorcode from child action
var Vector destination;
var float startTime;					// when did ramming movement start
var float endTime;						// timeOut for knocking
var Weapon w;
var float terminalHeight;
var array<Actor> ignore;
var Vector lastValidLocation;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	local BaseAICharacter ai;

	ai = BaseAICharacter(goal.resource.pawn());

	if ( ai.pack != None && ai.bUsePackActiveEffect && ClassIsChildOf( ai.pack.class, class'SpeedPack' ) )
		return 1.0;
	else
		return 0.0;
}

//---------------------------------------------------------------------
// The test used to figure out when to interrupt Follow

static function bool actionTest( ActionBase parent, NS_Action child )
{
	local AI_BucklerKnock bucklerKnock;
	local BaseAICharacter ai;

	bucklerKnock = AI_BucklerKnock(parent);
	ai = bucklerKnock.ai;

	// interrupt action when target dies
	if ( class'Pawn'.static.checkDead( bucklerKnock.target ) )
		return true;

	if ( ai.level.timeSeconds >= bucklerKnock.endTime ||	// timed out *or*
		(ai.lastBumpActor == bucklerKnock.target &&			// hit the target
		 ai.firstBumpTime >= bucklerKnock.startTime ) )
	{
		//log( ai.name @ "ended" @ bucklerKnock.name @ ai.level.timeSeconds >= bucklerKnock.endTime );
		return true;
	}
	else
		return false;
}

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	errorCode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------

function cleanup()
{
	local AI_Controller c;

	super.cleanup();

	c = AI_Controller(resource.pawn().controller);

	if ( c != None )
	{
		c.bNoLOA = false;
		c.stopMove();
	}
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "(" @ pawn.name @ ") has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started on" @ pawn.name $ ". Target:" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified pawn" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( pawn.controller == None )
	{
		log( "AI WARNING:" @ name @ "doesn't have a controller. This shouldn't be" );
		fail( ACT_GENERAL_FAILURE );
	}

	ai = baseAICharacter();
	c = AI_Controller(ai.Controller);

	while ( class'Pawn'.static.checkAlive( ai ) && class'Pawn'.static.checkAlive( target ) )
	{
		w = Buckler(ai.weapon);

		// don't block if no buckler equipped or buckler is flying 
		if ( w != None && w.hasAmmo() && ai.pack.IsInState( 'Charged' ) )
		{
			destination = target.predictedLocation( VSize2D( target.Location - ai.Location ) / SPRINT_SPEED );
			// make sure target can actually get to the predicted location...
			c.canPointBeReached( target.Location, destination, target, ignore, lastValidLocation );
			destination = lastValidLocation;

			if ( VSizeSquared2D( ai.Location - destination ) < knockDistance * knockDistance &&
				c.canJetToPoint( ai, ai.Location, destination, ai.energy ) >= 0 )
			{
				// claim legs; stop arms from firing buckler
				useResources( class'AI_Resource'.const.RU_ARMS | class'AI_Resource'.const.RU_LEGS );

				//todo: if legs weren't claimed, quit (can't really happen since this action goal has high default priority)

				// activate speed pack (has to be charged)
				ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackSpeed' );
				ai.pack.activate();

				startTime = ai.level.timeSeconds;
				endTime = startTime + TIME_OUT_DURATION;

				terminalHeight = target.Location.Z - c.getTerrainHeight( target.Location );
				if ( terminalHeight < 2.0f * target.CollisionHeight )
					terminalHeight = 0;	// no need to jetpack if target barely above the ground
				else
					terminalHeight -= class'AI_TakeCover'.const.BASE_NODE_GAP;

				//log( "KNOCK!  predicted-delta:" @ VSize2D( destination - target.Location ) );
				c.bNoLOA = true;
				interruptActionIf( class'NS_DoLocalMove'.static.startAction( c, self, destination, false,,,,,
									0,, terminalHeight, 50 ), class'AI_BucklerKnock' );
				c.bNoLOA = false;

				clearDummyWeaponGoal();			// resume regular firing behavior
				clearDummyMovementGoal();		// free up legs
			}
		}

		yield();
	}

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_BucklerKnockGoal'
}