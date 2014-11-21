//=====================================================================
// AI_DirectAttack
// Attacks a target by moving directly towards it and firing
//=====================================================================

class AI_DirectAttack extends AI_CharacterAction implements IFollowFunction
	editinlinenew;

//=====================================================================
// Constants

const DEFAULT_PROXIMITY = 1000;	// how close to get to target (by default)

//=====================================================================
// Variables

var(Parameters) editconst int rank "Rank of the AI; set by the ability in the class DB";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;
var(InternalParameters) editconst IFollowFunction followFunction;

var AI_Goal fireAtGoal;
var AI_Goal movementGoal;
var ACT_Errorcodes errorCode;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// callbacks from sub-goals;
// they are only used to stop the action when any success/failure message
// comes up that isn't an interruption
// todo: automate this process? A new flag on goals/waitForGoals?

function goalAchievedCB( AI_Goal goal, AI_Action child )
{
	super.goalAchievedCB( goal, child );

	errorCode = ACT_SUCCESS;
	runAction();
}

function goalNotAchievedCB( AI_Goal goal, AI_Action child, ACT_ErrorCodes anErrorCode ) 
{
	super.goalNotAchievedCB( goal, child, anErrorCode );

	errorCode = anErrorCode;

	if ( errorCode != ACT_INTERRUPTED )
		runAction();
}

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 0.1;		// always lower than character-specific attacks
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	weaponSelection = None;
	followFunction = None;

	if ( movementGoal != None )
	{
		movementGoal.Release();
		movementGoal = None;
	}

	if (fireAtGoal != None )
	{
		fireAtGoal.Release();
		fireAtGoal = None;
	}
}

//---------------------------------------------------------------------
// IFollowFunction interface: should offset be updated?

function bool updateOffset( Pawn follower, Pawn leader, int positionIndex )
{
	if ( followFunction != None )
		return followFunction.updateOffset( follower, leader, positionIndex );
	else
		return false;
}

//---------------------------------------------------------------------
// IFollowFunction interface: offset from leader pawn to actual location follower wants to go to

function Vector offset( Pawn leader, int positionIndex )
{
	if ( followFunction != None )
		return followFunction.offset( leader, positionIndex );
	else
		return vect(0,0,0);
}

//---------------------------------------------------------------------
// IFollowFunction interface: is a given location a valid place to follow to?

function bool validDestination( Vector point )
{
	if ( followFunction != None )
		return followFunction.validDestination( point );
	else
		return true;
}

//---------------------------------------------------------------------
// IFollowFunction interface: how close do you want to get to the target?

function float proximityFunction()
{
	local float proximity;
	local Weapon weapon;

	if ( baseAICharacter().combatRangeCategory == CR_STAND_GROUND )
		return 99999999.9f;

	weapon = character().weapon;

	if ( weaponSelection != None && weapon != None )
		proximity = weaponSelection.firingRange( weapon.class );
	else if ( weapon != None )
		proximity = 0.8f * (class'AimFunctions'.static.getMaxEffectiveRange( weapon.class ) + target.CollisionRadius);
	
	if ( proximity <= target.CollisionRadius )
		proximity = DEFAULT_PROXIMITY;

	return proximity;
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started." @ pawn.name @ "is attacking" @ target.name @ "directly" );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	pawn.level.speechManager.PlayDynamicSpeech( pawn, 'Attack', pawn );

	// move towards target
	movementGoal = (new class'AI_CombatMovementGoal'( movementResource(), achievingGoal.priority, target,, self )).postGoal( self ).myAddRef();
	// start shooting at target
	fireAtGoal = (new class'AI_FireAtGoal'( weaponResource(), achievingGoal.priority, target, weaponSelection, preferredWeaponClass )).postGoal( self ).myAddRef();
	//old: WaitForAnyGoal( movementGoal, fireAtGoal );				// handles resource death
	pause();

	AI_Controller(pawn.controller).stopMove();

	if ( pawn.logTyrion )
		log( name @ "(" @ pawn.name @ ") stopped with errorCode" @ errorCode );

	if ( class'Pawn'.static.checkDead( target ) )
		succeed();
	else 
		fail( errorCode );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_DirectAttackGoal'
}