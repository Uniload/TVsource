//=====================================================================
// AI_SkiTo
// Forces an AI to ski to a point on the map
//=====================================================================

class AI_SkiTo extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name jetToPointName "A path node label the AI will jet to before skiing (can be empty)";
var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) Character.SkiCompetencyLevels skiCompetency "How well the AI can ski";
var(Parameters) Character.JetCompetencyLevels jetCompetency "How well the AI can jetpack";
var(Parameters) float terminalDistanceXY "How close the AI must get to its destination in XY";
var(Parameters) float terminalDistanceZ "How close the AI must get to its destination in Z";
var(Parameters) float energyUsage "How much energy the AI must have when the action completes";
var(Parameters) float terminalVelocity "How fast the AI should be going when it reaches its destination";
var(Parameters) float terminalHeight "How high above the ground the AI should be when it reaches its destination";

var(InternalParameters) editconst Vector jetToPoint;
var(InternalParameters) editconst Vector destination;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;

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

	AI_Controller(resource.pawn().controller).bSkiTo = false;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( jetToPointName != '' )
	{
		node = resource.pawn().findStaticByLabel( class'Pathfinding.PlacedNode', jetToPointName );

		if ( node == None )
		{
			log( "AI WARNING:" @ name @ "(" @ resource.pawn().name @ ") can't find specified path node" @ destinationName );
			fail( ACT_INVALID_PARAMETERS, true );
		}

		jetToPoint = node.Location;
	}

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
		log( name @ "started." @ resource.pawn().name @ "is jetting to" @ jetToPoint @ "and the skiing to" @ destination @ "(dist:" @ VDist( destination, resource.pawn().Location ) @ ")" );

	AI_Controller(resource.pawn().controller).bSkiTo = true;

	if ( jetToPoint != vect(0,0,0) )
		waitForAction( class'NS_DoLocalMove'.static.startAction( AI_Controller(resource.pawn().controller),
						self, jetToPoint, false,, skiCompetency, jetCompetency,, 
						energyUsage, terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ,
						true, true ));

	waitForAction( class'NS_DoLocalMove'.static.startAction( AI_Controller(resource.pawn().controller),
					self, destination, false,, skiCompetency, jetCompetency,, 
					energyUsage, terminalVelocity, terminalHeight, terminalDistanceXY, terminalDistanceZ,
					false, true ));

	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") stopped with errorCode" @ errorCode );

	if ( errorCode != ACT_SUCCESS )
		fail( errorCode );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_SkiToGoal'
}