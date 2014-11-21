//=====================================================================
// AI_MoveToLocation
// Moves to an arbitrary location on the map using walking/jetting/skiing
//=====================================================================

class AI_MoveTo extends AI_MovementAction
	editinlinenew
	dependson(NS_MoveToLocation);

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) Character.SkiCompetencyLevels skiCompetency "How well the AI can ski";
var(Parameters) Character.JetCompetencyLevels jetCompetency "How well the AI can jetpack";
var(Parameters) Character.GroundMovementLevels groundMovement "Desired ground movement mode";
var(Parameters) float terminalDistanceXY "How close the AI must get to its destination in XY";
var(Parameters) float terminalDistanceZ "How close the AI must get to its destination in Z";
var(Parameters) float energyUsage "How much energy the AI must have when the action completes";
var(Parameters) float terminalVelocity "How fast the AI should be going when it reaches its destination";
var(Parameters) float terminalHeight "How high above the ground the AI should be when it reaches its destination";
var(Parameters) Rotator terminalRotation "Which way the AI should be facing when it reaches its destination";

var(InternalParameters) editconst Vector destination;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var Actor node;
var NS_MoveToLocation.TerminalConditions terminalConditions;

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
		log( name @ "started." @ resource.pawn().name @ "is moving to" @ destination @ "(dist:" @ VDist( destination, resource.pawn().Location ) @ ")" );

	terminalConditions.velocity = terminalVelocity;
	terminalConditions.height = terminalHeight;
	terminalConditions.distanceXY = terminalDistanceXY;
	terminalConditions.distanceZ = terminalDistanceZ;
	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(resource.pawn().controller),
					self, destination, None,
					skiCompetency, jetCompetency, groundMovement,
					energyUsage, terminalConditions ));

	if ( terminalRotation != default.terminalRotation )
	{
		waitForAction( class'NS_Turn'.static.startAction( AI_Controller(resource.pawn().controller), self, terminalRotation ));
	}

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
	satisfiesGoal = class'AI_MoveToGoal'
}