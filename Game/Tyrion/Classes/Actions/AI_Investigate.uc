//=====================================================================
// AI_Investigate
// Move to a location and look around.
// The action terminates more than "searchTime" seconds have elapsed
//=====================================================================

class AI_Investigate extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) float searchTime "How long (in seconds) to look for target at destination";

var(InternalParameters) Pawn target;	// the pawn being looked for (can be None) 
var(InternalParameters) editconst Vector destination;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;						// destination node

//=====================================================================
// Functions

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
	super.cleanup();

	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		AI_Controller(resource.pawn().controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( destinationName != '' )
	{
		node = resource.pawn().findStaticByLabel( class'Pathfinding.PlacedNode', destinationName );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ resource.pawn().name @ ") can't find specified path node" @ destinationName );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		destination = node.Location;
	}

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ resource.pawn().name @ "is investigating" @ destination );

	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(resource.pawn().controller),
					self, destination 
					/*, skiCompetency, jetCompetency, groundMovement, energyUsage */));

	if ( errorCode != ACT_SUCCESS )
	{
		if ( resource.pawn().logTyrion )
			log( name @ "(" @ resource.pawn().name @ ") couldn't get to investigation location" @ errorCode );
		fail( errorCode );
	}

	if ( resource.pawn().logTyrion )
		log( name $ ":" @ resource.pawn().name @ "is looking around." );

	waitForGoal( (new class'AI_SearchGoal'( resource, achievingGoal.priority, target, GM_Walk )).postGoal( self ), true );

	if ( resource.pawn().logTyrion )
		log( name @ "stopped." );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_InvestigateGoal'
}