//=====================================================================
// AI_Repair
//=====================================================================

class AI_Repair extends AI_MovementAction implements IBooleanActionCondition
	editinlinenew;

//=====================================================================
// Variables

var(InternalParameters) editconst Pawn target;

var BaseAICharacter ai;
var float proximity;
var ACT_ErrorCodes errorCode;		// errorcode from child action

//=====================================================================
// Functions

//---------------------------------------------------------------------
// The test used to figure out when to interrupt Follow

static function bool actionTest( ActionBase parent, NS_Action child )
{
	local AI_Repair repair;

	repair = AI_Repair(parent);

	// interrupt action when target dies
	if ( class'Pawn'.static.checkDead( repair.target ) )
		return true;

	if ( VDistSquared( child.controller.pawn.Location, repair.target.Location ) <= repair.proximity * repair.proximity )
		return true;
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

//=====================================================================
// State code

state Running
{
Begin:
	ai = baseAICharacter();

	if ( target == None )
		target = Pawn(characterResource().goalSpecificSensorAction.repairSensor.queryObjectValue());

	if ( target == None )
	{
		log( "AI WARNING:" @ name $ ":" @ ai.name @ "has no repair target" );
		succeed();
	}
	else
	{
		proximity = 0.5f * RepairPack(ai.pack).radius;

		if ( ai.logTyrion )
			log( self.name @ "started." @ ai.name @ "is repairing" @ target.name @ "at proximity" @ proximity );


		interruptActionIf( class'NS_Follow'.static.startAction( AI_Controller(ai.controller),
						self, target, 0.5f * proximity /* followFunction, positionIndex,
						energyUsage, terminalVelocity, terminalHeight )*/ ), class'AI_Repair' );

		AI_Controller(ai.controller).stopMove();

		if ( class'Pawn'.static.checkDead( target ) )
			succeed();

		if ( VDistSquared( ai.Location, target.Location ) < proximity * proximity )
		{
			if ( ai.logTyrion )
				log( self.name @ "(" @ ai.name @ ") succeeded! Activating repair pack..." );

			ai.level.speechManager.PlayDynamicSpeech( ai, 'UsePackRepair' );

			ai.pack.activate();	// assumes character has a charged repair pack (checked in goal)
			succeed();
		}
		else
		{
			if ( ai.logTyrion )
				log( self.name @ "(" @ ai.name @ ") failed with errorCode" @ errorCode );

			fail( errorCode );
		}
	}
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_RepairGoal'
}