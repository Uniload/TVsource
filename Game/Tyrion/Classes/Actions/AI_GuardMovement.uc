//=====================================================================
// AI_GuardMovement
// Handles non-attack related movement for Guard 
//=====================================================================

class AI_GuardMovement extends AI_MovementAction
	editinlinenew;

//=====================================================================
// Variables

var(InternalParameters) editconst Vector movementAreaCenter;

var Rotator terminalRotation;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	if ( AI_GuardMovementGoal(goal).movementAreaCenter == goal.resource.pawn().Location )
		return 0.0f;		// haven't moved from center - don't match 
	else
		return 1.0f;
}

//=====================================================================
// State code

state Running
{
Begin:
	// return to movement area center
	if ( resource.pawn().logTyrion )
		log( name @ "(" @ resource.pawn().name @ ") moving back to movementAreaCenter:" @ movementAreaCenter );

	// turn to enemy after moving if engaged with an enemy
	if ( AI_Guard(achievingGoal.parentAction).lastGuardTarget != None )
		terminalRotation = Rotator(AI_Guard(achievingGoal.parentAction).lastGuardTarget.Location - resource.pawn().Location);

	WaitForGoal( (new class'AI_MoveToGoal'( movementResource(), achievingGoal.priorityFn()-1, movementAreaCenter,
		,, GM_RUN,,,,,, terminalRotation )).postGoal( self ) );

	
	succeed();
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_GuardMovementGoal'
}