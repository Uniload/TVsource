//=====================================================================
// AI_PeriodicPackUse
// Use a pack periodically!
//=====================================================================

class AI_PeriodicPackUse extends AI_CharacterAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float period "Time between pack activations";

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	if ( pawn.logTyrion )
		log( self.name @ "(" @ pawn.name @ ") started" );

	// does character have a pack?
	if ( baseAICharacter().pack == None )
		fail( ACT_GENERAL_FAILURE );

	while ( true )
	{
		baseAICharacter().pack.activate();
		Sleep( period );
	}
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_PeriodicPackUseGoal'
	resourceUsage = 0
}