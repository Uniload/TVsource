//=====================================================================
// AI_GoalSpecificSensorAction
// Updates one-time use sensors needed to activate specific goals
//=====================================================================

class AI_GoalSpecificSensorAction extends AI_SensorCharacterAction;

//=====================================================================
// Constants

const HEALTH_SCALE = 40.0f;		// health weighting (vs. distance squared) for repair priority

//=====================================================================
// Variables

var AI_RepairSensor repairSensor;				// is updated by this sensor action
var AI_EnterVehicleSensor enterVehicleSensor;	// is updated by this sensor action

var BaseAICharacter ai;
var Rook target;					// target of repair
var int i;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// set up the sensors this action may update

function setupSensors( AI_Resource resource )
{
	// construct all sensors, add them to resource's sensor list
	repairSensor = AI_RepairSensor(addSensorClass( class'AI_RepairSensor' ));
	enterVehicleSensor = AI_EnterVehicleSensor(addSensorClass( class'AI_EnterVehicleSensor' ));

	// repeat if there are more sensors this sensorAction updates
}

//---------------------------------------------------------------------
// find the squad mate most in need of repair

private final function Rook findDamagedSquadMate()
{
	local int i;
	local Rook squaddie;
	local Rook hurtSquaddie;		// return value
	local float leastHealth;

	if ( ai.squad() == None )
		return None;

	leastHealth = 9999999999.9f;

	for ( i = 0; i < ai.squad().pawns.length; ++i )
	{
		squaddie = Rook(ai.squad().pawns[i]);
		if ( class'Pawn'.static.checkAlive( squaddie ) && squaddie.health < squaddie.healthMaximum )
		{
			if ( squaddie.health < leastHealth )
			{
				leastHealth = squaddie.health;
				hurtSquaddie = squaddie;
			}
		}
	}

	//if ( hurtSquaddie != None )
	//	log( "REPAIR:" @ ai.name @ "found" @ hurtSquaddie.name @ "in squad" );

	return hurtSquaddie;
}

//---------------------------------------------------------------------
// find nearby pawns in need of repair

private final function Rook findDamagedNearbyPawn()
{
	local int i;
	local Rook rook;
	local Rook hurtRook;		// return value
	local float bestScore;
	local float score;			// health + distance
	local array<Rook> seenList;

	bestScore = 9999999999.9f;
	seenList = ai.vision.getSeenList();

	for ( i = 0; i < seenList.length; ++i )
	{
		rook = seenList[i];
		if ( class'Pawn'.static.checkAlive( rook ) && rook.health < rook.healthMaximum && ai.isFriendly( rook ) )
		{
			score = HEALTH_SCALE * rook.health + VDist( ai.Location, rook.Location );
			if ( score < bestScore )
			{
				bestScore = score;
				hurtRook = rook;
			}
		}
	}

	//if ( hurtRook != None )
	//	log( "REPAIR:" @ ai.name @ "found" @ hurtRook.name @ "in seenlist" );

	return hurtRook;
}

//=====================================================================
// State Code

state Running
{
Begin:
	repairSensor.setObjectValue( None );
	enterVehicleSensor.setObjectValue( None );
	ai = baseAICharacter();

	while ( true )
	{
		if ( repairSensor.queryUsage() > 0 && ai.pack.IsInState( 'Charged' ) )
		{
			// check squad mates damage
			target = findDamagedSquadmate();

			// check seen pawns damage
			if ( target == None )
				target = findDamagedNearbyPawn();

			repairSensor.setObjectValue( target );
		}

		if ( enterVehicleSensor.queryUsage() > 0 )
		{
			if ( class'AI_EnterVehicleSensor'.static.isEnterable( enterVehicleSensor.vehicleOrTurret, enterVehicleSensor.vehiclePosition ) )
				enterVehicleSensor.setObjectValue( enterVehicleSensor.vehicleOrTurret );
			else
				enterVehicleSensor.setObjectValue( None );
		}

		Sleep(1.0f);
	}
}

//=====================================================================

defaultproperties
{
}
