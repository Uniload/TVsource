//=====================================================================
// AI_HeadResource
// Specialized AI_Resource for character's head
//=====================================================================

class AI_HeadResource extends AI_Resource;

//=====================================================================
// Variables

var Pawn m_pawn;		// reference to the rook is this resource is operating on

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Store a back pointer to the actor (pawn or squad) that this resource is attached to

function setResourceOwner( Engine.Actor p )
{
	m_pawn = Pawn(p);
}

//---------------------------------------------------------------------
// Called explicitly at start of gameplay

event init()
{
	// sensors are created here....

	super.init();
}
 
//---------------------------------------------------------------------
// perform resource-specific cleanup before resource is deleted

function cleanup()
{
	// Set sensorActions to None
	// ...

	super.cleanup();

	m_pawn = None;
}

//---------------------------------------------------------------------
// Should this resource be trying to satisfy goals?

event bool isActive()
{
	return class'Pawn'.static.checkAlive( m_pawn ) &&
#if IG_TRIBES3
		m_pawn.Controller != None &&
#endif
		m_pawn.AI_LOD_Level >= AILOD_NORMAL;
}

//---------------------------------------------------------------------
// Does the resource have the sub-resources available to run an action?
// legsPriority:  priority of the sub-goal that will be posted on the legs (0 if no goal)
// armsPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)
// headPriority:  priority of the sub-goal that will be posted on the arms (0 if no goal)
//
// Note: the head is considered exclusive - so even an action that doesn't declare it needs
//   this resource won't run unless it has higher priority than an already running action

function bool requiredResourcesAvailable( int legsPriority, int armsPriority, optional int headPriority )
{
	return usedByAction == None ||
		usedByAction.achievingGoal.priorityFn() < headPriority; 

	//this would be the check if heads were non-exclusive:
	//return headPriority == 0 ||					// head not required
	//	usedByAction == None ||						// head not in use
	//	usedByAction.achievingGoal.priorityFn() < headPriority; // head doing something less important
}

//---------------------------------------------------------------------
// Can this resource run "action" if it's already being used?
//
// Note: head is considered exclusive - so even an action that doesn't declare it needs
//   this resource won't run unless it has higher priority than an already running action

function bool multipleActionsCheck( AI_Action action )
{
	return false; 

	//this would be the check if heads were non-exclusive:
	//return (resourceUsage & RU_HEAD) == 0;		// arms not required
}

//----------------------------------------------------------------------
// Is the parent of this action already using a leaf resource?

function bool doesParentHaveResource( AI_Action parentAction )
{
	return parentAction != None &&
			ClassIsChildOf( parentAction.class, class'AI_HeadAction' ) &&
			(parentAction.resourceUsage & RU_HEAD) != 0;
}

//---------------------------------------------------------------------
// Accessor function

function Pawn pawn()
{
	return m_pawn;
}

//----------------------------------------------------------------------
// Return the corresponding action class for this type of resource

function class<AI_RunnableAction> getActionClass()
{
	return class'AI_HeadAction';
}

//=====================================================================

defaultproperties
{
}