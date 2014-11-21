//=====================================================================
// AI_VehicleGuard
//=====================================================================

class AI_VehicleGuard extends AI_VehicleAction
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
		log( "AI WARNING:" @ name $ ":" @ vehicle().name @ "has no guard target" );
	}
	else
	{
		if ( vehicle().logTyrion)
			log( self.name @ "started." @ vehicle().name @ "is attacking" @ target.name );

		// (it's important that Attack fail when target is lost - otherwise the guard sensor won't select a new target)
		waitForGoal( (new class'AI_VehicleAttackGoal'( resource, achievingGoal.priority, target )).postGoal( self ) );
	}

	if ( vehicle().logTyrion)
		log( self.name @ "(" @ vehicle().name @ ") stopped" );

	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_VehicleGuardGoal'