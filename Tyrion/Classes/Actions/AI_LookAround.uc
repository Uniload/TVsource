//=====================================================================
// AI_LookAround
//=====================================================================

class AI_LookAround extends AI_MovementAction
	editinlinenew
	dependsOn(NS_Turn);

//=====================================================================
// Variables

var Rotator r;

//=====================================================================
// Functions

//=====================================================================
// State code

state Running
{
Begin:
	if ( resource.pawn().logTyrion )
		log( self.name @ "started." @ resource.pawn().name @ "is looking around" );

	r = character().motor.getMoveRotation();
	r.Yaw = ( r.Yaw + 65535 ) & 65535;	// rotate a smidgeon to the left so character is forced to turn all the way around

	waitForAction( class'NS_Turn'.static.startAction( AI_Controller(resource.pawn().controller), self, r, TD_CLOCKWISE ));

	if ( resource.pawn().logTyrion )
		log( self.name @ "stopped." );

	if ( class'Pawn'.static.checkAlive( resource.pawn() ) )
		succeed();
	else
		fail( ACT_ALL_RESOURCES_DIED );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_LookAroundGoal'
}