//=====================================================================
// AI_CharacterAction
// Actions that involve "character" resources (rooks, vehicles)
//=====================================================================

class AI_CharacterAction extends AI_Action
	abstract;

//=====================================================================
// Variables

var Pawn pawn;
var AI_MovementResource movementResourceStorage;
var AI_WeaponResource weaponResourceStorage;
var AI_HeadResource headResourceStorage;

var AI_Goal DummyMovementGoal;
var AI_Goal DummyWeaponGoal;
var AI_Goal DummyHeadGoal;

//=====================================================================
// Functions

function cleanup()
{
	super.cleanup();

	if (DummyMovementGoal != None)
	{
		DummyMovementGoal.Release();
		DummyMovementGoal = None;
	}

	if (DummyWeaponGoal != None)
	{
		DummyWeaponGoal.Release();
		DummyWeaponGoal = None;
	}

	if (DummyHeadGoal != None)
	{
		DummyHeadGoal.Release();
		DummyHeadGoal = None;
	}
}

function clearDummyMovementGoal()
{
	if (DummyMovementGoal != None)
	{
		DummyMovementGoal.unPostGoal(self);
		DummyMovementGoal.Release();
		DummyMovementGoal = None;
	}
}

function clearDummyWeaponGoal()
{
	if (DummyWeaponGoal != None)
	{
		DummyWeaponGoal.unPostGoal(self);
		DummyWeaponGoal.Release();
		DummyWeaponGoal = None;
	}
}

function clearDummyHeadGoal()
{
	if (DummyHeadGoal != None)
	{
		DummyHeadGoal.unPostGoal(self);
		DummyHeadGoal.Release();
		DummyHeadGoal = None;
	}
}

function clearDummyGoals()
{
	clearDummyMovementGoal();
	clearDummyWeaponGoal();
	clearDummyHeadGoal();
}

//=====================================================================
// Action Idioms

//---------------------------------------------------------------------
// Marks the specified resources as being "in use" by this action
// If any of the specified resources are stolen by another action, the action that called this
// function will terminate with a ACT_REQUIRED_RESOURCE_STOLEN message
// resourceBits: Using RU_x constants, specified which leaf resources a dummy action should be created for

latent function useResources( int resourceBits )
{
	local int priority;
	local ACT_ErrorCodes errorCode;
	local AI_Goal movementGoal;
	local AI_Goal weaponGoal;
	local AI_Goal headGoal;

	priority = achievingGoal.priorityFn();

	if ( (resourceBits & resourceUsage & class'AI_Resource'.const.RU_ARMS) != 0 )
	{
		weaponGoal =   (new class'AI_DummyWeaponGoal'( weaponResource(), priority )).postGoal( self ).myAddRef();
		weaponGoal.bTerminateIfStolen = true;
		if ( pawn.logTyrion )
			log( "useResources:" @ weaponGoal.name @ "posted for" @ name );

		DummyWeaponGoal = weaponGoal;
		DummyWeaponGoal.addRef();
	}

	if ( (resourceBits & resourceUsage & class'AI_Resource'.const.RU_LEGS) != 0 )
	{
		movementGoal = (new class'AI_DummyMovementGoal'( movementResource(), priority )).postGoal( self ).myAddRef();
		movementGoal.bTerminateIfStolen = true;
		if ( pawn.logTyrion )
			log( "useResources:" @ movementGoal.name @ "posted for" @ name );

		DummyMovementGoal = movementGoal;
		DummyMovementGoal.addRef();
	}

	if ( (resourceBits & resourceUsage & class'AI_Resource'.const.RU_HEAD) != 0 )
	{
		headGoal = (new class'AI_DummyHeadGoal'( headResource(), priority )).postGoal( self ).myAddRef();
		headGoal.bTerminateIfStolen = true;
		if ( pawn.logTyrion )
			log( "useResources:" @ headGoal.name @ "posted for" @ name );

		DummyHeadGoal = headGoal;
		DummyHeadGoal.addRef();
	}


	if ( weaponGoal != None )
		waitForAllGoalsConsidered( weaponGoal, movementGoal, headGoal );
	else
		waitForAllGoalsConsidered( movementGoal, headGoal );

	if ( ( weaponGoal != None && !weaponGoal.beingAchieved() ) ||
		 ( movementGoal != None && !movementGoal.beingAchieved() ) ||
		 ( headGoal != None && !headGoal.beingAchieved() ))
	{
		if ( pawn.logTyrion )
			log( "useResources:" @ name @ "failing because resources unavailable" );

		// hack to handle the fact that Tyrion assumes character actions can never be blocked by resource contention
		// ideally, resource checking would be done before the character action is matched (one day...)
		resource.bMatchGoals = true;
		errorCode = ACT_INSUFFICIENT_RESOURCES_AVAILABLE;
	}

	if ( weaponGoal != None )
		weaponGoal.Release();

	if ( movementGoal != None )
		movementGoal.Release();

	if ( headGoal != None )
		headGoal.Release();

	if ( errorCode != ACT_SUCCESS )
		Fail( errorCode );
}

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Initialize a new action 
// 'goal' is the AI_Goal the action is achieving
// 'r' is the resource the action is running on
// Typically called by the resource - sets achievingAction

function initAction(AI_Resource r, AI_Goal goal)
{
	super.initAction( r, goal );

	pawn = AI_CharacterResource(r).m_pawn;
	movementResourceStorage = AI_MovementResource(pawn.movementAI);
	weaponResourceStorage = AI_WeaponResource(pawn.weaponAI);
	headResourceStorage = AI_HeadResource(pawn.headAI);
}

//---------------------------------------------------------------------
// Accessor function for resources

#if IG_TRIBES3
function Rook rook()
{
	return Rook(pawn);
}

function Character character()
{
	return Character(pawn);
}

function BaseAICharacter baseAIcharacter()
{
	return BaseAICharacter(pawn);
}
#endif

function AI_CharacterResource characterResource()
{
	return AI_CharacterResource(resource);
}

function AI_MovementResource movementResource()
{
	return movementResourceStorage;
}

function AI_WeaponResource weaponResource()
{
	return weaponResourceStorage;
}

function AI_HeadResource headResource()
{
	return headResourceStorage;
}

//---------------------------------------------------------------------
// Return the resource class for this action

static function class<Tyrion_ResourceBase> getResourceClass()
{
	return class'AI_CharacterResource';
}

//---------------------------------------------------------------------
// Depending on the type of action, find the resource the action should
// be attached to

static function Tyrion_ResourceBase findResource( Pawn p )
{
	return p.characterAI;
}

//=======================================================================

function classConstruct()
{
	// character actions use all of a character's sub-resources by default
	resourceUsage = class'AI_Resource'.const.RU_ARMS | class'AI_Resource'.const.RU_LEGS | class'AI_Resource'.const.RU_HEAD;
}

defaultproperties
{
     resourceUsage=7
}
