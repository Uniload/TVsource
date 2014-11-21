//=====================================================================
// AI_InvestigateGoal
//=====================================================================

class AI_InvestigateGoal extends AI_MovementGoal
	editinlinenew;

//=====================================================================
// Variables

var(Parameters) editinline Name destinationName "A path node label";
var(Parameters) float searchTime "How long (in seconds) to look around at destination";

var(InternalParameters) Pawn target;	// the pawn being looked for (can be None) 
var(InternalParameters) editconst Vector destination;

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Vector aDestination, float aSearchTime, optional Pawn aTarget )
{
	priority = pri;
	destination = aDestination;
	searchTime = aSearchTime;
	target = aTarget;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	searchTime = 2.0f
	bInactive = false
	bPermanent = false
}

