//=====================================================================
// AI_GruntAttack
// Grunt AI standard attack
//=====================================================================

class AI_GruntAttack extends AI_CharacterAction implements IWeaponSelectionFunction
	editinlinenew;

//=====================================================================
// Constants

//=====================================================================
// Variables

var(Parameters) int rank "Rank of the grunt (1, 2, or 3)";
var(Parameters) editinline Name targetName "Label of target (any Pawn)";
var(Parameters) class<Weapon> preferredWeaponClass "AI will use this weapon if at all possible";

var(InternalParameters) editconst Pawn target;
var(InternalParameters) editconst IWeaponSelectionFunction weaponSelection;	// not used
var(InternalParameters) editconst IFollowFunction followFunction;

var() float maxEnergyBladeRange "Maximum distance at which to use the energy blade";

var() float idealSpinfusorRange "preferred distance for using the spinfusor";
var() float idealBlasterRange "preferred distance for using the blaster";
var() float idealChaingunRange "preferred distance for using the chaingun";

//=====================================================================
// Functions

//---------------------------------------------------------------------
// Selection Heuristic
// Returns a value in the range [0, 1], indicating how suitable this action is for achieving this goal

static function float selectionHeuristic( AI_Goal goal )
{
	return 1.0;			// most suitable attack for a grunt
}

//---------------------------------------------------------------------
// function for determining what weapon to use

function Weapon bestWeapon( Character ai, Pawn target, class<Weapon> preferredWeaponClass )
{
	local Weapon w;

	w = Weapon( ai.nextEquipment( None, class'Blaster' ));
	if ( w != None && w.hasAmmo() )
		return w;

	w = Weapon( ai.nextEquipment( None, class'Chaingun' ));
	if ( w != None && w.hasAmmo() )
		return w;

	w = Weapon( ai.nextEquipment( None, class'EnergyBlade' ));
	if ( w != None && VDistSquared( ai.Location, target.Location ) <= maxEnergyBladeRange * maxEnergyBladeRange )
		return w;

	w = Weapon( ai.nextEquipment( None, class'Spinfusor' ));
	if ( w != None && w.hasAmmo() )
		return w;

	return ai.weapon;	// no weapon found: keep holding what you got
}

//---------------------------------------------------------------------
// best range at which to shoot weapon

function float firingRange( class<Weapon> weaponClass )
{
	if ( ClassIsChildOf( weaponClass, class'Spinfusor' ))
		return idealSpinfusorRange;

	if ( ClassIsChildOf( weaponClass, class'Blaster' ))
		return idealBlasterRange;

	if ( ClassIsChildOf( weaponClass, class'Chaingun' ))
		return idealChaingunRange;

	return 0.8f * (class'EnergyBlade'.default.range + target.CollisionRadius);	// energy blade
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

	// when GruntAttack deactivates, AI keeps on moving with his last direction
	// (maybe there should be a default low-pri action that lands the AI?)
	if ( class'Pawn'.static.checkAlive( pawn ) )
		AI_Controller(pawn.controller).stopMove();
}

//=====================================================================
// State code

state Running
{
Begin:
	if ( rank != 1 && rank != 2 && rank != 3 )
	{
		log( "AI ERROR: invalid rank" @ rank @ "given to grunt" @ Pawn.name );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None && targetName == '' )
	{
		log( "AI WARNING:" @ name @ "has no target" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	if ( target == None )
		target = Pawn(pawn.findByLabel( class'Pawn', targetName, true ));

	if ( pawn.logTyrion)
		log( name @ "started." @ pawn.name @ "is attacking" @ target.name );

	if ( target == None )
	{
		log( "AI WARNING:" @ name @ "can't find specified rook" );
		fail( ACT_INVALID_PARAMETERS, true );
	}

	// add argument so same goal doesn't get rematched
	// resource will have two attack goals attached to it - ok?
	// alternative is to add parameters to attack so gruntattack becomes unnecessary (not trivial but doable)
	// But it would be nicer to be able to control the grunt in an action - also more consistent with the other character (who will have individual actions)
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

	maxEnergyBladeRange		= 750

	idealSpinfusorRange		= 2500
	idealBlasterRange		= 1000
	idealChaingunRange		= 3000
}