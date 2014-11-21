//=====================================================================
// AI_GloraxAttack
// Glorax AI standard attack
//=====================================================================

class AI_GloraxAttack extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

const GLORAX_MELEE_ATTACK_DISTANCE = 280.0f;

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the glorax (1 or 2)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a glorax
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	if ( VDistSquared( ai.Location, target.Location ) >= GLORAX_MELEE_ATTACK_DISTANCE * GLORAX_MELEE_ATTACK_DISTANCE )
		return Weapon( ai.nextEquipment( None, class'GloraxWeapon' ));
	else
		return Weapon( ai.nextEquipment( None, class'GloraxMeleeWeapon' ));
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	return GLORAX_MELEE_ATTACK_DISTANCE;	// always move right up to the player
}

//---------------------------------------------------------------------
// are conditions met for firing this weapon?

function bool bShouldFire( BaseAICharacter ai, Weapon weapon )
{
	return true;
}

//---------------------------------------------------------------------

function cleanup()
{
	super.cleanup();

	weaponSelection = None;
	followFunction = None;

	// when GloraxAttack deactivates, AI keeps on moving with his last direction
	// (maybe there should be a default low-pri action that lands the AI?)
	if ( class'Pawn'.static.checkAlive( pawn ) )
		AI_Controller(pawn.controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rank != 1 && rank != 2 )
	{
		log( "AI ERROR: invalid rank" @ rank @ "given to glorax" @ Pawn.name );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion )
		log( name @ "started." @ pawn.name @ "is attacking" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	waitForGoal( (new class'AI_DirectAttackGoal'( characterResource(), achievingGoal.priority, target, self, preferredWeaponClass, followFunction )).postGoal( self ) );

	if ( class'Pawn'.static.checkDead( target ) )
	{
		if ( pawn.logTyrion )
			log( name @ "stopped. TARGET DEAD!" );
		succeed();
	}
	else
		fail( ACT_GENERAL_FAILURE );
}

//=====================================================================

defaultproperties
{
	satisfiesGoal = class'AI_AttackGoal'
}