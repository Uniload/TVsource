//=====================================================================
// AI_RepairGoal
//=====================================================================

class AI_RepairGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(InternalParameters) editconst Pawn target;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget )
{
	priority = pri;
	target = aTarget;

	super.construct( r );
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

function init( AI_Resource r )
{
	local BaseAICharacter ai;

	super.init( r );

	ai = BaseAICharacter(resource.pawn());

	if ( ai.pack == None || !ClassIsChildOf( ai.pack.class, class'RepairPack' ) )
	{
		log( "AI WARNING:" @ ai.name @ "doesn't have a repair pack but was given a repair goal" );
		return;
	}

	// userData is always 'None' for deactivation sensors, and != None for activation sensors
	activationSentinel.activateSentinel( self, class'AI_RepairSensor', characterResource(),, class'AI_Sensor'.const.ONLY_NON_NONE_VALUE, self );
	// action deactivates itself if target becoems repaired on the way there
}

//=====================================================================

defaultproperties
{
	bInactive = true
	bPermanent = true
	priority = 75
}

