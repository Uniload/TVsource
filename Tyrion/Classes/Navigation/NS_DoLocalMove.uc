//=====================================================================
// NS_DoLocalMove
//
// Encapsulates the native latent function doLocalMove within a
// Navigation System action.
//=====================================================================

class NS_DoLocalMove extends NS_Action
	native
	threaded
	dependson(AI_Controller);

//=====================================================================
// Constants

//=====================================================================
// Variables

var vector destination;
var Character.SkiCompetencyLevels skiCompetency;
var Character.JetCompetencyLevels jetCompetency;
var Character.GroundMovementLevels groundMovement;
var bool nextDestinationValid;
var vector nextDestination;
var float terminalDistanceXY;
var float terminalDistanceZ;
var float energyUsage;
var float terminalVelocity;
var float terminalHeight;
var bool bMustJetpack;
var bool bMustSki;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Every NS Action has a static startAction function which allocates the
// action, initialises it, and starts it running.
//
// destination: location where character desires to be at end of local move
// skiCompetency: ski skill level during local move, none implies no skiing
// jetCompetency: jet skill level during local move, none implies no jetting
// groundMovement: type of ground based movement during local move, none implies only jetting and skiing
// nextDestinationValid: true if nextDestination parameter is valid
// nextDestination: next destination that will be used for next call, ignored if nextDestinationValid is false
// energyUsage: min. amount of energy in pawn after action completes
// terminalVelocity: the speed you would like to be going when the action terminates
// terminalHeight: how high you'd like to be at destination
// terminalDistanceXY: distance from destination in XY for action to succeed
// terminalDistanceZ: distance from destination in Z for action to succeed
// bMustJetpack: destination is only reachable by jetpacking (overrides bMustSki)
// bMustSki: destination should be reached by skiing

static function NS_DoLocalMove startAction( AI_Controller c, ActionBase parent, vector destination,
	bool nextDestinationValid, optional vector nextDestination,
	optional Character.SkiCompetencyLevels skiCompetency, optional Character.JetCompetencyLevels jetCompetency,
	optional Character.GroundMovementLevels groundMovement,
	optional float energyUsage, optional float terminalVelocity, optional float terminalHeight,
	optional float terminalDistanceXY, optional float terminalDistanceZ,
	optional bool bMustJetpack, optional bool bMustSki )
{
	local NS_DoLocalMove action;

	// create new object
	// (in the future, we may want to allow for actions that don't create a
	// new action, and pay for that by having their child not be interruptable)
	action = new(c.level.Outer) class'NS_DoLocalMove'( c, parent );

	// verify parameter validity
	assert((skiCompetency != SC_None) || (jetCompetency != JC_None) ||
			(groundMovement != GM_None));

	// set action parameters
	action.destination = destination;
	action.nextDestinationValid = nextDestinationValid;
	action.nextDestination = nextDestination;
	action.skiCompetency = skiCompetency;
	action.jetCompetency = jetCompetency;
	action.groundMovement = groundMovement;
	action.terminalVelocity = terminalVelocity;
	action.terminalHeight = terminalHeight;
	action.terminalDistanceXY = terminalDistanceXY;
	action.terminalDistanceZ = terminalDistanceZ;
	action.energyUsage = energyUsage;
	action.bMustJetpack = bMustJetpack;
	action.bMustSki = bMustSki;

	action.runAction();
	return action;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	controller.bJetpacking = false;

	// need to guarantee that dlm will be None'd when DoLocalMove stops running
	if ( controller != None )
		controller.dlm = None;
}

//=====================================================================
// States

state Running
{
Begin:
	if (controller.Pawn.logNavigationSystem)
		log( name @ "(" @ controller.Pawn.name @ "): move to" @ destination @ "started (dist:" @ VDist(destination, controller.Pawn.Location) $ ")" );

	// setting these optional values has to be done here (and not in startAction) since pawn instance is accessed
	if ( skiCompetency == SC_Default )
		skiCompetency = Character(controller.pawn).skiCompetency;
	if ( jetCompetency == JC_Default )
		jetCompetency = Character(controller.pawn).jetCompetency;

	controller.doLocalMove( self );

	if (controller.Pawn.logNavigationSystem)
	{
		switch( controller.dlmReturnValue )
		{
		case DLM_SUCCESS:		
			log( name $ ": success" );
			break;
		case DLM_CANT_FIND_PATH: 
			log( name $ ": failure due to failure to find path" );
			break;
		case DLM_IRREVERSIBLY_OFF_COURSE:
			log( name $ ": failure due to being irreversibly off course" );
			break;
		case DLM_TIME_LIMIT_EXCEEDED:
			log( name $ ": failure due to time limit exceeded" );
			break;
		case DLM_INSUFFICIENT_ENERGY:
			log( name $ ": failure due to insufficient energy" );
			break;
		case DLM_ALL_RESOURCES_DIED:
			log( name $ ": failure due to pawn death" );
			break;
		case DLM_DESTINATION_ENCROACHED:
			log( name $ ": failure due to destination encroached" );
			break;
		default:
			log( name $ ": unknown errorCode" @ controller.dlmReturnValue @ "from doLocalMove" );
			break;
		}
	}

	switch( controller.dlmReturnValue )
	{
	case DLM_SUCCESS:		
		succeed();
		break;
	case DLM_CANT_FIND_PATH: 
		fail( ACT_ErrorCodes.ACT_CANT_FIND_PATH );
		break;
	case DLM_IRREVERSIBLY_OFF_COURSE:
		fail( ACT_ErrorCodes.ACT_IRREVERSIBLY_OFF_COURSE );
		break;
	case DLM_TIME_LIMIT_EXCEEDED:
		fail( ACT_ErrorCodes.ACT_TIME_LIMIT_EXCEEDED );
		break;
	case DLM_INSUFFICIENT_ENERGY:
		fail( ACT_ErrorCodes.ACT_INSUFFICIENT_ENERGY );
		break;
	case DLM_DESTINATION_ENCROACHED:
		fail( ACT_ErrorCodes.ACT_DESTINATION_ENCROACHED );
		break;
	case DLM_ALL_RESOURCES_DIED:
		fail( ACT_ErrorCodes.ACT_ALL_RESOURCES_DIED );
		break;
	}
}