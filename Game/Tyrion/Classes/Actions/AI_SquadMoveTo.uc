//=====================================================================
// AI_SquadMoveTo
// Moves a squad to an arbitrary location on the map using walking/jetting/skiing
//=====================================================================

class AI_SquadMoveTo extends AI_SquadAction implements IBooleanGoalCondition
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) float formationDiameter "What's the approximate diameter of the formation?";
var(Parameters) Character.SkiCompetencyLevels skiCompetency;
var(Parameters) Character.JetCompetencyLevels jetCompetency;
var(Parameters) Character.GroundMovementLevels groundMovement;
var(Parameters) float terminalDistanceXY;
var(Parameters) float terminalDistanceZ;
var(Parameters) float energyUsage;
var(Parameters) float terminalVelocity;
var(Parameters) float terminalHeight;

var(InternalParameters) editconst Vector destination;

var Actor node;
var Pawn pawn;
var int i;

var Pawn leader;					// leader pawn
var int leaderIndex;				// index of leader in pawn array (always last living pawn)
var int nFollowers;					// number of living followers
var AI_Goal moveGoal;				// leader's goal
var AI_Goal squadFollowGoal;		// squad goal for all the rest

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callback from child action

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes errorCode ) 
{
	super.goalNotAchievedCB( goal, child, errorCode );

	if ( (errorCode == ACT_ALL_RESOURCES_DIED || errorCode == ACT_RESOURCE_INACTIVE) && goal.isA('AI_SquadFollowGoal') )
	{
		goal.unpostGoal( self );

		if ( squad().logTyrion )
			log( name @ "unposting" @ goal.name @ "(all resources died)" );
	}

	if ( goal.isA( 'AI_MoveToGoal' ))
	{
		goal.unpostGoal( self );

		if ( squad().logTyrion )
			log( name @ "unposting" @ goal.name @ "(goal failed)" );
	}
}

//---------------------------------------------------------------------
// function to interrupt (slow down) leader if need be

static function bool goalTest( AI_Goal goal )
{
	return followersTooFarAway( AI_SquadMoveTo(goal.parentAction) );
}

//---------------------------------------------------------------------

static function bool followersTooFarAway( AI_SquadMoveTo action )
{
	local int i;
	local Pawn pawn;

	for ( i = 0; i < action.leaderIndex; i++ )
	{
		pawn = action.squad().pawns[i];

		if ( class'Pawn'.static.checkAlive( pawn ) &&
			VDistSquared( action.leader.Location, pawn.Location ) > 4 * action.formationDiameter * action.formationDiameter )
		{
			// log( action.name $ ": followers too far away!" );
			return true;
		}
	}

	return false;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	if ( moveGoal != None )
	{
		moveGoal.Release();
		moveGoal = None;
	}

	if ( squadFollowGoal != None )
	{
		squadFollowGoal.Release();
		squadFollowGoal = None;
	}
}

//=====================================================================
// State code
//
// Idea: have the leader execute the move, have the others follow him with a special version of follow that contains a desired position offset
// The offset will be updated (here or in local actions?) to take account of varying terain, doors, etc.
// In addition, AI's should have an action that coordinates them getting through doors (probably part of LOA?) whcih works even when they are not part of a squad
// This action assign a new leader if the old one dies

state Running
{
Begin:
	if ( destinationName != '' )
	{
		//log( name @ "moving to" @ destinationName );
		node = squad().findStaticByLabel( class'Pathfinding.PlacedNode', destinationName );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ squad().name @ ") can't find specified path node" @ destinationName );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		destination = node.Location;
	}

	if ( squad().logTyrion )
		log( name @ "started." @ squad().name @ "is moving to" @ destination );

	while ( leader == None )
	{
		// compute number of followers and assign leader
		nFollowers = 0;
		for ( i = squad().pawns.length-1; i >= 0; i-- )
		{
			pawn = squad().pawns[i];
			//log( name @ "checking" @ pawn.name );
			if ( class'Pawn'.static.checkAlive( pawn ) )
				if ( leader == None )
				{
					leader = pawn;	// leader is last pawn who is alive
					leaderIndex = i;
				}
				else
					nFollowers++;
		}

		if ( squad().logTyrion )
			log( name @ "picked leader" @ leader.name );

		if ( leader == None )
			fail( ACT_ALL_RESOURCES_DIED );

		if ( squadFollowGoal != None )
		{
			squadFollowGoal.unPostGoal( self );
			squadFollowGoal.Release();	// must be done here as well as cleanup because squadFollowGoal could be overwritten
			squadFollowGoal = None;
		}

		if ( nFollowers > 0 )
			squadFollowGoal = (new class'AI_SquadFollowGoal'( AI_SquadResource(resource), achievingGoal.priority, leader,
								 100, formationDiameter, ,terminalVelocity, terminalHeight, groundMovement )).postGoal( self ).myAddRef();

		do
		{
			if ( followersTooFarAway( self ) )
			{
				//log( name @ "leader waiting for followers to catch up" );
				leader.level.speechManager.PlayDynamicSpeech( leader, 'FollowLeader' );
				yield();
			}
			else
			{
				if ( moveGoal != None )
				{
					moveGoal.unPostGoal( self );
					moveGoal.Release();			// must be done here as well as cleanup because moveGoal could be overwritten
					moveGoal = None;
				}

				moveGoal = (new class'AI_MoveToGoal'( AI_MovementResource(leader.movementAI),
							achievingGoal.priority, destination,
							skiCompetency, jetCompetency, groundMovement,
							energyUsage, terminalVelocity, terminalHeight,
							terminalDistanceXY, terminalDistanceZ )).postGoal( self ).myAddRef();

				interruptGoalIf( moveGoal, class'AI_SquadMoveTo' );	// unposts goals after interruption (but not on failure)
				//log( name $ ":" @ moveGoal.resource.pawn().name $ "'s action interrupted" );
				if ( class'Pawn'.static.checkAlive( leader ) )
					AI_Controller(leader.controller).stopMove();
			}
		}
		until( (moveGoal != None && moveGoal.hasCompleted()) || class'Pawn'.static.checkDead( leader ) )

		//log( "moveGoal.Completion:" @ moveGoal.hasCompleted() );

		if ( class'Pawn'.static.checkDead( leader ) )
		{
			leader = None;
			moveGoal.unPostGoal( self );
			squadFollowGoal.unpostGoal( self );	// unposted explicitly so resources get freed up on this tick

			if ( squad().logTyrion )
				log( name @ "leader died!" );
		}
	}

	if ( squad().logTyrion )
		log( name @ "stopped." );

	if ( !moveGoal.wasAchieved() )
		fail( ACT_CANT_REACH_DESTINATION );
	else
		succeed();
}

//=====================================================================

function classConstruct()
{
	resourceUsage = class'AI_Resource'.const.RU_LEGS;
}

defaultproperties
{
	satisfiesGoal = class'AI_SquadMoveToGoal'
}