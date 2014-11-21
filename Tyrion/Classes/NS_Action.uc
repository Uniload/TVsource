//=====================================================================
// NS_Action
// An action that can run or be idle, and can create an interruptable
// child
//
// Notes on Usage:
// - every subclassed action should have a 'Running' state in which
//   the state code resides
//=====================================================================

class NS_Action extends ActionBase
	native
	abstract
	threaded;

//=====================================================================
// Variables

var AI_Controller controller;	// controller this action is attached to
var NS_Action childAction;		// action may have up to one child
var ActionBase parentAction;	// and usually a parent
var ACT_ErrorCodes errorCode;	// set when a child completes
var bool bWakeUpParent;			// when true, parent gets moved to 'Running' state upon child's completion

// nav system tick control
var float tickTime;				// when tickTime < 0, we tick the AI
var float tickTimeOrg;			// last generated tickTime value

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Constructor

overloaded function construct( AI_Controller c, ActionBase parent )
{
	controller = c;
	parentAction = parent;
	AddRef();			// balanced by Release in deleteRemovedActions (actions are pushed onto that list in removeAction)
	//log( "++" @ name );
	if ( parent != None )
		parent.setChildReference( self );

	// sanity check
	assert( checkForUniqueness( c, self ) );

	GotoState( 'Running' );
}

//---------------------------------------------------------------------
// Check that "action" is the only action of its type running on the
// controller. Returns true if atcion is unique.

function bool checkForUniqueness( AI_Controller c, NS_Action action )
{
	local int i;

	for ( i = 0; i < controller.idleActions.length; i++ )
		if ( controller.idleActions[i] != action && 
			controller.idleActions[i].class == action.class )
		{
			log( "AI ERROR: Duplicate navigation actions in" @ c.Pawn.name $ ":" @ controller.idleActions[i].name @ "(parent:" @ controller.idleActions[i].parentAction.name$ ")," @ action.name @ "(parent:" @ action.parentAction.name $ ")" );
			return false;
		}

	for ( i = 0; i < controller.runningActions.length; i++ )
		if ( controller.runningActions[i] != action && 
			controller.runningActions[i].class == action.class )
		{
			log( "AI ERROR: Duplicate navigation actions in" @ c.Pawn.name $ ":" @ controller.runningActions[i].name @ "(parent:" @ controller.runningActions[i].parentAction.name$ ")," @ action.name @ "(parent:" @ action.parentAction.name $ ")" );
			return false;
		}

	return true;
}

//---------------------------------------------------------------------
// Called by an action when it has successfully executed
// (No state code following this function is executed)

latent function succeed()
{
	//log( "Succeed called on" @ name );

	// call callback in parent
	if (parentAction != None )
		parentAction.actionSucceededCB( self );

	removeAction();
	yield();
}

//---------------------------------------------------------------------
// Called by an action when it has failed
// (called from non-state code)

event instantFail( ACT_ErrorCodes errorCode, optional bool bRemoveGoal )
{
	// call callback in parent
	if (parentAction != None )
		parentAction.actionFailedCB( self, errorCode );

	removeAction();
}

//---------------------------------------------------------------------
// Called by an action when it has failed
// (No state code following this function is executed)k)

latent function fail( ACT_ErrorCodes errorCode )
{
	instantFail( errorCode );
	yield();
}

//---------------------------------------------------------------------
// increments refCount and returns object

function NS_Action myAddRef()
{
	AddRef();
	return self;
}

//---------------------------------------------------------------------
// Interrupt an action
// Stop a running (or idle) action
// Typically called by the controller

function interruptAction()
{
	removeAction();
}

//---------------------------------------------------------------------
// Terminate an action
// Typically called by the controller

function removeAction()
{
	local int i;

	if ( controller.Pawn != None && controller.Pawn.logNavigationSystem )
		log( "NS_removeAction: Removing" @ name @ "from" @ controller.Pawn.name );

	// Remove action from idle list (if it's in there)
	for ( i = 0; i < controller.idleActions.length; i++ )
		if ( controller.idleActions[i] == self )
		{
			controller.idleActions.remove(i, 1);	// removes element - shifts the rest
			break;
		}

	// Remove action from running list (if it's in there)
	for ( i = 0; i < controller.runningActions.length; i++ )
		if ( controller.runningActions[i] == self )
		{
			controller.runningActions.remove(i, 1);	// removes element - shifts the rest
			break;
		}

	// Remove action from parent's childAction variable
	if ( parentAction != None )
	{
		parentAction.removeChildReference( self );
		parentAction = None;
	}

	// Recursively remove all the children
	if ( childAction != None )
	{
		childAction.removeAction();
		childAction = None;
	}

	if ( bCompleted == false )
	{
		controller.removedActions[controller.removedActions.length] = self;	// removedActions.Push(self)
		bCompleted = true;
		
		//log( "--" @ name );
	}

	cleanup();

	bDeleted = true;
}

//---------------------------------------------------------------------
// Run an action
// Typically called by the controller

function runAction()
{
	local int i;

	if ( controller == None )
		log( "AI WARNING:" @ name @ "has no controller" );

	if ( controller == None || class'Pawn'.static.checkDead( controller.Pawn ))
	{
		if ( controller.pawn.logNavigationSystem )
			log( name @ "stopped. Pawn is dead" );

		instantFail( ACT_ALL_RESOURCES_DIED );
		return;
	}

	// Remove action from idle list (if it's in there)
	for ( i = 0; i < controller.idleActions.length; i++ )
		if ( controller.idleActions[i] == self )
		{
			controller.idleActions.remove(i, 1);	// removes element - shifts the rest
			break;
		}

	if ( isIdle() )
	{
		// runningActions.Push(self)
		controller.runningActions[controller.runningActions.length] = self;

		bIdle = false;
	}
}

//---------------------------------------------------------------------
// Pause an action (put it onto idle list)
// Typically called by the controller

function pauseAction()
{
	// Remove action from running list (if it's in there)
	local int i;
	for ( i = 0; i < controller.runningActions.length; i++ )
		if ( controller.runningActions[i] == self )
		{
			controller.runningActions.remove(i, 1);	// removes element - shifts the rest

			// idleActions.Push(self)
			controller.idleActions[controller.idleActions.length] = self;
			break;
		}

	bIdle = true;
}

//---------------------------------------------------------------------
// Add action to childAction list

function setChildReference( NS_Action child )
{
	childAction = child;
}

//---------------------------------------------------------------------
// Remove action from childAction list

function removeChildReference( NS_Action child )
{
	if ( child == childAction )
		childAction = None;
}

//---------------------------------------------------------------------
// Return the Cersei child?

function NS_Action getChildReference()
{
	return childAction;
}

//---------------------------------------------------------------------
// Message notification functions (callbacks) for child actions
// Note: When writing action-specific callbacks, call super.<callback> first

function actionSucceededCB( NS_Action child )
{
	// the child succeeded
	errorCode = ACT_ErrorCodes.ACT_SUCCESS;

	super.actionSucceededCB( child );
}

function actionFailedCB( NS_Action child, ACT_ErrorCodes _errorCode )
{
	// the child failed
	errorCode = _errorCode;
	controller.lastErrorCode = _errorCode;	// for debug only

	super.actionFailedCB( child, _errorCode );
}

//=====================================================================
// States

state Running
{
Begin:
}

//=====================================================================

defaultproperties
{
}
