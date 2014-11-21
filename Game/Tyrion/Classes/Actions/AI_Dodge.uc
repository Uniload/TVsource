//=====================================================================
// AI_Dodge
// Dodges projectiles
//
// Dodging is usually handled inside the navigation code (the DodgeSensor
// sets a displacement vector on the controller). This action is only
// activated when the pawn isn't already moving. That's why the priority
// of the dodge goal is low.
//=====================================================================

class AI_Dodge extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var BaseAICharacter ai;
var AI_Controller c;
var ACT_ErrorCodes errorCode;		// errorcode from child action
var Vector destination;
var Pawn shooter;
var array<Actor> ignore;
var Vector lastValidLocation;

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
	ai = BaseAICharacter(resource.pawn());
	c = AI_Controller(ai.controller);

	if ( ai.logTyrion )
		log( name @ "started on" @ ai.name );

	if ( c.dodgeStartTime > c.level.TimeSeconds )
	{
		if ( ai.logTyrion )
			log( name @ "(" @ ai.name @ ") delaying by" @ c.dodgeStartTime - c.level.TimeSeconds );
		Sleep( c.dodgeStartTime - c.level.TimeSeconds );
	}

	if ( class'Pawn'.static.checkDead( ai ))
		fail( ACT_ALL_RESOURCES_DIED );

	// compute destination based on dodgeDisplacement
	destination = ai.Location + c.dodgeDisplacement;
	c.canPointBeReached( ai.Location, destination, ai, ignore, lastValidLocation );
	lastValidLocation.Z += c.dodgeDisplacement.Z;

	if ( c.dodgeDisplacement.Z == 0 )
		waitForAction( class'NS_DoLocalMove'.static.startAction( c, self, lastValidLocation, false ));
	else
		waitForAction( class'NS_DoLocalMove'.static.startAction( c, self, lastValidLocation, false, ,,,,,,,5000,1, true ));

	// look towards enemy (unnecessary if a general "stay faced towards enemy" goal is ever added to AI's)
	shooter = Pawn(characterResource().commonSenseSensorAction.dodgeSensor.queryObjectValue());
	if ( class'Pawn'.static.checkAlive( shooter ) )
	{
		waitForAction( class'NS_Turn'.static.startAction( c, self,
			Rotator(shooter.Location - ai.Location) ));		// cheat: accessing shooter's location
	}

	if ( ai.logTyrion )
		log( name @ "(" @ ai.name @ ") stopped" );

	succeed();	// pawn death check handled inside "waitForAction" 
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_DodgeGoal'
}