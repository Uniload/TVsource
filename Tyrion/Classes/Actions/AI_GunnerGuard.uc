//=====================================================================
// AI_GunnerGuard
// Vehicle weapon's and turret's default behaviour
//
// Turret's target selection depends on the type of the turret.
// Turret's accuracy depends on whether turret is manned or not.
//=====================================================================

class AI_GunnerGuard extends AI_GunnerAction
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) float engagementAreaRadius "Radius of engagement area";

var Pawn target;

//=====================================================================
// Functions

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	// clear GuardSensor value so action can be activated again
	// (also important because GuardSensor doesn't terminate when LOS is lost - it relies on the action to do this)
	if ( achievingGoal.activationSentinel.sensor != None )
		achievingGoal.activationSentinel.sensor.setObjectValue( None );
}

//=====================================================================
// State code

state Running
{
Begin:
	target = Pawn(achievingGoal.activationSentinel.sensor.queryObjectValue());

	if ( target == None )
	{
		log( "AI WARNING:" @ name $ ":" @ localRook().name @ "( in" @ rook().name @ ") has no guard target" );
	}
	else
	{
		if ( rook().logTyrion)
			log( self.name @ "started." @ localRook().name @ "is attacking" @ target.name );

		// (it's important that FireAt fail when target is lost - otherwise the guard sensor won't select a new target)
		waitForGoal( (new class'AI_GunnerFireAtGoal'( resource, achievingGoal.priority, target, position, true )).postGoal( self ) );
	}

	if ( rook().logTyrion)
		log( self.name @ "(" @ localRook().name @ ") stopped" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GunnerGuardGoal'