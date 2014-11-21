//=====================================================================
// AI_Wander
// Moves randomly between specified path nodes
//=====================================================================

class AI_Wander extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editconst array<Name> wanderPointNames;
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement speed";
var(Parameters) float wanderRadius "when no path nodes are specified, wander inside this radius";
var(Parameters) Range pauseRange "min and max wait times between moves";

var Vector wanderCenter;			
var int randomIndex;
var Vector nextDest;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Callbacks from Navigation System actions

function actionSucceededCB( NS_Action child )
{
	super.actionSucceededCB( child );
	errorcode = ACT_SUCCESS;
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes anErrorCode )
{
	super.actionFailedCB( child, anErrorCode );
	errorCode = anErrorCode;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	// when Wander deactivates, AI keeps on moving with his last direction
	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		AI_Controller(resource.pawn().controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( resource.pawn().logTyrion )
		log( name $ ":" @ resource.pawn().name @ "started wandering." );

	wanderCenter = resource.pawn().Location;

	while ( true )
	{
		if ( wanderPointNames.length > 0 )
		{
			randomIndex = Rand( wanderPointNames.length );
			node = resource.pawn().findStaticByLabel( class'Pathfinding.PlacedNode', wanderPointNames[randomIndex] );

			//log( "AI_Wander: Looking for " $ wanderPointNames[randomIndex] $ "; found: " $ node.name $ " (index: " $ randomIndex $ ")" );

			if ( node == None )
			{
				log( "AI WARNING:" @ name @ "(" @ resource.pawn().name @ ") can't find specified path node" @ wanderPointNames[randomIndex] );
				fail( ACT_INVALID_PARAMETERS, true );
			}

			nextDest = node.Location;
		}
		else
		{
			nextDest = AI_Controller(resource.pawn().controller).getRandomLocation( resource.pawn(), wanderCenter, wanderRadius, 0 );
		}
	

		//log( name @ "Heading from ("@ resource.pawn().Location.X @ resource.pawn().Location.Y @ resource.pawn().Location.Z @ ") to (" @ nextDest.X @ nextDest.Y @ nextDest.Z @ ")" );

		waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(resource.pawn().controller),
						self, nextDest, None,,, groundMovement) );

		Sleep( pauseRange.Min + FRand() * (pauseRange.Max - pauseRange.Min) );
	}
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_WanderGoal'
}