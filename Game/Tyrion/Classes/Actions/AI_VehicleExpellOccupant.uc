//=====================================================================
// AI_VehicleExpellOccupant
// Throw someone out of a vehicle or turret
//=====================================================================

class AI_VehicleExpellOccupant extends AI_VehicleAction
	editinlinenew;

//=====================================================================
// Constants

const N_TRIES = 10;	// number of times character tries to exit vehicle before giving up

//=====================================================================
// Variables

var(Parameters) Name occupantName "Name of character to expell";

var(InternalParameters) Character occupant;

var int i;

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	if ( occupant == None && occupantName == '' )
	{
		log( "AI WARNING:" @ name @ "has no occupant parameter" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( occupant == None )
		occupant = Character(resource.pawn().findByLabel( class'Engine.Pawn', occupantName ));

	if ( occupant == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified occupant" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( resource.pawn().logTyrion )
		log( name @ "started." @ occupant.name @ "is exiting" @ resource.pawn().name );

	occupant.exitMount( resource.pawn() );

	for ( i = 0; i < N_TRIES; ++i )
	{
		if ( !occupant.bIsInMount( resource.pawn() ) )
		{
			//occupant.level.speechManager.PlayDynamicSpeech( occupant, 'VehicleExit' );
			succeed();
		}

		Sleep(0.5);
	}

	fail( ACT_COULDNT_EXIT_VEHICLE );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleExpellOccupantGoal'
	resourceUsage = 0 // getting out of vehicle doesn't require any resources
}