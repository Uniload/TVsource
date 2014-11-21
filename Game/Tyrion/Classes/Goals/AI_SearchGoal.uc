//=====================================================================
// AI_SearchGoal
//=====================================================================

class AI_SearchGoal extends AI_MovementGoal;

//=====================================================================
// Variables

var(Parameters) float searchDistance "how far the AI moves when searching for something";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst Character.GroundMovementLevels searchSpeed "how fast the AI moves while searching";

//=====================================================================
// Functions

overloaded function construct( AI_Resource r, int pri, Pawn aTarget,
							  optional Character.GroundMovementLevels aSearchSpeed, optional float aSearchDistance )
{
	priority = pri;
	target = aTarget;
	searchSpeed = aSearchSpeed;		// (GM_Any is default)

	if ( aSearchDistance == 0 )
		searchDistance = default.searchDistance;
	else
		searchDistance = aSearchDistance;

	super.construct( r );
}
 
//=====================================================================

defaultproperties
{
	bInactive = false
	bPermanent = false

	searchDistance = 600
	searchSpeed = GM_ANY
}

