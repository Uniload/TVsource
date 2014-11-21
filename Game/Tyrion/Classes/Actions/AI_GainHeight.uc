//=====================================================================
// AI_GainHeight
// Tries to find nearby higher locations to go to
//=====================================================================

class AI_GainHeight extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn target;

var ACT_ErrorCodes errorCode;		// errorcode from child action
var Vector destination;

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
// Find highest spot in a certain area (BASE_NODE_GAP above the ground)
// returns pawn's location if no good spot found

static final function Vector findHighPosition( Pawn pawn, Vector center, float outerRadius, optional float innerRadius, optional bool bJetpack )
{
	local Vector result;
	local Vector trialDest;				// sampled destinations
	local int i;
	local AI_Controller c;

	c = AI_Controller(pawn.controller);
	result = c.getRandomLocation( pawn, center, outerRadius, innerRadius, bJetpack );

	for ( i = 0; i < 9; i++ )
	{
		trialDest = c.getRandomLocation( pawn, center, outerRadius, innerRadius, bJetpack );
		if ( trialDest.Z > result.Z )
			result = trialDest;
	}

	return result;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( resource.pawn().logTyrion )
		log( name @ "started on" @ resource.pawn().name );

	// destination = FindGoodPosition(energy, location, velocity, enemy-position);

	destination = static.findHighPosition( resource.pawn(), resource.pawn().Location, 2000, 1500,
											character().jetCompetency > JC_NONE );

	if ( destination.Z <= resource.pawn().Location.Z )
	{
		if ( resource.pawn().logTyrion )
			log( name @ "couldn't find a suitable location." );
		fail( ACT_GENERAL_FAILURE );
	}

	waitForAction( class'NS_MoveToLocation'.static.startAction( AI_Controller(resource.pawn().controller),
					self, destination, None,,,, energyUsage ));

	if ( errorCode != ACT_SUCCESS )
		fail( ACT_CANT_REACH_DESTINATION );
	else
		succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GainHeightGoal'
}