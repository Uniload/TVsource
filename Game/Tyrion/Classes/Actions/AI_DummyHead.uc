//=====================================================================
// AI_DummyHead
// Action that simply sleeps
//=====================================================================

class AI_DummyHead extends AI_HeadAction
	editinlinenew;

//=====================================================================
// Variables

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	if ( resource.pawn().logTyrion )
		log( self.name @ "started." );

	pause();

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_DummyHeadGoal'
}