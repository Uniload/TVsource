//=====================================================================
// AI_EnterVehicle
// Moves to a vehicle or turret and enters it
//=====================================================================

class AI_EnterVehicle extends AI_MovementAction implements IBooleanActionCondition
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name vehicleOrTurretName "Name of vehicle or turret to enter";
var(Parameters) Vehicle.VehiclePositionType vehiclePosition "Preferred vehicle position to enter; if position is taken AI will enter any free position";
var(Parameters) float energyUsage;

var(InternalParameters) editconst Pawn vehicleOrTurret;

var() float proximity "Added to the collisionRadius of the vehicle to determine at what distance the AI will enter";

var ACT_ErrorCodes errorCode;		// errorcode from child action
var array<Vehicle.VehiclePositionType> secondaryPositions;
var Vehicle vehicle;
var Turret turret;
var int positionIndex;				// index of position occupied (or -1)
var float desiredProximity;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// The test used to figure out when to interrupt Follow

static function bool actionTest( ActionBase parent, NS_Action child )
{
	local AI_EnterVehicle enterVehicle;

	enterVehicle = AI_EnterVehicle(parent);

	// interrupt action when target dies
	if ( class'Pawn'.static.checkDead( enterVehicle.vehicleOrTurret ) )
		return true;

	//log( VDist( child.controller.pawn.Location, enterVehicle.vehicleOrTurret.Location ) @ "/" @
	//	enterVehicle.vehicleOrTurret.CollisionRadius + enterVehicle.proximity @
	//	enterVehicle.vehicleOrTurret.CollisionRadius );

	if ( VDistSquared( child.controller.pawn.Location, enterVehicle.vehicleOrTurret.Location ) <=
			enterVehicle.desiredProximity * enterVehicle.desiredProximity )
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

//---------------------------------------------------------------------

function cleanup()
{
	local Pawn pawn;

	super.cleanup();

	pawn = resource.pawn();

	if ( class'Pawn'.static.checkAlive( pawn ) && pawn.controller != None )
		AI_Controller(pawn.controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( vehicleOrTurret == None && vehicleOrTurretName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target vehicle" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( vehicleOrTurret == None )
		vehicleOrTurret = Pawn(resource.pawn().findByLabel( class'Engine.Pawn', vehicleOrTurretName, true ));

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ resource.pawn().name @ "is entering" @ vehicleOrTurret.name );

	if ( vehicleOrTurret == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified vehicle or turret" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	secondaryPositions[0] = VP_DRIVER;
	secondaryPositions[1] = VP_GUNNER;
	secondaryPositions[2] = VP_LEFT_GUNNER;
	secondaryPositions[3] = VP_RIGHT_GUNNER;

	desiredProximity = vehicleOrTurret.CollisionRadius + proximity;

	interruptActionIf ( class'NS_Follow'.static.startAction( AI_Controller(resource.pawn().controller),
			self, vehicleOrTurret, 0, , , energyUsage ), class'AI_EnterVehicle' );

	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") stopped with errorCode" @ errorCode );

	if ( VDistSquared( rook().Location, vehicleOrTurret.Location ) <= desiredProximity * desiredProximity )
	{
		vehicle = Vehicle(vehicleOrTurret);
		turret = Turret(vehicleOrTurret);

		if ( vehicle != None )
			positionIndex = vehicle.tryToOccupy( character(), vehiclePosition, secondaryPositions );
		else
			positionIndex = -1;

		// occupy vehicle
		if ( positionIndex >= 0 )
		{
			if ( resource.pawn().logTyrion )
				log( name @ "(" @ resource.pawn().name @ ") entered vehicle as a" @ vehicle.positions[positionIndex].type );

			//if ( vehicle.positions[positionIndex].type == VP_DRIVER )
			//	vehicle.level.speechManager.PlayDynamicSpeech( rook(), 'VehicleEnterDriver' );
			//else
			//	vehicle.level.speechManager.PlayDynamicSpeech( rook(), 'VehicleEnterGunner' );

			// goal should stick around if deactivated, but not when the ai acually gets int the vehicle/turret
			achievingGoal.bPermanent = false;
			succeed();
		}
		else if ( turret != None && turret.tryToControl( character() ))
		{
			// goal should stick around if deactivated, but not when the ai acually gets int the vehicle/turret
			achievingGoal.bPermanent = false;
			succeed();
		}
		else
			fail( ACT_COULDNT_ENTER_VEHICLE );
	}
	else
		fail( errorCode );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_EnterVehicleGoal'

	proximity = 200
}